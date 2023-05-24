$(document).on('turbolinks:load', function () { 
  $(function () {
    $('#match_rule_id').blur(function () {
      //  フォームからフォーカスを外したタイミングで以下の処理を実行する
      var id = $.trim($(this).val());
      console.log(id);
      $.ajax({
        type: 'GET', // リクエストのタイプ
        url: '/rules/searches', // リクエストを送信するURL
        data:  { id: id }, // サーバーに送信するデータ
        dataType: 'json' // サーバーから返却される型
      })
      // 正常にデータを受け取れた際の処理
      .done(function(data) {
        $('.js-rule p').remove();
        $('.js-rule').append(
        `<p>${data.mochi}点持ち, ${data.kaeshi}点返し, ウマ(${data.uma_1},${data.uma_2},${data.uma_3},${data.uma_4}) </p>`
        );
      })
      .fail(function(){
        //通信に失敗した際の処理
        $('.js-rule p').remove();
      })
    })
  });
}); 