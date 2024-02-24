require 'rails_helper'

RSpec.describe League, type: :system do
  let(:user) { create(:user) }
  let(:current_p) { create(:player, user: user) }
  let(:other_players) { create_list(:player, 3) }
  let(:rule) { create(:rule, player: current_p) }
  # 自分が作成し、自分も参加しているリーグ
  let!(:league_1) { create(:league, player: current_p, rule: rule) }
  let!(:league_players) do
    players = [current_p] + other_players
    players.each do |p|
      create(:league_player, player: p, league: league_1)
    end
  end
  # 自分が作成し、自分は参加していないリーグ
  let!(:league_2) { create(:league, player: current_p, rule: rule) }
  let!(:other_player) { create(:player) }
  let!(:league_players_2) do
    players = [other_player] + other_players
    players.each do |p|
      create(:league_player, player: p, league: league_2)
    end
  end
  # 他人が作成し、自分も参加しているリーグ
  let!(:league_3) { create(:league, player: other_player, rule: rule) }
  let!(:league_players_3) do
    other_players = create_list(:player, 2)
    players = [current_p] + [other_player] + other_players
    players.each do |p|
      create(:league_player, player: p, league: league_3)
    end
  end
  # 他人が作成し、自分は参加していないリーグ
  let!(:league_4) { create(:league, player: other_player, rule: rule) }
  let!(:league_players_4) do
    players = [other_player] + other_players
    players.each do |p|
      create(:league_player, player: p, league: league_4)
    end
  end
  # 自分が作成し、プレイヤー未選択のリーグ
  let!(:league_5) { create(:league, player: current_p, rule: rule) }


  describe '● ACCESS' do
    describe '------ ログイン前 -------' do
      describe 'Leagues#index' do
        context 'リーグ一覧ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit leagues_path
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください'
          end
        end
      end
      describe 'Leagues#show' do
        context 'リーグ詳細ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit league_path(league_1)
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください'
          end
        end
      end
      describe 'Leagues#new' do
        context 'リーグ作成ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit new_league_path
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください'
          end
        end
      end
      describe 'Leagues#edit' do
        context 'リーグ編集ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit edit_league_path(league_1)
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください'
          end
        end
      end
    end
    describe '------ ログイン後 -------' do
      before do
        login(user, current_p)
      end
      describe 'Leagues#index' do
        context 'リーグ一覧ページへアクセスした場合' do
          it 'アクセス成功し、自分が作成したリーグ・参加しているリーグが表示される' do
            visit leagues_path
            expect(current_path).to eq leagues_path
            expect(page).to have_content 'リーグ一覧'
            expect(page).to have_css('.league_item', count: 4)
            expect(page).to have_content league_1.name
            expect(page).to have_content league_2.name
            expect(page).to have_content league_3.name
            expect(page).to have_content league_5.name
            expect(page).to have_css('.inactive-link', count: 2) # league_5の記録/成績ボタンは非活性
            expect(page).to have_link('プレイヤー選択へ', href: new_player_path(play_type: league_5.play_type, league: league_5.id))
            expect(page).to have_link('削除', href: league_path(league_5))
          end
        end
      end
      describe 'Leagues#new' do
        context 'リーグ詳細ページへアクセスした場合' do
          it 'アクセス成功し、~' do

          end
        end
      end
      describe 'Leagues#new' do
        context 'リーグ作成ページへアクセスした場合' do
          it 'アクセス成功し、フォームのjs正常作動する' do
            rule_no_tip = create(:rule, player: current_p, is_chip: false)
            visit new_league_path
            rule = current_p.rule_list(4).first
            expect(current_path).to eq new_league_path
            expect(page).to have_content 'リーグ作成'
            # ルール詳細ボタンをクリックすると、ルール詳細が表示される
            find('.js-rule-dropdown', visible: true).click
            expect(page).to have_css('.js-rule-details', count: 1)
            expect(page).to have_content "#{rule.mochi}点持ち / #{rule.kaeshi}点返し"
            expect(page).to have_content "ウマ (#{rule.uma_one},#{rule.uma_two},#{rule.uma_three},#{rule.uma_four})"
            expect(page).to have_content "点数計算 : #{Rule.get_value_score_decimal_point_calc(rule.score_decimal_point_calc)}"
            expect(page).to have_content "チップ : #{Rule.get_value_is_chip(rule.is_chip)}"
            # チップなしルールを選択すると、"リーグ成績にチップptを含めるか"の選択が非表示になる
            select rule_no_tip.name, from: 'league_rule_id'
            expect(page).to have_css('.js-rule-details', count: 1)
            expect(page).to have_content "#{rule_no_tip.mochi}点持ち / #{rule_no_tip.kaeshi}点返し"
            expect(page).to have_content "ウマ (#{rule_no_tip.uma_one},#{rule_no_tip.uma_two},#{rule_no_tip.uma_three},#{rule_no_tip.uma_four})"
            expect(page).to have_content "点数計算 : #{Rule.get_value_score_decimal_point_calc(rule_no_tip.score_decimal_point_calc)}"
            expect(page).to have_content "チップ : #{Rule.get_value_is_chip(rule_no_tip.is_chip)}"
          end
        end
      end
      describe 'Leagues#edit' do
        context 'リーグ編集ページへアクセスした場合' do
          it 'アクセス成功し、~' do

          end
        end
      end
    end
  end

end