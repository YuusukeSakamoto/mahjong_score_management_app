$(document).on('turbolinks:load', function () { 
  $(function () {
    // ページが読み込まれたら
    $(document).ready(function () {
      let player_num = $('#rule_player_num').val();
      if (player_num === '3') {
        // 三人麻雀の場合はウマ4位を非表示にし、値0とする
        $('.js-uma_4').removeClass('d-block');
        $('.js-uma_4').addClass('d-none');
        $('#rule_uma_1').attr('placeholder', '+20');
        $('#rule_uma_2').attr('placeholder', '0');
        $('#rule_uma_3').attr('placeholder', '-20');
        $('#rule_uma_4').val(0);
        
      } else if (player_num === '4') {
        $('.js-uma_4').removeClass('d-none');
        $('.js-uma_4').addClass('d-black');
        $('#rule_uma_1').attr('placeholder', '+20');
        $('#rule_uma_2').attr('placeholder', '+10');
        $('#rule_uma_3').attr('placeholder', '-10');      
        $('#rule_uma_4').attr('placeholder', '-20'); 
      }
    });
    // 変更があったら
    $('#rule_player_num').change(function () {
      let player_num = $('#rule_player_num').val();
      if (player_num === '3') { 
        // 三人麻雀の場合はウマ4位を非表示にし、値0とする
        $('.js-uma_4').removeClass('d-block');
        $('.js-uma_4').addClass('d-none');
        $('#rule_uma_1').attr('placeholder', '+20');
        $('#rule_uma_2').attr('placeholder', '0');
        $('#rule_uma_3').attr('placeholder', '-20');
        $('#rule_uma_4').val(0);
      } else if (player_num === '4') {
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