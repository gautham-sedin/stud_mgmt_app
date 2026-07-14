require "rails_helper"

RSpec.describe "Users", type: :request do
  let!(:admin) do
    create(:user, :admin)
  end

  let!(:teacher) do
    create(:user, :teacher)
  end

  let!(:student_teacher) do
    create(:user, :teacher)
  end

  let!(:student) do
    create(
      :student,
      user: teacher
    )
  end

  let!(:student_user) do
    User.find_by(email: student.email)
  end

  describe "GET /users" do
    context "when logged in as admin" do
      before do
        sign_in(admin)
        get users_path
      end

      it "returns success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "renders the teachers list" do
        expect(response.body)
          .to include(teacher.name)

        expect(response.body)
          .to include(student_teacher.name)
      end
    end

    context "when logged in as teacher" do
      before do
        sign_in(teacher)
        get users_path
      end

      it "redirects to the home page" do
        expect(response)
          .to redirect_to(root_path)
      end

      it "shows an access denied alert" do
        expect(flash[:alert])
          .to eq("Access denied.")
      end
    end

    context "when logged in as student" do
      before do
        sign_in(student_user)
        get users_path
      end

      it "redirects to the home page" do
        expect(response)
          .to redirect_to(root_path)
      end

      it "shows an access denied alert" do
        expect(flash[:alert])
          .to eq("Access denied.")
      end
    end

    context "when not signed in" do
      before do
        get users_path
      end

      it "redirects to the login page" do
        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end
end