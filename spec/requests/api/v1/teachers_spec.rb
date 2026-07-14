require "rails_helper"

RSpec.describe "API V1 Teachers", type: :request do
  let!(:admin) { create(:user, :admin) }

  let!(:teacher) do
    create(
      :user,
      :teacher,
      name: "Anand",
      email: "anand@example.com"
    )
  end

  let!(:student) do
    create(
      :student,
      user: teacher
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

  describe "GET /api/v1/teachers" do
    context "when logged in as admin" do
      before do
        get "/api/v1/teachers",
            headers: auth_headers(admin)
      end

      it "returns http success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "returns teachers" do
        body = JSON.parse(response.body)

        expect(body.first["id"])
          .to eq(teacher.id)
      end

      it "returns total_students" do
        body = JSON.parse(response.body)

        expect(body.first["total_students"])
          .to eq(teacher.students.count)
      end
    end

    context "when logged in as teacher" do
      before do
        get "/api/v1/teachers",
            headers: auth_headers(teacher)
      end

      it "returns forbidden" do
        expect(response)
          .to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /api/v1/teachers/:id" do
    before do
      get "/api/v1/teachers/#{teacher.id}",
          headers: auth_headers(admin)
    end

    it "returns success" do
      expect(response)
        .to have_http_status(:ok)
    end

    it "returns teacher details" do
      body = JSON.parse(response.body)

      expect(body["id"])
        .to eq(teacher.id)

      expect(body["name"])
        .to eq(teacher.name)
    end

    it "returns assigned students" do
      body = JSON.parse(response.body)

      expect(body["students"].size)
        .to eq(teacher.students.count)
    end
  end

  describe "POST /api/v1/teachers" do
    let(:valid_params) do
      {
        teacher: {
          name: "Meera",
          email: "meera@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    context "with valid parameters" do
      it "creates a teacher" do
        expect do
          post "/api/v1/teachers",
              params: valid_params,
              headers: auth_headers(admin)
        end.to change(User.teacher, :count).by(1)
      end

      it "returns created" do
        post "/api/v1/teachers",
            params: valid_params,
            headers: auth_headers(admin)

        expect(response)
          .to have_http_status(:created)
      end
    end
  end

  describe "PATCH /api/v1/teachers/:id" do
    before do
      patch "/api/v1/teachers/#{teacher.id}",
            params: {
              teacher: {
                name: "Updated Teacher"
              }
            },
            headers: auth_headers(admin)
    end

    it "updates the teacher" do
      teacher.reload

      expect(teacher.name)
        .to eq("Updated Teacher")
    end

    it "returns success" do
      expect(response)
        .to have_http_status(:ok)
    end
  end

  describe "DELETE /api/v1/teachers/:id" do
    it "deletes the teacher" do
      expect do
        delete "/api/v1/teachers/#{teacher.id}",
              headers: auth_headers(admin)
      end.to change(User.teacher, :count).by(-1)
    end

    it "returns success" do
      delete "/api/v1/teachers/#{teacher.id}",
            headers: auth_headers(admin)

      expect(response)
        .to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/teachers/:id" do
    context "when the teacher does not exist" do
      before do
        get "/api/v1/teachers/999999",
            headers: auth_headers(admin)
      end

      it "returns not found" do
        expect(response)
          .to have_http_status(:not_found)
      end

      it "returns an error message" do
        body = JSON.parse(response.body)

        expect(body["errors"])
          .to eq(["Teacher not found"])
      end
    end
  end
end