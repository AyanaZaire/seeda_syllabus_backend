class Api::V1::UsersController < ApplicationController
  # authorize user only AFTER they're created
  skip_before_action :authorized, only: [:create]

  def profile
    # using current_user helper in ApplicationController
    render json: { user: UserSerializer.new(current_user) }, status: :accepted
  end

  def create
    #byebug
    @user = User.create(user_params)
    if @user.valid?
      @token = encode_token(user_id: @user.id)
      #byebug
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
