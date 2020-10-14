'use strict';

require('highlight.js/styles/default.css');

const hljs = require('highlight.js/lib/core.js');
hljs.registerLanguage(
  'haskell',
  require('highlight.js/lib/languages/haskell.js'));

exports.setup = function() {
  document.querySelectorAll('pre code').forEach((block) => {
    hljs.highlightBlock(block);
  });
};
