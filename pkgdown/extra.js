/* pkgdown 2.2 hardcodes alt="" on the injected header logo
   (tweak_homepage_html). Restore the PROPOSAL label. */
(function () {
  var nodes = document.querySelectorAll("img.logo, img.navbar-logo");
  for (var i = 0; i < nodes.length; i++) {
    var img = nodes[i];
    if (!img.getAttribute("alt")) {
      img.setAttribute("alt", "hsquared hex logo (PROPOSAL)");
    }
  }
})();
