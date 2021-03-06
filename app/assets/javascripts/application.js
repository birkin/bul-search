// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require 'blacklight_advanced_search'

//= require jquery_ujs
//= require turbolinks
//
// Required by Blacklight
//= require blacklight/blacklight
//= require_tree ./global

//= require underscore-min


//= require handlebars.runtime
//= require_tree ./templates
//= require handlebars.helpers

//= require jquery.plug-google-content

//= require bootstrap/tooltip
//= require bootstrap/popover
//= require infobox

//= require analytics



// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'


// Shelf-Browse
//= require 'jquery.stackview.min.js'


// ------------------------------
// Functions used to display the option to Scan an
// item or request it.

// Only items from the Annex that are books and periodical
// titles can be requested.
// I think we might need to add a check on "status" since
// only Available items can be requested.
// See https://github.com/Brown-University-Library/easyscan/blob/391cbef95f4731894a0b0b30cf15f062263fd77e/easyscan_app/lib/josiah_easyscan.js#L214-L224
function canScanItem(location, format) {
  var location = (location || "").toLowerCase();
  var format = (format || "").toLowerCase();
  if (location != "annex") {
    return false;
  }
  if ((format != "book") && (format != "periodical title")) {
    return false;
  }
  return true;
}


function easyScanFullLink(scanLink, bib, title) {
  return scanLink + '&title=' + title + '&bibnum=' + bib;
}


function itemRequestFullLink(barCode, bib) {
  return "https://library.brown.edu/easyrequest/login/?bibnum=" + bib + "&barcode=" + barCode;
}
