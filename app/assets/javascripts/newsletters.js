var scheduled = false,
request = function(newsletterPath) {
  var ids = $.map($('.newsletter'), function(elem) {
    return elem.id.replace('newsletter_', '');
  });
  jQuery.ajax({
    url: newsletterPath,
    data: { ids: ids },
    dataType: 'script'
  });
  scheduled = false;
},
schedule = function() {
  if(!scheduled) {
    $('.newsletter:first').each(function(){
      var newsletterPath = $(this).data('newsletter-path');
      scheduled = true;
      window.setTimeout( function() { request(newsletterPath) }, 2000);
    })
  }
},
update_newsletter = function(id, state, progressPercent) {
  $('#newsletter_' + id)
  .attr('class', 'newsletter ' + state)
  .each( function(){
    $(this).find('.progress')
      .width(progressPercent)
      .show()
      .find('label')
      .text(progressPercent)
      .end();
      schedule();
  });
};

$(document).keypress(function(e) {
  if( (e.keyCode || e.which) == 113 ) {
    $("body").removeClass("default");
  }
})

$(document).ready(function () {
  $("ul.tabs").tabs("table > tbody", {
      effect: 'ajaxOverlay',
      initialIndex: -1
  });
  schedule();
  attachOverlay();
});