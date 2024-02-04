document.addEventListener("DOMContentLoaded", function() {
    // 閉じるボタンのクリックイベント
  $(document).on('click', '.close-flash', function() {
    $(this).parent().fadeOut(); // 親要素（Flashメッセージ）をフェードアウト
  });

  // Flashメッセージを3秒後に自動的にフェードアウト
  setTimeout(function() {
      $('.close-flash').parent().fadeOut();
  }, 3000); // 3000ミリ秒 = 3秒

});