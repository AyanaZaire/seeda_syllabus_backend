class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :email, :bio, :image_url
end
