require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    let!(:admin) { create(:user, :admin) }

    let!(:teacher) do
      create(
        :user,
        :teacher,
        name: "John Teacher"
      )
    end

    let!(:student_record) do
      create(
        :student,
        user: teacher,
        name: "Rahul Sharma",
        email: "rahul@example.com"
      )
    end

    let!(:student_user) do
      User.find_by(email: student_record.email)
    end

    context "when logged in as admin" do
      before do
        sign_in(admin)
        get root_path
      end

      it "returns success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "renders the dashboard" do
        expect(response.body)
          .to be_present
      end
    end

    context "when logged in as teacher" do
      before do
        sign_in(teacher)
        get root_path
      end

      it "returns success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "renders the dashboard" do
        expect(response.body)
          .to be_present
      end
    end

    context "when logged in as student with a profile" do
      before do
        sign_in(student_user)
        get root_path
      end

      it "returns success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "renders the dashboard" do
        expect(response.body)
          .to be_present
      end
    end

    context "when a student has no profile" do
      let!(:orphan_student) do
        create(
          :user,
          :student,
          email: "orphan@example.com"
        )
      end

      before do
        sign_in(orphan_student)
        get root_path
      end

      it "redirects to the login page" do
        expect(response)
          .to redirect_to(new_user_session_path)
      end

      it "shows an alert" do
        follow_redirect!

        expect(response.body)
          .to include("Student profile not found")
      end
    end
  end
end
