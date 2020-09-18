'use strict';

// 3rd Party CSS
require('normalize.css/normalize.css');

// 3rd Party Javascript
require('@fortawesome/fontawesome-free/js/brands.js');
require('@fortawesome/fontawesome-free/js/fontawesome.js');
require('@fortawesome/fontawesome-free/js/regular.js');
require('@fortawesome/fontawesome-free/js/solid.js');

// Default implementation has SVG try and replace the value meaning when Halogen
// re-renders some component, duplicate icons may appear. Avoid this by
// setting to "nest" meaning SVGs are inserted as child elements of the <i> tag.
FontAwesomeConfig.autoReplaceSvg = "nest";

// Custom CSS
require('static/css/root.css');
require('static/css/navbar.css');
