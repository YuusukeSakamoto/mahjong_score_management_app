$(document).on('turbolinks:load', function () { 
  
  //*******************************************
  //*. 関数の定義　                           *
  //*******************************************
  // ● 残得点の更新
  function updateRemainingScore() {
    let scores = [];
    $('[id$="_score"]').each(function() {
      scores.push($(this).val());
    });

    let total_score = scores.filter(v => v).reduce(function(sum, element){
      return sum + parseInt(element, 10);
    }, 0);

    let remainingScoreText = $('.js-remaining_score_hidden_value').text().trim();
    let remainingScore = parseInt(remainingScoreText, 10);
    let calculatedRemainingScore = remainingScore - total_score;
    $('.js-remaining_score_value').text(calculatedRemainingScore);

    if (calculatedRemainingScore < 0) {
      $('.js-remaining_score_value').css('color', 'red');
    } else {
      $('.js-remaining_score_value').css('color', '');
    }
    
    if (calculatedRemainingScore === 0) {
      $('#match_create_warning').css('visibility', 'hidden');
    } else {
      $('#match_create_warning').css('visibility', 'visible');
    }
  }
  
  // ● ルール詳細の取得
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
      let is_chip = '無'
      let pt_calc = ''
      
    	if (value === 1) {
    		pt_calc = "小数点有効"
    	} else if (value === 2) {
    		pt_calc = "五捨六入"
    	} else if (value === 3) {
    		pt_calc = "四捨五入"
    	} else if (value === 4) {
    		pt_calc = "切り捨て"
    	} else if (value === 5) {
    		pt_calc = "切り上げ"
    	} 
    	
    	if (data.is_chip) {
    	  is_chip = '有'
    	}
    	
    	let umas = []
    	if (data.play_type === 3) {
    	  umas = [data.uma_1, data.uma_2, data.uma_3].join(',');
    	} else if (data.play_type === 4) {
    	  umas = [data.uma_1, data.uma_2, data.uma_3, data.uma_4].join(',');
      }
      
      $('.js-rule').append(
      `<ul class="rounded border-green-thin px-1 py-1 text-gray fs-sm text-center">
      <li style="list-style:none">${data.mochi}点持ち / ${data.kaeshi}点返し</li>
      <li style="list-style:none">ウマ (${umas})</li>
      <li style="list-style:none">点数計算 : ${pt_calc}</li>
      <li style="list-style:none">チップ : ${is_chip}</li>
      </ul>`
      );
      $('.js-remaining_score').append(
       `<span class="js-remaining_score_value">${all_score}</span>
        <span class="js-remaining_score_hidden_value" style="display:none">${all_score}</span>`
      );
      updateRemainingScore(); // ajaxが完了したら残得点の計算
    })
    .fail(function(){
      //通信に失敗した際の処理
      $('.js-rule ul').remove();
      $('.js-remaining_score span').remove();
    })      
  }
  
  // ● 家・得点・ptがすべて埋まっていたらボタン状態更新
  function checkFormCompletion() {
    let isComplete = true;
    
    // IE, Score, Point フィールドのチェック
    $('[id$="_ie"], [id$="_score"], [id$="_point"]').each(function() {
      let value = $(this).val();
      if (value === "" || isNaN(value)) {
        isComplete = false;
        return false; // ループを中断
      }
    });

    // 登録ボタンの状態を更新
    if (isComplete) {
      $('#match_create_btn').prop('disabled', false).removeClass('inactive');
    } else {
      $('#match_create_btn').prop('disabled', true).addClass('inactive');
    }
  }
  
  // ● <leagueフォーム>ルール選択肢を更新する関数
  function updateRuleList(playType) {
    $.ajax({
      url: '/rules/searches/1',
      method: 'GET',
      dataType: 'json',
      data: { play_type: playType },
      success: function(rules) {
        var options = rules.map(function(rule) {
          return '<option value="' + rule.id + '">' + rule.name + '</option>';
        });
        $('#league_rule_id').html(options.join(''));
        rule_detail('#league_rule_id');
      }
    });
  }
  

  // *********************************************************************
  // match関連ページのとき、ルール検索実行
  if (/^\/matches\//.test(window.location.pathname)) {
    let selecter = '#match_rule_id';
    $(document).ready(rule_detail(selecter));
    $(selecter).change(function () {
      rule_detail(selecter);
    });
    let is_recording = gon.is_recording
    let is_league_recording = gon.is_league_recording
    let is_edit = gon.is_edit
    // 成績登録中はルールを固定する
    if (is_recording || is_league_recording || is_edit) {
      $('#match_rule_id').removeClass('bg-white');
      $('#match_rule_id').addClass('bg-disabled');
      $('#match_rule_id').css('pointer-events', 'none');
      $('#match_rule_id').attr('tabindex', '-1');
    }
  }
  // league関連ページのとき、ルール検索実行
  if (/^\/leagues\//.test(window.location.pathname)) {
    let selector = '#league_rule_id';
    $(document).ready(rule_detail(selector));
    $('body').on('change', selector, function() {
      rule_detail(selector);
    });
    // ページ読み込み時にルールリストを更新
    var initialPlayType = $('#league_play_type').val();
    updateRuleList(initialPlayType);
  
    // play_type セレクトボックスの値が変更されたときにルールリストを更新
    $('#league_play_type').on('change', function() {
      var selectedPlayType = $(this).val();
      updateRuleList(selectedPlayType);
    });
  }
  // ページロード時に関数実行
  checkFormCompletion();
  updateRemainingScore();
  // フィールドの変更時にチェック関数を実行
  $('[id$="_ie"], [id$="_score"], [id$="_point"]').change(checkFormCompletion);
  // 得点に変化があったとき、残得点の更新
  $('[id$="_score"]').change(updateRemainingScore);

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
            checkFormCompletion(); //　ボタン状態更新
            updateRemainingScore(); // 残得点更新
          })
          .fail(function(){
            //通信に失敗した際の処理
          })
      }
    })
  });
}); 

// ルール選択に応じた詳細情報の表示
$(document).on('click', '.js-rule-dropdown', function() {
  // ルール詳細の表示・非表示を切り替える前に現在の表示状態をチェック
  var isCurrentlyVisible = $('.js-rule-details').is(':visible');
  
  $('.js-rule-details').toggle(); // ルール詳細の表示・非表示を切り替える

  // アイコンのクラスを切り替える
  var icon = $(this).find('i');
  if (isCurrentlyVisible) {
    icon.removeClass('fa-caret-down'); // ルール詳細が表示されていた場合、非表示になるのでアイコンを変更
  } else {
    icon.addClass('fa-caret-down'); // ルール詳細が非表示だった場合、表示になるのでアイコンを変更
  }
});

// 対局メモの表示・非表示
$(document).on('click', '.js-memo-dropdown', function() {
  $('.js-memo-details').toggle(); // 対局メモの表示・非表示を切り替える

  // アイコンのクラスを切り替える
  var icon = $(this).children('i:first');
  if ($('.js-memo-details').is(':visible')) {
    icon.removeClass('fa-caret-right').addClass('fa-caret-down'); // メモが表示の場合
  } else {
    icon.removeClass('fa-caret-down').addClass('fa-caret-right'); // メモが非表示の場合
  }
});