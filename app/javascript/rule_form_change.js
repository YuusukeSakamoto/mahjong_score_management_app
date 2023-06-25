$(document).on('turbolinks:load', function () { 
  $(function () {
    // ページが読み込まれたら
    $(document).ready(function () {
      let is_recording = gon.is_recording
      // 成績登録中はルールを固定する
      if (is_recording) {
        $('#match_rule_id').css('pointer-events', 'none');
        $('#match_rule_id').attr('tabindex', '-1');
      }
      let play_type = $('#rule_play_type').val();
      if (play_type === '3') {
        // 三人麻雀の場合はウマ4位を非表示にし、値0とする
        $('.js-uma_4').removeClass('d-block');
        $('.js-uma_4').addClass('d-none');
        $('#rule_uma_1').attr('placeholder', '+20');
        $('#rule_uma_2').attr('placeholder', '0');
        $('#rule_uma_3').attr('placeholder', '-20');
        $('#rule_uma_4').val(0);
        
      } else if (play_type === '4') {
        $('.js-uma_4').removeClass('d-none');
        $('.js-uma_4').addClass('d-black');
        $('#rule_uma_1').attr('placeholder', '+20');
        $('#rule_uma_2').attr('placeholder', '+10');
        $('#rule_uma_3').attr('placeholder', '-10');      
        $('#rule_uma_4').attr('placeholder', '-20'); 
      }
    });
    // 変更があったら
    $('#rule_play_type').change(function () {
      let play_type = $('#rule_play_type').val();
      if (play_type === '3') { 
        // 三人麻雀の場合はウマ4位を非表示にし、値0とする
        $('.js-uma_4').removeClass('d-block');
        $('.js-uma_4').addClass('d-none');
        $('#rule_uma_1').attr('placeholder', '+20');
        $('#rule_uma_2').attr('placeholder', '0');
        $('#rule_uma_3').attr('placeholder', '-20');
        $('#rule_uma_4').val(0);
      } else if (play_type === '4') {
        $('#rule_uma_4').val('');
        $('.js-uma_4').removeClass('d-none');
        $('.js-uma_4').addClass('d-black');
        $('#rule_uma_1').attr('placeholder', '+20');
        $('#rule_uma_2').attr('placeholder', '+10');
        $('#rule_uma_3').attr('placeholder', '-10');      
        $('#rule_uma_4').attr('placeholder', '-20');      
      }
    });
  });
});