# spec/models/chip_result_spec.rb
require 'rails_helper'

RSpec.describe ChipResult, type: :model do
  describe 'ChipResult#validations' do
    context 'ChipResult#pointが空白のとき' do
      it 'バリデーションエラーになること' do
        player = create(:player)
        match_group = create(:match_group)
        cr = build(:chip_result, player_id: player.id, match_group: match_group, point: nil)
        expect(cr).not_to be_valid
        expect(cr.errors[:point]).to include("を入力してください")
      end
    end
    context 'ChipResult#numberが空白のとき' do
      it 'バリデーションエラーになること' do
        player = create(:player)
        match_group = create(:match_group)
        cr = build(:chip_result, player_id: player.id, match_group: match_group, number: nil)
        expect(cr).not_to be_valid
        expect(cr.errors[:number]).to include("を入力してください")
      end
    end
  end
end