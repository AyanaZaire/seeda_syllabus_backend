# Complex Database Relationships

Continued from 4 PART JS project build series where we currently have 2 models:
1. Syllabus
2. Category

Syllabus `belongs_to :categories`
Category `has_many :syllabus`

But let's say we want to build this into a true syllabus with associated keywords, themes/concentrations, required resources, projects, learning goals etc. We'd need more models!

Check out this example we're aiming for here: [Seeda Syllabus PDF](https://drive.google.com/file/d/1LVqTM272qiwVxnSgjsW6jzwtKEdeAW2C/view?usp=sharing).

### In this session we're going to focus on:
- [ ] 1. Ability to add concentrations
- [ ] 2. Ability to add keywords associated with each concentration
- [ ] 3. Ability to add projects associated with each concentration

### Before we code! Let's Diagram

We probably want to start testing with something like this:

| concentrations |  |
|-|-|
| Model: Concentration <br> `belongs_to :syllabus` <br> `has_many :projects` <br> `has_many :concentration_keywords` <br> `has_many :keywords, through: :concentration_keywords` |  |
| id | integer |
| title  | string |
| description | string |
| syllabus_id | integer |


| keywords |  |
|-|-|
| Model: Keyword <br> `has_many :concentration_keywords` <br> `has_many :concentrations, through: :concentration_keywords` |  |
| id | integer |
| word | string |

| concentration_keywords |  |
|-|-|
| Model: ConcentrationKeyword <br> `belongs_to :concentration` <br> `belongs_to :keyword` |  |
| id | integer |
| concentration_id | integer |
| keyword_id | integer |

| projects |  |
|-|-|
| Model: Project <br> `belongs_to :concentration` <br>  |  |
| id | integer |
| title  | string |
| description | string |
| deadline | date |
| concentration_id | integer |

Now we can code!

**REMEMBER: Build _vertically_ not _horizontally_!** Let's focus on one model at a time while testing along the way.

## Concentrations

Let's start with the concentrations table. We currently have a `Syllabus` model that's keeping track of the `title` and `description` of each syllabus but let's say we wanted to give the participant the ability create 3 "concentrations" or "themes" for their syllabus to help aide them in their research process.

### STOP!: Think about what that relationship would be.

<br><br><br><br>

If you proposed the following, you're correct!
- Concentration `belongs_to :syllabus`
- Syllabus `has_many :concentrations`

##### 1. Migration
Let's run the migrations to get this tested: `rails g model Concentration title description syllabus:references`

##### 2. Models
Let's update our models with our new associations:

```ruby
# IN SYLLABUS MODEL
class Syllabus < ApplicationRecord
  belongs_to :category
  has_many :concentrations
end

# IN CONCENTRATION MODEL
class Concentration < ApplicationRecord
  belongs_to :syllabus
end
```

##### 3. Seed Data
Lastly, let's create some seed data for testing
```ruby
# CONCENTRATIONS
imagination = Concentration.create(title: "Imagination", description: "Whenever one’s focus is liberation, the imagination must act as a core component. To tell the future one must engage their memory and imagination.", syllabus_id: ayana_syllabus.id)

industrialization = Concentration.create(title: "Industrialization", description: "Industrialization is present in manufacturing, education, and our sense of self. We must learn and unlearn these teachings to make liberation possible.", syllabus_id: ayana_syllabus.id)

pedagogy = Concentration.create(title: "Pedagogy", description: "To learn is to be human. To teach is to love. We become free by figuring out how best to expand our inner worlds.", syllabus_id: ayana_syllabus.id)
```

We can later add validations to make sure a syllabus can only have a max of 3 concentrations. But for now let's test this out!

##### 4. Test
First, let's see if our syllabus is associated with our concentrations. In our console let's run:
```BASH
~ $ rake db:migrate
~ $ rake db:seed
~ $ rails c
# Let's make sure all our concentrations seed data looks right
~ $ Concentration.all
# Let's make sure all our syllabus seed data looks right
~ $ Syllabus.all
# Let's grab a syllabus instance to call our has_many .concentration method
~ $ syllabus = Syllabus.first
~ $ syllabus.concentrations
```

Now let's check if a concentration is associated with a syllabus. Let's run:
```BASH
# Let's make sure all our concentration seed data is populated
~ $ Concentration.all
~ $ imagination = Concentration.first
~ $ imagination.syllabus
```

## Keywords

Now that we've outlined the 4-step process of Migration, Models, Seed Data, Test, let's move on to adding the keywords table. With this table, participants will be able to create keywords for their syllabus, associated with _specific_ concentrations.

