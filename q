
[1mFrom:[0m /home/ec2-user/environment/mahjong_score_management_app/app/models/player.rb:261 Player#point_history_data:

    [1;34m249[0m: [32mdef[0m [1;34mpoint_history_data[0m(mg_ids = [])
    [1;34m250[0m:   points = []
    [1;34m251[0m:   points_history = [[1;34m0[0m]
    [1;34m252[0m:   
    [1;34m253[0m:   [32mif[0m mg_ids.present?
    [1;34m254[0m:     [1;34m# binding.pry[0m
    [1;34m255[0m:     [1;34m# リーグルールがチップ=有の場合[0m
    [1;34m256[0m:     mg_ids.each [32mdo[0m |mg_id|
    [1;34m257[0m:       match_chip_pt = results.where([35mmatch_id[0m: mg_id.matches.pluck([33m:id[0m)).pluck([33m:point[0m)
    [1;34m258[0m:       match_chip_pt << [1;34;4mChipResult[0m.find_by([35mplayer_id[0m: id, [35mmatch_group_id[0m: mg_id).point [1;34m# 該当プレイヤーのチップptを取得[0m
    [1;34m259[0m:       points.concat(match_chip_pt) [1;34m# 配列の各要素を整数として配列に追加する[0m
    [1;34m260[0m:       binding.pry
 => [1;34m261[0m:     [32mend[0m
    [1;34m262[0m:   [32melse[0m
    [1;34m263[0m:     [1;34m# リーグルールがチップ=無の場合[0m
    [1;34m264[0m:     points = results.where([35mmatch_id[0m: match_ids).pluck([33m:point[0m)
    [1;34m265[0m:     binding.pry
    [1;34m266[0m:   [32mend[0m
    [1;34m267[0m:   
    [1;34m268[0m:   points.each [32mdo[0m |point|
    [1;34m269[0m:     points_history << (points_history[[1;34m-1[0m] + point).round([1;34m1[0m)
    [1;34m270[0m:   [32mend[0m
    [1;34m271[0m:   points_history
    [1;34m272[0m:   [1;34m# binding.pry[0m
    [1;34m273[0m: [32mend[0m

