'use strict';

require('./root.css');

require('./Main.purs').main();

if (module.hot) {
  module.hot.accept();
}
