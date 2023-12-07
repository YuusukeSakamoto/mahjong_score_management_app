// リーグ詳細の明細全体をリンクにする
$(document).ready(function() {
  $('tr[data-href]').on('click', function() {
    window.location = $(this).data('href');
  });
});
