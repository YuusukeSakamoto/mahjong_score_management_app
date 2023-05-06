class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy ]
  before_action :prohibit_not_group_user, only: %i[ edit update destroy ]
  
  def index
    @groups = Group.all
  end
  
  def show
  end
  
  def new
    @group = Group.new
  end
  
  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to new_user_path(group_id: @group.id), flash: {notice: 'グループを登録しました'}
    else
      render :new, status: :unprocessable_entity
    end
  end
    
  def edit
  end
  
  def update
    if @group.update(group_params)
      redirect_to group_path(@group), flash: {notice: "グループ情報を更新しました"}
    else
      render :edit
    end
  end
  
  def destroy
    @group.destroy
    redirect_to groups_url, flash: {notice: 'グループを削除しました'}
  end
  
  private 
  
    def set_group
      @group = Group.find(params[:id])  
    end
    
    def group_params
      params.require(:group).permit(:name, :member_count).merge(user_id: current_user.id)
    end
    
    #グループユーザー以外のアクセスを禁止する
    def prohibit_not_group_user
      redirect_to root_path, 
      flash: {alert: 'グループ参加者でなければ、編集できません。'} and return unless current_user == @group.user
    end
end