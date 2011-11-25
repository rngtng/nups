(function($) {
  $.fn.attachOverlay = function(options) {
    options = $.extend(true, {
      mask: '#333',
      top: '0%',
      onBeforeLoad: function() {
        this.getOverlay().find(".body").html("").load(this.getTrigger().attr("href"));
      },
      onLoad: function() {
        var h = $(window).height();
        $("#overlay").css('height', h - 55);
        $("#overlay .body").css('height', h - 73);
      }
    }, options);

   this.overlay(options);
   console.log("Overlays attached: " + this.size());
  };

  $.fn.showNothingFound = function() {
    var $footer = this.find("tfoot")
    $footer.show();
    this.find("tbody tr:first").each(function(){
      $footer.hide();
    });
  };
})(jQuery);