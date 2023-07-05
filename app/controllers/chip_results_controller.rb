class ChipResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match_group, :set_rule, only: [:edit, :create]
  
  def edit
    @players = @match_group.players
    mg_chip_results = @match_group.chip_results.select(:match_group_id, :player_id, :number)
    chip_results_ary = mg_chip_results.map do |cr|
      cr.attributes.delete("id") # idは除いてハッシュ化
      cr
    end
    @form = Form::ChipResultCollection.new(chip_results_ary, 'edit')
  end

  def create
    @form = Form::ChipResultCollection.new(chip_results_collection_params, 'create')
    @form.chip_results.each do |chip_result|
      chip_result.point = calculate_point(chip_result)
    end
    if @form.save(@match_group)
      end_record
      redirect_to match_group_path(@match_group.id, fix: true), notice: "記録を終了しました"
    else
      @players = @match_group.players
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
    
end
