var update_recipient= function(id, gender, first_name, last_name, email) {
  $('#recipient_' + id +' table')
    .attr('class', 'show')
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

$('tr.recipient tr.edit input').live('keyup', function(event) {
  if(event.which == 13) {
    $(event.target).closest('form').submit();
    return false;
  }
  if(event.which == 27) {
    $(event.target).closest('table').attr('class', 'show');
    return false;
  }
});

$("#recipients form.new")
  .live('ajax:success', function(data, xhr, status) {
    $(".valid").hide().find("ul").html("");
    $.each(xhr.valid, function(key, email) {
      $(".valid").show().find("ul").append('<li>' + email + '</li>');
    });
    $(".invalid").hide().find("ul").html("");
    $.each(xhr.invalid, function(key, email) {
      $(".invalid").show().find("ul").append('<li>' + email + '</li>');
    });
    $(".input textarea").val("");
  })
  .live('ajax:failure', function(xhr, status, error) {
    alert("Please try again!");}
  );

$("#recipients form.destroy")
  .live('ajax:success', function(data, xhr, status) {
    $(".valid").hide().find("ul").html("");
    $.each(xhr.valid, function(key, email) {
      $(".valid").show().find("ul").append('<li>' + email + '</li>');
      $(".input").hide();
      $("#recipients.form form").removeAttr("data-remote").removeData("remote");
    });
    $(".invalid").hide().find("ul").html("");
    $.each(xhr.invalid, function(key, email) {
      $(".invalid").show().find("ul").append('<li>' + email + '</li>');
    });
  })
  .live('ajax:failure', function(xhr, status, error) {
    alert("Please try again!");}
  );
