class ChipResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match_group, :set_rule, only: [:new, :edit]
  
  def index

  end
  
  # 記録したor記録された成績表一覧を表示する / ログインユーザーのみ照会可能
  def new
    @players = session[:players]
    @form = Form::ChipResultCollection.new(session_players_num)
  end
  
  def create
    @form = Form::ChipResultCollection.new(0 , chip_results_collection_params)
    @form.chip_results.each do |chip_result|
      chip_result.point = calculate_point(chip_result)
    end
    if @form.save
      mg = session[:mg]
      end_record
      redirect_to match_group_path(mg, fix: true), notice: "対局成績が確定しました"
    else
      render :new
    end
  end
  
  def edit
    @form = Form::ChipResultCollection.new(params[:play_type].to_i)
    @form.chip_results = @form.find(params[:match_group_id])
    @players = Player.get_players_name(@form.chip_results)
  end

  def update
    binding.pry
    @update_form = Form::ChipResultCollection.new(0 , chip_results_collection_params)
  end
  
  def destroy
    
  end
  
  private 
    
    def chip_results_collection_params
        params.require(:form_chip_result_collection)
          .permit(chip_results_attributes: [:match_group_id, :player_id, :number])
    end
    
    def set_match_group
      @match_group = MatchGroup.find(params[:match_group_id])
    end
    
    def set_rule
      @rule = Rule.find(@match_group.rule.id)
    end
    
    def calculate_point(chip_result)
      chip_result.number * Rule.find(session[:rule]).chip_rate
    end
end
