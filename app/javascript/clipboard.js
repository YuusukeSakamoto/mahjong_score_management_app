$(document).on('turbolinks:load', function () {
  $('#share-link').on('click', function() {
    var url = this.dataset.url;
    var tempInput = document.createElement('input');
    tempInput.value = url;
    document.body.appendChild(tempInput);
    tempInput.select();
    document.execCommand('copy');
    document.body.removeChild(tempInput);

    // リンクアイコンを非表示にする
    var linkIcon = document.querySelector('.fa-link');
    linkIcon.classList.add('hidden');
    // チェックマークアイコンを表示する
    var checkIcon = document.querySelector('.fa-check');
    checkIcon.classList.remove('hidden');
  });
})