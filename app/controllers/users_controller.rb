class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def new
    @user = User.new

  end
  
  def create

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
