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
            visit new_player_path(play_type: 4)
            find('li', text: players[0].name).click
            find('li', text: players[1].name).click
            find('li', text: players[2].name).click
            find('#create_btn', visible: true).click # プレイヤー作成ボタンをクリック
            # == 対局登録 ==
            visit new_match_path
            expect(current_path).to eq new_match_path
            expect(page).to have_content '対局成績登録'
            expect(page).to have_content '残得点：100000'
            expect(page).to have_content '残得点が0ではありません'
          end
        end
      end
      describe 'Matches#edit' do
        context '対局編集ページへアクセスした場合' do
          it 'アクセス成功' do
            visit edit_match_path(match)
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
            expect(page).to have_content "残得点：0"
            expect(page).to have_no_content "残得点が0ではありません"
          end
        end
      end
    end
  end
end