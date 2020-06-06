# PART 1 Review

1. Models/Associations
2. Schema
3. Seed Data
4. Follow Up Questions:
    1. Why should we do our migrations in our respective branches?
        - A: To fully build out features on respective branch. Merging a migration that we haven't confirmed migrates successfully compromises the master branch.
    2. What is the `belongs_to` [attribute in migrations](https://guides.rubyonrails.org/association_basics.html#the-belongs-to-association) doing for us? What's best practice?
        - A: It indexes our associations. `belongs_to` is actually an alias of references. Read more in [this stackoverflow answer](https://stackoverflow.com/a/9471187). Indexing our associations is best practice.
            - `rails g model Syllabus category:references` will generates an `category_id` column in the `syllabuses` table and will modify the `syllabus.rb` model to add a` belongs_to :category` relationship.
            - `rails g migration AddCategoryToSyllabus category:belongs_to` will generate the following migration:

            ```ruby
            class AddCategoryToSyllabus < ActiveRecord::Migration
              def change
                # add_reference :syllabuses, :category, null: false, foreign_key: true
                add_reference :syllabuses, :category, foreign_key: true
              end
            end
            ```
            - Because we're using PostGres we need to delete `null: false,` so this migration will be successful. Read why [here](https://stackoverflow.com/questions/24298171/pgnotnullviolation-error-null-value-in-column-id-violates-not-null-constra).
            - Run `rake db:migrate`

            - **Updated Schema:**

            ```ruby
            ActiveRecord::Schema.define(version: 2020_04_29_192202) do

              # These are extensions that must be enabled in order to support this database
              enable_extension "plpgsql"

              create_table "categories", force: :cascade do |t|
                t.string "name"
                t.datetime "created_at", precision: 6, null: false
                t.datetime "updated_at", precision: 6, null: false
              end

              create_table "syllabuses", force: :cascade do |t|
                t.string "title"
                t.string "description"
                t.string "image_url"
                t.datetime "created_at", precision: 6, null: false
                t.datetime "updated_at", precision: 6, null: false
                t.bigint "category_id"
                t.index ["category_id"], name: "index_syllabuses_on_category_id"
              end

              add_foreign_key "syllabuses", "categories"
            end
            ```
            - Add the following to seeds file

            ```ruby
            Category.destroy_all
            Syllabus.destroy_all
            ```

            - And add `has_many :syllabuses, dependent: :destroy` to `Category` model
            - Then run `rake db:reset` to drop, create, and "re-seed" database.
            - Why this is important? Foreign keys should always be indexed to improve the performance of your application. Learn more with these resources:
                - [Using indexes in rails: Index your associations](http://archive.is/i7SLO)
                - [:References in Rails](https://medium.com/@brianna.dixon023/references-in-rails-bc5ac3ccbd9d)
                - [Stop forgetting your foreign key indexes in Rails with this simple post-migration script](https://alexpeattie.com/blog/stop-forgetting-foreign-key-indexes-in-rails-post-migration-script)
                - [Ruby Docs on `add_reference`](https://edgeapi.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference)

# PART 2: Routes, Controllers, and Fast JSON API Serializer

## Routes

- Why namespaces routes?
    - Since, eventually, our frontend application might be hosted on a specific domain i.e. `http://seeda.com`, we will want all of our backend routes to be _namespaced_ **to indicate they are routes associated with the API**.
    - Example Index Route: `http://seeda.com/api/v1/syllabuses`
- In `config/routes.rb` we'll define the routes as follows:
    ```ruby
    Rails.application.routes.draw do
      namespace :api do
        namespace :v1 do
          resources :syllabuses, only: [:index]
        end
      end
    end
    ```
http://localhost:3000/rails/info/routes

## Controllers

- How does namespaced routes impact the controller?
    - In your console run: `rails g controller api/v1/Syllabuses`
    - Notice that the controller file this created lives in `/app/controllers/api/v1/syllabuses_controller.rb` and the actual class name of the controller is _namespaced_ like `Api::V1::SyllabusController` as well.
- Review [docs](http://guides.rubyonrails.org/routing.html#nested-resources) on nested resources in Rails

**Note on API Versioning:** This is the first version of our API. Therefore, the controller should go inside api/v1. If anyone is relying on our API and we update the code in a way that would break other people's projects, it's good practice to make that update its own version of the API. Read this if you want a deeper dive into api versioning.

**Example Syllabus Controller:**

```ruby
class Api::V1::SyllabusesController < ApplicationController

  def index
    @syllabuses = Syllabus.all
    render json: @syllabuses
  end

  def create
    @syllabus.new(syllabus_params)
    if @syllabus.save
      render json: @syllabus, status: :accepted
    else
      render json: { errors: @syllabus.errors.full_messages }, status: :unprocessible_entity
    end
  end

  private

  def syllabus_params
    params.permit(:title, :description, :image_url, :category_id)
  end

end
```

**A few things are happening in the above methods:**

1. We're rendering all syllabuses in the form of JSON.
2. We're creating a new syllabus based on whatever `syllabus_params` we get from our frontend.
3. We're setting out `syllabus_params` to permit a parameter named `title`, `description`, `image_url` and `category_id`. _These must be included in the body of the POST or PATCH requests we will be making with JS `fetch`._
4. We're setting the status based on the a successful `.save`. Check out the following links for more info on the [202 (Accepted)](https://httpstatuses.com/202) and [422 (Unprocessable Entity)](https://httpstatuses.com/422) status codes — along with other [`httpstatuses`](https://httpstatuses.com/) you can use in your methods.

## Serializers

#### Fast JSON API Intro

- Once `gem fast_jsonapi` is installed, you will gain access to a new generator, `serializer`.
- With these serializers, we can start to define information about each model and their _related_ models we want to share in our API.

**NOTE:** Serializers generated by the Fast JSON API gem have two built-in methods called `serializable_hash` and `serialized_json` which return a serialized hash and a JSON string respectively. However, we don't actually need either of these in this example, as `to_json` will still be called on `SightingSerializer.new(sighting)` implicitly. As we will see, once our serializers are configured and initialized, we will not need
to do any additional work

- When rendering JSON directly, controllers will render all attributes available by default. **Fast JSON API serializers work the other way around - we must always specify what attributes we want to include.**

**NOTE:** Having the [JSON Viewer](https://chrome.google.com/webstore/detail/json-viewer/gbmdgpbipfallnflgajpaliibnhdgobh?hl=en-US) Chrome extension installed. This will make JSON data much easier to read.

#### Adding Relationships

**Serializer:**
```ruby
class SyllabusSerializer
  include FastJsonapi::ObjectSerializer
  attributes :title, :description, :image_url, :category_id
  belongs_to :category
end
```

**Controller:**
```ruby
class Api::V1::SyllabusesController < ApplicationController
  def index
    @syllabuses = Syllabus.all
    options = {
      # include associated category
      include: [:category]
    }
    # pass options object to serializer
    render json: SyllabusSerializer.new(@syllabuses, options)
  end
end
```

#### Fast JSON API Conclusion

- _We do not get to choose exactly how data gets serialized_ the way we do when writing our own serializer classes, but we gain a lot of flexibility by using the Fast JSON API.
- Its conventions also allow it to work well even when dealing with a large number of related objects.    
- [Fast JSON API docs](https://github.com/Netflix/fast_jsonapi#table-of-contents)
