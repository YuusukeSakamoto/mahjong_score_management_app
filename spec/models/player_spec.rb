require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'Player#validations' do
    context 'Player#nameが空白のとき' do
      it 'バリデーションエラーになること' do
        player = build(:player, name: nil)
        expect(player).not_to be_valid
        expect(player.errors[:name]).to include("を入力してください")
      end

    end

    context 'Player#nameが8文字より大きいとき' do
      it 'バリデーションエラーになること' do
        player = build(:player, name: 'a' * 9)
        expect(player).not_to be_valid
        expect(player.errors[:name]).to include('は8文字以内で入力してください')
      end
    end
  end

  # 四麻のデータ
  let(:players_4) { create_list(:player, 4) }
  let!(:rule_4) { create(:rule, player: players_4.first) }
  # 1戦目
  let!(:match_4_1) { create(:match, player: players_4.first, rule: rule_4, play_type: 4) }
  let!(:results_4_1) do
    players_4.each_with_index.map do |player, index|
      create(:result, match: match_4_1, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
    end
  end
  # 2戦目
  let!(:match_4_2) { create(:match, player: players_4.first, rule: rule_4, play_type: 4) }
  let!(:results_4_2) do
    players_4.each_with_index.map do |player, index|
      create(:result, match: match_4_2, player: player, score: 20000 + (5000 * index), point: -30 + (20 * index), ie: index + 1, rank: 4 - index)
    end
  end

  # 三麻のデータ
  let(:players_3) { create_list(:player, 3) }
  let!(:rule_3) { create(:rule, player: players_3.first, play_type: 3) }
  # 1戦目
  let!(:match_3_1) { create(:match, player: players_3.first, rule: rule_3, play_type: 3) }
  let!(:results_3_1) do
    players_3.each_with_index.map do |player, index|
      create(:result, match: match_3_1, player: player, score: 35000 - (5000 * index), point: 30 - (30 * index), ie: index + 1, rank: index + 1)
    end
  end
  # 2戦目
  let!(:match_3_2) { create(:match, player: players_3.first, rule: rule_3, play_type: 3) }
  let!(:results_3_2) do
    players_3.each_with_index.map do |player, index|
      create(:result, match: match_3_2, player: player, score: 35000 - (5000 * index), point: 30 - (30 * index), ie: index + 1, rank: index + 1)
    end
  end

  # matchゼロのプレイヤー
  let(:player_0) { create(:player) }

  describe 'Player#find_by_results' do
    it 'resultからplayerが取得できること' do
      players = Player.find_by_results(players_4[0].matches.first.results)
      expect(players).to contain_exactly(players_4[0].name, players_4[1].name, players_4[2].name, players_4[3].name)
    end
  end

  # ************************************
  # メインデータ
  # ************************************

  describe 'Player#total_match_count' do
    it 'playerの総対戦数を取得できること' do
      expect(players_4[0].total_match_count(3)).to eq(0)
      expect(players_4[0].total_match_count(4)).to eq(2)
      expect(players_3[0].total_match_count(3)).to eq(2)
      expect(players_3[0].total_match_count(4)).to eq(0)
    end
  end

  describe 'Player#results_for_matches' do
    it 'playerが参加したmatchのresultsの取得できること' do
      expect(players_4[0].results_for_matches(4)).to contain_exactly(results_4_1.first, results_4_2.first)
      expect(players_4[0].results_for_matches(3)).not_to contain_exactly(results_3_1.first, results_3_2.first)
      expect(players_3[0].results_for_matches(3)).to contain_exactly(results_3_1.first, results_3_2.first)
      expect(players_3[0].results_for_matches(4)).not_to contain_exactly(results_4_1.first, results_4_2.first)
    end
  end

  describe 'Player#match_ids_for_play_type' do
    it 'play_typeに基づいて適切なmatch_idsの配列に含まれること' do
      expect(players_4[0].match_ids_for_play_type(4)).to contain_exactly(match_4_1.id, match_4_2.id)
      expect(players_4[0].match_ids_for_play_type(3)).not_to contain_exactly(match_4_1.id, match_4_2.id)
      expect(players_3[0].match_ids_for_play_type(3)).to contain_exactly(match_3_1.id, match_3_2.id)
      expect(players_3[0].match_ids_for_play_type(4)).not_to contain_exactly(match_3_1.id, match_3_2.id)
    end
  end

  describe 'Player#get_sanyon_matches' do
    it '直近の対局データを5局取得できること' do
      players_3[0].match_ids_for_play_type(3)
      players_4[0].match_ids_for_play_type(4)
      expect(players_3[0].get_sanyon_matches(3)).to eq(Match.match_ids(players_3[0].match_ids, 3).desc.first(2))
      expect(players_3[0].get_sanyon_matches(3)).not_to eq(Match.match_ids(players_4[0].match_ids, 3).desc.first(2))
      expect(players_4[0].get_sanyon_matches(4)).to eq(Match.match_ids(players_4[0].match_ids, 4).desc.first(2))
      expect(players_4[0].get_sanyon_matches(4)).not_to eq(Match.match_ids(players_3[0].match_ids, 4).desc.first(2))
    end
  end

  describe 'Player#get_sanyon_match_ids' do
    it 'play_typeに基づくmatch_idsを取得できること' do
      players_3[0].match_ids_for_play_type(3)
      players_4[0].match_ids_for_play_type(4)
      expect(players_3[0].get_sanyon_match_ids(3)).to eq(players_3[0].matches.to_a)
      expect(players_3[0].get_sanyon_match_ids(3)).not_to eq(players_4[0].matches.to_a)
      expect(players_4[0].get_sanyon_match_ids(4)).to eq(players_4[0].matches.to_a)
      expect(players_4[0].get_sanyon_match_ids(4)).not_to eq(players_3[0].matches.to_a)
    end
  end

  describe 'Player#matches_present?' do
    let(:players) { create_list(:player, 4) }
    context '対戦数が1以上の場合' do
      before do
        play_type = 4
        rule_4 = create(:rule, player: players.first)
        match_4_1 = create(:match, player: players.first, rule: rule_4, play_type: play_type)
        results_4_1 = players.each_with_index.map do |player, index|
            create(:result, match: match_4_1, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
        end
        allow(players[0]).to receive(:results_for_matches).and_return(players[0].results.where(match_id: players[0].match_ids_for_play_type(play_type)))
      end
      it 'trueを返すこと' do
        expect(players[0].matches_present?).to be true
      end
    end

    context '対戦数が0の場合' do
      it 'falseを返すこと' do
        expect(players[0].matches_present?).to be false
      end
    end
  end

  describe 'Player#total_point' do
    it 'playerの総合ptを取得できること' do
      expect(players_3[0].total_point(3)).to eq("+60.0")
      expect(players_3[1].total_point(3)).to eq("0.0")
      expect(players_3[2].total_point(3)).to eq("-60.0")
      expect(players_4[0].total_point(4)).to eq("0.0")
      expect(players_4[1].total_point(4)).to eq("0.0")
      expect(players_4[2].total_point(4)).to eq("0.0")
      expect(players_4[3].total_point(4)).to eq("0.0")
    end
  end

  describe 'Player#average_rank' do
    before do
      setup_results_for_matches
    end
    it 'playerの平均順位を取得できること' do
      expect(players_3[0].average_rank).to eq('1.00')
      expect(players_3[1].average_rank).to eq('2.00')
      expect(players_3[2].average_rank).to eq('3.00')
      expect(players_4[0].average_rank).to eq('2.50')
      expect(players_4[1].average_rank).to eq('2.50')
      expect(players_4[2].average_rank).to eq('2.50')
      expect(players_4[3].average_rank).to eq('2.50')
    end
    it 'playerの対局数が０の場合はハイフンを返すこと' do
      expect(player_0.average_rank).to eq(' - ')
    end
  end

  describe 'Player#rentai_rate' do
    before do
      setup_results_for_matches
    end
    it 'playerの連対率を取得できること' do
      expect(players_3[0].rentai_rate).to eq('100.00')
      expect(players_3[1].rentai_rate).to eq('100.00')
      expect(players_3[2].rentai_rate).to eq('0.00')
      expect(players_4[0].rentai_rate).to eq('50.00')
      expect(players_4[1].rentai_rate).to eq('50.00')
      expect(players_4[2].rentai_rate).to eq('50.00')
      expect(players_4[3].rentai_rate).to eq('50.00')
    end
    it 'playerの対局数が0の場合はハイフンを返すこと' do
      expect(player_0.rentai_rate).to eq(' - ')
    end

  end

  describe 'Player#graph_rank_data' do
    before do
      players_3.each do |player|
        player.match_ids_for_play_type(3)
        allow(player).to receive(:get_sanyon_match_ids).and_return(Match.match_ids(player.match_ids, 3))
      end
      players_4.each do |player|
        player.match_ids_for_play_type(4)
        allow(player).to receive(:get_sanyon_match_ids).and_return(Match.match_ids(player.match_ids, 4))
      end
    end

    it '順位グラフ用データをセットできること' do
      expect(players_3[0].graph_rank_data(3)).to eq({3 => [1, 1, nil, nil, nil, nil, nil, nil, nil, nil,] })
      expect(players_3[1].graph_rank_data(3)).to eq({3 => [2, 2, nil, nil, nil, nil, nil, nil, nil, nil,] })
      expect(players_3[2].graph_rank_data(3)).to eq({3 => [3, 3, nil, nil, nil, nil, nil, nil, nil, nil,] })
      expect(players_4[0].graph_rank_data(4)).to eq({4 => [1, 4, nil, nil, nil, nil, nil, nil, nil, nil,] })
      expect(players_4[1].graph_rank_data(4)).to eq({4 => [2, 3, nil, nil, nil, nil, nil, nil, nil, nil,] })
      expect(players_4[2].graph_rank_data(4)).to eq({4 => [3, 2, nil, nil, nil, nil, nil, nil, nil, nil,] })
      expect(players_4[3].graph_rank_data(4)).to eq({4 => [4, 1, nil, nil, nil, nil, nil, nil, nil, nil,] })
    end
  end

  describe 'Player#add_null' do
    it 'rank_dataが10個未満の場合はnilで埋めること' do
      rank_data = [1, 2, 3]
      players_4[0].add_null(rank_data)
      expect(rank_data).to eq([1, 2, 3, nil, nil, nil, nil, nil, nil, nil])
    end
    it 'rank_dataが10個以上の場合はnilで埋めない' do
      rank_data = [1, 2, 3, 4, 1, 2, 3, 4, 1, 2]
      players_4[0].add_null(rank_data)
      expect(rank_data).to eq([1, 2, 3, 4, 1, 2, 3, 4, 1, 2])
    end
  end

  # ************************************
  # 順位別データ
  # ************************************
  describe '#rank_results' do
    let(:player) { Player.new }

    it '成績なしの場合、-と0を返すこと' do
      expect(player.rank_results(3)).to eq([[" - ", 0], [" - ", 0], [" - ", 0]])
      expect(player.rank_results(4)).to eq([[" - ", 0], [" - ", 0], [" - ", 0], [" - ", 0]])
    end

    it '成績ありで、三麻の場合配列が3つであること' do
      expect(players_3[0].rank_results(3).size).to eq(3)
      expect(players_3[1].rank_results(3).size).to eq(3)
      expect(players_3[2].rank_results(3).size).to eq(3)
    end

    it '成績ありで、四麻の場合配列が4つであること' do
      expect(players_4[0].rank_results(4).size).to eq(4)
      expect(players_4[1].rank_results(4).size).to eq(4)
      expect(players_4[2].rank_results(4).size).to eq(4)
      expect(players_4[3].rank_results(4).size).to eq(4)
    end
  end

  describe '#rank_rate' do
    let(:player) { Player.new }
    context 'when rank_times sum is zero' do
      before do
        allow(player).to receive(:rank_times).and_return([0, 0, 0, 0])
      end

      it '順位回数が0である場合、ハイフンを返すこと' do
        expect(player.rank_rate).to eq(Player::HYPHENS)
      end
    end

    context '順位回数が0でない場合、ハイフンを返すこと' do
      before do
        allow(player).to receive(:rank_times).and_return([1, 2, 3, 4])
        allow(player).to receive(:total_match_count).and_return(10)
      end

      it '順位率を返すこと' do
        expect(player.rank_rate).to eq(['10.0', '20.0', '30.0', '40.0'])
      end
    end
  end

  describe '#rank_times' do
    it '順位回数を返すこと' do
      expect(players_3[0].rank_times(3)).to eq([2, 0, 0, 0])
      expect(players_3[1].rank_times(3)).to eq([0, 2, 0, 0])
      expect(players_3[2].rank_times(3)).to eq([0, 0, 2, 0])
      expect(players_4[0].rank_times(4)).to eq([1, 0, 0, 1])
      expect(players_4[1].rank_times(4)).to eq([0, 1, 1, 0])
      expect(players_4[2].rank_times(4)).to eq([0, 1, 1, 0])
      expect(players_4[3].rank_times(4)).to eq([1, 0, 0, 1])
    end
  end


  # ************************************
  # 家別データ
  # ************************************
  let(:player) { Player.new }

  describe '#ie_results' do
    it '家別データを配列で返すこと' do
      expect(player.ie_results).to be_an_instance_of(Array)
    end

    it '家別データは配列で4つの要素であること' do
      expect(player.ie_results.size).to eq(4)
    end
  end

  describe '#average_rank_by_ie' do
    before do
      setup_results_for_matches
    end

    it '対局数が0の場合、家別の順位率をすべてハイフンの配列で返すこと' do
      expect(player.average_rank_by_ie).to eq([" - ", " - ", " - ", " - "])
    end

    it '家別の順位率を配列で返すこと' do
      expect(players_3[0].average_rank_by_ie).to eq(["1.0", " - ", " - ", " - "])
      expect(players_3[1].average_rank_by_ie).to eq([" - ", "2.0", " - ", " - "])
      expect(players_3[2].average_rank_by_ie).to eq([" - ", " - ", "3.0", " - "])
      expect(players_4[0].average_rank_by_ie).to eq(["2.5", " - ", " - ", " - "])
      expect(players_4[1].average_rank_by_ie).to eq([" - ", "2.5", " - ", " - "])
      expect(players_4[2].average_rank_by_ie).to eq([" - ", " - ", "2.5", " - "])
      expect(players_4[3].average_rank_by_ie).to eq([" - ", " - ", " - ", "2.5"])
    end
  end

  describe '#ie_times' do
    before do
      setup_results_for_matches
    end
    it '家の回数を配列で返すこと' do
      expect(players_3[0].ie_times).to eq([2, 0, 0, 0])
      expect(players_3[1].ie_times).to eq([0, 2, 0, 0])
      expect(players_3[2].ie_times).to eq([0, 0, 2, 0])
      expect(players_4[0].ie_times).to eq([2, 0, 0, 0])
      expect(players_4[1].ie_times).to eq([0, 2, 0, 0])
      expect(players_4[2].ie_times).to eq([0, 0, 2, 0])
      expect(players_4[3].ie_times).to eq([0, 0, 0, 2])
    end
  end

  describe '#total_point_by_ie' do
    before do
      setup_results_for_matches
    end

    it '家別のptを配列で返すこと' do
      expect(players_3[0].total_point_by_ie).to eq(["+60.0", "+0.0", "+0.0", "+0.0"])
      expect(players_3[1].total_point_by_ie).to eq(["+0.0", "+0.0", "+0.0", "+0.0"])
      expect(players_3[2].total_point_by_ie).to eq(["+0.0", "+0.0", "-60.0", "+0.0"])
      expect(players_4[0].total_point_by_ie).to eq(["+0.0", "+0.0", "+0.0", "+0.0"])
      expect(players_4[1].total_point_by_ie).to eq(["+0.0", "+0.0", "+0.0", "+0.0"])
      expect(players_4[2].total_point_by_ie).to eq(["+0.0", "+0.0", "+0.0", "+0.0"])
      expect(players_4[3].total_point_by_ie).to eq(["+0.0", "+0.0", "+0.0", "+0.0"])
    end
  end

  # ************************************
  # よく遊ぶプレイヤーデータ
  # ************************************
  let!(:main_player) { create(:player) }
  let!(:other_players) { create_list(:player, 6) }
  let!(:matches) { create_list(:match, 5, player: main_player, rule: rule_4, play_type: 4) }
  let!(:match_players) do
    [
      [main_player, other_players[4], other_players[3], other_players[2]],
      [main_player, other_players[4], other_players[3], other_players[2]],
      [main_player, other_players[4], other_players[3], other_players[2]],
      [main_player, other_players[4], other_players[3], other_players[1]],
      [main_player, other_players[4], other_players[1], other_players[0]]
    ]
  end
  let!(:results) do
    match_players.each_with_index do |players, match_index|
      players.each_with_index.map do |m_player, i|
        create(:result, match: matches[match_index], player: m_player, score: 35000 - (5000 * i), point: 30 - (20 * i), ie: i + 1, rank: i + 1)
      end
    end
  end
  describe '#often_play_times' do
    before do
      allow(main_player).to receive(:results_for_matches).and_return(main_player.results.where(match_id: main_player.match_ids_for_play_type(4)))
      allow(players_4[0]).to receive(:results_for_matches).and_return(players_4[0].results.where(match_id: players_4[0].match_ids_for_play_type(4)))
    end
    context 'よく遊ぶプレイヤーが5人以上いる場合' do
      it 'プレイヤー名と回数を返すこと' do
        often_play_players = main_player.often_play_times
        expect(often_play_players).to eq([
                                        [other_players[4].id, 5],
                                        [other_players[3].id, 4],
                                        [other_players[2].id, 3],
                                        [other_players[1].id, 2],
                                        [other_players[0].id, 1]])
      end
    end

    context 'よく遊ぶプレイヤーが5人未満の場合' do
      it 'ハイフンと0で配列を埋めて返すこと' do
        often_play_players = players_4[0].often_play_times
        expect(often_play_players.size).to eq(5)
        expect(often_play_players.count { |player_id, times| player_id == Player::HYPHEN && times == 0 }).to eq(2)
      end
    end
  end

  # ************************************
  # 最高得点・最低得点
  # ************************************
  describe '#max_score' do
    before do
      setup_results_for_matches
    end
    it '最高得点を返すこと' do
      expect(players_3[0].max_score(3)).to eq(35000)
      expect(players_3[1].max_score(3)).to eq(30000)
      expect(players_3[2].max_score(3)).to eq(25000)
      expect(players_4[0].max_score(4)).to eq(35000)
      expect(players_4[1].max_score(4)).to eq(30000)
      expect(players_4[2].max_score(4)).to eq(30000)
      expect(players_4[3].max_score(4)).to eq(35000)
    end
  end

  describe '#max_score_match_id' do
    before do
      setup_results_for_matches
    end
    it '最高得点のマッチIDを返すこと' do
      expect(players_3[0].max_score_match_id(3)).to eq(match_3_1.id)
      expect(players_3[1].max_score_match_id(3)).to eq(match_3_1.id)
      expect(players_3[2].max_score_match_id(3)).to eq(match_3_1.id)
      expect(players_4[0].max_score_match_id(4)).to eq(match_4_1.id)
      expect(players_4[1].max_score_match_id(4)).to eq(match_4_1.id)
      expect(players_4[2].max_score_match_id(4)).to eq(match_4_2.id)
      expect(players_4[3].max_score_match_id(4)).to eq(match_4_2.id)
    end
  end

  describe '#max_score_date' do
    before do
      setup_results_for_matches
    end
    it '最高得点のマッチの日付を返すこと' do
      expect(players_3[0].max_score_date(3)).to eq(match_3_1.match_on.to_s(:yeardate))
      expect(players_3[1].max_score_date(3)).to eq(match_3_1.match_on.to_s(:yeardate))
      expect(players_3[2].max_score_date(3)).to eq(match_3_1.match_on.to_s(:yeardate))
      expect(players_4[0].max_score_date(4)).to eq(match_4_1.match_on.to_s(:yeardate))
      expect(players_4[1].max_score_date(4)).to eq(match_4_1.match_on.to_s(:yeardate))
      expect(players_4[2].max_score_date(4)).to eq(match_4_2.match_on.to_s(:yeardate))
      expect(players_4[3].max_score_date(4)).to eq(match_4_2.match_on.to_s(:yeardate))
    end
  end

  describe '#min_score' do
    before do
      setup_results_for_matches
    end
    it '最低得点を返すこと' do
      expect(players_3[0].min_score(3)).to eq(35000)
      expect(players_3[1].min_score(3)).to eq(30000)
      expect(players_3[2].min_score(3)).to eq(25000)
      expect(players_4[0].min_score(4)).to eq(20000)
      expect(players_4[1].min_score(4)).to eq(25000)
      expect(players_4[2].min_score(4)).to eq(25000)
      expect(players_4[3].min_score(4)).to eq(20000)
    end
  end

  describe '#min_score_match_id' do
    before do
      setup_results_for_matches
    end
    it '最低得点のマッチIDを返すこと' do
      expect(players_3[0].min_score_match_id(3)).to eq(match_3_1.id)
      expect(players_3[1].min_score_match_id(3)).to eq(match_3_1.id)
      expect(players_3[2].min_score_match_id(3)).to eq(match_3_1.id)
      expect(players_4[0].min_score_match_id(4)).to eq(match_4_2.id)
      expect(players_4[1].min_score_match_id(4)).to eq(match_4_2.id)
      expect(players_4[2].min_score_match_id(4)).to eq(match_4_1.id)
      expect(players_4[3].min_score_match_id(4)).to eq(match_4_1.id)
    end

  end

  describe '#min_score_date' do
    before do
      setup_results_for_matches
    end
    it '最低得点のマッチの日付を返すこと' do
      expect(players_3[0].min_score_date(3)).to eq(match_3_1.match_on.to_s(:yeardate))
      expect(players_3[1].min_score_date(3)).to eq(match_3_1.match_on.to_s(:yeardate))
      expect(players_3[2].min_score_date(3)).to eq(match_3_1.match_on.to_s(:yeardate))
      expect(players_4[0].min_score_date(4)).to eq(match_4_2.match_on.to_s(:yeardate))
      expect(players_4[1].min_score_date(4)).to eq(match_4_2.match_on.to_s(:yeardate))
      expect(players_4[2].min_score_date(4)).to eq(match_4_1.match_on.to_s(:yeardate))
      expect(players_4[3].min_score_date(4)).to eq(match_4_1.match_on.to_s(:yeardate))
    end
  end

  # ************************************
  # ユーザー招待リンク用
  # ************************************
  describe '#create_invite_token' do
    let(:player) { create(:player) }
    it '招待トークンを発行し、DBに保存すること' do
      expect { player.create_invite_token }.to change { player.invite_token }.from(nil)
    end
  end

  describe '#invitation_players' do
    it 'current_playerが招待可能な全プレイヤーを取得すること' do
      players_4[0].cp = players_4[0]
      players_4[0].recorded_players
      expect(players_4[0].invitation_players.size).to eq(3)
    end
  end

  describe '#recorded_match_ids' do
    it 'current_playerが記録した対局idを配列で取得すること' do
      players_4[0].cp = players_4[0]
      expect(players_4[0].recorded_match_ids).to eq([match_4_1.id, match_4_2.id])
    end
  end

  describe '#recorded_players' do
    it 'current_playerが成績記録したプレイヤーを配列で取得すること' do
      players_4[0].cp = players_4[0]
      players_4[0].recorded_match_ids
      expect(players_4[0].recorded_players).to eq([players_4[1].id, players_4[2].id, players_4[3].id])
    end
  end
  # ************************************
  # 登録したルール
  # ************************************
  describe '#rule_list' do
    it '指定したplay_typeに一致するルールをすべて取得すること' do
      expect(players_4[0].rule_list(4)).to include(rule_4)
      expect(players_3[0].rule_list(3)).to include(rule_3)
      expect(players_4[0].rule_list(3)).not_to include(rule_3)
      expect(players_3[0].rule_list(4)).not_to include(rule_4)
    end
  end
  # ************************************
  # リーグ用メソッド
  # ************************************
  let(:player) { create(:player) }
  let(:player_league_0) { create(:player) }
  let(:rule) { create(:rule) }
  let(:league) { create(:league, player: player, rule: rule) }

  describe '#leagues_registered?' do
    context 'プレイヤーがリーグを登録している場合' do
      before do
        player.leagues << league
      end

      let!(:league_player) { create(:league_player, player: player, league: league) }
      it '真を返すこと' do
        expect(player.leagues_registered?).to be true
      end
    end

    context 'プレイヤーがリーグを登録していない場合' do
      it '偽を返すこと' do
        expect(player_league_0.leagues_registered?).to be false
      end
    end
  end

  # ====================================
  # 共通メソッド
  # ====================================
  private

  def setup_results_for_matches
    players_3.each do |player|
      allow(player).to receive(:results_for_matches).and_return(player.results.where(match_id: player.match_ids_for_play_type(3)))
    end
    players_4.each do |player|
      allow(player).to receive(:results_for_matches).and_return(player.results.where(match_id: player.match_ids_for_play_type(4)))
    end
  end
end