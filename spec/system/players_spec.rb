require 'rails_helper'

RSpec.describe Player, type: :system do
  let(:user) { create(:user) }
  let(:current_p) { create(:player, user: user) }
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

    end

    describe '------ ログイン後 -------' do

    end
  end

  describe '● OPERATION' do
    before do
      login(user, current_p)
    end
    describe '------ ルール登録済み -------' do
      context 'プレイヤーを四人選択してプレイヤー決定ボタンを押した場合' do
        it '対局登録ページへ遷移し、選択されたプレイヤーがフォームに表示されている' do
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
          expect(page).to have_content "残得点：100000"
          expect(page).to have_content "残得点が0ではありません"
        end
      end
    end
    describe '------ ルール未登録 -------' do

    end
  end
end