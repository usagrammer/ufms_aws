$(function () {
  // 商品詳細ページの画像のスライド
  var opacity_timer;
  var before_mini_image = $(`img[data-mini-image-index="0"]`);
  $(`img[data-mini-image-index="0"]`).css('opacity', '1.0');

  $('.item-images__mini-images').on('mouseenter', 'img', function () {
    clearTimeout(opacity_timer);
    var self = this;
    opacity_timer = setTimeout($.proxy(function () {
      $(before_mini_image).css('opacity', '0.5');
      before_mini_image = self;
      $(self).css('opacity', '1.0');
      var image_index = $(self).data('mini-image-index');
      var next_image = $(`img[data-big-image-index="${image_index}"]`)
      $('.item-images__main-images').animate({
        right: $(`.item-images__main-images`).scrollLeft() + $(next_image).position().left
      }, 'fast');
    }), 500);

  });

});
