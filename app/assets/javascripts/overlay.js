$(function() {
  $("a[rel=#overlay]").overlay({
    mask: '#333',
    effect: 'apple',
    top: '0%',
    onBeforeLoad: function() {
      this.getOverlay().find(".content").load(this.getTrigger().attr("href"));
    }
  });

});