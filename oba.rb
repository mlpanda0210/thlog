
puts "SAY SOMETHING"
word = gets.to_s
bigword = word.upcase
if (word == bigword)
  random_number = rand(50..80)
  puts "NO! I'M #{random_number} YEAR-OLD!"
else
  puts "What?"
end
