
$(function() {
  $('#add-tag').click(function() {
    $('#tag-field').append('<input type="text" name="projects[]" id="projects_" class="form-control"/>');
  });
});
