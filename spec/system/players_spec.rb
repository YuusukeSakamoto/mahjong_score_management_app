require 'rails_helper'

RSpec.describe Player, type: :system do
  let(:user) { create(:user) }
  let(:current_p) { create(:player, user: user) }
  let(:other_p) { create(:player) }
  let(:created_p_by_user) { create(:player, created_user: user.id) }
  let(:players) { create_list(:player, 3, user: nil) }
  let(:rule) { create(:rule, player: current_p) }
  let(:match_group) { create(:match_group, rule: rule) }
  let(:match) { create(:match, player: current_p, rule: rule, match_group_id: match_group.id) }
  let(:points) { [50, 10, -20, -40] }
  let!(:results) do
    players_1 = players + [current_p]
    players_1.each_with_index.map do |p, index|
      create(:result, match: match, player: p, score: 40000 - (10000 * index), point: points[index], ie: index + 1, rank: index + 1)
    end
  end


  describe '● ACCESS' do
    describe '------ ログイン前 -------' do
      describe 'Players#index' do
        context 'プレイヤー一覧ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit players_path
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください。'
          end
        end
      end
      describe 'Players#show' do
        context 'プレイヤー詳細ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit player_path(current_p)
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください。'
          end
        end
      end
      describe 'Players#new' do
        context 'プレイヤー選択ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit new_player_path
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください。'
          end
        end
      end
      describe 'Players#edit' do
        context 'プレイヤー編集ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit edit_player_path(current_p)
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください。'
          end
        end
      end
    end

    describe '------ ログイン後 -------' do
      before do
        login(user, current_p)
      end
      describe 'Players#index' do
        context 'ログインプレイヤーのプレイヤー一覧ページへアクセスした場合' do
          it 'アクセス成功' do
            visit players_path
            expect(current_path).to eq players_path
          end
        end
      end
      describe 'Players#show' do
        context 'ログインプレイヤーのプレイヤー詳細ページへアクセスした場合' do
          it 'アクセス成功' do
            visit player_path(current_p)
            expect(current_path).to eq player_path(current_p)
          end
        end
        context 'ログインプレイヤーが他のプレイヤー詳細ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit player_path(other_p)
            expect(current_path).to eq root_path
            expect(page).to have_content 'アクセス権限がありません'
          end
        end
      end
      describe 'Players#edit' do
        context 'ログインプレイヤーが作成したプレイヤー編集ページへアクセスした場合' do
          it 'アクセス成功' do
            visit edit_player_path(created_p_by_user)
            expect(current_path).to eq edit_player_path(created_p_by_user)
          end
        end
        context 'ログインプレイヤーが他プレイヤーのプレイヤー編集ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit edit_player_path(other_p)
            expect(current_path).to eq root_path
            expect(page).to have_content '編集権限がありません'
          end
        end
        context 'ログインプレイヤーが削除済みプレイヤーのプレイヤー編集ページへアクセスした場合' do
          it 'アクセス失敗' do
            delete_p = create(:player, name: '削除済プレイヤー', deleted: true, created_user: user.id, user_id: nil)
            visit edit_player_path(delete_p)
            expect(current_path).to eq root_path
            expect(page).to have_content '編集権限がありません'
          end
        end
      end
      describe 'Players#new' do
        context 'ログインプレイヤーのプレイヤー選択ページへアクセスした場合' do
          it 'アクセス成功' do
            visit new_player_path(current_p)
            expect(current_path).to eq new_player_path(current_p)
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
    describe 'プレイヤー選択' do
      describe '------ ルール登録済み -------' do
        context 'プレイヤーを四人選択してプレイヤー決定ボタンを押した場合' do
          it '対局登録ページへ遷移し、選択されたプレイヤーがフォームに表示されている' do
            login(user, current_p)
            visit new_player_path(play_type: 4)
            find('li', text: players[0].name).click
            find('li', text: players[1].name).click
            find('li', text: players[2].name).click
            find('#create_btn', visible: true).click # プレイヤー作成ボタンをクリック
            expect(current_path).to eq new_match_path
            expect(page).to have_content players[0].name
            expect(page).to have_content players[1].name
            expect(page).to have_content players[2].name
            expect(page).to have_content current_p.name
            expect(page).to have_content "残得点 :100000"
            expect(page).to have_content "残得点が0ではありません"
          end
        end
      end
      describe '------ ルール未登録 -------' do
        context 'ルール未登録でプレイヤーを四人選択してプレイヤー決定ボタンを押した場合' do
          it 'ルール登録ページへ遷移し、ルール登録後対局成績登録画面へ遷移し、選択されたプレイヤーがフォームに表示されている' do
            user = create(:user)
            player = create(:player, user: user)
            login(user, player)
            # プレイヤー選択画面へ遷移し、プレイヤーを選択
            visit new_player_path(play_type: 4)
            fill_in 'new-player-form', with: 'aaa'
            find('#new-player-create-btn', visible: true).click
            fill_in 'new-player-form', with: 'bbb'
            execute_script('document.querySelector("#new-player-create-btn").click();')
            fill_in 'new-player-form', with: 'ccc'
            execute_script('document.querySelector("#new-player-create-btn").click();')
            find('#create_btn', visible: true).click # プレイヤー決定ボタンをクリック
            # ルール登録ページへ遷移し、ルールを登録する
            expect(current_path).to eq new_player_rule_path(player)
            fill_in 'rule_name', with: 'ルール名'
            fill_in 'rule_mochi', with: '25000'
            fill_in 'rule_kaeshi', with: '30000'
            fill_in 'rule_uma_one', with: '20'
            fill_in 'rule_uma_two', with: '10'
            fill_in 'rule_uma_three', with: '-10'
            fill_in 'rule_uma_four', with: '-20'
            execute_script('document.querySelector(".main-btn--orange").click();') # ルール登録ボタンをクリック
            # 対局登録ページへ遷移し、選択されたプレイヤーがフォームに表示されていることを検証
            expect(current_path).to eq new_match_path
            expect(page).to have_content 'aaa'
            expect(page).to have_content 'bbb'
            expect(page).to have_content 'ccc'
            expect(page).to have_content player.name
            expect(page).to have_content "残得点 :100000"
            expect(page).to have_content "残得点が0ではありません"
          end
        end
      end
      describe '------ リーグ登録 -------' do
        context 'リーグ登録後でプレイヤーを四人選択してプレイヤー決定ボタンを押した場合' do
          it '対局成績登録画面へ遷移し、選択されたプレイヤーがフォームに表示されている' do
            # Leagues_spec.rb - CRUDにて実施済み
          end
        end
      end

    end
    describe 'プレイヤー編集' do
      context 'プレイヤー名を編集した場合' do
        it '正しくプレイヤーが変更され、成績表示にも反映されていること' do
          login(user, current_p)
          created_p_by_user
          # プレイヤー一覧ページへ遷移
          visit players_path
          expect(current_path).to eq players_path
          # プレイヤー編集ページへ遷移
          find('a', text: '編集', match: :first).click
          expect(current_path).to eq edit_player_path(created_p_by_user)
          expect(page).to have_field('player_name', with: created_p_by_user.name)
          # プレイヤー名を編集
          fill_in 'player_name', with: 'p_updated'
          find('#update_player_btn').click
          # プレイヤー一覧ページへリダイレクトし、プレイヤー名が変更されていること
          expect(current_path).to eq players_path
          expect(page).to have_content 'プレイヤー名を更新しました'
          Player.find(created_p_by_user.id).name == 'p_updated'
        end
      end
    end
    describe 'プレイヤー削除' do
      context 'プレイヤー編集画面から削除した場合' do
        it 'プレイヤー一覧から表示が消え、記録上は"削除済みプレイヤー"と表示されていること' do
          login(user, current_p)
          created_p_by_user
          # プレイヤー一覧ページへ遷移
          visit players_path
          expect(current_path).to eq players_path
          # プレイヤー編集ページへ遷移
          find('a', text: '編集', match: :first).click
          expect(current_path).to eq edit_player_path(created_p_by_user)
          expect(page).to have_field('player_name', with: created_p_by_user.name)
          # プレイヤー削除
          name = created_p_by_user.name
          find('#delete_player_btn').click
          expect(page.driver.browser.switch_to.alert.text).to eq '本当にプレイヤーを削除しますか？'
          page.driver.browser.switch_to.alert.accept # OKボタンをクリック
          # プレイヤー一覧ページへリダイレクトされていることを検証
          expect(current_path).to eq players_path
          # 削除メッセージが表示されていることを検証
          expect(page).to have_content "プレイヤー : #{name}を削除しました"
          expect(page).to have_content "作成したプレイヤーはいません"
          p = Player.find(created_p_by_user.id)
          # 削除フラグがtrueに設定されていることを検証
          expect(p.deleted).to eq(true)
          # プレイヤーの名前が'削除済プレイヤー'に更新されていることを検証
          expect(p.name).to eq('削除済プレイヤー')
        end
      end
    end
  end

  describe '● VIEW' do
    before do
      login(user, current_p)
    end
    describe 'Player#new' do
      context 'プレイヤー選択画面で操作した場合' do
        it 'javascriptが正常に作動すること' do
          find('.top-btn_text', text: '四人麻雀').click
          expect(page).to have_css('#create_btn.inactive') # プレイヤー決定ボタンが非活性
          # 1 過去遊んだプレイヤーから選択する
          find('li', text: players[0].name).click
          find('li', text: players[1].name).click
          find('li', text: players[2].name).click
          expect(page).to have_css('#create_btn.inactive', count: 0) # プレイヤー決定ボタンが活性
          expect(page).to have_css('.selected_players-item', count: 4) # 選択したプレイヤーが4人表示されている
          # プレイヤー選択解除
          all('.player-delete-2')[0].click
          all('.player-delete-2')[0].click
          all('.player-delete-2')[0].click
          expect(page).to have_css('.selected_players-item', count: 1) # 選択したプレイヤーが4人表示されている
          expect(page).to have_css('#create_btn.inactive') # プレイヤー決定ボタンが非活性
          # 2 プレイヤーを新規作成する
          fill_in 'new-player-form', with: 'aaa'
          find('#new-player-create-btn', visible: true).click
          fill_in 'new-player-form', with: 'bbb'
          execute_script('document.querySelector("#new-player-create-btn").click();')
          fill_in 'new-player-form', with: 'ccc'
          execute_script('document.querySelector("#new-player-create-btn").click();')
          expect(page).to have_css('.selected_players-item', count: 4) # 選択したプレイヤーが4人表示されている
          expect(page).to have_css('#create_btn.inactive', count: 0) # プレイヤー決定ボタンが活性
          # 上限に達している場合アラート表示(プレイヤー選択)
          element = find('li', text: players[2].name, visible: :all)
          page.execute_script('arguments[0].click();', element.native)
          expect(page.driver.browser.switch_to.alert.text).to eq '上限に達しているため追加できません'
          page.driver.browser.switch_to.alert.accept # OKボタンをクリック
          # 上限に達している場合アラート表示(プレイヤー追加)
          fill_in 'new-player-form', with: 'ddd'
          execute_script('document.querySelector("#new-player-create-btn").click();')
          expect(page.driver.browser.switch_to.alert.text).to eq '上限に達しているため追加できません'
          page.driver.browser.switch_to.alert.accept # OKボタンをクリック
        end
      end
    end
  end

end