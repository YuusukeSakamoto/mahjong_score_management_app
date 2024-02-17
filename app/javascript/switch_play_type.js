const matchUrl = '/matches/switches';
const matchGroupUrl = '/match_groups/switches';

function bindToggleButtons() {
  // ボタンの種類と関連するURLをマッピング
  const buttonMappings = [
    {selector: '#toggle-to-four-m', playType: '4', url: matchUrl},
    {selector: '#toggle-to-three-m', playType: '3', url: matchUrl},
    {selector: '#toggle-to-four-mg', playType: '4', url: matchGroupUrl},
    {selector: '#toggle-to-three-mg', playType: '3', url: matchGroupUrl},
  ];

  buttonMappings.forEach(({selector, playType, url}) => {
    $(selector).off('click').on('click', function() {
      updateMatches(playType, url);
    });
  });
}

function updateMatches(playType, url) {
  $.ajax({
    url,
    type: 'GET',
    dataType: 'script',
    data: { play_type: playType }
  }).done(function() {
    // ボタンのアクティブ状態の更新
    const activeSelector = playType === '4' ? 'four' : 'three';
    const inactiveSelector = playType === '4' ? 'three' : 'four';

    $(`#toggle-to-${activeSelector}-m`).addClass('active');
    $(`#toggle-to-${inactiveSelector}-m`).removeClass('active');
    $(`#toggle-to-${activeSelector}-mg`).addClass('active');
    $(`#toggle-to-${inactiveSelector}-mg`).removeClass('active');

    bindToggleButtons();
  });
}

$(document).on('turbolinks:load', function () {
  bindToggleButtons();
});