$(document).on('turbolinks:load', function () { 
  $(function () {
    $('[id$="_score"], #match_rule_id, [id$="_ie"]').change(function () {
      let is_full = true;
      $('[id$="_score"], #match_rule_id').each(function(index) {
        if ($('[id$="_score"], #match_rule_id').eq(index).val() === "") {
          is_full = false; //scoreが空白の場合falseをセット
        }
      });
      // 全プレイヤーのscoreが入力された場合
      if (is_full) {
          let scores_rules_ies = [];
          let rule_id = [];
          let scores = [];
          let ies = [];
          
          $('[id$="_score"]').each(function(){
            let score = parseInt($(this).val());
            scores.push(score)
          });
          $('[id$="_ie"]').each(function(){
            let ie = parseInt($(this).val());
            ies.push(ie)
          });
          rule_id.push(parseInt($('#match_rule_id').val()))
          
          scores_rules_ies.push(rule_id)
          scores_rules_ies.push(scores)
          scores_rules_ies.push(ies)

          $.ajax({
            type: 'GET', // リクエストのタイプ
            url: '/matches/calculates', // リクエストを送信するURL
            data:  { scores_rules_ies: scores_rules_ies }, // サーバーに送信するデータ
            dataType: 'json' // サーバーから返却される型
          })
          // 正常にデータを受け取れた際の処理
          .done(function(data) {
            $('[id$="_point"]').each(function(i){
              $(this).val(Math.round(data[0][0][i] * 10) / 10);
            });
            $('[id$="_rank"]').each(function(i){
              $(this).val(data[0][1][i]);
            });
          })
          .fail(function(){
            //通信に失敗した際の処理
          })
      }
    })
    
  });
}); 