$(document).on('turbolinks:load', function () { 
  $(document).ready(function() {
    $('.faq-question').on('click', function() {
      $(this).next('.faq-answer').slideToggle(200);
      $(this).children('.fa').toggleClass('fa-chevron-down fa-chevron-up');
    });
  });
})