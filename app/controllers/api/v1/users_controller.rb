class Api::V1::UsersController < ApplicationController
  skip_before_action :authorized, only: [:create]

  def create
    #byebug
    @user = User.create(user_params)
    if @user.valid?
      # passing encode_token a payload of user id
      @token = encode_token(user_id: @user.id)
      render json: { user: UserSerializer.new(@user), jwt: @token }, status: :created
    else
      render json: { error: 'failed to create user' }, status: :not_acceptable
    end
  end

  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :bio, :image_url)
  end

end
