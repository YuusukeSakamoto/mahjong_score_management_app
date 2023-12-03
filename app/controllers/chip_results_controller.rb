class ChipResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match_group, :set_rule, only: [:edit, :update]

  def edit
    redirect_to root_path, alert: FlashMessages::EDIT_DENIED and return unless @match_group.players.include?(current_player)
    redirect_to root_path, alert: FlashMessages::CHIP_EDIT_DENIED and return unless @match_group.rule.is_chip
    @players = @match_group.players
    mg_chip_results = @match_group.chip_results.select(:match_group_id, :player_id, :number)
    chip_results_ary = mg_chip_results.map do |cr|
      cr.attributes.delete("id") # idは除いてハッシュ化
      cr
    end
    @form = Form::ChipResultCollection.new(chip_results_ary, 'edit')
  end

  def update
    redirect_to root_path, alert: FlashMessages::UPDATE_DENIED and return unless @match_group.players.include?(current_player)
    redirect_to root_path, alert: FlashMessages::CHIP_UPDATE_DENIED and return unless @match_group.rule.is_chip
    @form = Form::ChipResultCollection.new(chip_results_collection_params, 'update')
    @form.chip_results.each do |chip_result|
      chip_result.point = calculate_point(chip_result)
    end
    if @form.save(@match_group)
      end_record
      redirect_to match_group_path(@match_group.id, fix: true), notice: FlashMessages::END_RECORD
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
      @match_group = MatchGroup.find_by(id: params[:match_group_id])
      redirect_to root_path, alert: FlashMessages::CHIP_RESULTS_NOT_FOUND and return unless @match_group
    end

    def set_rule
      @rule = Rule.find_by(id: @match_group.rule.id)
      redirect_to root_path, alert: FlashMessages::ERROR and return unless @rule
    end

    def calculate_point(chip_result)
      chip_result.number * @rule.chip_rate
    end

end
