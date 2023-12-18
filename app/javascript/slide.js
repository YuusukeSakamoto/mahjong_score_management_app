function moveSlide(direction) {
  var slider = document.querySelector('.slides');
  var scrollAmount = 600; // スクロールする量（スライドの幅に依存）

  if (direction === -1) {
    slider.scrollLeft -= scrollAmount;
  } else {
    slider.scrollLeft += scrollAmount;
  }
}
