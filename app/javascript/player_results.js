$(document).on('turbolinks:load', function () {
  let params = new URLSearchParams(window.location.search); //paramsを取得
  let playType = params.get('play_type'); //play_typeを取得
  if (playType == '4' || playType == null) { //play_typeが4またはnullの場合
    $('#result-4').show();
    $('#result-3').hide();
    $('#toggle-to-four-top').addClass('active');
    $('#toggle-to-three-top').removeClass('active');
    $('#toggle-to-four-player').addClass('active');
    $('#toggle-to-three-player').removeClass('active');
  } else if (playType == '3') { //play_typeが3の場合
    $('#result-3').show();
    $('#result-4').hide();
    $('#toggle-to-three-top').addClass('active');
    $('#toggle-to-four-top').removeClass('active');
    $('#toggle-to-three-player').addClass('active');
    $('#toggle-to-four-player').removeClass('active');
  }

  // プレイヤー切り替えボタン(topページ)
  $('#toggle-to-four-top').click(function() {
    $('#result-4').show();
    $('#result-3').hide();
    $('#toggle-to-four-top').addClass('active');
    $('#toggle-to-three-top').removeClass('active');
    $('#toggle-to-four-player').addClass('active');
    $('#toggle-to-three-player').removeClass('active');
  });

  $('#toggle-to-three-top').click(function() {
    $('#result-3').show();
    $('#result-4').hide();
    $('#toggle-to-three-top').addClass('active');
    $('#toggle-to-four-top').removeClass('active');
    $('#toggle-to-three-player').addClass('active');
    $('#toggle-to-four-player').removeClass('active');
  });

  // プレイヤー切り替えボタン(成績詳細ページ)
  $('#toggle-to-four-player').click(function() {
    $('#result-4').show();
    $('#result-3').hide();
    $('#toggle-to-four-player').addClass('active');
    $('#toggle-to-three-player').removeClass('active');
  });

  $('#toggle-to-three-player').click(function() {
    $('#result-3').show();
    $('#result-4').hide();
    $('#toggle-to-three-player').addClass('active');
    $('#toggle-to-four-player').removeClass('active');
  });

});