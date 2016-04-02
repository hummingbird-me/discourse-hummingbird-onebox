# name: hummingbird-onebox
# about: Embed hummingbird.me media links in discourse posts
# version: 1.0
# authors: Hummingbird Media, Inc.

module Onebox::Engine::HummingbirdOnebox
  include Onebox::Engine
  include Onebox::JSON

  # a|m are short links for anime|manga
  matches_regexp /https?:\/\/(?:www\.)?hummingbird\.me\/(?<type>anime|manga|a|m)\/(?<slug>.+)/
  always_https
  
  def url
    # TODO: switch to APIv16
    "https://hummingbird.me/#{type}/#{slug}.json"
  end

  def to_html
    return "<a href=\"#{@url}\">#{@url}</a>" if media.nil?

    <<-HTML
      <div class="onebox">
        <div class="source">
          <div class="info">
            <a href="#{@url}" class="track-link" target="_blank">
              #{type} (#{media_type})
            </a>
          </div>
        </div>
        <div class="onebox-body media-embed">
          <img src="#{media['poster_image_thumb']" class="thumbnail">
          <h3><a href="#{@url}" target="_blank">#{media['romaji_title']}</a></h3>
          <h4>#{media['genres'].sort * ", "}</h4>
          #{media['synopsis']}
        </div>
        <div class="clearfix"></div>
      </div>
    HTML
  end

  private

  def type
    return 'anime' if @@matcher.match(@url)['type'] == 'a'
    return 'manga' if @@matcher.match(@url)['type'] == 'm'
    @@matcher.match(@url)['type']
  end

  def slug
    @@matcher.match(@url)['slug']
  end

  def media
    raw[type]
  end

  def media_type
    case media['type']
      when 'anime'; media['show_type']
      when 'manga'; media['manga_type']
    end
  end

  def uri
    @_uri ||= URI(@url)
  end
end