### STOP!: Think about what that relationship would be.

<br><br><br><br>

If you proposed the following, you're close! What's going to go wrong here?
- Keyword `has_many :concentrations`
- Concentration `has_many :keywords`
- Syllabus `has_many :keywords`

We want users to eventually be able to query our site by keyword to discover other syllabi associated with their research. A syllabus is going to have many keywords but a keyword can have many concentrations and a concentration can have many keywords. This means we're going to need a join table to properly test this association!

##### 1. Migration
Let's run the migrations to get this tested:
1. `rails g model Keyword word`
2. `rails g model ConcentrationKeyword concentration:references keyword:references`

##### 2. Models
Let's update our models with our new associations:

```ruby
# IN KEYWORD MODEL
class Keyword < ApplicationRecord
  has_many :concentration_keywords
  has_many :concentrations, through: :concentration_keywords
end

# IN ConcentrationKeyword MODEL
class ConcentrationKeyword < ApplicationRecord
  belongs_to :concentration
  belongs_to :keyword
end

# IN CONCENTRATION MODEL
class Concentration < ApplicationRecord
  belongs_to :syllabus
  has_many :concentration_keywords
  has_many :keywords, through: :concentration_keywords
end

# IN SYLLABUS MODEL
class Syllabus < ApplicationRecord
  belongs_to :category
  has_many :concentrations
  # must establish has many in both concentration and keyword models to access these associations
  has_many :concentration_keywords, through: :concentrations
  has_many :keywords, through: :concentration_keywords
end
```

##### 3. Seed Data
Lastly, let's create some seed data for testing
```ruby
# KEYWORDS
art = Keyword.create(word: "Art")
pleasure = Keyword.create(word: "Pleasure Activism")
sociology = Keyword.create(word: "Sociology")
design = Keyword.create(word: "Design")
decentralization = Keyword.create(word: "Decentralization")
cooperation = Keyword.create(word: "Cooperation")
curriculum = Keyword.create(word: "Curriculum")
liberation = Keyword.create(word: "Liberation")
utility = Keyword.create(word: "Utilitarism")
classroom = Keyword.create(word: "Classroom")

# CONCENTRATION KEYWORDS
# imagination concentration
imagination_art = ConcentrationKeyword.create(concentration_id: imagination.id, keyword_id: art.id)
imagination_pleasure = ConcentrationKeyword.create(concentration_id: imagination.id, keyword_id: pleasure.id)

# industrialization concentration
industrialization_design = ConcentrationKeyword.create(concentration_id: industrialization.id, keyword_id: design.id)
industrialization_decentralization = ConcentrationKeyword.create(concentration_id: industrialization.id, keyword_id: decentralization.id)

# pedagogy concentration
pedagogy_decentralization = ConcentrationKeyword.create(concentration_id: pedagogy.id, keyword_id: decentralization.id)
pedagogy_curriculum = ConcentrationKeyword.create(concentration_id: pedagogy.id, keyword_id: curriculum.id)
pedagogy_liberation = ConcentrationKeyword.create(concentration_id: pedagogy.id, keyword_id: liberation.id)
pedagogy_classroom = ConcentrationKeyword.create(concentration_id: pedagogy.id, keyword_id: classroom.id)

```

##### 4. Test
First, let's see if our keywords associated associated with their concentration. In our console let's run:
```BASH
~ $ rake db:migrate
~ $ rake db:seed
```

**REMEMBER:** We have foreign key constraints on some of our tables. In both `Syllabus` and `Concentration` we must add `dependent: :destroy` to some of our `has_many` associations.

```ruby
class Syllabus < ApplicationRecord
  belongs_to :category

  # foreign key constraints
  has_many :concentrations, dependent: :destroy

  has_many :concentration_keywords, through: :concentrations
  has_many :keywords, through: :concentration_keywords

  validates :title, presence: true
end

class Concentration < ApplicationRecord
  belongs_to :syllabus

  # foreign key constraints
  has_many :concentration_keywords, dependent: :destroy
  has_many :keywords, through: :concentration_keywords
end
```

```BASH
# Now that we've added `dependent: :destroy` where we have foreign key constraints
~ $ rake db:seed
~ $ rails c
# Let's make sure all our keyword and concentration_keyword seed data looks right
~ $ Keyword.all
~ $ ConcentrationKeyword.all
```

