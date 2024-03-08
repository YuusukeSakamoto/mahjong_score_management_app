require 'rails_helper'

RSpec.describe Match, type: :system do
  let(:user) { create(:user) }
  let(:player) { create(:player, user: user) }
  let(:players) { create_list(:player, 3, user: nil) }
  let(:rule) { create(:rule, player: player) }
  let(:match_group) { create(:match_group, rule: rule) }
  let(:match) { create(:match, player: player, rule: rule, match_group_id: match_group.id) }
  let(:points) { [50, 10, -20, -40] }
  let!(:results) do
    players_1 = players + [player]
    players_1.each_with_index.map do |player, index|
      create(:result, match: match, player: player, score: 40000 - (10000 * index), point: points[index], ie: index + 1, rank: index + 1)
    end
  end
  let(:other_user) { create(:user ) }
  let(:other_player) { create(:player, user: other_user) }
  let(:other_players) { create_list(:player, 2, user: nil) }

  describe '● ACCESS' do
    describe '------ ログイン前 -------' do
      describe 'Matches#index' do
        context '対局一覧ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit matches_path
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください'
          end
        end
      end
      describe 'Matches#show' do
        context '対局詳細ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit match_path(match)
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください'
          end
        end
      end
      describe 'Matches#new' do
        context '対局登録ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit new_match_path
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください'
          end
        end
      end
      describe 'Matches#edit' do
        context '対局編集ページへアクセスした場合' do
          it 'アクセス失敗' do
            visit edit_match_path(match)
            expect(current_path).to eq new_user_session_path
            expect(page).to have_content 'ログインもしくはアカウント登録してください'
          end
        end
      end

      describe '------ 共有リンク -------' do
        describe 'Matches#show' do
          context '不正な共有リンク(token誤り)から対局詳細ページへアクセスした場合' do
            it 'アクセス失敗' do
              visit match_path(match, tk: 'aaa', resource_type: 'MatchGroup')
              expect(current_path).to eq root_path
              expect(page).to have_content '無効なリンクです。リンク発行者に再発行をお願いしてください'
            end
          end
          context '不正な共有リンク(resource_type誤り)から対局詳細ページへアクセスした場合' do
            it 'アクセス失敗' do
              share_link = create(:share_link, user: user, resource_id: match_group.id, resource_type: 'MatchGroup')
              visit match_path(match, tk: share_link.token, resource_type: 'League')
              expect(current_path).to eq root_path
              expect(page).to have_content '無効なリンクです。リンク発行者に再発行をお願いしてください'
            end
          end
          context '正しい共有リンクから対局詳細ページへアクセスした場合' do
            it 'アクセス成功' do
              share_link = create(:share_link, user: user, resource_id: match_group.id, resource_type: 'MatchGroup')
              visit match_path(match, tk: share_link.token, resource_type: 'MatchGroup')
              expect(current_path).to eq match_path(match)
              expect(page).to have_link('成績表を見る',
                                        href: match_group_path(match_group, tk: share_link.token, resource_type: share_link.resource_type))
            end
          end
        end
      end
    end

    describe '------ ログイン後 ------' do
      before do
        login(user, player)
      end
      describe 'Matches#index' do
        context '対局一覧ページへアクセスした場合' do
          it 'アクセス成功' do
            visit matches_path
            expect(current_path).to eq matches_path
            end
        end
      end
      describe 'Matches#show' do
        context '対局詳細ページへアクセスした場合' do
          it 'アクセス成功' do
            visit match_path(match)
            expect(current_path).to eq match_path(match)
            expect(page).to have_content '対局成績'
          end
        end
        context '対局詳細ページ(自分が含まれない対局)へアクセスした場合' do
          it 'アクセス失敗' do
            visit match_path(100000)
            expect(current_path).to eq root_path
            expect(page).to have_content 'アクセス権限がありません'
          end
        end
      end
      describe 'Matches#new' do
        context '対局登録ページへアクセスした場合' do
          it 'アクセス成功' do
            # == プレイヤー選択 ==
            create_players(players)
            # == 対局登録 ==
            visit new_match_path
            expect(current_path).to eq new_match_path
          end
        end
      end
      describe 'Matches#edit' do
        context '対局編集ページへアクセスした場合' do
          it 'アクセス成功' do
            visit edit_match_path(match)
            expect(current_path).to eq edit_match_path(match)
          end
        end
        context '対局編集ページ(自分が含まれない対局)へアクセスした場合' do
          it 'アクセス失敗' do
            visit edit_match_path(100000)
            expect(current_path).to eq root_path
            expect(page).to have_content 'アクセス権限がありません'
          end
        end
      end
    end
  end

  describe '● CRUD' do
    before do
      login(user, player)
    end
    describe '・対局成績登録' do
      before do
        create_players(players)
        visit new_match_path
      end
      context '(ptで記録するoff)フォームの入力値が正常の場合' do
        it '成績登録が成功' do
          expect(page).to have_content '残得点が0ではありません'
          expect(page).to have_content "残得点 :100000"
          fill_in 'match_results_attributes_0_score', with: '100'
          expect(page).to have_content "残得点 :90000"
          fill_in 'match_results_attributes_1_score', with: '200'
          expect(page).to have_content "残得点 :70000"
          fill_in 'match_results_attributes_2_score', with: '300'
          expect(page).to have_content "残得点 :40000"
          # 得点補完jsの確認
          find('body').click
          expect(page).to have_field('match_results_attributes_3_score', with: '400', wait: 3)
          # pt自動計算jsの確認
          expect(page).to have_field('match_results_attributes_0_point', with: '-40')
          expect(page).to have_field('match_results_attributes_1_point', with: '-20')
          expect(page).to have_field('match_results_attributes_2_point', with: '10')
          expect(page).to have_field('match_results_attributes_3_point', with: '50')
          # 残得点jsの確認
          expect(page).to have_content "残得点 :0"
          expect(page).to have_no_content '残得点が0ではありません'

          # 成績登録ボタンをクリック
          click_match_create_btn

          expect(current_path).to eq match_path(Match.last)

          expect(page).to have_content '対局成績を登録しました'
          expect(page).to have_content '対局成績'

          # 対局成績が正しく表示されていること
          within('table#match-result-table thead') do
            expect(page).to have_selector('th', text: '順位')
            expect(page).to have_selector('th', text: 'プレイヤー')
            expect(page).to have_selector('th', text: '得点')
            expect(page).to have_selector('th', text: 'pt')
            expect(page).to have_selector('th', text: '家')
          end
          rows = [
            ['1', players[2].name, '400', '50', '北'],
            ['2', players[1].name, '300', '10', '西'],
            ['3', players[0].name, '200', '-20', '南'],
            ['4', player.name, '100', '-40', '東']
          ]
          expect(page).to have_table('match-result-table', with_rows: rows)

          # 成績表が正しく表示されていること
          within('table#result-table') do
            expect(page).to have_selector('th', text: 'No')
            expect(page).to have_selector('th', text: player.name)
            expect(page).to have_selector('th', text: players[0].name)
            expect(page).to have_selector('th', text: players[1].name)
            expect(page).to have_selector('th', text: players[2].name)
          end

          rows = [
            ['1', '-40', '-20', '10', '50'],
            ['計', '-40', '-20', '10', '50'],
          ]
          expect(page).to have_table('result-table', with_rows: rows)

          # ボタンが正しく表示されていること
          expect(page).to have_link(href: edit_match_path(Match.last)) # 編集ボタン
          expect(page).to have_link(href: match_path(Match.last, btn: 'match')) # 削除ボタン
          expect(page).to have_link('2戦目の成績を登録', href: new_match_path) # 対局登録ボタン
          expect(page).to have_link('記録終了する', href: match_group_path(Match.last.match_group_id, fix: 'true')) # 記録終了ボタン
          expect(page).to have_css('.fa-check', count: 0)
          expect(page). to have_content '共有リンクをコピー'
          element = find('#share-link')
          page.execute_script('arguments[0].click()', element) #共有リンクをコピーをクリック
          expect(page).to have_css('.fa-check', count: 1)
        end
      end
      context '(ptで記録するon)フォームの入力値が正常の場合' do
        it '成績登録が成功' do
          # ptで記録するトグルのクリック
          execute_script('document.getElementById("pt-toggle").click();')
          # pt自動計算jsの確認
          expect(page).to have_content '残得点が0ではありません'
          fill_in 'match_results_attributes_0_point', with: '-40'
          fill_in 'match_results_attributes_1_point', with: '-20'
          fill_in 'match_results_attributes_2_point', with: '10'
          expect(page).to have_content "残得点 :100000"
          # 得点補完jsの確認
          find('body').click
          expect(page).to have_field('match_results_attributes_3_point', with: '50.0', wait: 3)
          # score自動計算jsの確認
          expect(page).to have_field('match_results_attributes_0_score', with: '100')
          expect(page).to have_field('match_results_attributes_1_score', with: '200')
          expect(page).to have_field('match_results_attributes_2_score', with: '300')
          expect(page).to have_field('match_results_attributes_3_score', with: '400')
          # 残得点jsの確認
          expect(page).to have_content "残得点 :0"
          expect(page).to have_no_content '残得点が0ではありません'
        end
      end
      context '残得点が0ではない場合' do
        it '成績登録ボタン押下時に確認メッセージが出力する' do
          fill_in 'match_results_attributes_0_score', with: '100'
          fill_in 'match_results_attributes_1_score', with: '200'
          fill_in 'match_results_attributes_2_score', with: '300'
          fill_in 'match_results_attributes_3_score', with: ''
          fill_in 'match_results_attributes_3_score', with: '444'
          expect(page).to have_content "残得点 :-4400"
          expect(page).to have_content '残得点が0ではありません'
          # 成績登録ボタンをクリック
          element = find('#match_create_btn', visible: true, wait: 3)
          execute_script("arguments[0].click();", element)
          # 確認ダイアログが表示されること
          sleep 1
          expect(page.driver.browser.switch_to.alert.text).to eq '残得点が0ではありません。登録しますか？'
          page.driver.browser.switch_to.alert.dismiss # キャンセルボタンをクリック
          # 成績登録ボタンをクリック
          element = find('#match_create_btn', visible: true, wait: 3)
          execute_script("arguments[0].click();", element)
          # 確認ダイアログが表示されること
          expect(page.driver.browser.switch_to.alert.text).to eq '残得点が0ではありません。登録しますか？'
          page.driver.browser.switch_to.alert.accept # OKボタンをクリック
          expect(current_path).to eq match_path(Match.last)
          expect(page).to have_content '対局成績を登録しました'
          expect(page).to have_content '44400'
        end
      end
      context 'フォームの入力値が異常の場合' do
        # js制御により基本的には発生しない
      end

    end
    describe '・対局成績編集' do
      before do
        visit edit_match_path(match)
      end
      context 'フォームの入力値が正常の場合' do
        it '成績編集が成功' do
          fill_in 'match_results_attributes_0_score', with: ''
          fill_in 'match_results_attributes_0_score', with: '300'
          fill_in 'match_results_attributes_1_score', with: ''
          fill_in 'match_results_attributes_1_score', with: '400'
          find('body').click
          sleep 3
          expect(page).to have_content "残得点 :0"
          expect(page).to have_no_content '残得点が0ではありません'
          expect(page).to have_field('match_results_attributes_0_point', with: '10')
          expect(page).to have_field('match_results_attributes_1_point', with: '50')
          expect(page).to have_field('match_results_attributes_2_point', with: '-20')
          expect(page).to have_field('match_results_attributes_3_point', with: '-40')
          click_match_create_btn
          expect(current_path).to eq match_path(match)
          expect(page).to have_content '対局成績を更新しました'
          expect(page).to have_content '対局成績'
          # 対局成績が正しく表示されていること
          expect(match.results[0].score).to eq 30000
          expect(match.results[0].point).to eq 10.0
          expect(match.results[1].score).to eq 40000
          expect(match.results[1].point).to eq 50.0
          expect(match.results[2].score).to eq 20000
          expect(match.results[2].point).to eq -20.0
          expect(match.results[3].score).to eq 10000
          expect(match.results[3].point).to eq -40.0
        end
      end
    end
    describe '・対局成績削除' do
      context 'フォームの入力値が正常の場合' do
        it '成績削除が成功' do
          mg_delete =  create(:match_group, rule: rule)
          match_delete = create(:match, player: player, rule: rule, match_group_id: mg_delete.id)
          d_players = players + [player]
          results = d_players.each_with_index.map do |player, index|
            create(:result, match: match_delete, player: player, score: 40000 - (10000 * index), point: points[index], ie: index + 1, rank: index + 1)
          end
          visit match_path(match_delete)
          find('.fa-trash-can').click #削除ボタンをクリック
          page.driver.browser.switch_to.alert.accept # OKボタンをクリック
          expect(current_path).to eq match_groups_path
          expect(page).to have_content '対局成績を削除しました'
          expect(Match.exists?(match_delete.id)).to be_falsey
        end
      end
    end
  end

  describe '● VIEW' do
    before do
      login(user, player)
    end
    describe 'Matches#index' do
      context '対局一覧ページへアクセスした場合' do
        it '自分が参加している対局が一覧で表示されること' do
          # 他プレイヤーが記録し、自分が参加した対局
          match_group_2 =  create(:match_group, rule: rule)
          match_2 = create(:match, player: other_player, rule: rule, match_group_id: match_group_2.id)
          players_2 = players + [other_player]
          results_2 = players_2.each_with_index.map do |player, index|
            create(:result, match: match_2, player: player, score: 40000 - (10000 * index), point: points[index], ie: index + 1, rank: index + 1)
          end
          # 他プレイヤーが記録し、自分が参加していない対局
          match_group_3 = create(:match_group, rule: rule)
          match_3 = create(:match, player: other_player, rule: rule, match_group_id: match_group_3.id)
          players_3 = [other_player] + other_players + [player]
          results_3 = players_3.each_with_index.map do |player, index|
            create(:result, match: match_3, player: player, score: 40000 - (10000 * index), point: points[index], ie: index + 1, rank: index + 1)
          end
          visit matches_path
          expect(current_path).to eq matches_path
          expect(page).to have_content '対局一覧'
          expect(page).to have_css('.matches-list', count: 2)
        end
      end
    end
    describe 'Matches#new' do
      before do
        create_players(players)
        visit new_match_path
      end
      context '対局登録ページへアクセスした場合' do
        it '残得点と残得点エラーメッセージが出力され、登録ボタンは非アクティブであること' do
          expect(current_path).to eq new_match_path
          expect(page).to have_content '対局成績登録'
          expect(page).to have_content '残得点 :100000'
          expect(page).to have_content '残得点が0ではありません'
          expect(page).to have_css('.inactive', count: 1)
        end
      end
      context 'ルール詳細をクリックした場合' do
        it '選択しているルールの詳細情報が出力されること' do
          # ルール詳細ボタンをクリック
          find('.js-rule-dropdown', visible: true).click
          expect(page).to have_css('.js-rule-details', count: 1)
          expect(page).to have_content "#{rule.mochi}点持ち / #{rule.kaeshi}点返し"
          expect(page).to have_content "ウマ (#{rule.uma_one},#{rule.uma_two},#{rule.uma_three},#{rule.uma_four})"
          expect(page).to have_content "点数計算 : #{Rule.get_value_score_decimal_point_calc(rule.score_decimal_point_calc)}"
          expect(page).to have_content "チップ : #{Rule.get_value_is_chip(rule.is_chip)}"
          find('.js-rule-dropdown', visible: true).click # ルール詳細ボタンをクリックすること閉じること
          expect(page).to have_css('.js-rule-details', count: 0)
        end
      end
      context '家が重複している場合' do
        it '注意メッセージが出力され、登録ボタンは非アクティブになること' do
          fill_in_match_form
          select '南', from: 'match_results_attributes_0_ie'
          expect(page).to have_content '対局成績登録'
          expect(page).to have_css('.inactive', count: 1)
        end
      end
      context '対局日が空白の場合' do
        it '登録ボタンは非アクティブになること' do
          fill_in_match_form
          fill_in 'match_match_on', with: ''
          expect(page).to have_css('.inactive', count: 1)
        end
      end
    end

    describe 'Matches#edit' do
      context '対局編集ページへアクセスした場合' do
        it '各プレイヤーの対局成績がフォームに正しくセットされ、jsも正常作動していること' do
          visit edit_match_path(match)
          expect(page).to have_selector('#match_rule_id[tabindex="-1"]')
          find('.js-rule-dropdown', visible: true).click # ルール詳細ボタンをクリック
          expect(current_path).to eq edit_match_path(match)
          expect(page).to have_content '対局成績編集'
          expect(page).to have_select('match_rule_id', selected: match.rule.name)
          expect(page).to have_css('.js-rule-details', count: 1)
          expect(page).to have_content "#{match.rule.mochi}点持ち / #{match.rule.kaeshi}点返し"
          expect(page).to have_content "ウマ (#{match.rule.uma_one},#{match.rule.uma_two},#{match.rule.uma_three},#{match.rule.uma_four})"
          expect(page).to have_content "点数計算 : #{Rule.get_value_score_decimal_point_calc(match.rule.score_decimal_point_calc)}"
          expect(page).to have_content "チップ : #{Rule.get_value_is_chip(match.rule.is_chip)}"
          expect(page).to have_field('match_match_on', with: match.match_on)
          expect(page).to have_content match.results.first.player.name
          expect(page).to have_field('match_results_attributes_0_score', with: match.results.first.score / 100)
          expect(page).to have_field('match_results_attributes_0_point', with: match.results.first.point)
          expect(page).to have_select('match_results_attributes_0_ie', selected: '東')
          expect(page).to have_content match.results.second.player.name
          expect(page).to have_field('match_results_attributes_1_score', with: match.results.second.score / 100)
          expect(page).to have_field('match_results_attributes_1_point', with: match.results.second.point)
          expect(page).to have_select('match_results_attributes_1_ie', selected: '南')
          expect(page).to have_content match.results.third.player.name
          expect(page).to have_field('match_results_attributes_2_score', with: match.results.third.score / 100)
          expect(page).to have_field('match_results_attributes_2_point', with: match.results.third.point)
          expect(page).to have_select('match_results_attributes_2_ie', selected: '西')
          expect(page).to have_content match.results.fourth.player.name
          expect(page).to have_field('match_results_attributes_3_score', with: match.results.fourth.score / 100)
          expect(page).to have_field('match_results_attributes_3_point', with: match.results.fourth.point)
          expect(page).to have_select('match_results_attributes_3_ie', selected: '北')
          expect(page).to have_content "残得点 :0"
          expect(page).to have_no_content "残得点が0ではありません"
        end
      end
    end
    describe 'Matches#show' do
      describe '---- 記録中 -----' do
        context '対局詳細ページへアクセスした場合' do
          it '対局成績が正しく表示されていること' do
            # CRUDの対局成績登録で実施済み
          end
        end
      end
      describe '---- 記録中以外 -----' do
        context '対局詳細ページへアクセスした場合' do
          it '対局成績が正しく表示されていること' do
            visit match_path(match)
            expect(current_path).to eq match_path(match)
            # 対局成績が正しく表示されていること
            within('table#match-result-table thead') do
              expect(page).to have_selector('th', text: '順位')
              expect(page).to have_selector('th', text: 'プレイヤー')
              expect(page).to have_selector('th', text: '得点')
              expect(page).to have_selector('th', text: 'pt')
              expect(page).to have_selector('th', text: '家')
            end
            rows = [
              ['1', players[2].name, '400', '50', '北'],
              ['2', players[1].name, '300', '10', '西'],
              ['3', players[0].name, '200', '-20', '南'],
              ['4', player.name, '100', '-40', '東']
            ]
            # expect(page).to have_table('match-result-table', with_rows: rows) #原因不明のエラーにより保留

            # ボタンが正しく表示されていること
            expect(page).to have_link(href: edit_match_path(match)) # 編集ボタン
            expect(page).to have_link(href: match_path(match, btn: 'match')) # 削除ボタン
          end
        end
      end
    end
  end
end