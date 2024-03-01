require 'rails_helper'

RSpec.describe 'Recordings', type: :system do
  let(:user) { create(:user) }
  let(:player) { create(:player, user: user) }
  let(:players) { create_list(:player, 3, user: nil) }
  let(:rule_1) { create(:rule, player: player) }
  let(:rule_2) { create(:rule, player: player, is_chip: true, chip_rate: 2) }
  let(:match_group) { create(:match_group, rule: rule_1) }
  let(:match) { create(:match, player: player, rule: rule_1, match_group_id: match_group.id) }
  let(:points) { [50, 10, -20, -40] }
  let!(:results) do
    players_1 = players + [player]
    players_1.each_with_index.map do |player, i|
      create(:result, match: match, player: player, score: 40000 - (10000 * i), point: points[i], ie: i + 1, rank: i + 1)
    end
  end
  let!(:league_1) { create(:league, player: player, rule: rule_1) }
  let!(:league_players) do
    players_2 = players + [player]
    players_2.each do |p|
      create(:league_player, player: p, league: league_1)
    end
  end


  describe '● プレイヤー選択から記録終了まで' do
    before do
      login(user, player)
    end
    describe '・対局成績登録(連続)' do
      before do
        create_players(players) # プレイヤー選択
      end
      context 'チップなしルールの場合' do
        it '5戦目までの成績登録が成功し、成績表を表示する' do
          visit new_match_path  # 対局登録ページへ遷移
          record_match_5times
          scroll_to(find('.main-btn--white-orange'))
          # 記録終了ボタンをクリック
          element = find('.main-btn--white-orange', visible: true, wait: 3)
          execute_script("arguments[0].click();", element)
          # 確認ダイアログをokボタンをクリック
          page.driver.browser.switch_to.alert.accept # OKボタンをクリック

          expect(current_path).to eq match_group_path(Match.last.match_group_id)
          # 成績表が正しく表示されていること
          expect(page).to have_content '成績表'
          rows = [
            ['1', '-40', '-20', '10', '50'],
            ['2', '-40', '-20', '10', '50'],
            ['3', '-40', '-20', '10', '50'],
            ['4', '-40', '-20', '10', '50'],
            ['5', '-40', '-20', '10', '50'],
            ['計', '-200', '-100', '50', '250'],
          ]
          expect(page).to have_table('result-table', with_rows: rows)

        end
      end
      context 'チップありルールの場合' do
        it '5戦目までの成績登録が成功し、チップ集計後、成績表を表示する' do
          rule_2 = create(:rule, player: player, is_chip: true, chip_rate: 2)
          visit new_match_path  # 対局登録ページへ遷移
          select rule_2.name, from: 'match_rule_id'
          record_match_5times
          scroll_to(find('.main-btn--white-orange'))
          # チップ集計ボタンをクリック
          element = find('.main-btn--white-orange', visible: true, wait: 3)
          execute_script("arguments[0].click();", element)
          # 確認ダイアログをokボタンをクリック
          page.driver.browser.switch_to.alert.accept # OKボタンをクリック

          # チップ集計ページへ推移
          expect(current_path).to eq edit_match_group_chip_results_path(Match.last.match_group_id)
          expect(page).to have_content 'チップ集計'
          fill_in 'tip_number_0', with: ''
          fill_in 'tip_number_0', with: '2'
          fill_in 'tip_number_1', with: ''
          fill_in 'tip_number_1', with: '4'
          fill_in 'tip_number_2', with: ''
          fill_in 'tip_number_2', with: '-6'
          fill_in 'tip_number_3', with: ''
          fill_in 'tip_number_3', with: '0'
          find('#tip_create_btn').click
          # 成績表へ推移
          expect(current_path).to eq match_group_path(Match.last.match_group_id)
          # 成績表が正しく表示されていること
          expect(page).to have_content '成績表'
          rows = [
            ['1', '-40', '-20', '10', '50'],
            ['2', '-40', '-20', '10', '50'],
            ['3', '-40', '-20', '10', '50'],
            ['4', '-40', '-20', '10', '50'],
            ['5', '-40', '-20', '10', '50'],
            ['', '4', '8', '-12', '0'],
            ['計', '-196', '-92', '38', '250'],
          ]
          expect(page).to have_table('result-table', with_rows: rows)
        end
      end
    end
  end

  describe '● 記録中の禁止操作制御' do
    before do
      login(user, player)
    end
    context '記録中にリーグ登録しようとする場合' do
      it 'エラーメッセージ出力しtopページへ戻る' do
        create_players(players) # プレイヤー選択
        visit new_match_path  # 対局登録ページへ遷移
        record_match_1times
        find('a.text-nowrap.current', text: 'リーグ戦').hover
        click_link 'リーグ作成'
        expect(page).to have_content '記録中はリーグ作成できません'
        expect(current_path).to eq root_path
      end
    end
    context '記録中にルール登録しようとする場合' do
      it 'エラーメッセージ出力しtopページへ戻る' do
        create_players(players) # プレイヤー選択
        visit new_match_path  # 対局登録ページへ遷移
        record_match_1times
        find('a.text-nowrap.current', text: 'ルール').hover
        click_link 'ルール登録'
        expect(page).to have_content '記録中はルール登録できません'
        expect(current_path).to eq root_path
      end
    end
    context '通常対局記録中に他のリーグ対局記録しようとする場合' do
      it 'エラーメッセージ出力しtopページへ戻る' do
        create_players(players) # プレイヤー選択
        visit new_match_path  # 対局登録ページへ遷移
        record_match_1times
        # リーグ一覧ページへ遷移
        find('a.text-nowrap.current', text: 'リーグ戦').hover
        click_link 'リーグ一覧'
        expect(current_path).to eq leagues_path
        # league_1の記録ボタンを押下すると記録できる
        click_link '記録'
        expect(page).to have_content '他の成績を記録中です'
        expect(current_path).to eq root_path
      end
    end
    context 'リーグ対局記録中に他のリーグ対局記録しようとする場合' do
      let!(:league_2) { create(:league, player: player, rule: rule_1) }
      let!(:league_players_2) do
        players_2 = players + [player]
        players_2.each do |p|
          create(:league_player, player: p, league: league_2)
        end
      end
      it 'エラーメッセージ出力しtopページへ戻る' do
        # リーグ一覧ページへ遷移
        find('a.text-nowrap.current', text: 'リーグ戦').hover
        click_link 'リーグ一覧'
        expect(current_path).to eq leagues_path
        # league_1の記録ボタンを押下すると記録できる(1戦目)
        all('.league_item')[1].find_link('記録').click
        record_match_1times
        # リーグ一覧ページへ遷移
        find('a.text-nowrap.current', text: 'リーグ戦').hover
        click_link 'リーグ一覧'
        # league_1の記録ボタンを押下すると記録できる(2戦目)
        all('.league_item')[1].find_link('記録').click
        fill_in_match_form
        expect(page).to have_content league_1.name
        find('#match_create_btn').send_keys(:enter)
        expect(page).to have_content '2戦目'
        expect(page).to have_content '3戦目の成績を登録'
        # リーグ一覧ページへ遷移
        find('a.text-nowrap.current', text: 'リーグ戦').hover
        click_link 'リーグ一覧'
        # league_2の記録ボタンを押下するとエラーメッセージが出力される
        all('.league_item')[0].find_link('記録').click
        expect(page).to have_content '他の成績を記録中です'
        expect(current_path).to eq root_path
      end
    end
  end

  private


  def record_match_1times
    # === 1戦目 ===
    fill_in_match_form
    find('#match_create_btn').send_keys(:enter)
    expect(page).to have_content '1戦目'
    expect(page).to have_content '2戦目の成績を登録'
    # 成績表が正しく表示されていること
    within('table#result-table') do
      expect(page).to have_selector('th', text: 'No')
      expect(page).to have_selector('th', text: players[0].name)
      expect(page).to have_selector('th', text: players[1].name)
      expect(page).to have_selector('th', text: players[2].name)
      expect(page).to have_selector('th', text: player.name)
    end
    rows = [
      ['1', '-40', '-20', '10', '50'],
      ['計', '-40', '-20', '10', '50'],
    ]
    expect(page).to have_table('result-table', with_rows: rows)
  end

  def record_match_5times
    # === 1戦目 ===
    fill_in_match_form
    find('#match_create_btn').send_keys(:enter)
    expect(page).to have_content '1戦目'
    expect(page).to have_content '2戦目の成績を登録'
    # 成績表が正しく表示されていること
    within('table#result-table') do
      expect(page).to have_selector('th', text: 'No')
      expect(page).to have_selector('th', text: players[0].name)
      expect(page).to have_selector('th', text: players[1].name)
      expect(page).to have_selector('th', text: players[2].name)
      expect(page).to have_selector('th', text: player.name)
    end
    rows = [
      ['1', '-40', '-20', '10', '50'],
      ['計', '-40', '-20', '10', '50'],
    ]
    expect(page).to have_table('result-table', with_rows: rows)
    find('.main-btn--white-green').click
    # === 2戦目 ===
    fill_in_match_form
    find('#match_create_btn').send_keys(:enter)
    expect(page).to have_content '2戦目'
    expect(page).to have_content '3戦目の成績を'
    # 成績表が正しく表示されていること
    rows = [
      ['1', '-40', '-20', '10', '50'],
      ['2', '-40', '-20', '10', '50'],
      ['計', '-80', '-40', '20', '100'],
    ]
    expect(page).to have_table('result-table', with_rows: rows)
    find('.main-btn--white-green').click
    # === 3戦目 ===
    fill_in_match_form
    find('#match_create_btn').send_keys(:enter)
    expect(page).to have_content '3戦目'
    expect(page).to have_content '4戦目の成績を登録'
    # 成績表が正しく表示されていること
    rows = [
      ['1', '-40', '-20', '10', '50'],
      ['2', '-40', '-20', '10', '50'],
      ['3', '-40', '-20', '10', '50'],
      ['計', '-120', '-60', '30', '150'],
    ]
    expect(page).to have_table('result-table', with_rows: rows)
    find('.main-btn--white-green').click
    # === 4戦目 ===
    fill_in_match_form
    find('#match_create_btn').send_keys(:enter)
    expect(page).to have_content '4戦目'
    expect(page).to have_content '5戦目の成績を登録'
    # 成績表が正しく表示されていること
    rows = [
      ['1', '-40', '-20', '10', '50'],
      ['2', '-40', '-20', '10', '50'],
      ['3', '-40', '-20', '10', '50'],
      ['4', '-40', '-20', '10', '50'],
      ['計', '-160', '-80', '40', '200'],
    ]
    expect(page).to have_table('result-table', with_rows: rows)
    find('.main-btn--white-green').click
    # === 5戦目 ===
    fill_in_match_form
    find('#match_create_btn').send_keys(:enter)
    expect(page).to have_content '5戦目'
    expect(page).to have_content '6戦目の成績を登録'
    # 成績表が正しく表示されていること
    rows = [
      ['1', '-40', '-20', '10', '50'],
      ['2', '-40', '-20', '10', '50'],
      ['3', '-40', '-20', '10', '50'],
      ['4', '-40', '-20', '10', '50'],
      ['5', '-40', '-20', '10', '50'],
      ['計', '-200', '-100', '50', '250'],
    ]
    expect(page).to have_table('result-table', with_rows: rows)
  end
end