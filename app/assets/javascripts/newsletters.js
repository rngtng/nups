var scheduled = false,
request = function(newsletterPath) {
  var ids = $.map($('.newsletter'), function(elem) {
    return elem.id.replace('newsletter-', '');
  });
  $.ajax({
    url: newsletterPath,
    data: { ids: ids },
    dataType: 'script'
  });
  scheduled = false;
},
schedule = function() {
  if(!scheduled) {
    $('.newsletter:first').not(':.finished').each(function(){
      var newsletterPath = $(this).data('newsletter-path');
      scheduled = true;
      window.setTimeout(function() {
        request(newsletterPath)
      }, 2000);
    })
  }
},
updateNewsletter = function(id, state, progressPercent, sendingTime, sendingsPerSecond) {
  $('#newsletter-' + id)
  .attr('class', 'newsletter ' + state)
  .each(function() {
    $(this).find('.progress')
      .attr('title', progressPercent + '% - ' + sendingTime + ' - ' + sendingsPerSecond + '/sec.')
      .width(progressPercent + '%')
      .show()
      .find('label')
      .text(progressPercent + '%')
      .end();
      schedule();
  });
};

$.tools.tabs.addEffect("ajaxOverlay", function(tabIndex, done) {
  this.getPanes().eq(0).html("").load(this.getTabs().eq(tabIndex).attr("href"), function() {
    $(newsletterNavElements).attr('data-type', 'html');
    $("tbody a[rel=#overlay]").attachOverlay();
    $("table.content").showNothingFound();

    if( (url = $("a.current").data("new-url")) ) {
      $("a.new").show().attr("href", url);
    }
    else {
      $("a.new").hide();
    }
  });

  done.call();
});

var newsletterNavElements = "#newsletters table .paginate a";

$("#newsletters table .paginate a")
  .live('ajax:success', function(e, data, status, xhr) {
    $("#newsletters table tbody").html(data);

    $(newsletterNavElements).attr('data-type', 'html');
    $("tbody a.preview[rel=#overlay]").attachOverlay();
    $("table.content").showNothingFound();
  })
  .live('ajax:error', function(e, xhr, status, error) {
    alert("Please try again!");
  });

$(document).keypress(function(e) {
  if( (e.keyCode || e.which) == 113 ) {
    $("body").removeClass("default");
  }
})

$(document).ready(function () {
  $("#newsletters").each(function() {
    schedule();
    $("ul.tabs").tabs("table > tbody", {
        effect: 'ajaxOverlay',
        initialIndex: -1
    });
    $(newsletterNavElements).attr('data-type', 'html');
    $("a[rel=#overlay]").attachOverlay();
    $("table.content").showNothingFound();
    console.log('#newsletters loaded');
  });
});

