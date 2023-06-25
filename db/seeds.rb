players = []

# **** user & player作成 *******************************************************
4.times do |n|
  user = User.create(email: "test#{n+1}@example.com", password: '00000000', password_confirmation: '00000000', name: "テストユーザー##{n+1}")
  user.build_player(name: "テストユーザー##{n+1}").save
  players << user.player
end

# **** ルール登録 *******************************************************
Rule.create(player_id: players[0].id,
            name: 'ヨンマルール1', 
            mochi: 25000, 
            kaeshi: 30000,
            uma_1: 30,
            uma_2: 10,
            uma_3: -10,
            uma_4: -30,
            score_decimal_point_calc: 1,
            is_chip: 0,
            play_type: 4)
              
Rule.create(player_id: players[0].id,
            name: 'ヨンマルール2', 
            mochi: 25000, 
            kaeshi: 30000,
            uma_1: 20,
            uma_2: 10,
            uma_3: -10,
            uma_4: -20,
            score_decimal_point_calc: 2,
            is_chip: 1,
            chip_rate: 2,
            play_type: 4)
            
Rule.create(player_id: players[0].id,
            name: 'サンマルール', 
            mochi: 35000, 
            kaeshi: 40000,
            uma_1: 30,
            uma_2: 0,
            uma_3: -30,
            uma_4: 0,
            score_decimal_point_calc: 2,
            is_chip: 0,
            play_type: 3)

# **** 成績登録 (4マ)*******************************************************
scores = [ 31500, 27000, 23000, 18500]
points = [ 50, 7, -17, -40]
ies = [ 1, 2, 3, 4]
ranks = [1, 2, 3, 4]

mg = MatchGroup.create(rule_id: players[0].rules.first.id)
  
4.times do |i|
  m = Match.create(player_id: players[0].id,
               rule_id: players[0].rules.first.id,
               match_on: Date.today,
               play_type: 4,
               match_group_id: mg.id)
               
  4.times do |k|
    Result.create(match_id: m.id, 
                  player_id: players[k].id,
                  score: scores[k],
                  point: points[k],
                  ie: ies[k],
                  rank: ranks[k])
  end
  scores << scores.shift
  points << points.shift
  ies << ies.shift
  ranks << ranks.shift
end
# **** 成績登録 (3マ)*******************************************************
scores = [ 45000, 35000, 25000]
points = [ 50, -5, -35]
ies = [ 1, 2, 3]
ranks = [1, 2, 3]

mg = MatchGroup.create(rule_id: players[0].rules.last.id)
  
3.times do |i|
  m = Match.create(player_id: players[0].id,
               rule_id: players[0].rules.last.id,
               match_on: Date.today,
               play_type: 3,
               match_group_id: mg.id)
               
  3.times do |k|
    Result.create(match_id: m.id, 
                  player_id: players[k].id,
                  score: scores[k],
                  point: points[k],
                  ie: ies[k],
                  rank: ranks[k])
  end
  scores << scores.shift
  points << points.shift
  ies << ies.shift
  ranks << ranks.shift
end