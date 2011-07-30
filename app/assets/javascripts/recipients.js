$(document).ready(function() {
  //index
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

  //new
  $("#recipients form.new")
    .live('ajax:success', function(data, xhr, status) {
      $.each(xhr.valid, function(key, email) {
        $("#recipients .valid").show().find("ul").append('<li>' + email + '</li>');
      });
      $.each(xhr.invalid, function(key, email) {
        $("#recipients .invalid").show().find("ul").append('<li>' + email + '</li>');
      });
      $("#recipients .input").hide();
    })
    .live('ajax:failure', function(xhr, status, error) {
      alert("Please try again!");}
    );
    //.bind('ajax:loading', function() {alert("loading!");})
    //.bind('ajax:complete', function() {alert("complete!");});
});