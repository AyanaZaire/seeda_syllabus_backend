# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.destroy_all
Syllabus.destroy_all

art = Category.create(name: "Art")
tech = Category.create(name: "Tech")
science = Category.create(name: "Science")

ayana_syllabus = Syllabus.create(title: "AYZACO", description: "This intersection of study (IOS) is informed by my background as an artist, educator, and designer with a community facing practice.  My previous work in engaging the imagination and memory through art and photography, researching labor studies and materials, and hosting workshops on design, facilitating community discussions, and conducting lectures online and digitally has inspired me to embark on this IOS.", image_url: "https://freight.cargo.site/t/original/i/848ae0967d6f6f6478304ca5440fc24fba5bb07903a366bce9654d14e1d2025c/Screen-Shot-2020-06-08-at-9.48.43-AM.png", category_id: art.id)
