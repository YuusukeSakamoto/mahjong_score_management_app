document.addEventListener("DOMContentLoaded", function() {
    // メッセージを表示
    document.querySelector('.flash').style.top = '7px';
    
    // メッセージのテキストを取得
    var messageText = document.querySelector('.flash').textContent;
  
    // メッセージの文字数に応じて幅を計算
    var messageWidth = 50 + messageText.length;
  
    // Flashメッセージの幅を設定
    document.querySelector('.flash').style.width = messageWidth + '%';
    
    // 一定時間後にメッセージを非表示
    setTimeout(function() {
      document.querySelector('.flash').style.top = '-100px';
    }, 4000); // 4秒後に非表示にする
    
      // 閉じるボタンのクリックイベント
    $(document).on('click', '.close-flash', function() {
      $(this).parent().fadeOut(); // 親要素（Flashメッセージ）をフェードアウト
    });

});

