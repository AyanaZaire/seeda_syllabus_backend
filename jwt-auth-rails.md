# JWT Auth Rails

This walkthrough will heavily rely on the walkthrough outlined in this Learn.co lesson on [JWT Auth using Rails](https://learn.co/lessons/jwt-auth-rails). How do we implement auth in our JavaScript application if our Rails backend is separate from our JavaScript frontend? Let's talk about how we can implement auth using [JWT (JSON Web Tokens)](https://jwt.io/).

## Getting Started — Create New User Functionality

To get started we need to follow these initial steps:

- [x] 1. Build Our Server (make sure you `bundle add jwt` && don't forget to uncomment `rack-cors` and `bcrypt` from your Gemfile.)
- [x] 2. Create Users migration, model, seed data, validations, serializer, routes, and controller (make sure to add `has_secure_password` to the user model. Recall that `has_secure_password` comes from ActiveModel and [adds methods to set and authenticate against a BCrypt password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password).)

NOTE: Our `Syllabus` will `belong_to` `User` so after creating users we must run the following migration to add a reference to `users` in the `syllabuses` table:

1. `rails g migration add_user_id_to_syllabuses user:references`
2. Drop into `rails console` and run `Syllabus.all.each{|s| s.destroy}` (_Remember_ this from PART 3? `rake db:migrate` will fail because existing syllabi in the database can not have a null value for `user_id`. By destroying the syllabi in the database, there are no null values because there are no syllabi.)
3. Now we can run: `rake db:migrate`
4. Let's add `has_secure_password` to our `User` model and update the associations in the `User` and `Syllabus` model
5. Let's create some seed data for `users` and update our syllabus seed data to `belong_to` a user. (_Remember_ from PART 5: In `User` model our association should look like this `has_many :syllabuses, dependent: :destroy` because we're adding `User.destory_all` at the top of our seed file.) Test your associations in the console.
6. Add validations to `User` model `validates :email, uniqueness: { case_sensitive: false }` (validate the uniqueness of your login attribute.)
7. Add a `create` method to our `UsersController`.

```ruby
class Api::V1::UsersController < ApplicationController
  def create
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
```

8. Update our `UserSerializer`: `attributes :name, :email, :bio, :image_url`
9. Update our routes:
```ruby
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
    end
  end
end
```

- [ ] 3. Confirm we can send a `POST` request and Create a New User. We're going to confirm this using [Postman](https://www.getpostman.com/apps) and implement sign up on the frontend later. In order to do this we're going to follow the following steps:

1. Create a new "Request". Fill out the form with relevant details for creating this request.
2. In the url box, select `POST` from the drop down and we're sending this request to the route we created so we can hit our `create` controller action: "http://localhost:3000/api/v1/users"
3. We're going update the headers with `Content-Type: 'application/json'` as the first key/value pair then `Accept: 'application/json'` as the second (although is optional).
4. Within the "Body" tab in Postman select the "raw" radio button and "JSON" in the drop down menu. We're going to manually stringify our data so the body of request should look like this for example:
```json
{"user": {
    "name": "Sylvia Woods",
    "email": "sylviawoods@sylviawoods.com",
    "password": "whatscooking",
    "bio": "Sylvia Woods was an American restaurateur who founded the soul food restaurant Sylvia's in Harlem on Lenox Avenue, New York City in 1962. She published two cookbooks and was an important figure in the community.",
    "image_url": "https://upload.wikimedia.org/wikipedia/commons/4/49/Syvia_of_Sylvia%27s_reaturant_N.Y.C_%28cropped%29.jpg"
  }
}
```
5. If successful, your response should look like serialized JSON data with an `id`!

**NOTICE:** We have to send the body of this request as a nested user object because in our user's strong params we `require` the `User` object.

## Implementing JWT in Backend

#### Why JSON Web Tokens (JWT)?

Token-based authentication is **stateless**. _We are not storing any information about a logged in user on the server_ (which also means we don't need a model or table for our user sessions). No stored information means our application can scale and add more machines as necessary without worrying about where a user is logged in. **Instead, the client (browser) stores a token and sends that token along with every authenticated request.** Instead of storing a plaintext `email`, or `user_id`, we can encode user data with JSON Web Tokens (JWT) and store that encoded token client-side.

**Check out this image visualizing the [JWT Auth Flow](https://i.stack.imgur.com/f2ZhM.png).**

#### Here is the JWT authentication flow for logging in:

1. An already existing user requests access with their username and password
2. The app validates these credentials
3. The app gives a signed token to the client
4. The client stores the token and presents it with every request. This token is effectively the user's access pass––it proves to our server that they are who they claim to be.

#### STEP 1: Encoding/Decoding JWT Token Functionality

Given that many different controllers will need to authenticate and authorize users––`AuthController`, `UsersController`, etc––it makes sense to lift the functionality of encoding/decoding tokens to our top level `ApplicationController`. (Recall that all controllers inherit from `ApplicationController`)

```ruby
class ApplicationController < ActionController::API
  def encode_token(payload)
    # payload => { beef: 'steak' }
    JWT.encode(payload, 'my_s3cr3t')
    # jwt string: "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"
  end

  def decoded_token(token)
    # token => "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"

    JWT.decode(token, 'my_s3cr3t')[0]
    # JWT.decode => [{ "beef"=>"steak" }, { "alg"=>"HS256" }]
    # [0] gives us the payload { "beef"=>"steak" }
  end
end
```

## Implementing Login on Frontend
