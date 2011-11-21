var update_recipient= function(id, state, gender, first_name, last_name, email) {
  $('#recipient_' + id)
    .toggleClass('class', 'edit')
    .find('.show .state')
      .text(state)
      .end()
    .find('.show .gender')
      .text(gender)
      .end()
    .find('.show .first_name')
      .text(first_name)
      .end()
    .find('.show .last_name')
      .text(last_name)
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

$("#recipients table th a").live('click', function(e) {
  $(e.target).closest('tr').find('th').removeClass('order');
  $(e.target).closest('th').addClass('order');
});

var nav_elements = "#recipients table th a, #recipients table .paginate a, form.search"

$(nav_elements)
  .live('ajax:success', function(e, data, status, xhr) {
    $("#recipients table tbody").html(data);
    $(nav_elements).attr('data-type', 'html');
  })
  .live('ajax:error', function(e, xhr, status, error) {
    alert("error");
    console.log("e");
    console.log(e);
    console.log("xhr");
    console.log(xhr);
    console.log("s");
    console.log(status);
    console.log("e");
    console.log(error);
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
    alert("Please try again!");}
  );

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
    alert("Please try again!");}
  );

$(document).ready(function () {
  $(nav_elements).attr('data-type', 'html');

  $("#recipients a[rel=#overlay]:first")
   .each( function() {
      $(this).overlay().onClose( function() {
        window.location.reload();
      });
    });
});