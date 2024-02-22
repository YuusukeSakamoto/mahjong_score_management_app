require 'rails_helper'

RSpec.describe MatchGroup, type: :model do
  let(:players) { create_list(:player, 4) }
  let(:rule) { create(:rule) }
  let(:match_group) { create(:match_group, play_type: rule.play_type) }
  let(:match) { create(:match, player: players[0], rule: rule, play_type: rule.play_type, match_group_id: match_group.id, match_on: Date.today) }
  let!(:results) do
    players.each_with_index.map do |player, index|
      create(:result, match: match, player: player, score: 35000 - (5000 * index), point: 30 - (20 * index), ie: index + 1, rank: index + 1)
    end
  end

  describe '#table_element' do
    it '各マッチの結果と合計ポイントを返すこと(チップなし)' do
      each_points, total_points = match_group.table_element
      expect(each_points).to eq [[results[0].point, results[1].point, results[2].point, results[3].point]]
      expect(total_points).to eq [results[0].point, results[1].point, results[2].point, results[3].point]
    end
    it '各マッチの結果と合計ポイントを返すこと(チップあり)' do
      chip_results = players.each_with_index.map do |player, index|
        create(:chip_result, match_group: match_group, player_id: player.id, is_temporary: false)
      end
      match_group.reload
      each_points, total_points = match_group.table_element
      expect(each_points).to eq [[results[0].point, results[1].point, results[2].point, results[3].point],
                                  [chip_results[0].point, chip_results[1].point, chip_results[2].point, chip_results[3].point]]
      expect(total_points).to eq [results[0].point + chip_results[0].point,
                                  results[1].point + chip_results[1].point,
                                  results[2].point + chip_results[2].point,
                                  results[3].point + chip_results[3].point]
    end
  end

  describe '#get_index' do
    it 'matchがmatch_groupのなかにおけるインデックスを返すこと' do
      expect(match_group.get_index(match.id)).to eq 1
    end
  end

  describe '#players' do
    it 'match_groupのプレイヤーを返すこと' do
      expect(match_group.players).to eq(players)
    end
  end

  describe '#created_by?' do
    context '現在のプレイヤーが作成者である場合' do
      it 'trueを返すこと' do
        expect(match_group.created_by?(players[0])).to be true
      end
    end

    context '現在のプレイヤーが作成者でない場合' do
      let(:other_player) { create(:player) }

      it 'falseを返すこと' do
        expect(match_group.created_by?(other_player)).to be false
      end
    end
  end

  describe '#chip_record?' do
    context 'チップ有ルールである場合' do
      it 'マッチの数がidx+1より少ない場合、真を返す' do
        allow(match_group).to receive(:tip_rule?).and_return(true)
        allow(match_group).to receive_message_chain(:matches, :count).and_return(0)
        expect(match_group.chip_record?(1)).to be_truthy
      end

      it 'マッチの数がidx+1以上の場合、偽を返す' do
        allow(match_group).to receive(:tip_rule?).and_return(true)
        allow(match_group).to receive_message_chain(:matches, :count).and_return(2)
        expect(match_group.chip_record?(1)).to be_falsey
      end
    end

    context 'チップ無ルールである場合' do
      it '偽を返す' do
        allow(match_group).to receive(:tip_rule?).and_return(false)
        expect(match_group.chip_record?(1)).to be_falsey
      end
    end
  end

  describe '#last_match_day' do
    it '最後のマッチの日付を返す' do
      last_match = match
      allow(match_group).to receive_message_chain(:matches, :last).and_return(last_match)
      expect(match_group.last_match_day).to eq Date.today.to_s(:yeardate)
    end
  end

end