$(document).ready(function() {
  editors = $(".cleditor").cleditor({
    width:        600, // width not including margins, borders or padding
    height:       500, // height not including margins, borders or padding
    controls:     // controls to add to the toolbar
                  "bold italic underline strikethrough | font size " +
                  "style | color highlight removeformat | bullets numbering | outdent " +
                  "indent | alignleft center alignright justify | " +
                  "rule image link unlink | source"
  });

  editors.each(function() {
    var editor = this;
    $(editor.doc).keypress(function(e) {
      if ((e.keyCode || e.which) == 13) {
        var body   = editor.$frame.contents().find("body")[0];
        var height = body.scrollHeight + (body.offsetHeight - body.clientHeight) + 27 ;
        console.log('' + editor.$frame.css('height') + ' - ' + height);
        if( parseInt(editor.$frame.css('height')) < height) {
          editor.$main.css('height', height + 27);
          editor.$area.css('height', height);
          editor.$frame.css('height', height);
        }
      }
    });
  });

});
