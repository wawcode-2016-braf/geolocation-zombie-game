// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import $ from "jquery"

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
  
    /* Logowanie / Rejestracja */
    $(".form1").on('submit', function() {
        var name = $("#name1").val();
        $.getJSON("/api/token/" + name, function(data) {
            window.location.href = "/game/?token=" + data.data.token;
        });
        return false;
    });

    $(".form2").on('submit', function() {
        var name = $("#name2").val();
        $.getJSON("/api/token/" + name, function(data) {
            window.location.href = "/game/?token=" + data.data.token;
        });
        return false;
    });

    /* Pobieranie lokalizacji */

    function getLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(setPosition);
        } else {
            var x = document.getElementById("location");
            x.innerHTML = "Geolocation is not supported by this browser.";
        }
    }

    function setPosition(position) {
        var x = document.getElementById("location");
        x.innerHTML = "Latitude: " + position.coords.latitude +
        "<br>Longitude: " + position.coords.longitude;
        $.ajax({
            url: '/api/location/?token=' + token,
            type: 'PUT',
            data: "longitude=" + position.coords.longitude + "&latitude=" + position.coords.latitude,
            success: function(data) {
                console.log(data);
            }
        });
    }

    setInterval(getLocation, 2000);