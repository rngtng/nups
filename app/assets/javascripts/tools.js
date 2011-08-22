var attachOverlay = function() {
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
  if($("a[rel=#overlay]").size() <= 0) {
    $("tfoot").show();
  }
  else {
    $("tfoot").hide();
  }
};

$.tools.tabs.addEffect("ajaxOverlay", function(tabIndex, done) {
    this.getPanes().eq(0).html("").load(this.getTabs().eq(tabIndex).attr("href"), function() {
      attachOverlay();
      if( (url = $("a.current").data("new-url")) ) {
        $("a.new").show().attr("href", url );
      }
      else {
        $("a.new").hide();
      }

    });
    done.call();
});
