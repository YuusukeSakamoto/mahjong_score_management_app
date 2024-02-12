require 'rails_helper'

RSpec.describe Rule, type: :model do
  let(:player) { create(:player) }
  let(:rule_1) { create(:rule, player: player) }

  # ====================
  # バリデーション
  # ====================
  describe '#validations' do
    describe '#play_type' do
      context "Rule#play_typeが空白の場合" do
        it 'バリデーションエラーとなること' do
          rule = build(:rule, play_type: nil)
          expect(rule).not_to be_valid
          expect(rule.errors[:play_type]).to include("を入力してください")
        end
      end
      context "Rule#play_typeが3か4以外の場合" do
        it 'バリデーションエラーとなること' do
          rule = build(:rule, play_type: 5)
          expect(rule).not_to be_valid
          expect(rule.errors[:play_type]).to include("は一覧にありません")
        end
      end
    end

    describe '#name' do
      context "Rule#nameが空白の場合" do
        it 'バリデーションエラーとなること' do
          rule = build(:rule, name: nil)
          expect(rule).not_to be_valid
          expect(rule.errors[:name]).to include("を入力してください")
        end
      end
      context "Rule#nameが15文字以上の場合" do
        it 'バリデーションエラーとなること' do
          rule = build(:rule, name: 'aaaaabbbbbcccccd')
          expect(rule).not_to be_valid
          expect(rule.errors[:name].join).to include("15文字以内で入力してください")      end
      end
      context "Rule#nameが同じプレイヤーで重複している場合" do
        it 'バリデーションエラーとなること' do
          rule = build(:rule, name: rule_1.name, player: player)
          expect(rule).not_to be_valid
          expect(rule.errors[:name]).to include("はすでに存在します")
        end
      end
    end

    let(:rule) { build(:rule, player: player) }

    describe '#mochi' do
      context "存在しない場合" do
        it 'バリデーションエラーとなること' do
          rule.mochi = nil
          expect(rule).not_to be_valid
          expect(rule.errors[:mochi]).to include("を入力してください")
        end
      end
    end

    describe '#is_chip' do
      context "trueまたはfalseでない場合" do
        it 'バリデーションエラーとなること' do
          rule.is_chip = nil
          expect(rule).not_to be_valid
          expect(rule.errors[:is_chip]).to include("は一覧にありません")
        end
      end
    end

    describe '#chip_rate' do
      context "is_chipがtrueで存在しない場合" do
        it 'バリデーションエラーとなること' do
          rule.is_chip = true
          rule.chip_rate = nil
          expect(rule).not_to be_valid
          expect(rule.errors[:chip_rate]).to include("を入力してください")
        end
      end

      context "is_chipがfalseで存在する場合" do
        it 'バリデーションエラーとなること' do
          rule.is_chip = false
          rule.chip_rate = 10
          expect(rule).not_to be_valid
          expect(rule.errors[:chip_rate]).to include("は入力しないでください")
        end
      end
    end

    describe '#description' do
      context "50文字を超える場合" do
        it 'バリデーションエラーとなること' do
          rule.description = 'a' * 51
          expect(rule).not_to be_valid
          expect(rule.errors[:description].join).to include("50文字以内で入力してください")
        end
      end
    end
  end

  # ====================
  # メソッド
  # ====================
  describe '.get_value_score_decimal_point_calc' do
    it 'コード値に対応する文字列を返すこと' do
      expect(Rule.get_value_score_decimal_point_calc(1)).to eq '小数点有効'
      expect(Rule.get_value_score_decimal_point_calc(2)).to eq '五捨六入'
      expect(Rule.get_value_score_decimal_point_calc(3)).to eq '四捨五入'
      expect(Rule.get_value_score_decimal_point_calc(4)).to eq '切り捨て'
      expect(Rule.get_value_score_decimal_point_calc(5)).to eq '切り上げ'
      # 他のコード値についても同様にテストを追加してください
    end
  end

  describe '.get_value_is_chip' do
    context 'is_chipがtrueの場合' do
      it '「有」を返すこと' do
        expect(Rule.get_value_is_chip(true)).to eq '有'
      end
    end

    context 'is_chipがfalseの場合' do
      it '「無」を返すこと' do
        expect(Rule.get_value_is_chip(false)).to eq '無'
      end
    end
  end

  describe '.get_value_chip_rate' do
    context 'chip_rateがnilの場合' do
      it '「-」を返すこと' do
        expect(Rule.get_value_chip_rate(nil)).to eq '-'
      end
    end

    context 'chip_rateが存在する場合' do
      it 'chip_rateに"pt"を追加した文字列を返すこと' do
        expect(Rule.get_value_chip_rate(10)).to eq '10pt'
      end
    end
  end

  # ====================
  # カスタムバリデーション
  # ====================
  describe '#mochi_kaeshi_check' do
    let(:player) { create(:player) }
    let(:rule) { build(:rule, player: player) }
    context '持ち点が返し点より大きい場合' do
      it 'エラーが追加されること' do
        rule.mochi = 35000
        rule.kaeshi = 30000
        rule.valid?
        expect(rule.errors[:kaeshi]).to include('点は持ち点より大きくしてください')
      end
    end

    context '持ち点が返し点より小さい場合' do
      it 'エラーが追加されないこと' do
        rule.mochi = 25000
        rule.kaeshi = 30000
        rule.valid?
        expect(rule.errors[:kaeshi]).to be_empty
      end
    end
  end
end