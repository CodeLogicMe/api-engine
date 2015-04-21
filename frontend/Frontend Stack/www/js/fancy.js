$('#builderNav aside h3').each(function(){

  var $content = $(this).closest('aside').find('.table');
  var $parent = $(this).closest('aside');
  $(this).click(function(e){

    e.preventDefault();

    if($parent.hasClass("open")) {
      $parent.removeClass("open");
      $parent.removeClass("active");
    }else {
      $parent.addClass("open");
    }
  });
});

$("#iModal .fa-times").click(function() {
  $("#iModal").removeClass("active");
});

$("#iModal .cancel").click(function() {
  $("#iModal").removeClass("active");
});

$(".table-list .fa-info").click(function() {
  $("#iModal").addClass("active");
});
