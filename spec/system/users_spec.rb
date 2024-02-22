require 'rails_helper'

RSpec.describe User, type: :system do
  let(:user) { create(:user) }
  let(:player) { create(:player, user: user) }
  let(:other_user) { create(:user) }

  describe '● CRUD' do
    describe '--- ログイン前 ----' do
      describe 'ユーザー新規登録' do
        before do
          visit new_user_registration_path
        end
        context 'ユーザー名未入力の場合' do
          it 'ユーザーの新規作成が失敗' do
            fill_in 'user_name', with: ''
            fill_in 'user_email', with: 'test@example.com'
            fill_in 'user_password', with: 'password'
            fill_in 'user_password_confirmation', with: 'password'
            click_button '登録'
            expect(current_path).to eq new_user_registration_path
            expect(page).to have_content 'ユーザー名を入力してください'
          end
        end
        context 'メールアドレス未記入の場合' do
          it 'ユーザーの新規作成が失敗' do
            fill_in 'user_name', with: 'test'
            fill_in 'user_email', with: ''
            fill_in 'user_password', with: 'password'
            fill_in 'user_password_confirmation', with: 'password'
            click_button '登録'
            expect(current_path).to eq new_user_registration_path
            expect(page).to have_content 'メールアドレスを入力してください'
          end
        end
        context '登録済メールアドレスの場合' do
          it 'ユーザーの新規作成が失敗' do
            User.create!(name: 'test', email: 'test@example.com', password: 'password', password_confirmation: 'password')
            fill_in 'user_name', with: 'test'
            fill_in 'user_email', with: 'test@example.com'
            fill_in 'user_password', with: 'password'
            fill_in 'user_password_confirmation', with: 'password'
            click_button '登録'
            expect(current_path).to eq new_user_registration_path
            expect(page).to have_content 'メールアドレスはすでに存在します'
          end
        end
        context 'フォームの入力値が正常の場合' do
          it 'ユーザーの新規作成が成功' do
            fill_in 'user_name', with: 'test'
            fill_in 'user_email', with: 'test@example.com'
            fill_in 'user_password', with: 'password'
            fill_in 'user_password_confirmation', with: 'password'
            click_button '登録'
            expect(current_path).to eq root_path
            expect(page).to have_content 'アカウント登録が完了しました。'
          end
        end
      end
    end
    describe '--- ログイン後 ---' do
      describe 'ユーザー編集' do
        before do
          login(user, player)
          visit edit_user_registration_path(user)
        end
        context 'フォームの入力値が正常の場合' do
          it 'ユーザーの編集が成功' do
            fill_in 'user_name', with: 'test_edit'
            fill_in 'user_email', with: 'test@example.com'
            fill_in 'user_current_password', with: 'password'
            click_button '編集'
            expect(current_path).to eq root_path
            expect(page).to have_content 'アカウント情報を変更しました。'
          end
        end
        context 'ユーザー名未記入の場合' do
          it 'ユーザーの編集が失敗' do
            fill_in 'user_name', with: ''
            fill_in 'user_email', with: 'test@example.com'
            fill_in 'user_current_password', with: 'password'
            click_button '編集'
            expect(current_path).to eq "/users"
            expect(page).to have_content 'ユーザー名を入力してください'
          end
        end
        context 'メールアドレス未記入の場合' do
          it 'ユーザーの編集が失敗' do
            fill_in 'user_name', with: 'test_edit'
            fill_in 'user_email', with: ''
            fill_in 'user_current_password', with: 'password'
            click_button '編集'
            expect(current_path).to eq "/users"
            expect(page).to have_content 'メールアドレスを入力してください'
          end
        end
        context '変更後パスワードと確認パスワード異なる場合' do
          it 'ユーザーの編集が失敗' do
            fill_in 'user_name', with: 'test_edit'
            fill_in 'user_email', with: 'test@example.com'
            fill_in 'user_password', with: 'password1'
            fill_in 'user_password_confirmation', with: 'password2'
            fill_in 'user_current_password', with: 'password'
            click_button '編集'
            expect(current_path).to eq "/users"
            expect(page).to have_content 'パスワード（確認用）とパスワードの入力が一致しません'
          end
        end
      end
    end
  end

  describe '● ACCESS' do
    describe '--- ログイン前 ----' do
      describe 'Users#show' do
        context 'ログイン前にユーザー詳細ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit me_path
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください。'
          end
        end
      end
    end
    describe '--- ログイン後 ---' do
      describe 'Users#show' do
        before do
          login(user, player)
        end
        context 'ログインユーザーがユーザー詳細ページへアクセスした場合' do
          it 'アクセス成功' do
            visit me_path
            expect(current_path).to eq me_path
            expect(page).to have_content user.name
          end
        end
      end
    end
  end
end