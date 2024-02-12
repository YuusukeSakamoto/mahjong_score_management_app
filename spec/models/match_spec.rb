require 'rails_helper'

RSpec.describe Match, type: :model do
  let(:rule) { create(:rule) }
  let(:match) { build(:match, rule: rule) }

  # ====================
  # バリデーション
  # ====================
  describe '#validations' do
    describe '#play_type' do
      context '存在しない場合' do
        it 'バリデーションエラーとなること' do
          match.play_type = nil
          match.valid?
          expect(match.errors[:play_type]).to include("を入力してください")
        end
      end

      context '3より小さい場合' do
        it 'バリデーションエラーとなること' do
          match.play_type = 2
          match.valid?
          expect(match.errors[:play_type]).to include("は一覧にありません")
        end
      end
    end

    describe '#match_on' do
      context '存在しない場合' do
        it 'バリデーションエラーとなること' do
          match.match_on = nil
          match.valid?
          expect(match.errors[:match_on]).to include("を入力してください")
        end
      end
    end

    describe '#rule_id' do
      context '存在しない場合' do
        it 'バリデーションエラーとなること' do
          match.rule_id = nil
          match.valid?
          expect(match.errors[:rule_id]).to include("を入力してください")
        end
      end
    end

    describe '#memo' do
      context '50文字を超える場合' do
        it 'バリデーションエラーとなること' do
          match.memo = 'a' * 51
          match.valid?
          expect(match.errors[:memo].join).to include("50文字以内で入力してください")
        end
      end
    end
  end

  # ====================
  # メソッド
  # ====================
  let(:player) { create(:player) }
  let(:match) { create(:match, rule: rule, play_type: rule.play_type) }
  let!(:result) { create(:result, player: player, match: match) } # `let!`を使用して即時評価
  let(:player_2) { create(:player) }

  describe '#current_player_point' do
    context '該当のプレイヤーIDが存在する場合' do
      it 'プレイヤーのポイントを返すこと' do
        expect(match.current_player_point(player.id)).to eq result.point
      end
    end

    context '該当のプレイヤーIDが存在しない場合' do
      it 'nilを返すこと' do
        expect(match.current_player_point(player_2.id)).to be_nil
      end
    end
  end
end