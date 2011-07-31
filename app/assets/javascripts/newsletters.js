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
      var newsletterPath = this.data('newsletter-path');
      console.log(newsletterPath);
      scheduled = true;
      window.setTimeout(request(newsletterPath), 2000);
    })
  }
},
update = function(id, state, progressPercent) {
  $('#newsletter_' + id)
  .attr('class', 'newsletter ' + state)
  .filter('.sending,.testing,.stopping').each( function(){
    $(this).find('.progress')
      .width(progressPercent)
      .show()
      .find('label')
      .text(progressPercent)
      .end();
      schedule();
  });
};

$(document).ready(function () {
  $("ul.tabs").tabs("table > tbody", {effect: 'ajax'});
  schedule();
});