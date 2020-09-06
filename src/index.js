'use strict';

require('pure-css/index.js');

require('./root.css');

require('./Main.purs').main();

if (module.hot) {
  module.hot.accept();
}
