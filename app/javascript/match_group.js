$(document).on('turbolinks:load', function () {

  // 成績表の明細全体をリンクにする
  $(document).ready(function() {
    $('td[data-href]').on('click', function() {
      window.location = $(this).data('href');
    });
  });

});