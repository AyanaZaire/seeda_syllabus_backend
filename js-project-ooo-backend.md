# JS/Rails Order of Operations Guide (BACKEND)

The JavaScript Project repo has a handful of helpful [READMEs](https://github.com/learn-co-students/js-spa-project-instructions-online-web-sp-000) that outline the requirements for the JS/Rails Project along with project planning tips and a note about what to expect during your review. There is also this [JavaScript Rails API Project Setup README](https://github.com/learn-co-curriculum/mod3-project-week-setup-example) that provides a thorough step by step walkthrough to get your project up and running along with some help OOJS refactoring tips. Lastly, we also wanted to outline a suggested flow of execution to aide you in building your project. We put together this "Order of Operations Guide" for organizing and completing your JS/Rails Project. This guide is based on the 4-part project build. All study groups can be found [here](https://learn.co/study-groups).

The application we will create during the project build series is a "Syllabus Sharing App" for independent study.

 **USER STORY: A user should be able to read and create syllabi based on category**

## Checklist

### PART 1: Planning and Building a Rails API

**BEFORE YOU CODE**
- [x] 1. Check project requirements in [JavaScript READMEs](https://github.com/learn-co-students/js-spa-project-instructions-online-web-sp-000)
- [x] 2. Ideate! What do you want to build?
    - choose a domain you're familiar with!
    - choose a domain you care about
- [x] 3. Wireframing & User Stories
    - Write down your models, their attributes, and their associations
    - "As a user, I can ....."
    - "A user should be able to ....."
    - What does your app _do_?
- [x] 4. Design your MVP = 'Minimum Viable Product' vs. what are my 'stretch goals'
    - Stretch goals - bonus features you want but don't need

**NOW WE'RE READY FOR PROJECT SET UP**

- [x] 5. Generate new [Rails API](https://edgeguides.rubyonrails.org/api_app.html) using `rails new <my_app_name> --database=postgresql --api`
    - (Replace `<my_app_name>` with the actual name of your project)
- [x] 6. Create github repo
- [x] 7. Create a new branch for building out models `git co -b <branch_name>`. This way you can always go back to the fresh API.
    - **NOTE**: It is best practice to always create a new branch when working on a new feature/edit to your code. Your master branch should only have working code. Debug in a branch, not in master.

**NOW WE'RE READY TO CODE (BUT JUST OUR MODELS — NO CONTROLLERS OR SERIALIZERS YET)**

**NOTE**: Remember to _**VERTICALLY**_ build your MVP! This means building out one model/feature at a time. DO NOT build out _all_ the models and controllers at the same time. This is the easiest way to get lost in your project very early. Read more about this [here](https://github.com/learn-co-students/js-spa-project-instructions-online-web-sp-000/blob/master/project-planning-tips.md#build-vertically-not-horizontallys).

- [x] 8. Build your models: `rails g model <your_model_name> name` (Make sure you capitalize the first letter of the model name!)
    - Migrations
    - Model classes
    - Associations
- [x] 9. Test your models and associations in the console
    - Create some seed data
    - Adjust migrations as needed


### PART 2: Routes, Controllers, Serializers

- [x] 1. Routes
    - Implement _specific_ namespaced routes for _a_ controller **for MVP**
    - REMEMBER! We're _trying_ to build vertically.

      ```ruby
      Rails.application.routes.draw do
        namespace :api do
          namespace :v1 do
            resources :syllabuses, only: [:index, :create]
          end
        end
      end
      ```
    - Run `rails routes` to confirm routes
    - Visit `http://localhost:3000/api/v1/<your_resource_name>` to see error


- [x] 2. Controllers
    - In your console run: `rails g controller api/v1/<your controller_name>` (Make sure you capitalize and the first letter of the controller name!)
    - Build relevant routes for MVP (ex: `index` and `create`)
    - Visit `http://localhost:3000/api/v1/<your_resource_name>` to see JSON data

- [x] 3. Fast JSON API Serializer
    - Add `gem 'fast_jsonapi'` to your Rails project's Gemfile and run `bundle install`
    - Create Serializer classes
      - `rails g serializer <your_resource_name>`
      - `rails g serializer <your_resource_name>`
    - Update Controller Actions
        ```ruby
        class Api::V1::SyllabusesController < ApplicationController
          def index
            @syllabuses = Syllabus.all
            # render json: @syllabuses
            render json: SyllabusSerializer.new(@syllabuses)
          end
        end
        ```
    - Adding Attributes
        ```ruby
        class SyllabusSerializer
          include FastJsonapi::ObjectSerializer
          attributes :title, :description, :image_url, :category_id
        end
        ```
    - Accessing Associations (Related Objects)
        ```ruby
        class SyllabusSerializer
          include FastJsonapi::ObjectSerializer
          attributes :title, :description, :image_url, :category_id, :category
        end
        ```
    - Adding Relationships
        - To control the attributes displayed in the association view PART 2 notes on adding relationships


- [x] 4. **TEST:** Confirm data at your Rails endpoints! (ex: `http://seeda.com/api/v1/syllabuses`)
- [ ] 5. Build out your associated models using this same process. **REMEMBER: Focus on building vertically for MVP** this means only starting with 2 or 3 models before moving on to the frontend.


### PART 3: DOM Manipulation, Events, and Fetch using Rails API
- **JS MANTRA:** When _some event_ happens, I want to make _what kind of_ fetch and then manipulate the DOM _in what way_?
- [ ] 1. `GET` request
- [ ] 2. `POST` request

### PART 4: OOJS Refactor
- [ ] 1. Create a Syllabus Class

### Bonus
- [ ] Leverage a CSS framework to improve the styling of your application
  - Easiest to implement: [Bulma](https://bulma.io/)
  - Most popular: [Bootstrap](https://getbootstrap.com/)
  - Also good: [Semantic UI](https://semantic-ui.com/)
  - Not bootstrap: [Materialize](https://materializecss.com/)

### Confirm
- [ ] You have a large number of small Git commits
- [ ] Your commit messages are meaningful
- [ ] You made the changes in a commit that relate to the commit message
- [ ] You don't include changes in a commit that aren't related to the commit message
