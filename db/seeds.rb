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
    # binding.pry
    u = User.create(email: user[:email],
                    password: user[:password],
                    password_confirmation: user[:password_confirmation],
                    name: user[:name])
    u.build_player(name: u.name).save
    players_1 << u.player
    players_2 << u.player if i == 0    
  end
end

# users.each do |user|
#   binding.pry
#   user.build_player(name: user.name[:name]).save
#   players_1 << user.player
#   players_2 << user.player if n == 0
# end
# 4.times do |n|
#   user = User.find_or_create_by({email: "test#{n+1}@example.com", password: '00000000', password_confirmation: '00000000', name: "テストユーザー##{n+1}"})
#   user.build_player(name: "テストユーザー##{n+1}").save
#   players_1 << user.player
#   players_2 << user.player if n == 0
# end
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