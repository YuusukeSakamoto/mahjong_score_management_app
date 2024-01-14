$(document).on('turbolinks:load', function () {
  $('#modal-icon-league').on('click', function() {
    $('#league-modal').modal('show');
  });
})