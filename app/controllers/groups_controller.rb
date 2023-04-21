class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy ]
  
  def index
    @groups = Group.all
  end
  
  def show
  end
  
  def edit
  end
  
  def new
    @group = Group.new
  end
  
  def create
    @group = current_user.groups.build(group_params)
    
    if @group.save
      redirect_to group_path(@group), notice: 'グループを登録しました'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @group.update(group_params)
      flash[:notice] = "トレーニングを更新しました"
      redirect_to group_path(@group), notice: 'グループ情報を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @group.destroy
    
    redirect_to groups_url, notice: 'グループを削除しました'
  end
  
  private 
  
    def set_group
      @group = Group.find(params[:id])  
    end
    
    def group_params
      params.require(:group).permit(:name)
    end
  
end
