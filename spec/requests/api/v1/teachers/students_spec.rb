require "rails_helper"

RSpec.describe "API V1 Teachers Students", type: :request do
  let!(:admin) { create(:user, :admin) }

  let!(:teacher) do
    create(
      :user,
      :teacher,
      name: "Anand",
      email: "anand@example.com"
    )
  end

  let!(:another_teacher) do
    create(
      :user,
      :teacher,
      name: "Meera",
      email: "meera@example.com"
    )
  end

  let!(:student1) do
    create(
      :student,
      user: teacher,
      name: "Rahul"
    )
  end

  let!(:student2) do
    create(
      :student,
      user: teacher,
      name: "Ajay"
    )
  end

  def auth_headers(user)
    token = JWT.encode(
      {
        user_id: user.id,
        email: user.email,
        role: user.role,
        exp: 24.hours.from_now.to_i
      },
      Rails.application.secret_key_base,
      "HS256"
    )

    {
      "Authorization" => "Bearer #{token}"
    }
  end

  describe "GET /api/v1/teachers/:teacher_id/students" do
    context "when logged in as admin" do
      before do
        get "/api/v1/teachers/#{teacher.id}/students",
            headers: auth_headers(admin)
      end

      it "returns http success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "returns all students for the teacher" do
        body = JSON.parse(response.body)

        expect(body.size)
          .to eq(teacher.students.count)
      end

      it "returns the student names" do
        body = JSON.parse(response.body)

        names = body.map { |student| student["name"] }

        expect(names)
          .to include(student1.name)

        expect(names)
          .to include(student2.name)
      end
    end

    context "when the teacher views their own students" do
      before do
        get "/api/v1/teachers/#{teacher.id}/students",
            headers: auth_headers(teacher)
      end

      it "returns success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "returns their students" do
        body = JSON.parse(response.body)

        expect(body.size)
          .to eq(teacher.students.count)
      end
    end

    context "when a teacher tries to view another teacher's students" do
      before do
        get "/api/v1/teachers/#{teacher.id}/students",
            headers: auth_headers(another_teacher)
      end

      it "returns forbidden" do
        expect(response)
          .to have_http_status(:forbidden)
      end

      it "returns an access denied message" do
        body = JSON.parse(response.body)

        expect(body["errors"])
          .to eq(
            [ "Access denied. You can only view your own students." ]
          )
      end
    end

    context "when the teacher does not exist" do
      before do
        get "/api/v1/teachers/999999/students",
            headers: auth_headers(admin)
      end

      it "returns not found" do
        expect(response)
          .to have_http_status(:not_found)
      end

      it "returns an error message" do
        body = JSON.parse(response.body)

        expect(body["errors"])
          .to eq([ "Teacher not found" ])
      end
    end
  end

  describe "POST /api/v1/teachers/:teacher_id/students" do
    let(:valid_params) do
      {
        student: {
          name: "Karthik",
          email: "karthik@example.com",
          age: 21,
          city: "Chennai",
          course: "Rails",
          marks: 88
        }
      }
    end

    let(:invalid_params) do
      {
        student: {
          name: "",
          email: "",
          course: "",
          city: ""
        }
      }
    end

    context "when logged in as admin" do
      it "creates a student under the teacher" do
        expect do
          post "/api/v1/teachers/#{teacher.id}/students",
              params: valid_params,
              headers: auth_headers(admin)
        end.to change(Student, :count).by(1)

        expect(Student.last.user)
          .to eq(teacher)
      end

      it "returns created" do
        post "/api/v1/teachers/#{teacher.id}/students",
            params: valid_params,
            headers: auth_headers(admin)

        expect(response)
          .to have_http_status(:created)
      end
    end

    context "when the teacher creates their own student" do
      it "creates the student" do
        expect do
          post "/api/v1/teachers/#{teacher.id}/students",
              params: valid_params,
              headers: auth_headers(teacher)
        end.to change(Student, :count).by(1)
      end
    end

    context "when a teacher creates a student for another teacher" do
      before do
        post "/api/v1/teachers/#{teacher.id}/students",
            params: valid_params,
            headers: auth_headers(another_teacher)
      end

      it "returns forbidden" do
        expect(response)
          .to have_http_status(:forbidden)
      end
    end

    context "with invalid parameters" do
      before do
        post "/api/v1/teachers/#{teacher.id}/students",
            params: invalid_params,
            headers: auth_headers(admin)
      end

      it "returns unprocessable content" do
        expect(response)
          .to have_http_status(:unprocessable_content)
      end

      it "returns validation errors" do
        body = JSON.parse(response.body)

        expect(body["errors"])
          .not_to be_empty
      end
    end

    context "when the teacher does not exist" do
      before do
        post "/api/v1/teachers/999999/students",
            params: valid_params,
            headers: auth_headers(admin)
      end

      it "returns not found" do
        expect(response)
          .to have_http_status(:not_found)
      end
    end
  end
end
