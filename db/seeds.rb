# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


art = Category.create(name: "Art")
tech = Category.create(name: "Tech")
science = Category.create(name: "Science")

Syllabus.create(title: "West African Art History", description: "West African cultures developed bronze casting for reliefs, like the famous Benin Bronzes, to decorate palaces and for highly naturalistic royal heads from around the Bini town of Benin City, Edo State, as well as in terracotta or metal, from the 12th–14th centuries. Akan goldweights are a form of small metal sculptures produced over the period 1400–1900; some apparently represent proverbs, contributing a narrative element rare in African sculpture; and royal regalia included impressive gold sculptured elements.[8] Many West African figures are used in religious rituals and are often coated with materials placed on them for ceremonial offerings. The Mande-speaking peoples of the same region make pieces from wood with broad, flat surfaces and arms and legs shaped like cylinders. In Central Africa, however, the main distinguishing characteristics include heart-shaped faces that are curved inward and display patterns of circles and dots.", image_url: "https://upload.wikimedia.org/wikipedia/commons/9/97/AdinkraCalabashStamps.jpg", category_id: art.id)
