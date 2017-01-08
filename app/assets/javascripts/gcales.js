
$(function() {
  $('#add-tag').click(function() {
    $('#tag-field').append('<input type="text" name="projects_name[]" id="projects_" class="form-control" placeholder="タグネームを入力"/>');
    $('#tag-field').append('<input type="text" name="projects_description[]" id="projects_" class="form-control" placeholder="説明を入力"/>');
  });
});


$(".nav li a").on("click", function(){
   $(".nav").find(".active").removeClass("active");
   $(this).parent().addClass("active");
});
