$(function() {
  $("a[rel=#overlay]").overlay({
    mask: '#333',
    top: '0%',
    onBeforeLoad: function() {
      this.getOverlay().find(".body").html("").load(this.getTrigger().attr("href"));
    },
    onLoad: function() {
      var h = $(window).height();
      $("#overlay").css('height', h - 55)
      $("#overlay .body").css('height', h - 73)
    }
  });
});

var resizeTimer;
$(window).resize(function() {
    clearTimeout(resizeTimer);
    if( typeof(isOpened) != "undefined" && isOpened() ) {
      resizeTimer = setTimeout(doSomething, 100);
    }
});