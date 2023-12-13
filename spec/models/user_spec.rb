require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'User#validations' do
    context "User#nameが空白のとき" do
      it 'バリデーションエラーとなること' do
        user = User.new(name: nil)
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("を入力してください")
      end
    end

    context "User#nameが10文字より大きいとき" do
      it 'バリデーションエラーとなること' do
        user = User.new(name: 'a' * 11)
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include('は10文字以内で入力してください')
      end
    end
  end

  describe 'User#generate_authentication_url' do
    let(:user) { User.create(name: 'Test User', email: 'test@example.com', password: 'password') }

    it 'player_select_tokenがセットされること' do
      expect(user.player_select_token).to be_nil
      user.generate_authentication_url
      expect(user.player_select_token).not_to be_nil
    end

    it 'player_select_token_created_atがセットされること' do
      expect(user.player_select_token_created_at).to be_nil
      user.generate_authentication_url
      expect(user.player_select_token_created_at).not_to be_nil
    end
  end
end