require "rails_helper"

RSpec.describe "API V1 Students", type: :request do
  let!(:admin) { create(:user, :admin) }

  let!(:teacher) { create(:user, :teacher) }

  let!(:student1) do
    create(
      :student,
      user: teacher,
      name: "Rahul",
      course: "Rails"
    )
  end

  let!(:student2) do
    create(
      :student,
      user: teacher,
      name: "Ajay",
      course: "Ruby"
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

  describe "GET /api/v1/students" do
    context "when logged in as admin" do
      before do
        get "/api/v1/students",
            headers: auth_headers(admin)
      end

      it "returns http success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "returns all students" do
        body = JSON.parse(response.body)

        expect(body.length)
          .to eq(Student.count)
      end

      it "returns student names" do
        body = JSON.parse(response.body)

        names = body.map { |student| student["name"] }

        expect(names)
          .to include(student1.name)

        expect(names)
          .to include(student2.name)
      end
    end

    context "when logged in as teacher" do
      before do
        get "/api/v1/students",
            headers: auth_headers(teacher)
      end

      it "returns only the teacher's students" do
        body = JSON.parse(response.body)

        expect(body.length)
          .to eq(teacher.students.count)
      end
    end
  end

  describe "GET /api/v1/students/:id" do
    context "when logged in as admin" do
      before do
        get "/api/v1/students/#{student1.id}",
            headers: auth_headers(admin)
      end

      it "returns http success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "returns the requested student" do
        body = JSON.parse(response.body)

        expect(body["id"])
          .to eq(student1.id)

        expect(body["name"])
          .to eq(student1.name)

        expect(body["email"])
          .to eq(student1.email)
      end

      it "includes teacher information" do
        body = JSON.parse(response.body)

        expect(body["teacher"]["id"])
          .to eq(teacher.id)

        expect(body["teacher"]["name"])
          .to eq(teacher.name)
      end
    end
  end

  describe "POST /api/v1/students" do
    let(:valid_params) do
      {
        student: {
          name: "Karthik",
          email: "karthik@example.com",
          age: 22,
          city: "Chennai",
          course: "Rails",
          marks: 91,
          user_id: teacher.id
        }
      }
    end

    let(:teacher_params) do
      {
        student: {
          name: "Karthik",
          email: "karthik@example.com",
          age: 22,
          city: "Chennai",
          course: "Rails",
          marks: 91
        }
      }
    end

    let(:invalid_params) do
      {
        student: {
          name: "",
          email: "",
          course: "",
          age: nil,
          city: ""
        }
      }
    end

    context "when logged in as admin" do
      it "creates a student" do
        expect do
          post "/api/v1/students",
              params: valid_params,
              headers: auth_headers(admin)
        end.to change(Student, :count).by(1)
      end

      it "returns created" do
        post "/api/v1/students",
            params: valid_params,
            headers: auth_headers(admin)

        expect(response)
          .to have_http_status(:created)
      end

      it "returns the created student" do
        post "/api/v1/students",
            params: valid_params,
            headers: auth_headers(admin)

        body = JSON.parse(response.body)

        expect(body["student"]["name"])
          .to eq("Karthik")

        expect(body["student"]["course"])
          .to eq("Rails")
      end
    end

    context "when logged in as teacher" do
      it "creates a student assigned to the teacher" do
        expect do
          post "/api/v1/students",
              params: teacher_params,
              headers: auth_headers(teacher)
        end.to change(Student, :count).by(1)

        expect(Student.last.user)
          .to eq(teacher)
      end
    end

    context "with invalid parameters" do
      before do
        post "/api/v1/students",
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

    context "when logged in as a student" do
      let!(:student_user) do
        User.find_by(email: student1.email)
      end

      before do
        post "/api/v1/students",
            params: teacher_params,
            headers: auth_headers(student_user)
      end

      it "returns forbidden" do
        expect(response)
          .to have_http_status(:forbidden)
      end

      it "returns an access denied message" do
        body = JSON.parse(response.body)

        expect(body["errors"])
          .to eq(["Access denied. Teachers and Admins only."])
      end
    end
  end

  describe "PATCH /api/v1/students/:id" do
    let(:update_params) do
      {
        student: {
          name: "Updated Student",
          city: "Coimbatore",
          marks: 95
        }
      }
    end

    context "when logged in as admin" do
      before do
        patch "/api/v1/students/#{student1.id}",
          params: update_params,
          headers: auth_headers(admin)
      end

      it "returns http success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "updates the student" do
        student1.reload

        expect(student1.name)
          .to eq("Updated Student")

        expect(student1.city)
          .to eq("Coimbatore")

        expect(student1.marks)
          .to eq(95)
      end

      it "returns the updated student" do
        body = JSON.parse(response.body)

        expect(body["student"]["name"])
          .to eq("Updated Student")
      end
    end

    context "when logged in as teacher" do
      before do
        patch "/api/v1/students/#{student1.id}",
          params: update_params,
          headers: auth_headers(teacher)
      end

      it "updates the student" do
        expect(response)
          .to have_http_status(:ok)

        student1.reload

        expect(student1.name)
          .to eq("Updated Student")
      end
    end

    context "with invalid parameters" do
      before do
        patch "/api/v1/students/#{student1.id}",
          params: {
            student: {
              email: ""
            }
          },
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

    context "when logged in as student" do
      let!(:student_user) do
        User.find_by(email: student1.email)
      end

      before do
        patch "/api/v1/students/#{student1.id}",
          params: update_params,
          headers: auth_headers(student_user)
      end

      it "returns forbidden" do
        expect(response)
          .to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/students/:id" do

    context "when logged in as admin" do
      it "deletes the student" do
        expect do
          delete "/api/v1/students/#{student1.id}",
            headers: auth_headers(admin)
        end.to change(Student, :count).by(-1)
      end

      it "returns success" do
        delete "/api/v1/students/#{student1.id}",
          headers: auth_headers(admin)

        expect(response)
          .to have_http_status(:ok)
      end
    end

    context "when logged in as teacher" do
      it "deletes one of their students" do
        expect do
          delete "/api/v1/students/#{student1.id}",
            headers: auth_headers(teacher)
        end.to change(Student, :count).by(-1)
      end
    end

    context "when logged in as student" do
      let!(:student_user) do
        User.find_by(email: student1.email)
      end

      before do
        delete "/api/v1/students/#{student1.id}",
          headers: auth_headers(student_user)
      end

      it "returns forbidden" do
        expect(response)
          .to have_http_status(:forbidden)
      end
    end

    context "when the student does not exist" do
      before do
        delete "/api/v1/students/999999",
          headers: auth_headers(admin)
      end

      it "returns not found" do
        expect(response)
          .to have_http_status(:not_found)
      end

      it "returns an error message" do
        body = JSON.parse(response.body)

        expect(body["errors"])
          .to eq(["Student not found."])
      end
    end
  end

  describe "POST /api/v1/students/:id/generate_report" do
    context "when logged in as admin" do
      before do
        allow(StudentReportService)
          .to receive(:queue)

        post "/api/v1/students/#{student1.id}/generate_report",
            headers: auth_headers(admin)
      end

      it "queues report generation" do
        expect(StudentReportService)
          .to have_received(:queue)
          .with(student1)
      end

      it "returns accepted" do
        expect(response)
          .to have_http_status(:accepted)
      end

      it "returns success message" do
        body = JSON.parse(response.body)

        expect(body["success"])
          .to eq(true)

        expect(body["data"]["status"])
          .to eq("queued")
      end
    end

    context "when logged in as teacher" do
      before do
        allow(StudentReportService)
          .to receive(:queue)

        post "/api/v1/students/#{student1.id}/generate_report",
            headers: auth_headers(teacher)
      end

      it "queues report generation" do
        expect(StudentReportService)
          .to have_received(:queue)
          .with(student1)
      end
    end

    context "when logged in as student" do
      let!(:student_user) do
        User.find_by(email: student1.email)
      end

      before do
        post "/api/v1/students/#{student1.id}/generate_report",
            headers: auth_headers(student_user)
      end

      it "returns forbidden" do
        expect(response)
          .to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v1/students/:id/generate_all_reports" do
    context "when logged in as admin" do
      before do
        allow(StudentReportService)
          .to receive(:queue_all)

        post "/api/v1/students/generate_all_reports",
            headers: auth_headers(admin)
      end

      it "queues reports for every student" do
        expect(StudentReportService)
          .to have_received(:queue_all)
      end

      it "returns accepted" do
        expect(response)
          .to have_http_status(:accepted)
      end
    end

    context "when logged in as teacher" do
      before do
        post "/api/v1/students/generate_all_reports",
            headers: auth_headers(teacher)
      end

      it "returns forbidden" do
        expect(response)
          .to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /api/v1/students/:id/report" do
    context "when the report card is not attached" do
      before do
        get "/api/v1/students/#{student1.id}/report",
            headers: auth_headers(admin)
      end

      it "returns not found" do
        expect(response)
          .to have_http_status(:not_found)
      end

      it "returns an error message" do
        body = JSON.parse(response.body)

        expect(body["errors"])
          .to eq(["Report card has not been generated yet."])
      end
    end

    context "when the report card exists" do
      before do
        student1.report_card.attach(
          io: StringIO.new("Dummy PDF"),
          filename: "report.pdf",
          content_type: "application/pdf"
        )

        get "/api/v1/students/#{student1.id}/report",
            headers: auth_headers(admin)
      end

      it "redirects to the report download" do
        expect(response)
          .to have_http_status(:redirect)
      end
    end
  end
end