class UnsubscribesController < ApplicationController
  # アカウント削除
  before_action :authenticate_user!
  
  def index
    @user = User.find_by(id: current_user.id)
  end
end