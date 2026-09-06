/* pkgdown 2.2 hardcodes alt="" on the header logo it injects
   (tweak_homepage_html), so the one hex on the page would be announced as
   nothing. Give it a real description instead. */
/* pkgdown emits this file as a plain <script> in <head>, so it runs before the
   body exists and every querySelector below returned an empty list. Defer to
   DOMContentLoaded (or run immediately if the document is already parsed, e.g.
   if a future pkgdown moves the tag). */
function hsquaredEnhance() {
  var marks = document.querySelectorAll("img.logo");
  for (var i = 0; i < marks.length; i++) {
    if (!marks[i].getAttribute("alt")) {
      marks[i].setAttribute("alt", "hsquared hex logo: a pedigree and h squared");
    }
  }

  /* Local file:// preview: keep hero CTA clicks on this build. */
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
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", hsquaredEnhance);
} else {
  hsquaredEnhance();
}
