class ChipResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match_group, :set_rule, only: [:new, :create]
  
  # 記録したor記録された成績表一覧を表示する / ログインユーザーのみ照会可能
  def new
    @players = @match_group.players
    mg_chip_results = @match_group.chip_results.select(:match_group_id, :player_id, :number)
    chip_results_ary = mg_chip_results.map do |cr|
      cr.attributes.delete("id") # idは除いてハッシュ化
      cr
    end
    @form = Form::ChipResultCollection.new(chip_results_ary, 'new')
  end
  
  def create
    @form = Form::ChipResultCollection.new(chip_results_collection_params, 'create')
    @form.chip_results.each do |chip_result|
      chip_result.point = calculate_point(chip_result)
    end
    delete_chip_results if @form.valid?
    if @form.save
      end_record
      redirect_to match_group_path(@match_group.id, fix: true), notice: "記録を終了しました"
    else
      render :new
    end
  end
  
  private 
    
    def chip_results_collection_params
        params.require(:form_chip_result_collection)
          .permit(chip_results_attributes: [:match_group_id, :player_id, :number, :is_temporary])
    end
    
    def set_match_group
      @match_group = MatchGroup.find(params[:match_group_id])
    end
    
    def set_rule
      @rule = Rule.find(@match_group.rule.id)
    end
    
    def calculate_point(chip_result)
      chip_result.number * @rule.chip_rate
    end
    
    def delete_chip_results
      ChipResult.where(match_group_id: @match_group.id).destroy_all
    end
end
