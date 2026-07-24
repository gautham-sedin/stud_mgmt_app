# db/seeds.rb
#
# Idempotent: safe to re-run (e.g. on every deploy with RUN_DB_SEEDS=true) since it
# uses find_or_create_by! instead of wiping existing data.

puts "===================================="
puts "Creating Admin..."
puts "===================================="

admin = User.find_or_create_by!(email: "admin@studentapp.com") do |user|
  user.name = "System Administrator"
  user.password = AppConstants::STUDENT_DEFAULT_PASSWORD
  user.password_confirmation = AppConstants::STUDENT_DEFAULT_PASSWORD
  user.role = :admin
end

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
  teacher_email = "teacher#{index + 1}@studentapp.com"

  teachers << User.find_or_create_by!(email: teacher_email) do |user|
    user.name = teacher_names[index] || "Teacher #{index + 1}"
    user.password = AppConstants::STUDENT_DEFAULT_PASSWORD
    user.password_confirmation = AppConstants::STUDENT_DEFAULT_PASSWORD
    user.role = :teacher
  end
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
students_per_teacher = 3

teachers.each do |teacher|
  students_per_teacher.times do
    first_name = first_names.sample
    last_name = last_names.sample
    student_name = "#{first_name} #{last_name}"
    student_email = "student#{student_counter}@example.com"

    # Create the Student profile (idempotent: re-running seeds won't duplicate)
    Student.find_or_create_by!(email: student_email) do |student|
      student.name = student_name
      student.age = rand(18..25)
      student.course = courses.sample
      student.city = cities.sample
      student.marks = rand(20..100)
      student.user = teacher
    end

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
puts "Password : #{AppConstants::STUDENT_DEFAULT_PASSWORD}"

puts ""
puts "Teachers:"
teachers.each do |teacher|
  puts "Email    : #{teacher.email} (Name: #{teacher.name})"
end
puts "Password : #{AppConstants::STUDENT_DEFAULT_PASSWORD}"

puts ""
puts "Students Sample Login:"
sample_student = Student.first
if sample_student
  puts "Email    : #{sample_student.email} (Name: #{sample_student.name})"
  puts "Password : #{AppConstants::STUDENT_DEFAULT_PASSWORD}"
end
puts "===================================="
