$(document).on('turbolinks:load', function () {
  $('#share-link').on('click', function() {
    var url = this.dataset.url;
    var tempInput = document.createElement('input');
    tempInput.value = url;
    document.body.appendChild(tempInput);
    tempInput.select();
    document.execCommand('copy');
    document.body.removeChild(tempInput);
    alert('リンクをコピーしました！');
  });
})