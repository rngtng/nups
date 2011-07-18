$(function() {
  $("a[rel=#overlay]").overlay({
    mask: '#333',
    top: '0%',
    onBeforeLoad: function() {
      this.getOverlay().find(".content").html("").load(this.getTrigger().attr("href"));
    },
    onLoad: function() {
      var h = $(window).height();
      $("#overlay").css('height', h - 55)
      $("#overlay .content").css('height', h - 73)
    }
  });
});

var resizeTimer;
$(window).resize(function() {
    clearTimeout(resizeTimer);
    if( isOpened()) {
      resizeTimer = setTimeout(doSomething, 100);
    }
});