class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find_by(id: params[:id])
    redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @user
  end
end