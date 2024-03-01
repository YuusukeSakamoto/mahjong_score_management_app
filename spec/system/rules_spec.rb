require 'rails_helper'

RSpec.describe Rule, type: :system do
  let(:user) { create(:user) }
  let(:player) { create(:player, user: user) }
  let(:rule) { create(:rule, player: player) }

  let(:other_user) { create(:user) }
  let(:other_player) { create(:player, user: other_user) }
  let(:other_rule) { create(:rule, player: other_player) }


  describe '● ACCESS' do
    describe '--- ログイン前 ----' do
      describe 'Rules#index' do
        context 'ルール詳細ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit player_rules_path(player)
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください。'
          end
        end
      end
      describe 'Rules#new' do
        context 'ルール作成ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit new_player_rule_path(player)
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください。'
          end
        end
      end
      describe 'Rules#edit' do
        context 'ルール編集ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit edit_player_rule_path(player, rule)
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください。'
          end
        end
      end
    end
    describe '--- ログイン後 ---' do
      before do
        login(user, player)
      end
      describe 'Rules#index' do
        context 'ログインプレイヤーのルール一覧ページへアクセスした場合' do
          it 'アクセス成功' do
            visit player_rules_path(player)
            expect(current_path).to eq player_rules_path(player)
          end
        end
        context 'ログインプレイヤーが他プレイヤーのルール一覧ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit player_rules_path(other_player)
            expect(current_path).to eq root_path
            expect(page).to have_content 'アクセス権限がありません'
          end
        end
      end
      describe 'Rules#edit' do
        context 'ログインプレイヤーのルール編集ページへアクセスした場合' do
          it 'アクセス成功' do
            visit edit_player_rule_path(player, rule)
            expect(current_path).to eq edit_player_rule_path(player, rule)
          end
        end
        context 'ログインプレイヤーが他プレイヤーのルール編集ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit edit_player_rule_path(other_player, other_rule)
            expect(current_path).to eq root_path
            expect(page).to have_content '編集権限がありません'
          end
        end
      end
      describe 'Rules#new' do
        context 'ログインプレイヤーのルール登録ページへアクセスした場合' do
          it 'アクセス成功' do
            visit new_player_rule_path(player)
            expect(current_path).to eq new_player_rule_path(player)
          end
        end
        context 'ログインプレイヤーが他プレイヤーのルール登録ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit new_player_rule_path(other_player)
            expect(current_path).to eq root_path
            expect(page).to have_content 'アクセス権限がありません'
          end
        end
        context 'ログインプレイヤーが記録中にルール作成ページへアクセスした場合' do
          it 'アクセス失敗' do
          end
        end
      end
    end
  end

  describe '● CRUD' do
    before do
      login(user, player)
    end
    describe 'ルール登録' do
    end
    describe 'ルール編集' do
    end
    describe 'ルール削除' do
    end
  end

end