Now let's check if a concentration has many keywords. Let's run:
```BASH
# Let's make sure all our concentration seed data is populated
~ $ pedagogy = Concentration.last
~ $ pedagogy.keywords
```

Lastly, let's check if a syllabus has many keywords. Let's run:
```BASH
# Let's make sure all our concentration seed data is populated
~ $ syllabus = Syllabus.first
~ $ syllabus.keywords
```

### STOP!: Can we access all the syllabi a keyword is associated with?

<br><br><br><br>

## Projects

Keeping with the 4-step process of Migration, Models, Seed Data, Test, let's move on to adding the projects table. With this table, participants will be able to create projects for their syllabus, associated with _specific_ concentrations. Participants can add 4 projects max, per syllabus.

### STOP!: Think about what that relationship would be.

<br><br><br><br>

If you proposed the following, you're correct!
- Project `belongs_to :concentration`
- Concentration `has_many :projects`
- Syllabus `has_many :projects, through: :concentrations`

##### 1. Migration
Let's run the migrations to get this tested: `rails g model Project title description deadline:date concentration:references`

##### 2. Models
Let's update our models with our new associations:

```ruby
# IN SYLLABUS MODEL
class Syllabus < ApplicationRecord
  belongs_to :category
  has_many :concentrations, dependent: :destroy

  has_many :concentration_keywords, through: :concentrations
  has_many :keywords, through: :concentration_keywords

  has_many :projects, through: :concentrations

  validates :title, presence: true
end

# IN CONCENTRATION MODEL
class Concentration < ApplicationRecord
  belongs_to :syllabus

  has_many :concentration_keywords, dependent: :destroy
  has_many :keywords, through: :concentration_keywords

  has_many :projects
end

# IN PROJECT MODEL
class Project < ApplicationRecord
  belongs_to :concentration
end
```

##### 3. Seed Data
Lastly, let's create some seed data for testing
```ruby
# PROJECTS
# feature to add: a project can belong to many concentrations (add a join table between project and concentration)
seeda_syllabus = Project.create(title: "Seeda Syllabus", description: "Seeda Syllabus is a decentralized learning framework for independent and collective study. The mission is: collectively create and share educational resources that will aid in liberation. Seeda is related to my IOS as it is a pedagogy research practice imagining how we might dismantle the industrialization of education and leverage the decentralization power of the internet.", deadline: "05/15/2020", concentration_id: pedagogy.id)

griot_practice = Project.create(title: "Griot Practice", description: "With a “Sankofa sensibility” my practice as a griot engages our collective memory by using storytelling to educate us on our past and paint the future. The primary materials I am employing are copper, cotton, leather, acrylic paint, and appropriating photographs. Relying on the black DIY aesthetic the works will be grounded in familiarity while also feeling suspended in an alternate world.", deadline: "09/15/2020", concentration_id: industrialization.id)

seeda_studio = Project.create(title: "Seeda Studio", description: "Research a design studio idea where people build technology tools for their communities.", deadline: "05/15/2020", concentration_id: imagination.id)

```

We can later add validations to make sure a syllabus can only have a max of 4 projects. But for now let's test this out!

##### 4. Test
First, let's see if our projects associated associated with their syllabus. In our console let's run:
```BASH
~ $ rake db:migrate
~ $ rake db:seed
~ $ rails c
# Let's make sure all our project seed data looks right
~ $ Project.all
# Let's grab a project instance to call our belongs_to .concentration method
~ $ project = Project.first
~ $ project.concentration
```

Now let's check if a concentration is associated with a project. Let's run:
```BASH
# Let's make sure all our concentration seed data is populated
~ $ imagination = Concentration.first
~ $ imagination.projects
```

Lastly, let's check if a syllabus has many projects. Let's run:
```BASH
# Let's make sure all our concentration seed data is populated
~ $ syllabus = Syllabus.first
~ $ syllabus.projects
```

### Conclusion

**HOMEWORK:** How might we build our relationships so I can call _both_ `syllabus.keywords` and `keyword.syllabuses`?

We haven't yet added validations to our models and we may have to update our associations when we start on our other stretch goals like implementing auth for users, required resources, and learning goals. THAT diagram might look something like this: [Seeda Syllabus API Associations Diagram](https://drive.google.com/file/d/1OBdTaaOXadhUTV8QEsZYdZU9mhwXRsDo/view?usp=sharing).



BUT we know have a solid foundation to build on as we set our sights on new stretch goals. In the meantime, we have plenty of data to work with. In the next session we're going to work on implementing Bootstrap on the front end to improve the UI on our frontend.
