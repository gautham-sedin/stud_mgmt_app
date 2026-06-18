# db/seeds.rb

puts "===================================="
puts "Cleaning existing data..."
puts "===================================="

Student.destroy_all
User.destroy_all

puts "Existing data removed."

puts "===================================="
puts "Creating Admin..."
puts "===================================="

admin = User.create!(
  email: "admin@studentapp.com",
  password: "password123",
  password_confirmation: "password123",
  role: :admin
)

puts "Admin created: #{admin.email}"

puts "===================================="
puts "Creating Teachers..."
puts "===================================="

teachers = []

4.times do |index|
  teachers << User.create!(
    email: "teacher#{index + 1}@studentapp.com",
    password: "password123",
    password_confirmation: "password123",
    role: :teacher
  )
end

puts "#{teachers.count} teachers created."

puts "===================================="
puts "Creating Students..."
puts "===================================="

courses = [
  "Ruby",
  "Rails",
  "React",
  "Java"
]

cities = [
  "Chennai",
  "Bangalore",
  "Hyderabad",
  "Mumbai",
  "Pune",
  "Coimbatore"
]

first_names = %w[
  Arun
  Priya
  Rahul
  Divya
  Karthik
  Meena
  Vishal
  Sneha
  Ajith
  Kavya
  Naveen
  Harini
  Akash
  Nisha
  Surya
  Deepika
]

last_names = %w[
  Kumar
  Sharma
  Reddy
  Singh
  Raj
  Patel
  Das
  Gupta
]

student_counter = 1

teachers.each do |teacher|
  number_of_students = rand(2..5)

  number_of_students.times do
    first_name = first_names.sample
    last_name = last_names.sample

    Student.create!(
      name: "#{first_name} #{last_name}",
      email: "student#{student_counter}@example.com",
      age: rand(18..25),
      course: courses.sample,
      city: cities.sample,
      marks: rand(20..100),
      user: teacher
    )

    student_counter += 1
  end
end

puts "===================================="
puts "SEED COMPLETED SUCCESSFULLY"
puts "===================================="

puts "Admin Count    : #{User.admin.count}"
puts "Teacher Count  : #{User.teacher.count}"
puts "Student Count  : #{Student.count}"

puts "===================================="
puts "LOGIN CREDENTIALS"
puts "===================================="

puts "Admin:"
puts "Email    : admin@studentapp.com"
puts "Password : password123"

puts ""

puts "Teachers:"
(1..4).each do |i|
  puts "teacher#{i}@studentapp.com"
end

puts "Password : password123"

puts "===================================="
