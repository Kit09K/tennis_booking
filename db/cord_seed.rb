cord = Cord.find_or_initialize_by(name: "Court 1")
cord.update!(
  location: "Tipco Tower"
)

puts "Seed Court Complete #{Cord.count}"
