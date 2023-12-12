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
require("match_form.js")  // ←jsファイル分だけ追加する
require("global_menu.js")
require("dropdown_menu.js")
require("rule_form_change.js")
require("player_select.js")
require("flash.js")
require("user_form.js")
require("questions.js")
require("switch_play_type.js")
require("league.js")
require("match_group.js")

Rails.start()
Turbolinks.start()
ActiveStorage.start()