// ● チップの合計枚数を計算し、注意メッセージを表示する
function calcTotalTip() {
  let tipNum = [];
  $('[id*="tip_number_"]').each(function() {
    tipNum.push($(this).val());
  });

  let tipTotalNum = tipNum.filter(v => v).reduce(function(sum, element){
    return sum + parseInt(element, 10);
  }, 0);

  if (tipTotalNum === 0) {
    $('#tip_total_warning').css('visibility', 'hidden');
  } else {
    $('#tip_total_warning').css('visibility', 'visible');
  }
  return tipTotalNum;
}


$(document).on('turbolinks:load', function () {
  // ページ読み込み時にチップ合計枚数を計算
  calcTotalTip();
  // チップ枚数入力時にチップ合計枚数を計算
  $('[id*="tip_number_"]').on('input', calcTotalTip);
  // チップ登録ボタンクリック時にチップ合計枚数がゼロでない場合、確認メッセージ出力
  $('#tip_create_btn').on('click', function() {
    let totalTip = calcTotalTip()
    if (totalTip !== 0) {
      if (!window.confirm('チップ合計枚数が0ではありません。登録しますか？')) {
        return false;
      }
    }
  });
});
