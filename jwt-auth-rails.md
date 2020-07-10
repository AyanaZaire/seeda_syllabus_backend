# JWT Auth Rails

This walkthrough will _heavily_ rely on the walkthrough outlined in this Learn.co lesson on [JWT Auth using Rails](https://learn.co/lessons/jwt-auth-rails). How do we implement auth in our JavaScript application if our Rails backend is separate from our JavaScript frontend? Let's talk about how we can implement auth using [JWT (JSON Web Tokens)](https://jwt.io/).

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
      # using built-in rails status codes
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

**NOTE:** You shouldn't use the `password_digest` attribute directly, instead there are two attributes you should be using: `password` and `password_confirmation` (these attributes become available to you automatically when you use `has_secure_password`, so you don't need to define them).

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

- [ ] 3. **TEST (BEFORE PROCEEDING):** Confirm we can send a `POST` request and Create a New User. We're going to confirm this using [Postman](https://www.getpostman.com/apps) and implement sign up on the frontend later. In order to do this we're going to follow the following steps:

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

### Why JSON Web Tokens (JWT)?

Token-based authentication is **stateless**. _We are not storing any information about a logged in user on the server_ (which also means we don't need a model or table for our user sessions). No stored information means our application can scale and add more machines as necessary without worrying about where a user is logged in. **Instead, the client (browser) stores a token and sends that token along with every authenticated request.** Instead of storing a plaintext `email`, or `user_id`, we can encode user data with JSON Web Tokens (JWT) and store that encoded token client-side.

**Check out this image visualizing the [JWT Auth Flow](https://i.stack.imgur.com/f2ZhM.png).**

### Here is the JWT authentication flow for logging in:

1. An already existing user requests access with their email and password
2. The app validates these credentials
3. The app gives a signed token to the client
4. The client stores the token and presents it with every request. This token is effectively the user's access pass––it proves to our server that they are who they claim to be.

### STEP 1: Encoding/Decoding JWT Token Functionality

Given that many different controllers will need to authenticate and authorize users––`AuthController`, `UsersController`, etc––it makes sense to lift the functionality of encoding/decoding tokens to our top level `ApplicationController`. (Recall that **all** controllers inherit from `ApplicationController`)

```ruby
class ApplicationController < ActionController::API
  # WHY?: Will call the authorized method before anything else happens in our app. This will effectively lock down the entire application.
  before_action :authorized

  # STEP 1: Encode/Decode Tokens
  # WHY?: `JWT.encode` takes up to three arguments: a payload to encode, an application secret of the developer's choice, and an optional third that can be used to specify the hashing algorithm used. Typically, we don't need to show the third. This method returns a JWT as a string.
  def encode_token(payload)
    # should store secret in env variable
    JWT.encode(payload, 'my_s3cr3t')
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  # WHY?: `JWT.decode` takes three arguments as well: a JWT as a string, an application secret, and––optionally––a hashing algorithm.
  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      # header: { 'Authorization': 'Bearer <token>' }
      # The Begin/Rescue syntax allows us to rescue out of an exception in Ruby.
      begin
        JWT.decode(token, 'my_s3cr3t', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  # STEP 2: Authentication helper methods
  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
    # returns a boolean instead of truthy user object
  end

  # STEP 3: Authorization helper methods
  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end
end
```

### STEP 2: Updating the `UsersController` & Test

Let's update the `UsersController` so that it issues a token when users register for our app.

```ruby
class Api::V1::UsersController < ApplicationController
  # authorize user only AFTER they're created
  skip_before_action :authorized, only: [:create]

  def create
    byebug
    @user = User.create(user_params)
    if @user.valid?
      @token = encode_token(user_id: @user.id)
      byebug
      # using built-in rails status codes
      render json: { user: UserSerializer.new(@user), jwt: @token }, status: :created
    else
      render json: { error: 'failed to create user' }, status: :not_acceptable
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :bio, :avatar)
  end
end
```

**NOTE:** We need to make sure to skip the `before_action :authorized` coming from `ApplicationController`. It wouldn't make sense to ask our users to be logged in before they create an account. This circular logic will make it **impossible** for users to authenticate into the app. How can a user create an account if our app asks them to be logged in or `authorized` to do so? **Skipping the before action 'unlocks' this portion of our app.**

**TEST:** Let's try creating a new user again with Postman and confirm that your server successfully issues a token on signup.

A token should be issued in two different controller actions: `UsersController#create` and `AuthController#create`.

**Think about what these methods are responsible for:**
1. A user signing up for our app for the first time.
2. An already existing user logging back in.

In both cases, our server needs to issue a new token.

### STEP 3: Implementing Login on Frontend

#### Let's start with the backend

1. We'll need to create a new controller to handle login: `rails g controller api/v1/auth`.
2. Let's add the following to this newly created `AuthController`:

```ruby
class Api::V1::AuthController < ApplicationController
  skip_before_action :authorized, only: [:create]

  def create
    @user = User.find_by(email: user_login_params[:email])
    # User#authenticate comes from BCrypt
    if @user && @user.authenticate(user_login_params[:password])
      # encode token comes from ApplicationController
      token = encode_token({ user_id: @user.id })
      render json: { user: UserSerializer.new(@user), jwt: token }, status: :accepted
    else
      render json: { message: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_login_params
    # params { user: {email: 'missy@missyelliott.com', password: 'misdemeanor' } }
    params.require(:user).permit(:email, :password)
  end
end
```

We can simply call our `ApplicationController#encode_token` method, passing the found user's ID in a payload. The newly created JWT can then be passed back along with the user's data. **The user data can be stored in our application's server, while the token can be stored client-side.**

Next, let's update our routes:

```ruby
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      post '/login', to: 'auth#create'
    end
  end
end
```

Finally, let's test using Postman! Our method would be: `POST`, our end point would be: "http://localhost:3000/api/v1/login", our body might look like:

```javascript
  {"user": {
        "email": "sylviawoods@sylviawoods.com",
        "password": "whatscooking"
      }
  }
```

Again, the client should be sending a JWT along with every authenticated request. Refer to [this diagram](https://cdn.scotch.io/scotchy-uploads/2014/11/tokens-new.png) from [scotch.io](https://scotch.io/tutorials/the-ins-and-outs-of-token-based-authentication).

#### Store the Token on Frontend

**DISCLAIMER:** There are tradeoffs to every auth implementation. To name a few:
- There are some [tradeoffs](https://stormpath.com/blog/where-to-store-your-jwts-cookies-vs-html5-web-storage) to storing JWTs in browser localStorage.
- This [StackOverflow post](https://stackoverflow.com/questions/35291573/csrf-protection-with-json-web-tokens/35347022#35347022) has a concise summary of the benefits/tradeoffs about where/how to store tokens client-side.

We will be using [`localStorage`](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage) because this is the most familiar method. **To secure our application further, we should set our tokens to expire and make sure our app is being served over HTTPS.**

#### When _some event_ happens, I want to make _what kind of_ fetch and then manipulate the DOM _in what way_?

A: When a **`submit` event** happens, I want to make a **`POST` fetch request** to my login route, **render a welcome message**.

- [x] 1. Create a form for Login on frontend

```html
<form id="login-form">
  <div class="form-group">
    <h5 class="text-white">Email</h5>
    <input type="email" class="form-control" id="login-email" aria-describedby="emailHelp">
    <small id="emailHelp" class="form-text text-muted">We'll never share your email with anyone else.</small>
  </div>
  <div class="form-group">
    <h5 class="text-white">Password</h5>
    <input type="password" class="form-control" id="login-password">
  </div>
  <button type="submit" class="btn btn-primary">Submit</button>
</form>
```

- [ ] 2. Create an event listener and handler for the login form.

```javascript
// in DOMContentLoaded
const loginForm = document.querySelector("#login-form")
loginForm.addEventListener("submit", (e) => loginFormHandler(e))

// in form handler capture the user's input
function loginFormHandler(e) {
  e.preventDefault()
  const emailInput = e.target.querySelector("#login-email").value
  const pwInput = e.target.querySelector("#login-password").value
  loginFetch(emailInput, pwInput)
}
```

- [ ] 3. Make a `POST` fetch request to the login route

```javascript
function loginFetch(email, password){
  const bodyData = {user: {
        email: email,
        password: password
      }
  }

  fetch("http://localhost:3000/api/v1/login", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(bodyData)
  })
  .then(response => response.json())
  .then(json => {
    console.log(json);
  })
}
```

- [ ] 4. Store token (from login fetch request) in `localStorage` using: `localStorage.setItem('jwt_token', token)`

```javascript
function loginFetch(email, password){
  const bodyData = {user: {
        email: email,
        password: password
      }
  }

  fetch("http://localhost:3000/api/v1/login", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(bodyData)
  })
  .then(response => response.json())
  .then(json => {
    localStorage.setItem('jwt_token', json.jwt)
    renderUserProfile()
  })
}
```

- [ ] 5. Show the user their data using: `let token = localStorage.getItem('jwt_token')`

**A sample request might look like:**
```javascript
function renderUserProfile() {
  console.log(localStorage.getItem('jwt_token'));
  fetch('http://localhost:3000/api/v1/profile', {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${localStorage.getItem('jwt_token')}`
    }
  })
  .then(response => response.json())
  .then(json => {
    alert(`Welcome back ${json.user.data.attributes.name}`)
  })
}
```

But first! We would need to update our `UsersController` so that an authenticated user can access their profile information:

```ruby
class Api::V1::AuthController < ApplicationController
  skip_before_action :authorized, only: [:create]

  def profile
    # using current_user helper in ApplicationController
    render json: { user: UserSerializer.new(current_user) }, status: :accepted
  end

  def create
    @user = User.find_by(email: user_login_params[:email])
    # User#authenticate comes from BCrypt
    if @user && @user.authenticate(user_login_params[:password])
      # encode token comes from ApplicationController
      token = encode_token({ user_id: @user.id })
      render json: { user: UserSerializer.new(@user), jwt: token }, status: :accepted
    else
      render json: { message: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_login_params
    # params { user: {email: 'missy@missyelliott.com', password: 'misdemeanor' } }
    params.require(:user).permit(:email, :password)
  end
end
```

**One final note about the snippet above:** `ApplicationController` calls `authorized` **before any other controller methods are called**. If authorization fails, our server will never call `UsersController#profile` and will instead: `render json: { message: 'Please log in' }, status: :unauthorized`

Lastly, we'll need to update our routes:

```ruby
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      post '/login', to: 'auth#create'
      get '/profile', to: 'users#profile'
    end
  end
end
```

Now you'll be able to make a `GET` fetch request to `profile` or any other methods using the JWT token on the frontend and your `current_user` helper method.

## Questions to answer next session:
1. How would I create a syllabus with a logged in user?
2. Do we need the `true` argument when decoding the token? `JWT.decode(token, 'my_s3cr3t', true, algorithm: 'HS256')`
