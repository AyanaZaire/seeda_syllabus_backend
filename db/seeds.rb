# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.destroy_all
Syllabus.destroy_all
Concentration.destroy_all
ConcentrationKeyword.destroy_all
Keyword.destroy_all

art = Category.create(name: "Art")
tech = Category.create(name: "Tech")
science = Category.create(name: "Science")

ayana_syllabus = Syllabus.create(title: "AYZACO", description: "This intersection of study (IOS) is informed by my background as an artist, educator, and designer with a community facing practice.  My previous work in engaging the imagination and memory through art and photography, researching labor studies and materials, and hosting workshops on design, facilitating community discussions, and conducting lectures online and digitally has inspired me to embark on this IOS.", image_url: "https://freight.cargo.site/t/original/i/848ae0967d6f6f6478304ca5440fc24fba5bb07903a366bce9654d14e1d2025c/Screen-Shot-2020-06-08-at-9.48.43-AM.png", category_id: art.id)

# CONCENTRATIONS
imagination = Concentration.create(title: "Imagination", description: "Whenever one’s focus is liberation, the imagination must act as a core component. To tell the future one must engage their memory and imagination.", syllabus_id: ayana_syllabus.id)

industrialization = Concentration.create(title: "Industrialization", description: "Industrialization is present in manufacturing, education, and our sense of self. We must learn and unlearn these teachings to make liberation possible.", syllabus_id: ayana_syllabus.id)

pedagogy = Concentration.create(title: "Pedagogy", description: "To learn is to be human. To teach is to love. We become free by figuring out how best to expand our inner worlds.", syllabus_id: ayana_syllabus.id)


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
