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
    $("#recipients .new .valid").show().find("ul").html("").hide();
    $.each(xhr.valid, function(key, email) {
      $("#recipients .new .valid").show().find("ul").append('<li>' + email + '</li>');
    });
    $("#recipients .new .invalid").show().find("ul").html("").hide();
    $.each(xhr.invalid, function(key, email) {
      $("#recipients .new .invalid").show().find("ul").append('<li>' + email + '</li>');
    });
  })
  .live('ajax:failure', function(xhr, status, error) {
    alert("Please try again!");}
  );
  
$("#recipients form.destroy")
  .live('ajax:success', function(data, xhr, status) {
    console.log(xhr);
    $("#recipients .destroy .valid").show().find("ul").html("").hide();
    $.each(xhr.valid, function(key, email) {
      $("#recipients .destroy .valid").show().find("ul").append('<li>' + email + '</li>');
    });
    $("#recipients .destroy .invalid").show().find("ul").html("").hide();
    $.each(xhr.invalid, function(key, email) {
      $("#recipients .destroy .invalid").show().find("ul").append('<li>' + email + '</li>');
    });
    //$("#recipients .input").hide();
  })
  .live('ajax:failure', function(xhr, status, error) {
    alert("Please try again!");}
  );
