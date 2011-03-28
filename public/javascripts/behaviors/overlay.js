$(function() {
  $("a[rel]").overlay({
    mask: '#333',
    effect: 'apple',
    top: '0%',
    onBeforeLoad: function() {
      var wrap = this.getOverlay().find(".content");
      wrap.load(this.getTrigger().attr("href"));
    }
  });

});