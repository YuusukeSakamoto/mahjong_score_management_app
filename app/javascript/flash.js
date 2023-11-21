document.addEventListener("DOMContentLoaded", function() {
      // 閉じるボタンのクリックイベント
    $(document).on('click', '.close-flash', function() {
      $(this).parent().fadeOut(); // 親要素（Flashメッセージ）をフェードアウト
    });

});