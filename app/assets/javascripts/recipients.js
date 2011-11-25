var updateRecipient= function(id, state, gender, firstName, lastName, email) {
  $('#recipient-' + id)
    .toggleClass('class', 'edit')
    .find('.show .state')
      .text(state)
      .end()
    .find('.show .gender')
      .text(gender)
      .end()
    .find('.show .first-name')
      .text(firstName)
      .end()
    .find('.show .last-name')
      .text(lastName)
      .end()
    .find('.show .email')
      .text(email);
};

$('tr.recipient tr.edit input').live('keyup', function(e) {
  if(e.which == 13) {
    $(e.target).closest('form').submit();
    return false;
  }
  if(e.which == 27) {
    $(e.target).closest('table').attr('class', 'show');
    return false;
  }
});

$('tr.recipient a.save').live('click', function(e) {
 //ajax put here
 alert('put put');
});

$("#recipients table th a").live('click', function(e) {
  $(e.target).closest('tr').find('th').removeClass('order');
  $(e.target).closest('th').addClass('order');
});

var recipientsNavElements = "#recipients table th a, #recipients table .paginate a, form.search"

$(recipientsNavElements)
  .live('ajax:success', function(e, data, status, xhr) {
    $("#recipients table tbody").html(data);
    $(recipientsNavElements).attr('data-type', 'html');
    $("a.show[rel=#overlay]").attachOverlay();
    $("table.content").showNothingFound();
  })
  .live('ajax:error', function(e, xhr, status, error) {
    alert("Please try again!");
  });

$("#recipients form.new")
  .live('ajax:success', function(e, data, status, xhr) {
    console.log(e);
    $(".valid").hide().find("ul").html("");
    $.each(data.valid, function(key, email) {
      $(".valid").show().find("ul").append('<li>' + email + '</li>');
    });
    $(".invalid").hide().find("ul").html("");
    $.each(data.invalid, function(key, email) {
      $(".invalid").show().find("ul").append('<li>' + email + '</li>');
    });
    $(".input textarea").val("");
  })
  .live('ajax:failure', function(event, data, status, xhr) {
      alert("Please try again!");
  });

$("#recipients form.destroy")
  .live('ajax:success', function(e, data, status, xhr) {
    $(".valid").hide().find("ul").html("");
    $.each(data.valid, function(key, email) {
      $(".valid").show().find("ul").append('<li>' + email + '</li>');
      $(".input").hide();
      $("#recipients.form form").removeAttr("data-remote").removeData("remote");
    });
    $(".invalid").hide().find("ul").html("");
    $.each(data.invalid, function(key, email) {
      $(".invalid").show().find("ul").append('<li>' + email + '</li>');
    });
  })
  .live('ajax:failure', function(event, data, status, xhr) {
    alert("Please try again!");
  });

$(document).ready(function() {
  $("#recipients").each(function() {
    $(recipientsNavElements).attr('data-type', 'html');

    $("table.content").showNothingFound();

    //// new overlay shoud relaod. TODO: only on changes!! Same for delete??
    $("a[rel=#overlay]").attachOverlay();
    $("a.new[rel=#overlay]").each(function() {
      $(this).overlay().onClose(function() {
        window.location.reload();
      });
    });
    console.log('#recipients loaded');
  });
});