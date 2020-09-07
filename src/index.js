'use strict';

// 3rd Party CSS
require('normalize.css/normalize.css');

// 3rd Party Javascript
require('@fortawesome/fontawesome-free/js/fontawesome.js');
require('@fortawesome/fontawesome-free/js/regular.js');
require('@fortawesome/fontawesome-free/js/solid.js');

// Custom CSS
require('./root.css');

// Purescript
require('./Main.purs').main();
