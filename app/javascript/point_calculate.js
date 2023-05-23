$(document).on('turbolinks:load', function () { 
  $(function () {
    $('[id$="_score"], #match_rule_id').change(function () {
      let is_full = true;
      $('[id$="_score"], #match_rule_id').each(function(index) {
        if ($('[id$="_score"], #match_rule_id').eq(index).val() === "") {
          is_full = false; //scoreが空白の場合falseをセット
        }
      });
      // 全プレイヤーのscoreが入力された場合
      if (is_full) {
          var datas = [];
          var rule_id = [];
          var scores = [];
          
          $('[id$="_score"]').each(function(){
            var score = parseInt($(this).val());
            scores.push(score)
          });
          rule_id.push(parseInt($('#match_rule_id').val()))
          
          datas.push(rule_id)
          datas.push(scores)

          $.ajax({
            type: 'GET', // リクエストのタイプ
            url: '/matches/calculates', // リクエストを送信するURL
            data:  { datas: datas }, // サーバーに送信するデータ
            dataType: 'json' // サーバーから返却される型
          })
          // 正常にデータを受け取れた際の処理
          .done(function(data) {
            $('[id$="_point"]').each(function(index){
              $(this).val(data[index]);
            });
          })
          .fail(function(){
            //通信に失敗した際の処理
          })
      }
    })
    
  });
}); 