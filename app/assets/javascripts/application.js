// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//= require jquery
//= require jquery_ujs
//= require jquery.tools.min
//= require jquery.progress
//= require plupload/jquery.plupload.queue.min
//= require plupload/plupload.full.min
//= require cleditor/jquery.cleditor
//= require cleditor
//= require highcharts
//= require newsletters
//= require recipients
//= require send_outs
//= require tools

window.distance_of_time = function(from_time, to_time, include_seconds){
  var out         = '',
  s               = {},
  diff            = Math.abs(new Date(to_time || $.now()) - new Date(from_time)) / 1000;
  var day_diff    = diff % (7 * 24 * 60 * 60);
  s.weeks         = (diff - day_diff) / (7 * 24 * 60 * 60);
  var hour_diff   = day_diff % (24 * 60 * 60);
  s.days          = (day_diff - hour_diff) / (24 * 60 * 60);
  var minute_diff = hour_diff % (60 * 60);
  s.hours         = (hour_diff - minute_diff) / (60 * 60);
  var second_diff = minute_diff % 60;
  s.minutes       = (minute_diff - second_diff) / 60;
  var fractions   = second_diff % 1;
  s.seconds       = second_diff - fractions;
  if (s.weeks > 0) {
    out += s.weeks + 'w';
  }
  if (s.days > 0) {
    out += ' ' + s.days + 'd';
  }
  if (s.hours > 0) {
    out += ' ' + s.hours + 'h';
  }
  if (!include_seconds || s.minutes > 0) {
    out += ' ' + s.minutes + 'm';
  }
  if (include_seconds) {
    out += ' ' + s.seconds + 's';
  }
  return out;
}

