# frozen_string_literal: true

class ChipResultsController < ApplicationController
  before_action :authenticate_user!, only: [:update]
  before_action :set_match_group, :set_rule, only: %i[edit update]

  def edit
    if params[:tk] && params[:resource_type]
      @share_token = validate_share_token(params[:tk],
                                          params[:resource_type],
                                          'chip_results_controller',
                                          @match_group) # トークンが有効か判定
    else
      redirect_to(user_session_path,
                  alert: FlashMessages::UNAUTHENTICATED) && return unless current_user #ログインユーザーがアクセスしているか判定
      unless @match_group.players.include?(current_player)
        redirect_to(root_path,
                    alert: FlashMessages::EDIT_DENIED) && return
      end
      redirect_to(root_path, alert: FlashMessages::CHIP_EDIT_DENIED) && return unless @match_group.rule.is_chip
    end

    @players = @match_group.players
    mg_chip_results = @match_group.chip_results.select(:match_group_id, :player_id, :number)
    chip_results_ary = mg_chip_results.map do |cr|
      cr.attributes.delete('id') # idは除いてハッシュ化
      cr
    end
    @form = Form::ChipResultCollection.new(chip_results_ary, 'edit')
  end

  def update
    unless @match_group.players.include?(current_player)
      redirect_to(root_path,
                  alert: FlashMessages::UPDATE_DENIED) && return
    end
    redirect_to(root_path, alert: FlashMessages::CHIP_UPDATE_DENIED) && return unless @match_group.rule.is_chip

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
          .permit(chip_results_attributes: %i[match_group_id player_id number is_temporary])
  end

  def set_match_group
    @match_group = MatchGroup.find_by(id: params[:match_group_id])
    redirect_to(root_path, alert: FlashMessages::CHIP_RESULTS_NOT_FOUND) && return unless @match_group
  end

  def set_rule
    @rule = Rule.find_by(id: @match_group.rule.id)
    redirect_to(root_path, alert: FlashMessages::ERROR) && return unless @rule
  end

  def calculate_point(chip_result)
    chip_result.number * @rule.chip_rate
  end

end
