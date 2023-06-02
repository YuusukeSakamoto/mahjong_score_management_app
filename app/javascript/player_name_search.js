$(document).on('turbolinks:load', function () { 
  $(function () {
    $('#form_player_collection_players_attributes_0_id').blur(function () {
      //  フォームからフォーカスを外したタイミングで以下の処理を実行する
      var id = $.trim($(this).val());
      $.ajax({
        type: 'GET', // リクエストのタイプ
        url: '/players/searches', // リクエストを送信するURL
        data:  { id: id }, // サーバーに送信するデータ
        dataType: 'json' // サーバーから返却される型
      })
      // 正常にデータを受け取れた際の処理
      .done(function(data) {
        $("#form_player_collection_players_attributes_0_name").val(data.name)　//nameをセットする
        
      })
      .fail(function(){
        //通信に失敗した際の処理
        $("#form_player_collection_players_attributes_0_name").val("") //空白をセットする
      })
    })
  
    
    $('#form_player_collection_players_attributes_1_id').blur(function () {
      //  フォームからフォーカスを外したタイミングで以下の処理を実行する
      var id = $.trim($(this).val());
      $.ajax({
        type: 'GET', // リクエストのタイプ
        url: '/players/searches', // リクエストを送信するURL
        data:  { id: id }, // サーバーに送信するデータ
        dataType: 'json' // サーバーから返却される型
      })
      // 正常にデータを受け取れた際の処理
      .done(function(data) {
        $("#form_player_collection_players_attributes_1_name").val(data.name)　//nameをセットする
        
      })
      .fail(function(){
        //通信に失敗した際の処理
        $("#form_player_collection_players_attributes_1_name").val("")//空白をセットする
      })
    })
    
    $('#form_player_collection_players_attributes_2_id').blur(function () {
      //  フォームからフォーカスを外したタイミングで以下の処理を実行する
      var id = $.trim($(this).val());
      $.ajax({
        type: 'GET', // リクエストのタイプ
        url: '/players/searches', // リクエストを送信するURL
        data:  { id: id }, // サーバーに送信するデータ
        dataType: 'json' // サーバーから返却される型
      })
      // 正常にデータを受け取れた際の処理
      .done(function(data) {
        $("#form_player_collection_players_attributes_2_name").val(data.name)　//nameをセットする
        
      })
      .fail(function(){
        //通信に失敗した際の処理
        $("#form_player_collection_players_attributes_2_name").val("") //空白をセットする
      })
    })
  
    $('#form_player_collection_players_attributes_3_id').blur(function () {
      //  フォームからフォーカスを外したタイミングで以下の処理を実行する
      var id = $.trim($(this).val());
      $.ajax({
        type: 'GET', // リクエストのタイプ
        url: '/players/searches', // リクエストを送信するURL
        data:  { id: id }, // サーバーに送信するデータ
        dataType: 'json' // サーバーから返却される型
      })
      // 正常にデータを受け取れた際の処理
      .done(function(data) {
        $("#form_player_collection_players_attributes_3_name").val(data.name)　//nameをセットする
        
      })
      .fail(function(){
        //通信に失敗した際の処理
        $("#form_player_collection_players_attributes_3_name").val("") //空白をセットする
      })
    })
  });
}); 