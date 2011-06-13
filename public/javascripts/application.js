// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$('#micropost_content').live('keyup keydown', function(e) {
  var maxLen = 140;
  var left = maxLen - $(this).val().length;
  $('#char-count').html(left);
});