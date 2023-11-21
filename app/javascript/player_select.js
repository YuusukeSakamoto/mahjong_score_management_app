// プレイヤー選択における選択したプレイヤーの追加を行う
$(document).ready(function() { 
  // 読み込み時
  let selectedPlayers_str = sessionStorage.getItem('selected_players'); // jsセッション情報取得
  let selectedPlayers = JSON.parse(selectedPlayers_str); // 文字列→配列変換
  
  if (selectedPlayers === "[]" || selectedPlayers === null) {
    selectedPlayers = [];
  } else {
    // jsセッション情報があればプレイヤー選択している状態にする
    var $selectedPlayersContainer = $('.selected_players');
    
    selectedPlayers.forEach(function(player) {
      var $playerItem = $(
        `<div class="selected_players-item">
           <span>${player[1]}</span>
           <i class='bx bx-trash player-delete-2'></i>
           <div class="p_id" style="display: none">${player[0]}</div>
         </div>`
      );
      
      $selectedPlayersContainer.append($playerItem);
    });
  }
  
  // プレイヤー選択数の上限を設定
  let playerCount = $('.player-count').text();
  let maxPlayers = Number(playerCount);
  
  add_params(); // セッション格納分のプレイヤー情報をparamsに追加
  updateCreateButtonActivation(); // 決定ボタン状態の初期設定をする

  // プレイヤーを選択肢から選択する処理
  $('.players_list-item').click(function () {
    let p_name = $(this).find(".p_name").text();
    let p_id = $(this).find(".p_id").text();
      // 選択プレイヤー上限数をチェック
    if ($(".selected_players-item").length >= maxPlayers) {
      // 選択制限に達した場合、何もしないかエラーメッセージを表示
      alert('上限に達しているため追加できません');
      return;
    }

    add_players(p_name, p_id);
    add_params();
    updateCreateButtonActivation();

  });
  
  // プレイヤー新規作成処理
  $('.create_players button').click(function () {
    if ($(".selected_players-item").length >= maxPlayers) {
      // 人数制限に達した場合、何もしないかエラーメッセージを表示
      alert('上限に達しているため追加できません');
      return;
    }
    let newPlayerName = $('.create_players input').val().trim(); // 前後の空白を削除
    if (newPlayerName === "") {
      // 入力が空白の場合はエラーメッセージを表示するか、処理を中断できます
      alert('プレイヤー名を入力してください。');
      return;
    }
    add_players(newPlayerName, 0);
    add_params();
    updateCreateButtonActivation();
    $('.create_players input').val(''); // inputを空にする
  });
  
  // プレイヤー選択解除処理① - 追加したアカウント登録済みプレイヤーを削除する場合
  //  → プレイヤー情報はコントローラーで取得しているためセッションは更新しない
  $('.selected_players').on('click', '.player-delete-1', function () {
    $(this).parent().remove();
    updateCreateButtonActivation(); // 決定ボタン更新
  });  
  
  // プレイヤー選択解除処理２- 過去遊んだプレイヤーor新規登録プレイヤーを削除する場合
  //  → プレイヤー情報をセッションに格納しているため,セッションは更新する
  $('.selected_players').on('click', '.player-delete-2', function () {
    let clickedIndex = $(this).index('.player-delete-2'); // クリックされた要素のindex
    selectedPlayers.splice(clickedIndex, 1); //クリックされたindexのプレイヤーを削除
    sessionStorage['selected_players'] = JSON.stringify(selectedPlayers); //セッション更新
    
    $(this).parent().remove();
    updateCreateButtonActivation(); // 決定ボタン更新
  });
  
  // プレイヤー決定したらセッションをクリアする'
  $('#create_btn').click(function () {
    sessionStorage.clear();
  });
  
  //  ******** 関数 **************** //

  function add_players(selected_player_name, p_id){
    let id = Number(p_id);
    
    let ids = selectedPlayers.map(selectedPlayer => selectedPlayer[0]);
    // 選択済みのプレイヤーをチェック
    if (($.inArray(id, ids) !== -1) && (id !== 0)) {
      // // すでに選択済みの場合、何もしない
    } else {
      // 未選択の場合、選択プレイヤーに追加
      selectedPlayers.push([id, selected_player_name]);
      sessionStorage['selected_players'] = JSON.stringify(selectedPlayers); //セッション更新
      $('.selected_players').append(
        `<div class="selected_players-item">
          <span>${selected_player_name}</span>
          <i class='bx bx-trash player-delete-2'></i>
          <div class="p_id" style="display: none">${p_id}</div>
        </div>`
      );
    }
  }
  
  function add_params() {
    
    // 最初に#create_btn内のすべてのinput要素を削除
    $('#create_btn').find('input').remove();

    // プレイヤー人数になったら#create_btnにparamsを追加
    if ($('.selected_players-item').length === maxPlayers) {

      let selectedPlayerNames = [];
      let selectedPlayerIds = [];
      
      // "selected_players-item" クラスを持つすべての要素をループ
      $(".selected_players-item").each(function() {
          let playerName = $(this).find("span").text();
          let playerId = $(this).find(".p_id").text();
          selectedPlayerNames.push(playerName);
          selectedPlayerIds.push(playerId);
      });
      for (var i = 0; i < selectedPlayerIds.length; i++) {
        $('#create_btn').append(
          `<input type="hidden" name="p_ids[]" value="${selectedPlayerIds[i]}" autocomplete="off">`
        );
      }
      
      for (var i = 0; i < selectedPlayerNames.length; i++) {
        $('#create_btn').append(
          `<input type="hidden" name="p_names[]" value="${selectedPlayerNames[i]}" autocomplete="off">`
        );
      }
    };
  }
  
  function updateCreateButtonActivation() {
    // プレイヤー人数が上限に達している場合に#create_btnをアクティブにするか非アクティブにする
    if ($('.selected_players-item').length === maxPlayers) {
      $('#create_btn').prop('disabled', false).removeClass('inactive');
    } else {
      $('#create_btn').prop('disabled', true).addClass('inactive');
    }
  }

});
