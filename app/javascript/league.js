$(document).on('turbolinks:load', function () {

  // リーグ詳細の明細全体をリンクにする
  $(document).ready(function() {
    $('tr[data-href]').on('click', function() {
      window.location = $(this).data('href');
    });
  });

});

// <leagueフォーム> ルール新規登録ボタンをクリックしたら入力されているリーグ名をセッションへ格納
$(document).on('click', '#rule_link', function() {
  var leagueName = document.querySelector('#league_name').value;
  console.log(leagueName);
  window.sessionStorage.setItem(['league_name'],[leagueName]);
});

// <leagueフォーム> ページ読み込み時にセッションに格納されているリーグ名を表示
document.addEventListener('DOMContentLoaded', function() {
  var leagueName = window.sessionStorage.getItem('league_name');
  if (leagueName) {
    document.querySelector('#league_name').value = leagueName;
    // セッションに格納されているリーグ名を削除
    window.sessionStorage.removeItem('league_name');
  }
});