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
    let calculatedRemainingScore = remainingScore - (total_score * 100)
    $('.js-remaining_score_value').text(calculatedRemainingScore);

    if (calculatedRemainingScore < 0) {
      $('.js-remaining_score_value').css('color', 'red');
    } else {
      $('.js-remaining_score_value').css('color', '');
    }

    if (calculatedRemainingScore === 0) {
      $('#match_create_warning_1').css('visibility', 'hidden');
    } else {
      $('#match_create_warning_1').css('visibility', 'visible');
    }
  }

  // ● ルール選択肢で選択された時のjs
  function selectRule(selector) {
    let id = $(selector).val();
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

      // league作成・編集ページのとき
      if (/^\/leagues\/[^/]+\/edit$/.test(window.location.pathname) ||window.location.pathname === '/leagues/new') {
        updateIsTipValid(data.is_chip); //「リーグ成績にチップptを含めるか」項目を表示・非表示にする
      }

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
        umas = [data.uma_one, data.uma_two, data.uma_three].join(',');
      } else if (data.play_type === 4) {
        umas = [data.uma_one, data.uma_two, data.uma_three, data.uma_four].join(',');
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
        `<span class="js-remaining_score_value ps-1">${all_score}</span>
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

  // ● 対局日・家・得点・ptがすべて入力済みかつ家重複状態に応じてボタン状態更新
  function checkFormCompletion() {
    let isComplete = true;

    // match_on, IE, Score, Pointフィールドのチェックと家重複チェック
    $('[id$="_match_on"], [id$="_ie"], [id$="_score"], [id$="_point"]').each(function() {
      let value = $(this).val();
      if (value === "" || value === null || value === undefined || checkDuplicateIE()) {
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
    if (checkDuplicateIE()) {
      $('#match_create_warning_2').css('visibility', 'visible');
    } else {
      $('#match_create_warning_2').css('visibility', 'hidden');
    }
  }

  // ● 家の重複チェック
  function checkDuplicateIE() {
    let ies = [];
    $('[id$="_ie"]').each(function() {
      ies.push($(this).val());
    });
    let isDuplicate = ies.some(function(ie, index) {
      return ies.indexOf(ie) !== index;
    });
    return isDuplicate;
  }

  // ● 得点項目の入力が残り１つの場合、点数を自動補完する
  function autoCompleteScore() {
    let emptyScoreElements = $('[id$="_score"]').filter(function() {
      return !$(this).val();
    });
    if (emptyScoreElements.length === 1) {
      let remainingScoreText = $('.js-remaining_score_value').text().trim();
      let remainingScore = parseInt(remainingScoreText, 10);
      emptyScoreElements.val(remainingScore / 100);
      updateRemainingScore(); // 残得点更新
      calculate_point_rank(); // ポイント・順位の計算
    }
  }

  // ● pt記録ボタンonでpt項目の入力が残り１つの場合、ptを自動補完する
  function autoCompletePoint() {
    let element = document.getElementById('pt-toggle');
    let checked = element.checked; // チェックボックスの状態を取得(on or off)
    // チェックボックスがonの場合
    if (checked) {
      var points_sum = 0;
      let emptyPointElements = $('[id$="_point"]').filter(function() {
        let value = $(this).val();
        let point = parseFloat(value);
        if (isNaN(point)) {
          point = 0; // デフォルト値
        }
        points_sum += point;
        return !value;
      });
      if (emptyPointElements.length === 1) {
        emptyPointElements.val((points_sum * -1).toFixed(1)); // 残りptを自動補完
        updateRemainingScore(); // 残得点更新
        calculate_point_rank(); // ポイント・順位の計算
        calculate_score_rank(); // ptから得点と順位を計算
      }
    }
  }

  // ● 得点からポイント・順位の計算する
  function calculate_point_rank() {
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
        data:  { scores_rules_ies: scores_rules_ies, pt_checked: 'off' }, // サーバーに送信するデータ
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
        checkFormCompletion(); // ボタン状態更新
        updateRemainingScore(); // 残得点更新
      })
      .fail(function(){
        //通信に失敗した際の処理
      })
    }
  }

  // ● ptから得点と順位を計算する
  function calculate_score_rank() {
    let element = document.getElementById('pt-toggle');
    let checked = element.checked; // チェックボックスの状態を取得(on or off)
    var inputs = document.querySelectorAll('[id$="_score"]');
    // チェックボックスがonの場合
    if (checked) {
      // "ptで記録"テキスト強調する
      $('.toggle-text').addClass('fw-bold');
      // 得点を入力不可にする
      for(var i = 0; i < inputs.length; i++) {
        $(inputs[i]).readonly = checked;
        $(inputs[i]).removeClass('bg-white');
        $(inputs[i]).addClass('bg-disabled');
        $(inputs[i]).css('pointer-events', 'none');
        $(inputs[i]).attr('tabindex', '-1');
      }
      // 得点・順位を計算
      let is_full = true;
      $('[id$="_point"], #match_rule_id').each(function(index) {
        if ($('[id$="_point"], #match_rule_id').eq(index).val() === "") {
          is_full = false; //scoreが空白の場合falseをセット
        }
      });
      // 全プレイヤーのptが入力された場合
      if (is_full) {
        let points_rules_ies = [];
        let rule_id = [];
        let points = [];
        let ies = [];
        $('[id$="_point"]').each(function(){
          let point = parseFloat($(this).val());
          points.push(point)
        });
        $('[id$="_ie"]').each(function(){
          let ie = parseInt($(this).val());
          ies.push(ie)
        });
        rule_id.push(parseInt($('#match_rule_id').val()))
        points_rules_ies.push(rule_id)
        points_rules_ies.push(points)
        points_rules_ies.push(ies)
        $.ajax({
          type: 'GET', // リクエストのタイプ
          url: '/matches/calculates', // リクエストを送信するURL
          data:  { points_rules_ies: points_rules_ies, pt_checked: 'on' }, // サーバーに送信するデータ
          dataType: 'json' // サーバーから返却される型
        })
        // 正常にデータを受け取れた際の処理
        .done(function(data) {
          $('[id$="_score"]').each(function(k){
            $(this).val(Math.round(data[0][k] * 10) / 1000);
          });
          $('[id$="_rank"]').each(function(k){
            $(this).val(data[1][k]);
          });
          checkFormCompletion(); // ボタン状態更新
          updateRemainingScore(); // 残得点更新
        })
        .fail(function(){
          //通信に失敗した際の処理
        })
      }
    }
    // チェックボックスがoffの場合
    else {
      // "ptで記録"テキスト強調解除する
      $('.toggle-text').removeClass('fw-bold');
      // 得点を入力可にする
      for(var i = 0; i < inputs.length; i++) {
        $(inputs[i]).readonly = checked;
        $(inputs[i]).removeClass('bg-disabled');
        $(inputs[i]).addClass('bg-white');
        $(inputs[i]).css('pointer-events', 'auto');
        $(inputs[i]).attr('tabindex', '0');
      }
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
        selectRule('#league_rule_id');
      }
    });
  }

  // ● <leagueフォーム>ルール新規登録リンクをクリックしたらplay_typeをパラメータに付与する
  function updateRuleLink(initialPlayType) {
    var originalUrl = document.getElementById('rule_link').getAttribute('href');
    var newUrl = new URL(originalUrl, window.location.origin);
    newUrl.searchParams.set('play_type', initialPlayType);
    document.getElementById('rule_link').setAttribute('href', newUrl.toString());
  }

  // ● <leagueフォーム>選択されているルールのチップ有無によって「リーグ成績にチップptを含めるか」項目を表示・非表示にする
  function updateIsTipValid(is_tip) {
    if (is_tip) {
      $('#is_tip_valid').show();
    } else {
      $('#is_tip_valid').hide();
    }
  }

  // *********************************************************************
  // match関連ページのとき、ルール検索実行
  if (/\/matches(\/|$)/.test(window.location.pathname)) {
    let selector = '#match_rule_id';
    if (document.querySelector(selector)) {
      selectRule(selector);
    }
    $(selector).on('change', function () {
      selectRule(selector);
    });
    let is_fixed_rule = gon.is_fixed_rule
    // 成績登録中はルールを固定する
    if (is_fixed_rule) {
      $('#match_rule_id').removeClass('bg-white');
      $('#match_rule_id').addClass('bg-disabled');
      $('#match_rule_id').css('pointer-events', 'none');
      $('#match_rule_id').attr('tabindex', '-1');
    }
    $('#match_create_btn').on('click', function(e) {
      var remainingScore = $('.js-remaining_score_value').text();
      if (parseInt(remainingScore) !== 0) {
        if (!window.confirm('残得点が0ではありません。登録しますか？')) {
          return false;
        }
      }
    });
  }
  // league作成・編集ページのとき実行
  if (/^\/leagues\/[^/]+\/edit$/.test(window.location.pathname) || window.location.pathname === '/leagues/new') {
    // リーグ作成時のみページ読み込み時にルールリストとルール登録リンクを更新
    if (window.location.pathname === '/leagues/new') {
      var initialPlayType = $('#league_play_type').val();
      updateRuleList(initialPlayType);
      updateRuleLink(initialPlayType);
    }
    // 選択されたルールに対応する詳細を表示
    let selector = '#league_rule_id';
    selectRule(selector);
    $('body').on('change', selector, function() {
      selectRule(selector);
    });
    // play_type セレクトボックスの値が変更されたときにルールリストとルール登録リンクを更新
    $('#league_play_type').on('change', function() {
      var selectedPlayType = $(this).val();
      updateRuleList(selectedPlayType);
      updateRuleLink(selectedPlayType);
    });
  }
  // ページロード時に関数実行
  checkFormCompletion();
  updateRemainingScore();
  // フィールドの変更時にチェック関数を実行
  $('[id$="_match_on"], [id$="_ie"], [id$="_score"], [id$="_point"]').on('change', checkFormCompletion);
  // 得点に変化があったとき、残得点の更新
  $('[id$="_score"]').on('input', updateRemainingScore);
  // 得点の未入力が残り１つの場合、点数を自動補完する
  $('[id$="_score"]').on('blur', autoCompleteScore);
  // 得点・ルール・家に変化があったとき、ポイント・順位を計算して表示
  $('[id$="_score"], #match_rule_id, [id$="_ie"]').on('input', calculate_point_rank);
  // ----- ● pt記録ボタンon ------
  // ptに変化があったとき、ポイントから得点・順位を計算して表示
  $('[id$="_point"]').on('input', calculate_score_rank);
  // pt入力チェックボックスがonになったとき、ポイントから得点・順位を計算して表示
  $('#pt-toggle').on('change', calculate_score_rank);
  // ptの未入力が残り１つの場合、点数を自動補完する
  $('[id$="_point"]').on('blur', autoCompletePoint);
});

// ルール詳細情報の表示・非表示
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