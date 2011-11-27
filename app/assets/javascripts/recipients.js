var updateRecipient = function(recipient) {
  console.log(recipient);
  r = recipient;
  $('#recipient-' + recipient.id)
    .removeClass()
    .addClass(recipient.state)
    .find('.state')
      .text(recipient.state)
      .end()
    .find('.show.gender')
      .text(recipient.gender || "")
      .end()
    .find('.show.first-name')
      .text(recipient.first_name || "")
      .end()
    .find('.show.last-name')
      .text(recipient.last_name || "")
      .end()
    .find('.show.email')
      .text(recipient.email);
};

$("#recipients table th a").live('click', function(e) {
  $(e.target).closest('tr').find('th').removeClass('order');
  $(e.target).closest('th').addClass('order');
});

$('#recipients td.edit input').live('keyup', function(e) {
  if(e.which == 13) {
    $(e.target).closest('form').submit();
    return false;
  }
  if(e.which == 27) {
    $(e.target).closest('table').attr('class', 'show');
    return false;
  }
});

$('#recipients a.save').live('click', function(e) {
  var $recipient = $(this).closest('tr');
  if( (recipientPath = $recipient.data('recipient-path')) ) {
    $.ajax({
      url: recipientPath,
      type: 'put',
      dataType: 'json',
      data: {
        recipient: {
          gender: $recipient.find('.edit.gender option:selected').val(),
          first_name: $recipient.find('.edit.first-name input').val(),
          last_name: $recipient.find('.edit.last-name input').val(),
          email: $recipient.find('.edit.email input').val() //VALIDATE!!
        }
      },
      success: function (data, status, xhr) {
        updateRecipient(data);
      }
    });
  }
});

$('#recipients a.delete').live('ajax:success', function(e, data, status, xhr) {
  $('#recipient-' + data.id).remove();
});

var recipientsNavElements = "#recipients .paginate a, #recipients form.search"

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

    //// new overlay shoud relaod. TODO: only on changes!! Same for delete??
    $("a[rel=#overlay]").attachOverlay();
    $("table.content").showNothingFound();
    $("a.new[rel=#overlay]").each(function() {
      $(this).overlay().onClose(function() {
        window.location.reload();
      });
    });
  });
});