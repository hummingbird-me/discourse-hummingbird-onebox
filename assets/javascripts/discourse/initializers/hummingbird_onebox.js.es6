import { withPluginApi } from 'discourse/lib/plugin-api';

function initReadMoreToggle(ob) {
  const synopsis = $('.hb-onebox-synopsis', ob),
        readmore = $('.hb-onebox-readmore', ob);

  readmore.on('click', e => {
    synopsis.toggleClass('hb-onebox-synopsis-open');
  })
}

export default {
  name: 'apply-hb-onebox',
  initialize() {
    withPluginApi('0.2', api => {
      api.decorateCooked((post) => {
        $('.hb-onebox', post).each((i, onebox) => {
          initReadMoreToggle($(onebox);
        });
      });
    });
  }
};
