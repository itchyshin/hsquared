/* pkgdown 2.2 hardcodes alt="" on the injected header logo
   (tweak_homepage_html). Navbar keeps logo.*; home hero uses sticker.*. */
(function () {
  var nodes = document.querySelectorAll("img.logo, img.navbar-logo");
  for (var i = 0; i < nodes.length; i++) {
    var img = nodes[i];
    if (!img.getAttribute("alt")) {
      img.setAttribute("alt", "hsquared hex logo (PROPOSAL v2)");
    }
  }

  var stickers = document.querySelectorAll("img.hs-hero-hex");
  for (var s = 0; s < stickers.length; s++) {
    var hex = stickers[s];
    var src = hex.getAttribute("src") || "";
    if (src.indexOf("man/figures/") !== -1) {
      hex.setAttribute("src", src.replace("man/figures/", "reference/figures/"));
    }
    if (!hex.getAttribute("alt")) {
      hex.setAttribute("alt", "hsquared hex sticker (PROPOSAL v2)");
    }
  }

  /* Local file:// preview: keep Start-here CTA clicks on this build. */
  if (window.location.protocol === "file:") {
    var root = window.location.href.replace(/[^/]*$/, "");
    var links = document.querySelectorAll(".hs-cta a[href]");
    for (var j = 0; j < links.length; j++) {
      var href = links[j].getAttribute("href");
      if (href && href.indexOf("http") !== 0 && href.indexOf("#") !== 0) {
        links[j].setAttribute("href", root + href);
      }
    }
  }
})();
