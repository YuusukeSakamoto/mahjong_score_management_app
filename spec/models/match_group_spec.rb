require 'rails_helper'

RSpec.describe MatchGroup, type: :model do
  let(:player) { create(:player) }
  # let(:match_group) { create(:match_group) }
  # let(:match) { create(:match, match_group: match_group) }
  # let(:result) { create(:result, player: player, match: match) }

  let(:rule) { create(:rule) }
  let(:match_group) { create(:match_group, play_type: rule.play_type) }
  let(:match) { create(:match, rule: rule, play_type: rule.play_type) }
  let!(:result) { create(:result, player: player, match: match) } # `let!`を使用して即時評価


  # describe '#table_element' do
  #   it '各マッチの結果と合計ポイントを返すこと' do
  #     each_points, total_points = match_group.table_element
  #     expect(each_points).to eq [[result.point]]
  #     expect(total_points).to eq [result.point]
  #   end
  # end

  # describe '#get_index' do
  #   it 'マッチのインデックスを返すこと' do
  #     expect(match_group.get_index(match.id)).to eq 1
  #   end
  # end

  # describe '#players' do
  #   it 'マッチグループのプレイヤーを返すこと' do
  #     expect(match_group.players).to contain_exactly(player)
  #   end
  # end

  # describe '#created_by?' do
  #   context '現在のプレイヤーが作成者である場合' do
  #     it 'trueを返すこと' do
  #       expect(match_group.created_by?(player)).to be true
  #     end
  #   end

  #   context '現在のプレイヤーが作成者でない場合' do
  #     let(:other_player) { create(:player) }

  #     it 'falseを返すこと' do
  #       expect(match_group.created_by?(other_player)).to be false
  #     end
  #   end
  # end
end