# name: hummingbird-onebox
# about: Onebox plugin for hummingbird
# version: 1.0
# authors: Hummingbird Media

register_asset "stylesheets/hummingbird_onebox.scss"
register_asset 'stylesheets/hummingbird_onebox_mobile.scss', :mobile

class Onebox::Engine::HummingbirdOnebox
  include Onebox::Engine
  include Onebox::Engine::JSON

  TYPES = {
    'anime' => 'anime',
    'a'     => 'anime',
    'manga' => 'manga',
    'm'     => 'manga'
  }
  HOST_REGEX = %r{https?://(?:www\.)?hummingbird\.me}
  TYPE_REGEX = %r{(?<type>#{TYPES.keys.join('|')})}
  SLUG_REGEX = %r{(?<slug>[A-Za-z0-9\-]+)}
  MATCH_REGEX = %r{^#{HOST_REGEX}/#{TYPE_REGEX}/#{SLUG_REGEX}$}

  matches_regexp MATCH_REGEX
  always_https

  def url
    # TODO: switch to APIv16
    "https://hummingbird.me/full_#{type}/#{slug}.json"
  end

  def link
    super.downcase
  end

  def to_html
    return "<a href=\"#{link}\">#{link}</a>" if media.nil?

    <<-HTML
      <aside class="onebox onebox-result hb-onebox hb-onebox-#{type}"
             data-media-type="#{type}" data-media-slug="#{slug}">
        #{poster_html}
        <div class="hb-onebox-info">
          <h1 class="hb-onebox-header">
            <a href="#{link}" target="_blank" class="track-link">
              #{media['romaji_title']}
            </a>
          </h1>
          <div class="hb-onebox-rating" title="#{media['bayesian_rating']}">
            #{stars_html}
          </div>
          <div class="hb-onebox-synopsis">
            #{media['synopsis']}
            #{readmore_html}
          </div>
          <div class="hb-onebox-genres">
            #{genres_html}
          </div>
          <a class="hb-onebox-library-entry" href="https://hummingbird.me/sign-up" target="_blank">
            <span>Track this #{type} with Hummingbird</span>
          </a>
        </div>
      </aside>
    HTML
  end

  private

  def type
    TYPES[MATCH_REGEX.match(@url)['type']]
  end

  def slug
    MATCH_REGEX.match(@url)['slug'].downcase
  end

  def media
    raw["full_#{type}"]
  end

  def media_type
    case type
      when 'anime'; media['show_type']
      when 'manga'; media['manga_type']
    end
  end

  def title
    media['romaji_title']
  end

  def poster_image
    image = media['poster_image']
    (image == '/assets/missing-anime-cover.jpg') ? nil : image
  end

  def poster_html
    poster_image.nil? ? '' : <<-HTML
      <div class="hb-onebox-poster">
        <img src="#{poster_image}">
      </div>
    HTML
  end

  def average_rating
    media['bayesian_rating']
  end

  def stars_html
    return '' if average_rating.blank?

    rating = (media['bayesian_rating'] / 0.5).round * 0.5
    whole_stars = '<i class="fa fa-star"></i>' * rating.floor
    half_stars = '<i class="fa fa-star-half-o"></i>' * (rating % 1 / 0.5)
    empty_stars = '<i class="fa fa-star-o"></i>' * (5 - rating).floor

    "#{whole_stars}#{half_stars}#{empty_stars}"
  end

  def genres_html
    media['genres'].sort.map do |g|
      "<div class=\"hb-onebox-genre\">#{g}</div>"
    end.join
  end

  # Bigger than a tweet, smaller than a bread basket
  def readmore?
    media['synopsis'].length > 350
  end

  def readmore_html
    !readmore? ? '' : <<-HTML
      <a class="hb-onebox-readmore">
        read
        <span class="hb-onebox-readmore-more">more</span>
        <span class="hb-onebox-readmore-less">less</span>
      </a>
    HTML
  end
end
