// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//= require jquery
//= require jquery_ujs

var selected_user_id = 0;

function show_menu(user_id) {
    if(selected_user_id > 0) $('#user_menu_' + selected_user_id).hide();
    $('#user_menu_' + user_id).show();
    selected_user_id = user_id;
}