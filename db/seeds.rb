users = [
  {email: 'user1@example.com', password: '00000000', password_confirmation: '00000000', name: "テストユーザー#1"},
  {email: 'user2@example.com', password: '00000000', password_confirmation: '00000000', name: "テストユーザー#2"},
  {email: 'user3@example.com', password: '00000000', password_confirmation: '00000000', name: "テストユーザー#3"},
  {email: 'user4@example.com', password: '00000000', password_confirmation: '00000000', name: "テストユーザー#4"}
]
  
  players_1 = []
  players_2 = []
  
# **** user & player作成 *******************************************************
users.each_with_index do |user, i|
  user_data = User.find_by(email: user[:email])
  if user_data.nil?
    u = User.create(email: user[:email],
                    password: user[:password],
                    password_confirmation: user[:password_confirmation],
                    name: user[:name])
    u.build_player(name: u.name).save
    players_1 << u.player
    players_2 << u.player if i == 0
  end
end

# **** player作成 *******************************************************
4.times do |n|
  player = Player.find_or_create_by(name: "テストプレイヤー##{n+1}")
  players_2 << player if n <= 2
end

# **** ルール登録 *******************************************************
Rule.find_or_create_by({player_id: players_1[0].id,
                        name: 'ヨンマルール1', 
                        mochi: 25000, 
                        kaeshi: 30000,
                        uma_1: 30,
                        uma_2: 10,
                        uma_3: -10,
                        uma_4: -30,
                        score_decimal_point_calc: 1,
                        is_chip: 0,
                        play_type: 4})
              
Rule.find_or_create_by({player_id: players_1[0].id,
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
                        play_type: 4})
                        
Rule.find_or_create_by({player_id: players_1[0].id,
                        name: 'サンマルール', 
                        mochi: 35000, 
                        kaeshi: 40000,
                        uma_1: 30,
                        uma_2: 0,
                        uma_3: -30,
                        uma_4: 0,
                        score_decimal_point_calc: 2,
                        is_chip: 0,
                        play_type: 3})

# **** 成績登録 (4マ)*******************************************************
scores = [ 31500, 27000, 23000, 18500]
points = [ 50, 7, -17, -40]
ies = [ 1, 2, 3, 4]
ranks = [1, 2, 3, 4]

mg = MatchGroup.create({rule_id: players_1[0].rules.first.id})
  
4.times do |i|
  m = Match.create({player_id: players_1[0].id,
                   rule_id: players_1[0].rules.first.id,
                   match_on: Date.today,
                   play_type: 4,
                   match_group_id: mg.id})
  4.times do |k|
    Result.create({match_id: m.id, 
                  player_id: players_1[k].id,
                  score: scores[k],
                  point: points[k],
                  ie: ies[k],
                  rank: ranks[k]})
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

mg = MatchGroup.create({rule_id: players_1[0].rules.last.id})
  
3.times do |i|
  m = Match.create({player_id: players_1[0].id,
                   rule_id: players_1[0].rules.last.id,
                   match_on: Date.today,
                   play_type: 3,
                   match_group_id: mg.id})
               
  3.times do |k|
    Result.create({match_id: m.id, 
                  player_id: players_1[k].id,
                  score: scores[k],
                  point: points[k],
                  ie: ies[k],
                  rank: ranks[k]})
  end
  scores << scores.shift
  points << points.shift
  ies << ies.shift
  ranks << ranks.shift
end
# **** 成績登録 (4マ)*******************************************************
scores = [ 31500, 27000, 23000, 18500]
points = [ 50, 7, -17, -40]
ies = [ 1, 2, 3, 4]
ranks = [1, 2, 3, 4]

mg = MatchGroup.create({rule_id: players_2[0].rules.first.id})
  
4.times do |i|
  m = Match.create({player_id: players_2[0].id,
                   rule_id: players_2[0].rules.first.id,
                   match_on: Date.today,
                   play_type: 4,
                   match_group_id: mg.id})
               
  4.times do |k|
    Result.create({match_id: m.id, 
                  player_id: players_2[k].id,
                  score: scores[k],
                  point: points[k],
                  ie: ies[k],
                  rank: ranks[k]})
  end
  scores << scores.shift
  points << points.shift
  ies << ies.shift
  ranks << ranks.shift
end
# **** リーグ登録 (4マ)*******************************************************
league = League.create({player_id: players_1[0].id,
                        rule_id: players_1[0].rules.first.id,
                        name: "テストリーグ",
                        play_type: 4,
                        description: "これはテストリーグです"
                      })

4.times do |i|
  LeaguePlayer.create!({league_id: league.id,
                      player_id: players_1[i].id})
end

# **** リーグ成績登録 #1 *******************************************************
scores = [ 31500, 27000, 23000, 18500]
points = [ 50, 7, -17, -40]
ies = [ 1, 2, 3, 4]
ranks = [1, 2, 3, 4]

mg = MatchGroup.create({rule_id: players_1[0].rules.first.id, league_id: league.id })
                        
4.times do |i|
  m = Match.create({player_id: players_1[0].id,
                   rule_id: players_1[0].rules.first.id,
                   match_on: Date.today - 2,
                   play_type: 4,
                   match_group_id: mg.id})
               
  4.times do |k|
    Result.create({match_id: m.id, 
                  player_id: players_1[k].id,
                  score: scores[k],
                  point: points[k],
                  ie: ies[k],
                  rank: ranks[k]})
  end
  if i < 2 # 対局結果を均一にしないため
    scores << scores.shift
    points << points.shift
    ies << ies.shift
    ranks << ranks.shift
  end
end
# **** リーグ成績登録 #2 *******************************************************
scores = [ 34500, 23900, 19300, 22300]
points = [ 54.5, 3.9, -40.7, -17.7]
ies = [ 1, 2, 3, 4]
ranks = [1, 2, 4, 3]

mg = MatchGroup.create({rule_id: players_1[0].rules.first.id, league_id: league.id })
                        
4.times do |i|
  m = Match.create({player_id: players_1[0].id,
                   rule_id: players_1[0].rules.first.id,
                   match_on: Date.today - 1 ,
                   play_type: 4,
                   match_group_id: mg.id})
               
  4.times do |k|
    Result.create({match_id: m.id, 
                  player_id: players_1[k].id,
                  score: scores[k],
                  point: points[k],
                  ie: ies[k],
                  rank: ranks[k]})
  end
  
  scores << scores.shift
  points << points.shift
  ies << ies.shift
  ranks << ranks.shift
end

# **** リーグ成績登録 #3 *******************************************************
scores = [ 9100, 34900, 19800, 13900]
points = [ -50.9, 77.2, -0.2, -26.1]
ies = [ 1, 2, 3, 4]
ranks = [4, 1, 2, 3]

mg = MatchGroup.create({rule_id: players_1[0].rules.first.id, league_id: league.id })
                        
4.times do |i|
  m = Match.create({player_id: players_1[0].id,
                   rule_id: players_1[0].rules.first.id,
                   match_on: Date.today,
                   play_type: 4,
                   match_group_id: mg.id})
               
  4.times do |k|
    Result.create({match_id: m.id, 
                  player_id: players_1[k].id,
                  score: scores[k],
                  point: points[k],
                  ie: ies[k],
                  rank: ranks[k]})
  end
  
  if i > 1 # 対局結果を均一にしないため
    scores << scores.shift
    points << points.shift
    ies << ies.shift
    ranks << ranks.shift
  end
end