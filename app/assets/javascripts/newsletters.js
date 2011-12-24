var request = function(newsletterPath){
  $.ajax({
    url: newsletterPath,
    data: {
      ids: $.makeArray($('.newsletter').map(function(){
        return this.id.replace('newsletter-', '');
      }))
    },
    dataType: 'json',
    success: function (data, status, xhr) {
      $('#newsletters').removeClass('scheduled');
      $.each(data, function(index, newsletter){
        updateNewsletter(newsletter);
      });
      schedule();
    },
    error: function (jqXHR, textStatus, errorThrown) {
      console.log(jqXHR);
      console.log("Error in request:" + textStatus + " - " + errorThrown);
      schedule();
    }
  });
},
schedule = function(){
  $('#newsletters:not(.scheduled) .newsletter:not(.finished):first').each(function(){
    var newsletterPath = $(this).data('newsletter-path'),
        pullTime = $(this).data('pull-time');
    $('#newsletters').addClass('scheduled');
    window.setTimeout(function(){
      request(newsletterPath);
    }, window.parseInt(pullTime));
  })
},
updateNewsletter = function(nl){
  $('#newsletter-' + nl.id)
    .attr('class', 'newsletter ' + nl.state)
    .find('.progress')
      .width(nl.progress_percent + '%')
      .show()
      .find('label')
        .text(nl.progress_percent + '%')
        .end()
      .end()
    .find('.stats')
      .find('.progress-percent').html(nl.progress_percent + '%').end()
      .find('.sending-time').html(distance_of_time(nl.delivery_started_at, nl.delivery_ended_at, true)).end()
      .find('.sendings-per-sec').html(nl.sendings_per_second + '/sec.').end()
      .find('.finishs span').html(nl.finishs_count).end()
      .find('.reads span').html(nl.reads_count).end()
      .find('.bounces span').html(nl.bounces_count).end()
      .find('.fails span').html(nl.fails_count).end();
};

$('#newsletters a.delete').live('ajax:success', function(e, data, status, xhr) {
  $('#newsletter-' + data.id).remove();
});

$('#newsletters').find('.send-live,.send-test,.stop').live('ajax:success', function(e, data, status, xhr) {
  updateNewsletter(data);
  schedule();
}).live('ajax:error', function(e, xhr, status, error){
  alert("Please try again!" + e + " " +error);
});


$.tools.tabs.addEffect("ajaxOverlay", function(tabIndex, done) {
  this.getPanes().eq(0).html("").load(this.getTabs().eq(tabIndex).attr("href"), function() {
    $(newsletterNavElements).attr('data-type', 'html');
    $("tbody a[rel=#overlay]").attachOverlay();
    $("table.content").showNothingFound();

    if( (url = $("a.current").data("new-url")) ){
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
  .live('ajax:success', function(e, data, status, xhr){
    $("#newsletters table tbody").html(data);

    $(newsletterNavElements).attr('data-type', 'html');
    $("tbody a.preview[rel=#overlay]").attachOverlay();
    $("table.content").showNothingFound();
  })
  .live('ajax:error', function(e, xhr, status, error){
    alert("Please try again!");
  });

$(document).keypress(function(e){
  if( (e.keyCode || e.which) == 113 ){
    $("body").removeClass("default");
  }
})

$(document).ready(function (){
  $("#newsletters").each(function(){
    schedule();
    $("ul.tabs").tabs("table > tbody", {
        effect: 'ajaxOverlay',
        initialIndex: -1
    });
    $(newsletterNavElements).attr('data-type', 'html');
    $("a[rel=#overlay]").attachOverlay();
    $("table.content").showNothingFound();
    //console.log('#newsletters loaded');
  });
});

