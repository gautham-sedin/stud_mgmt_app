# Student Management Application - RESTful API Implementation Guide

This guide provides a minimal, step-by-step walkthrough to implement the **Teacher**, **Student**, and **Teacher-Student Association** RESTful APIs.

It maps directly to the existing database schema in the codebase, without adding any new columns, attributes, or features (such as grades or subjects).

---

## Step 1: Define API Routes (`config/routes.rb`)

Add the RESTful API endpoints under an `:api` scope. Ensure they default to JSON format.

Modify `config/routes.rb` to:
```ruby
# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  # Web UI Routes
  resources :students
  resources :users, only: [ :index ]

  # RESTful JSON API Routes
  scope :api, defaults: { format: :json } do
    resources :teachers, only: [:index, :show, :create, :update, :destroy] do
      resources :students, only: [:index, :create], controller: 'api/teacher_students'
    end
    resources :students, only: [:index, :show, :create, :update, :destroy]
  end
end
```

---

## Step 2: Implement Base API Controller (`app/controllers/api/base_controller.rb`)

Create `app/controllers/api/base_controller.rb` to bypass browser-specific session validations and handle database exceptions with clean JSON errors.

```ruby
# app/controllers/api/base_controller.rb
class Api::BaseController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  private

  def record_not_found(exception)
    render json: { errors: [exception.message] }, status: :not_found
  end

  def record_invalid(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end
end
```

---

## Step 3: Implement Teachers API Controller (`app/controllers/api/teachers_controller.rb`)

Create `app/controllers/api/teachers_controller.rb` to manage `User` records with `role: :teacher`.

```ruby
# app/controllers/api/teachers_controller.rb
class Api::TeachersController < Api::BaseController
  before_action :set_teacher, only: [:show, :update, :destroy]

  # GET /api/teachers
  def index
    @teachers = User.teacher
    render json: @teachers.map { |t| serialize_teacher_list(t) }, status: :ok
  end

  # GET /api/teachers/:id
  def show
    render json: serialize_teacher_detail(@teacher), status: :ok
  end

  # POST /api/teachers
  def create
    @teacher = User.new(teacher_params)
    @teacher.role = :teacher
    @teacher.password ||= "password123"
    @teacher.password_confirmation ||= "password123"

    if @teacher.save
      render json: serialize_teacher_list(@teacher), status: :created
    else
      render json: { errors: @teacher.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /api/teachers/:id
  def update
    if @teacher.update(teacher_params)
      render json: serialize_teacher_list(@teacher), status: :ok
    else
      render json: { errors: @teacher.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/teachers/:id
  def destroy
    @teacher.destroy
    head :no_content
  end

  private

  def set_teacher
    @teacher = User.teacher.find(params[:id])
  end

  def teacher_params
    params.require(:teacher).permit(:name, :email, :password, :password_confirmation)
  end

  def serialize_teacher_list(teacher)
    {
      id: teacher.id,
      name: teacher.name,
      email: teacher.email
    }
  end

  def serialize_teacher_detail(teacher)
    {
      id: teacher.id,
      name: teacher.name,
      email: teacher.email,
      students: teacher.students.map { |s| { id: s.id, name: s.name } }
    }
  end
end
```

---

## Step 4: Implement Students API Controller (`app/controllers/api/students_controller.rb`)

Create `app/controllers/api/students_controller.rb` to handle Student operations.

```ruby
# app/controllers/api/students_controller.rb
class Api::StudentsController < Api::BaseController
  before_action :set_student, only: [:show, :update, :destroy]

  # GET /api/students
  def index
    @students = Student.all

    if params[:name].present?
      @students = @students.search(params[:name])
    end

    render json: @students.map { |s| serialize_student(s) }, status: :ok
  end

  # GET /api/students/:id
  def show
    render json: serialize_student(@student), status: :ok
  end

  # POST /api/students
  def create
    @student = Student.new(student_params)

    if @student.save
      render json: serialize_student(@student), status: :created
    else
      render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /api/students/:id
  def update
    if @student.update(student_params)
      render json: serialize_student(@student), status: :ok
    else
      render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/students/:id
  def destroy
    @student.destroy
    head :no_content
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:name, :email, :age, :course, :city, :marks, :user_id)
  end

  def serialize_student(student)
    {
      id: student.id,
      name: student.name,
      email: student.email,
      age: student.age,
      course: student.course,
      city: student.city,
      marks: student.marks,
      teacher: student.user ? { id: student.user.id, name: student.user.name } : nil
    }
  end
end
```

---

## Step 5: Implement Teacher-Student Associations Controller (`app/controllers/api/teacher_students_controller.rb`)

Create `app/controllers/api/teacher_students_controller.rb` to handle associated endpoints.

```ruby
# app/controllers/api/teacher_students_controller.rb
class Api::TeacherStudentsController < Api::BaseController
  before_action :set_teacher

  # GET /api/teachers/:teacher_id/students
  def index
    @students = @teacher.students
    render json: @students.map { |s| { id: s.id, name: s.name } }, status: :ok
  end

  # POST /api/teachers/:teacher_id/students
  def create
    @student = @teacher.students.build(student_params)

    if @student.save
      render json: { id: @student.id, name: @student.name }, status: :created
    else
      render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_teacher
    @teacher = User.teacher.find(params[:teacher_id])
  end

  def student_params
    params.require(:student).permit(:name, :email, :age, :course, :city, :marks)
  end
end
```

