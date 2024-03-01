module MatchModule
  # 対局登録フォームを埋める
  def fill_in_match_form
    fill_in 'match_results_attributes_0_score', with: '100'
    fill_in 'match_results_attributes_1_score', with: '200'
    fill_in 'match_results_attributes_2_score', with: '300'
    find('body').click
  end

  # 対局登録ボタンをクリック
  def click_match_create_btn
    element = find('#match_create_btn', visible: true, wait: 3)
    execute_script("arguments[0].click();", element)
  end

end
