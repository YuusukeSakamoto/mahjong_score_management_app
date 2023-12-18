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

    context 'Player#nameが10文字より大きいとき' do
      it 'バリデーションエラーになること' do
        player = build(:player, name: 'a' * 11)
        expect(player).not_to be_valid
        expect(player.errors[:name]).to include('は10文字以内で入力してください')
      end
    end
  end

  # 四麻のデータ
  let(:players_4) { create_list(:player, 4) }
  let!(:rule_4) { create(:rule, player: players_4.first) }
  let!(:match_4) { create(:match, player: players_4.first, rule: rule_4, play_type: 4) }

  let!(:results_4) do
    players_4.each_with_index.map do |player, index|
      create(:result, match: match_4, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
    end
  end

  # 三麻のデータ
  let(:players_3) { create_list(:player, 3) }
  let!(:rule_3) { create(:rule, player: players_3.first) }
  let!(:match_3) { create(:match, player: players_3.first, rule: rule_3, play_type: 3) }

  let!(:results_3) do
    players_3.each_with_index.map do |player, index|
      create(:result, match: match_3, player: player, score: 35000 - (5000 * index), point: 30 - (30 * index), ie: index + 1, rank: index + 1)
    end
  end

  # matchゼロのプレイヤー
  let(:player_0) { create(:player) }

  describe 'Player#find_by_results' do
    it 'resultからplayerが取得できること' do
      players = Player.find_by_results(players_4[0].matches.first.results)
      expect(players).to contain_exactly(players_4[0], players_4[1], players_4[2], players_4[3])
    end
  end

  describe 'Player#total_match_count' do
    it 'playerの総対局数を取得できること' do
      expect(players_4[0].total_match_count(3)).to eq(0)
      expect(players_4[0].total_match_count(4)).to eq(1)
      expect(players_3[0].total_match_count(3)).to eq(1)
      expect(players_3[0].total_match_count(4)).to eq(0)
    end
  end

  describe 'Player#results_for_matches' do
    it 'playerが参加したmatchのresultsの取得できること' do
      expect(players_4[0].results_for_matches(4)).to contain_exactly(results_4.first)
      expect(players_4[0].results_for_matches(3)).not_to contain_exactly(results_3.first)
      expect(players_3[0].results_for_matches(3)).to contain_exactly(results_3.first)
      expect(players_3[0].results_for_matches(4)).not_to contain_exactly(results_4.first)
    end
  end

  describe 'Player#match_ids_for_play_type' do
    it 'play_typeに基づいて適切なmatch_idsの配列に含まれること' do
      expect(players_4[0].match_ids_for_play_type(4)).to contain_exactly(match_4.id)
      expect(players_4[0].match_ids_for_play_type(3)).not_to contain_exactly(match_4.id)
      expect(players_3[0].match_ids_for_play_type(3)).to contain_exactly(match_3.id)
      expect(players_3[0].match_ids_for_play_type(4)).not_to contain_exactly(match_3.id)
    end
  end

  describe 'Player#get_sanyon_matches' do
    it '直近の対局データを5局取得できること' do
      players_3[0].match_ids_for_play_type(3)
      players_4[0].match_ids_for_play_type(4)
      expect(players_3[0].get_sanyon_matches(3)).to contain_exactly(players_3[0].matches.last)
      expect(players_3[0].get_sanyon_matches(3)).not_to contain_exactly(players_4[0].matches.last)
      expect(players_4[0].get_sanyon_matches(4)).to contain_exactly(players_4[0].matches.last)
      expect(players_4[0].get_sanyon_matches(4)).not_to contain_exactly(players_3[0].matches.last)
    end
  end

  describe 'Player#get_sanyon_match_ids' do
    it 'play_typeに基づくmatch_idsを取得できること' do
      players_3[0].match_ids_for_play_type(3)
      players_4[0].match_ids_for_play_type(4)
      expect(players_3[0].get_sanyon_match_ids(3)).to contain_exactly(players_3[0].matches.last)
      expect(players_3[0].get_sanyon_match_ids(3)).not_to contain_exactly(players_4[0].matches.last)
      expect(players_4[0].get_sanyon_match_ids(4)).to contain_exactly(players_4[0].matches.last)
      expect(players_4[0].get_sanyon_match_ids(4)).not_to contain_exactly(players_3[0].matches.last)
    end
  end

  describe 'Player#matches_present?' do
    let(:players) { create_list(:player, 4) }
    context '対局数が1以上の場合' do
      before do
        rule_4 = create(:rule, player: players.first)
        match_4 = create(:match, player: players.first, rule: rule_4, play_type: 4)
        results_4 = players.each_with_index.map do |player, index|
            create(:result, match: match_4, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
          end
      end
      it 'trueを返すこと' do
        expect(players[0].matches_present?).to be true
      end
    end

    context '対局数が0の場合' do
      it 'falseを返すこと' do
        expect(players[0].matches_present?).to be false
      end
    end
  end

  # describe 'Player#total_point' do
  #   it 'playerの総合ptを取得できること' do
  #     expect(player.total_point(3)).to eq('+10.0')
  #     expect(player.total_point(4)).to eq('+20.0')
  #   end
  # end

  # describe 'Player#average_rank' do
  #   it 'playerの平均順位を取得できること' do
  #     expect(player.average_rank).to eq('1.50')
  #   end
  # end

  # describe 'Player#rentai_rate' do
  #   it 'playerの連対率を取得できること' do
  #     expect(player.rentai_rate).to eq('100.00')
  #   end
  # end

  # describe 'Player#graph_rank_data' do
  #   it '順位グラフ用データをセットできること' do
  #     expect(player.graph_rank_data(3)).to eq({ '3' => [1] })
  #     expect(player.graph_rank_data(4)).to eq({ '4' => [2] })
  #   end
  # end

  # describe 'Player#add_null' do
  #   it 'rank_dataが10個未満の場合はnilで埋めること' do
  #     rank_data = [1, 2, 3]
  #     player.add_null(rank_data)
  #     expect(rank_data).to eq([1, 2, 3, nil, nil, nil, nil, nil, nil, nil])
  #   end
  # end

end