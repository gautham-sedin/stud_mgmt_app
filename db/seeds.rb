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
  name: "System Administrator",
  email: "admin@studentapp.com",
  password: AppConstants::STUDENT_DEFAULT_PASSWORD,
  password_confirmation: AppConstants::STUDENT_DEFAULT_PASSWORD,
  role: :admin
)

puts "Admin created: #{admin.email} (Name: #{admin.name})"

puts "===================================="
puts "Creating Teachers..."
puts "===================================="

teacher_names = [
  "Anand Iyer",
  "Senthil Kumar",
  "Meera Krishnan",
  "Rajesh Pillai"
]

teachers = []

4.times do |index|
  teachers << User.create!(
    name: teacher_names[index] || "Teacher #{index + 1}",
    email: "teacher#{index + 1}@studentapp.com",
    password: AppConstants::STUDENT_DEFAULT_PASSWORD,
    password_confirmation: AppConstants::STUDENT_DEFAULT_PASSWORD,
    role: :teacher
  )
end

teachers.each do |teacher|
  puts "Teacher created: #{teacher.email} (Name: #{teacher.name})"
end

puts "#{teachers.count} teachers created."

puts "===================================="
puts "Creating Students and User Logins..."
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
    student_name = "#{first_name} #{last_name}"
    student_email = "student#{student_counter}@example.com"

    # Create the Student profile
    Student.create!(
      name: student_name,
      email: student_email,
      age: rand(18..25),
      course: courses.sample,
      city: cities.sample,
      marks: rand(20..100),
      user: teacher
    )

    # Safe fallback creation of User login record for the Student:
    # If the student model callbacks have already been written, they will auto-create
    # the user and this check will skip it. If not, this seeds it manually.
    user = User.find_by(email: student_email)

    if user.nil?
      User.create!(
        name: student_name,
        email: student_email,
        password: AppConstants::STUDENT_DEFAULT_PASSWORD,
        password_confirmation: AppConstants::STUDENT_DEFAULT_PASSWORD,
        role: :student
      )
    elsif !user.student?
      raise "User with email #{student_email} already exists but is not a student."
    end

    student_counter += 1
  end
end

puts "===================================="
puts "SEED COMPLETED SUCCESSFULLY"
puts "===================================="

puts "Admin Count    : #{User.admin.count}"
puts "Teacher Count  : #{User.teacher.count}"
puts "Student Count  : #{Student.count}"
puts "Student Users  : #{User.student.count}"

puts "===================================="
puts "LOGIN CREDENTIALS"
puts "===================================="

puts "Admin:"
puts "Email    : admin@studentapp.com"
puts "Password : #{AppConstants::DEFAULT_PASSWORD}"

puts ""
puts "Teachers:"
teachers.each do |teacher|
  puts "Email    : #{teacher.email} (Name: #{teacher.name})"
end
puts "Password : #{AppConstants::DEFAULT_PASSWORD}"

puts ""
puts "Students Sample Login:"
sample_student = Student.first
if sample_student
  puts "Email    : #{sample_student.email} (Name: #{sample_student.name})"
  puts "Password : #{AppConstants::DEFAULT_PASSWORD}"
end
puts "===================================="