---

## Step 6: Postman Collection Configuration (JSON)

Save the content below as `Student_Management_APIs.postman_collection.json` and import it into Postman:

```json
{
  "info": {
    "name": "Student Management APIs",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Teacher APIs",
      "item": [
        {
          "name": "Create Teacher",
          "request": {
            "method": "POST",
            "header": [{ "key": "Content-Type", "value": "application/json" }],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"teacher\": {\n    \"name\": \"John Doe\",\n    \"email\": \"johndoe@studentapp.com\",\n    \"password\": \"password123\",\n    \"password_confirmation\": \"password123\"\n  }\n}"
            },
            "url": { "raw": "http://localhost:3000/api/teachers", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "teachers"] }
          }
        },
        {
          "name": "Fetch All Teachers",
          "request": {
            "method": "GET",
            "url": { "raw": "http://localhost:3000/api/teachers", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "teachers"] }
          }
        },
        {
          "name": "Fetch Teacher by ID",
          "request": {
            "method": "GET",
            "url": { "raw": "http://localhost:3000/api/teachers/1", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "teachers", "1"] }
          }
        },
        {
          "name": "Update Teacher",
          "request": {
            "method": "PUT",
            "header": [{ "key": "Content-Type", "value": "application/json" }],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"teacher\": {\n    \"name\": \"John Updated\"\n  }\n}"
            },
            "url": { "raw": "http://localhost:3000/api/teachers/1", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "teachers", "1"] }
          }
        },
        {
          "name": "Delete Teacher",
          "request": {
            "method": "DELETE",
            "url": { "raw": "http://localhost:3000/api/teachers/1", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "teachers", "1"] }
          }
        }
      ]
    },
    {
      "name": "Student APIs",
      "item": [
        {
          "name": "Create Student",
          "request": {
            "method": "POST",
            "header": [{ "key": "Content-Type", "value": "application/json" }],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"student\": {\n    \"name\": \"Alice Cooper\",\n    \"email\": \"alice.cooper@example.com\",\n    \"age\": 21,\n    \"course\": \"Ruby\",\n    \"city\": \"Chennai\",\n    \"marks\": 92,\n    \"user_id\": 2\n  }\n}"
            },
            "url": { "raw": "http://localhost:3000/api/students", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "students"] }
          }
        },
        {
          "name": "Fetch All Students",
          "request": {
            "method": "GET",
            "url": { "raw": "http://localhost:3000/api/students", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "students"] }
          }
        },
        {
          "name": "Fetch Student by ID",
          "request": {
            "method": "GET",
            "url": { "raw": "http://localhost:3000/api/students/1", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "students", "1"] }
          }
        },
        {
          "name": "Update Student",
          "request": {
            "method": "PATCH",
            "header": [{ "key": "Content-Type", "value": "application/json" }],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"student\": {\n    \"marks\": 95\n  }\n}"
            },
            "url": { "raw": "http://localhost:3000/api/students/1", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "students", "1"] }
          }
        },
        {
          "name": "Delete Student",
          "request": {
            "method": "DELETE",
            "url": { "raw": "http://localhost:3000/api/students/1", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "students", "1"] }
          }
        }
      ]
    },
    {
      "name": "Association APIs",
      "item": [
        {
          "name": "Fetch Students of a Teacher",
          "request": {
            "method": "GET",
            "url": { "raw": "http://localhost:3000/api/teachers/2/students", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "teachers", "2", "students"] }
          }
        },
        {
          "name": "Create Student Under Teacher",
          "request": {
            "method": "POST",
            "header": [{ "key": "Content-Type", "value": "application/json" }],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"student\": {\n    \"name\": \"Bob Dylan\",\n    \"email\": \"bob.dylan@example.com\",\n    \"age\": 22,\n    \"course\": \"React\",\n    \"city\": \"Bangalore\",\n    \"marks\": 85\n  }\n}"
            },
            "url": { "raw": "http://localhost:3000/api/teachers/2/students", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "teachers", "2", "students"] }
          }
        }
      ]
    },
    {
      "name": "Filters & Error Checking",
      "item": [
        {
          "name": "Negative - Missing Student Name",
          "request": {
            "method": "POST",
            "header": [{ "key": "Content-Type", "value": "application/json" }],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"student\": {\n    \"name\": \"\",\n    \"email\": \"missing@example.com\"\n  }\n}"
            },
            "url": { "raw": "http://localhost:3000/api/students", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "students"] }
          }
        },
        {
          "name": "Filter Students by Name",
          "request": {
            "method": "GET",
            "url": { "raw": "http://localhost:3000/api/students?name=Alice", "protocol": "http", "host": ["localhost"], "port": "3000", "path": ["api", "students"], "query": [{ "key": "name", "value": "Alice" }] }
          }
        }
      ]
    }
  ]
}
```
