$(document).on('turbolinks:load', function () { 
  $(function () {
    let selecter = '#match_rule_id'
    $(document).ready(rule_detail(selecter));
    $(selecter).change(function () {
      rule_detail(selecter)
    });
    
      function rule_detail(selecter) {
        let id = $(selecter).val();
        $.ajax({
          type: 'GET', // リクエストのタイプ
          url: '/rules/searches', // リクエストを送信するURL
          data:  { id: id }, // サーバーに送信するデータ
          dataType: 'json' // サーバーから返却される型
        })
        // 正常にデータを受け取れた際の処理
        .done(function(data) {
          $('.js-rule ul').remove();
          $('.js-remaining_score span').remove();
          let all_score = data.mochi * data.play_type
          let value = data.score_decimal_point_calc
          let pt_calc = ''
          
        	if (value === 1) {
        		pt_calc = "計算しない(小数点そのまま)"
        	} else if (value === 2) {
        		pt_calc = "五捨六入"
        	} else if (value === 3) {
        		pt_calc = "四捨五入"
        	} else if (value === 4) {
        		pt_calc = "切り捨て"
        	} else if (value === 5) {
        		pt_calc = "切り上げ"
        	} 
        	
        	let umas = []
        	if (data.play_type === 3) {
        	  umas = [data.uma_1, data.uma_2, data.uma_3].join(',');
        	} else if (data.play_type === 4) {
        	  umas = [data.uma_1, data.uma_2, data.uma_3, data.uma_4].join(',');
          }
          
          $('.js-rule').append(
          `<ul class="rounded border-green-thin px-1 py-1 text-gray fs-sm text-center fadeIn">
          <p class="mb-0">< ルール詳細 ></p>
          <li style="list-style:none">${data.mochi}点持ち</li>
          <li style="list-style:none">${data.kaeshi}点返し</li>
          <li style="list-style:none">ウマ (${umas})</li>
          <li style="list-style:none">pt小数点 : ${pt_calc}</li>
          </ul>`
          );
          $('.js-remaining_score').append(
           `<span class="js-remaining_score_value">${all_score}</span>
            <span class="js-remaining_score_hidden_value" style="display:none">${all_score}</span>`
          );
        })
        .fail(function(){
          //通信に失敗した際の処理
          $('.js-rule ul').remove();
          $('.js-remaining_score span').remove();
        })      
      }
  });
}); 