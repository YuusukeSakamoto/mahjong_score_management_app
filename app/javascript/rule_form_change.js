$(document).on('turbolinks:load', function () { 
  let play_type = $('#rule_play_type').val();
  if (play_type === '3') {
    // 三人麻雀の場合はウマ4位を非表示にし、値0とする
    $('.js-uma_four').removeClass('d-block');
    $('.js-uma_four').addClass('d-none');
    $('#rule_uma_one').attr('placeholder', '+20');
    $('#rule_uma_two').attr('placeholder', '0');
    $('#rule_uma_three').attr('placeholder', '-20');
    $('#rule_uma_four').val(0);
    
  } else if (play_type === '4') {
    $('.js-uma_four').removeClass('d-none');
    $('.js-uma_four').addClass('d-black');
    $('#rule_uma_one').attr('placeholder', '+20');
    $('#rule_uma_two').attr('placeholder', '+10');
    $('#rule_uma_three').attr('placeholder', '-10');      
    $('#rule_uma_four').attr('placeholder', '-20'); 
  }
  // 変更があったら
  $('#rule_play_type').change(function () {
    let play_type = $('#rule_play_type').val();
    if (play_type === '3') { 
      // 三人麻雀の場合はウマ4位を非表示にし、値0とする
      $('.js-uma_four').removeClass('d-block');
      $('.js-uma_four').addClass('d-none');
      $('#rule_uma_one').attr('placeholder', '+20');
      $('#rule_uma_two').attr('placeholder', '0');
      $('#rule_uma_three').attr('placeholder', '-20');
      $('#rule_uma_four').val(0);
    } else if (play_type === '4') {
      $('#rule_uma_four').val('');
      $('.js-uma_four').removeClass('d-none');
      $('.js-uma_four').addClass('d-black');
      $('#rule_uma_one').attr('placeholder', '+20');
      $('#rule_uma_two').attr('placeholder', '+10');
      $('#rule_uma_three').attr('placeholder', '-10');      
      $('#rule_uma_four').attr('placeholder', '-20');      
    }
  });
});