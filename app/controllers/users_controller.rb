class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def new
    @user = User.new
    # @form = Form::UserCollection.new
    # @users = UserCollection.new
    @form = Form::UserCollection.new
  end
  
  def create
    @form = Form::UserCollection.new(user_collection_params)
    if @form.save
      redirect_to users_path, notice: "商品を登録しました"
    else
      flash.now[:alert] = "商品登録に失敗しました"
      render :new
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  private
   
    def user_params
      params.require(:user).permit(:name)  
    end
  
    def users_params
      params.require(:users)
    end
    
    def user_collection_params
        params.require(:form_user_collection)
        .permit(users_attributes: [:name])
    end
end
