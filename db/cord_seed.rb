cord = Cord.find_or_initialize_by(name: "Court 1")
cord.update!(
  location: "Tipco Tower"
)

cord2 = Cord.find_or_initialize_by(name: "Court 2")
cord2.update!(
  location: "Tipco Tower"
)

puts "Seed Court Complete #{Cord.count}"
