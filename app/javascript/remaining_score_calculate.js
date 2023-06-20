// # 対局成績の得点に入力された値をもとに残り点数を計算する
$(document).on('turbolinks:load', function () { 
  $(function(){
    $('[id$="_score"]').change(function () {
      let scores = [];
      $('[id$="_score"]').each(function() {
        scores.push($( this ).val());
      });
      
      let scores_filtered = scores.filter(v => v) // nilを排除する

      let total_score = scores_filtered.reduce(function(sum, element){
        let total = (sum + parseInt(element))
        return total;
      }, 0);
      let remaining_score = $('.js-remaining_score_hidden_value').text();
     
      let calculated_remaining_score = remaining_score - total_score
      $('.js-remaining_score_value').text(calculated_remaining_score);
      if (calculated_remaining_score < 0) {
        $('.js-remaining_score_value').css('color', 'red');
      } else {
        $('.js-remaining_score_value').css('color', '');
      }

    });
  }); 
}); 