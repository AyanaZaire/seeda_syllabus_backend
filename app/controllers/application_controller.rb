class ApplicationController < ActionController::API
  before_action :authorized

  def encode_token(payload)
    JWT.encode(payload, 'my_s3cr3t')
  end

  def auth_header
    request.headers['Authorization']
  end

  def decode_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, 'my_s3cr3t', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user
    if decode_token
      # JWT.decode => [{ "user_id"=> 1 }, { "alg"=>"HS256" }]
      # [0] gives us the payload { "user_id"=> 1 }
      user_id = decode_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
    # returns a boolean instead of truthy user object
  end

  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end



end
