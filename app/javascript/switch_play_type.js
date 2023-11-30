const match_url = '/matches/switches';
const match_group_url = '/match_groups/switches';

function bindToggleButtons() {

  var url;
  $('#toggle-to-four-m').off('click').click(function() {
    url = match_url;
    updateMatches('4', url);
  });

  $('#toggle-to-three-m').off('click').click(function() {
    url = match_url;
    updateMatches('3', url);
  });

  $('#toggle-to-four-mg').off('click').click(function() {
    url = match_group_url;
    updateMatches('4', url);
  });

  $('#toggle-to-three-mg').off('click').click(function() {
    url = match_group_url;
    updateMatches('3', url);
  });
}

function updateMatches(playType, url) {
  $.ajax({
    url: url, // 対応するURLに変更
    type: 'GET',
    dataType: 'script',
    data: { play_type: playType }
  }).done(function() {
    if (playType === '4') {
      if (url === match_group_url) {
        $('#toggle-to-four-mg').addClass('active');
        $('#toggle-to-three-mg').removeClass('active');
      } else {
        $('#toggle-to-four-m').addClass('active');
        $('#toggle-to-three-m').removeClass('active');
      }
    } else {
      if (url === match_group_url) {
        $('#toggle-to-three-mg').addClass('active');
        $('#toggle-to-four-mg').removeClass('active');
      } else {
        $('#toggle-to-three-m').addClass('active');
        $('#toggle-to-four-m').removeClass('active');
      }
    }
    bindToggleButtons(); // Ajaxリクエスト後にボタンにイベントリスナーを再設定
  });
}

$(document).on('turbolinks:load', function () {
  bindToggleButtons(); // ページロード時にボタンにイベントリスナーを設定
  console.log('read')
});