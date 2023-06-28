
[1mFrom:[0m /home/ec2-user/environment/mahjong_score_management_app/app/controllers/matches_controller.rb:17 MatchesController#new:

    [1;34m12[0m: [32mdef[0m [1;34mnew[0m
    [1;34m13[0m:   [32munless[0m session_players_num == [1;34m3[0m || session_players_num == [1;34m4[0m
    [1;34m14[0m:     redirect_to root_path, [35mflash[0m: {[35malert[0m: [31m[1;31m'[0m[31mプレイヤーが選択されていません[1;31m'[0m[31m[0m} [32mand[0m [32mreturn[0m 
    [1;34m15[0m:   [32mend[0m
    [1;34m16[0m:   binding.pry
 => [1;34m17[0m:   @match = [1;34;4mMatch[0m.new
    [1;34m18[0m:   @match.play_type = session_players_num
    [1;34m19[0m:   @players = session[[33m:players[0m]
    [1;34m20[0m:   session_players_num.times { @match.results.build }
    [1;34m21[0m:   gon.is_recording = recording?
    [1;34m22[0m: [32mend[0m

