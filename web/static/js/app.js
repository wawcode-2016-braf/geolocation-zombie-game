// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

(function () {
      window.addEventListener('scroll', function (event) {
          var depth, i, layer, layers, len, movement, topDistance, translate3d;
          topDistance = this.pageYOffset;
          layers = document.querySelectorAll('[data-type=\'parallax\']');
          for (i = 0, len = layers.length; i < len; i++) {
              if (window.CP.shouldStopExecution(1)) {
                  break;
              }
              layer = layers[i];
              depth = layer.getAttribute('data-depth');
              movement = -(topDistance * depth);
              translate3d = 'translate3d(0, ' + movement + 'px, 0)';
              layer.style['-webkit-transform'] = translate3d;
              layer.style['-moz-transform'] = translate3d;
              layer.style['-ms-transform'] = translate3d;
              layer.style['-o-transform'] = translate3d;
              layer.style.transform = translate3d;
          }
          window.CP.exitedLoop(1);
      });
  }.call(this));
  