class Api::V1::UsersController < ApplicationController

  def create
    #byebug
    @user = User.create(user_params)
    if @user.valid?
      render json: { user: UserSerializer.new(@user) }, status: :created
    else
      render json: { error: 'failed to create user' }, status: :not_acceptable
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :bio, :image_url)
  end

end
