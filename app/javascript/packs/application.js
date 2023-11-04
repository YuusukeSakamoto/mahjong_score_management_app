// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//= require clipboard

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
require("jquery")  // ←jquery使えるようにする1行を追加
require("player_name_search.js")  // ←jsファイル分だけ追加する
require("point_calculate.js")  // ←jsファイル分だけ追加する
require("rule_search.js")  // ←jsファイル分だけ追加する
require("remaining_score_calculate.js")  // ←jsファイル分だけ追加する
require("global_menu.js")
require("dropdown_menu.js")
require("rule_form_change.js")
require("player_select.js")

Rails.start()
Turbolinks.start()
ActiveStorage.start()

$(function(){
  setTimeout("$('.flash').fadeOut('slow')", 2000);
});