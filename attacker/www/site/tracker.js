// served by the attacker container. No subresource integrity, no pinning.
document.currentScript && console.log('tracker loaded from ' + location.host);
window.vibeshopTracker = { version: 1, origin: location.origin };

(function () {
  var img = new Image();
  img.src = '/tracker-pixel.gif?u=' + encodeURIComponent(location.href) + '&t=' + Date.now();
})();
