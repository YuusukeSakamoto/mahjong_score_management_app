require 'rails_helper'

RSpec.describe League, type: :model do
  let(:player) { create(:player) }
  let(:rule) { create(:rule) }
  let!(:league) { create(:league, player: player, rule: rule) }
  let!(:match_1) { create(:match, player: player, rule: rule, play_type: rule.play_type, league_id: league.id, match_on: '2024/01/01') }
  let!(:match_2) { create(:match, player: player, rule: rule, play_type: rule.play_type, league_id: league.id, match_on: '2024/01/02') }

  # ************************************
  # リーグ情報
  # ************************************

  describe '#first_record_day' do
    context 'マッチが存在しない場合' do
      it 'nilを返す' do
        allow(league).to receive_message_chain(:matches, :count).and_return(0)
        expect(league.first_record_day).to be_nil
      end
    end

    context 'マッチが存在する場合' do
      it '最初に記録した日を返す' do
        expect(league.first_record_day).to eq('2024/1/1')
      end
    end
  end

  describe '#last_record_day' do
    context 'マッチが存在しない場合' do
      it 'nilを返す' do
        allow(league).to receive_message_chain(:matches, :count).and_return(0)
        expect(league.last_record_day).to be_nil
      end
    end

    context 'マッチが存在する場合' do
      it '最後に記録した日を返す' do
        expect(league.last_record_day).to eq('2024/1/2')
      end
    end
  end

  describe '#match_count' do
    it 'マッチの総数を返す' do
      expect(league.match_count).to eq 2
    end
  end

  describe '#is_tip_valid?' do
    let(:rule_true) { create(:rule, is_chip: true, chip_rate: 2) }
    let(:rule_false) { create(:rule, is_chip: false) }

    let(:league_1) { create(:league, player: player, rule: rule_true, is_tip_valid: true) }
    let(:league_2) { create(:league, player: player, rule: rule_false, is_tip_valid: false) }
    let(:league_3) { create(:league, player: player, rule: rule_true, is_tip_valid: false) }
    let(:league_4) { create(:league, player: player, rule: rule_false, is_tip_valid: true) }

    context 'リーグルールがチップ有かつリーグ成績にチップptを含める場合' do
      it '真を返す' do
        expect(league_1.is_tip_valid?).to be_truthy
      end
    end
    context 'リーグルールがチップ無かつリーグ成績にチップptを含めない場合' do
      it '偽を返す' do
        expect(league_2.is_tip_valid?).to be_falsey
      end
    end
    context 'リーグルールがチップ有かつリーグ成績にチップptを含めない場合' do
      it '偽を返す' do
        expect(league_3.is_tip_valid?).to be_falsey
      end
    end
    context 'リーグルールがチップ無かつリーグ成績にチップptを含める場合' do
      it '偽を返す' do
        expect(league_4.is_tip_valid?).to be_falsey
      end
    end
  end

  # ************************************
  # リーグ順位表
  # ************************************

  let(:players) { create_list(:player, 4) }
  let(:rule) { create(:rule) }
  let!(:league_2) { create(:league, player: players[0], rule: rule, play_type: 4) }
  let!(:league_players) do
    players.each do |player|
      create(:league_player, player: player, league: league_2)
    end
  end
  let!(:match) { create(:match, player: players[0], rule: rule, play_type: rule.play_type, league_id: league_2.id) }
  let!(:results) do
    players.each_with_index.map do |player, index|
      create(:result, match: match, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
    end
  end

  describe '#rank_table' do
    context 'リーグにマッチとプレイヤーが存在する場合' do
      it '順位表データを返す' do
        league_2.point_histories
        allow(league_2).to receive(:rank_times).and_return([1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1])
        expect(league_2.rank_table).to eq([{ name: players[0].name, rank_times: [1, 0, 0, 0], total_pt: 30 },
                                          { name: players[1].name, rank_times: [0, 1, 0, 0], total_pt: 10 },
                                          { name: players[2].name, rank_times: [0, 0, 1, 0], total_pt: -10 },
                                          { name: players[3].name, rank_times: [0, 0, 0, 1], total_pt: -30 }])
      end
    end
  end

  describe '#rank_times' do
    context 'プレイヤーがリーグのマッチに参加している場合' do
      it 'プレイヤーの各順位回数を返す' do
        l_matches = Match.where(league_id: league_2.id)
        league_2.l_match_ids = l_matches.pluck(:id)
        expect(league_2.rank_times(players[0].id)).to eq [1, 0, 0, 0]
        expect(league_2.rank_times(players[1].id)).to eq [0, 1, 0, 0]
        expect(league_2.rank_times(players[2].id)).to eq [0, 0, 1, 0]
        expect(league_2.rank_times(players[3].id)).to eq [0, 0, 0, 1]
      end
    end
  end

  # ************************************
  # 総合pt推移グラフ
  # ************************************

  describe '#graph_data' do
    context 'リーグにプレイヤーとマッチが存在する場合' do
      it 'グラフデータを返す' do
        league.point_histories
        allow(league).to receive(:players_name).and_return(['Player1', 'Player2', 'Player3', 'Player4'])
        allow(league).to receive(:point_histories).and_return([[-10, 10, 20, 30], [0, 10, 20, 30], [10, 10, 20, 30], [20, 10, 20, 30]])
        allow(league).to receive(:player_color).and_return(['#FF4B00', '#005AFF', '#F6AA00', '#52bb93'])
        allow(league).to receive(:player_bgcolor).and_return(['#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF'])
        expect(league.graph_data).to eq([[{label: "Player1", data: [-10, 10, 20, 30], borderColor: "#FF4B00", backgroundColor: "#FFFFFF"},
                                          {label: "Player2", data: [0, 10, 20, 30], borderColor: "#005AFF", backgroundColor: "#FFFFFF"},
                                          {label: "Player3", data: [10, 10, 20, 30], borderColor: "#F6AA00", backgroundColor: "#FFFFFF"},
                                          {label: "Player4", data: [20, 10, 20, 30], borderColor: "#52bb93", backgroundColor: "#FFFFFF"}],
                                          100, 0])
      end
    end
  end

  describe '#graph_label' do
    context 'リーグにmatchが0つ存在する場合' do
      it 'グラフのx軸ラベルを返す' do
        league_0 = create(:league, player: players[0], rule: rule, play_type: 4)
        expect(league_0.graph_label).to eq([''])
      end
    end
    context 'リーグにmatchが1つ存在する場合' do
      it 'グラフのx軸ラベルを返す' do
        expect(league_2.graph_label).to eq(['', 1])
      end
    end
    context 'リーグにmatchが20つ存在する場合' do
      it 'グラフのx軸ラベルを返す' do
        league_20 = create(:league, player: players[0], rule: rule, play_type: 4)
        20.times do |i|
          create(:match, player: players[0], rule: rule, play_type: rule.play_type, league_id: league_20.id)
        end
        expect(league_20.graph_label).to eq(['','','','','',5,'','','','',10,'','','','',15,'','','','',20])
      end
    end
    context 'リーグにmatchが49つ存在する場合' do
      it 'グラフのx軸ラベルを返す' do
        league_49 = create(:league, player: players[0], rule: rule, play_type: 4)
        49.times do |i|
          create(:match, player: players[0], rule: rule, play_type: rule.play_type, league_id: league_49.id)
        end
        expect(league_49.graph_label).to eq(['','','','','',5,'','','','',10,
                                              '','','','',15,'','','','',20,
                                              '','','','',25,'','','','',30,
                                              '','','','',35,'','','','',40,
                                              '','','','',45,'','','',''])
      end
    end
    context 'リーグにmatchが50つ存在する場合' do
      it 'グラフのx軸ラベルを返す' do
        league_50 = create(:league, player: players[0], rule: rule, play_type: 4)
        50.times do |i|
          create(:match, player: players[0], rule: rule, play_type: rule.play_type, league_id: league_50.id)
        end
        expect(league_50.graph_label).to eq(['','','','','','','','','','',10,
                                              '','','','','','','','','',20,
                                              '','','','','','','','','',30,
                                              '','','','','','','','','',40,
                                              '','','','','','','','','',50])
      end
    end
  end

  describe '#point_histories' do
    context 'リーグ成績にチップ成績を含めない && ルールチップ有の場合' do
      it 'チップ成績を含めず成績推移データを返す' do
        players = create_list(:player, 4)
        rule_tip_valid = create(:rule, is_chip: true, chip_rate: 2)
        league_tip_invalid = create(:league, player: players[0], rule: rule_tip_valid, is_tip_valid: false)
        league_players = players.each do |player|
          create(:league_player, player: player, league: league_tip_invalid)
        end
        mg = create(:match_group, play_type: rule_tip_valid.play_type)
        match = create(:match, player: players[0], rule: rule_tip_valid,
                        play_type: rule_tip_valid.play_type, match_group_id: mg.id,
                        league_id: league_tip_invalid.id)
        results = players.each_with_index.map do |player, index|
          create(:result, match: match, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
        end
        chip_reuslts = players.each_with_index.map do |player, index|
          create(:chip_result, match_group: mg, player_id: player.id)
        end

        expect(league_tip_invalid.point_histories).to eq([[0, 30.0], [0, 10.0], [0, -10.0], [0, -30.0]])
      end
    end
    context 'リーグ成績にチップ成績を含めない && ルールチップ無の場合' do
      it 'チップ成績を含めず成績推移データを返す' do
        players = create_list(:player, 4)
        rule_tip_invalid = create(:rule, is_chip: false)
        league_tip_invalid = create(:league, player: players[0], rule: rule_tip_invalid, is_tip_valid: false)
        league_players = players.each do |player|
          create(:league_player, player: player, league: league_tip_invalid)
        end
        mg = create(:match_group, play_type: rule_tip_invalid.play_type)
        match = create(:match, player: players[0], rule: rule_tip_invalid,
                        play_type: rule_tip_invalid.play_type, match_group_id: mg.id,
                        league_id: league_tip_invalid.id)
        results = players.each_with_index.map do |player, index|
          create(:result, match: match, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
        end
        chip_reuslts = players.each_with_index.map do |player, index|
          create(:chip_result, match_group: mg, player_id: player.id)
        end

        expect(league_tip_invalid.point_histories).to eq([[0, 30.0], [0, 10.0], [0, -10.0], [0, -30.0]])
      end
    end
    context 'リーグ成績にチップ成績を含める && ルールチップ無の場合' do
      it 'チップ成績を含めず成績推移データを返す' do
        players = create_list(:player, 4)
        rule_tip_invalid = create(:rule, is_chip: false)
        league_tip_valid = create(:league, player: players[0], rule: rule_tip_invalid, is_tip_valid: true)
        league_players = players.each do |player|
          create(:league_player, player: player, league: league_tip_valid)
        end
        mg = create(:match_group, play_type: rule_tip_invalid.play_type)
        match = create(:match, player: players[0], rule: rule_tip_invalid,
                        play_type: rule_tip_invalid.play_type, match_group_id: mg.id,
                        league_id: league_tip_valid.id)
        results = players.each_with_index.map do |player, index|
          create(:result, match: match, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
        end
        chip_reuslts = players.each_with_index.map do |player, index|
          create(:chip_result, match_group: mg, player_id: player.id)
        end

        expect(league_tip_valid.point_histories).to eq([[0, 30.0], [0, 10.0], [0, -10.0], [0, -30.0]])
      end
    end
    context 'リーグ成績にチップ成績を含める && ルールチップ有の場合' do
      it 'チップ成績を含めた成績推移データを返す' do
        players = create_list(:player, 4)
        rule_tip_valid = create(:rule, is_chip: true, chip_rate: 2)
        league_tip_valid_2 = create(:league, player: players[0], rule: rule_tip_valid, is_tip_valid: true)
        league_players = players.each do |player|
          create(:league_player, player: player, league: league_tip_valid_2)
        end
        mg = create(:match_group, play_type: rule_tip_valid.play_type, league: league_tip_valid_2)
        match = create(:match, player: players[0], rule: rule_tip_valid,
                        play_type: rule_tip_valid.play_type, match_group_id: mg.id,
                        league_id: league_tip_valid_2.id)
        results = players.each_with_index.map do |player, index|
          create(:result, match: match, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
        end
        chip_results = players.each_with_index.map do |player, index|
          create(:chip_result, match_group: mg, player_id: player.id, point: rule_tip_valid.chip_rate * (index + 1), number: index + 1)
        end

        expect(league_tip_valid_2.point_histories).to eq([[0, 30.0, 32.0], [0, 10.0, 14.0], [0, -10.0, -4.0], [0, -30.0, -22.0]])
      end
    end
  end



end
