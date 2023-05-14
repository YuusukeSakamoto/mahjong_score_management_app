class ResultsController < ApplicationController
  before_action :set_result, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @results = Result.all.where(player_id: params[:player_id])
  end

  def show
  end

  def new
    @result = Result.new
    # @form = Form::ResultCollection.new
  end

  def create
    # @form = Form::ResultCollection.new(result_collection_params)
    
    # if @form.save
    #   redirect_to "/"
    # else
    #   flash.now[:alert] = "プレイヤー選択に失敗しました"
    #   render :new
    # end
    
    @result = Result.new(result_params)
    if @result.save
      redirect_to '/'
    else
      # set_player
      render :new
    end
  end

  def edit
    set_player
  end

  def update
    # redirect_to root_path, flash: {alert: '投稿者でなければ、更新できません。'} and return unless current_user == @result.user

    if @result.update(result_params)
      redirect_to player_results_path, flash: {notice: "ルール < #{@result.name} > を編集しました"}
    else
      set_player
      render :edit
    end
  end

  def destroy
    # redirect_to root_path, flash: {alert: '投稿者でなければ、削除できません。'} and return unless current_user == @result.user
    @result.destroy
    redirect_to player_results_path, flash: {notice: "ルール < #{@result.name} > を削除しました"}
  end

  private
    
    def set_result_player
      @result = Result.new
      set_player
      session[:players] = params[:players] unless params[:players].nil? #params[:players] → PlayersControllerのcreateアクションから受け取る
    end
  
    def result_params
      params.require(:result).
        permit(:rule_id, :match_time, :score, :point, :ie, :memo, :recorded_player_id).
        merge(player_id: current_user.player.id)
    end
    
    def result_collection_params
        params.require(:form_result_collection)
        .permit(results_attributes: [:rule_id, :match_time, :score, :point, :ie, :memo, :recorded_player_id])
    end
  
end
