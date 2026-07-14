# spec/requests/students/authorization_spec.rb

require "rails_helper"

RSpec.describe "Student Authorization", type: :request do
  let(:admin) { create(:user, :admin) }

  let(:teacher) { create(:user, :teacher) }

  let!(:student) do
    create(
      :student,
      email: "student@example.com"
    )
  end

  let(:student_user) do
    User.find_by!(email: student.email)
  end

  let!(:another_student) do
    create(:student)
  end

  describe "GET /students" do
    context "when signed in as admin" do
      before do
        sign_in(admin)
      end

      it "allows access to the students index" do
        get students_path

        expect(response)
          .to have_http_status(:ok)
      end
    end

    context "when signed in as teacher" do
      before do
        sign_in(teacher)
      end

      it "allows access to the students index" do
        get students_path

        expect(response)
          .to have_http_status(:ok)
      end
    end

    context "when signed in as student" do
      before do
        sign_in(student_user)
      end

      it "redirects to the home page" do
        get students_path

        expect(response)
          .to redirect_to(root_path)
      end

      it "shows an access denied message" do
        get students_path

        expect(flash[:alert])
          .to eq("Access denied. Student account do not have access to this page.")
      end
    end
  end

  describe "GET /students/:id" do
    context "when signed in as admin" do
      before do
        sign_in(admin)
      end

      it "allows viewing any student profile" do
        get student_path(student)

        expect(response)
          .to have_http_status(:ok)

        expect(response.body)
          .to include(student.name)
      end
    end

    context "when signed in as teacher" do
      let!(:teacher_student) do
        create(:student, user: teacher)
      end

      before do
        sign_in(teacher)
      end

      it "allows viewing assigned student profile" do
        get student_path(teacher_student)

        expect(response)
          .to have_http_status(:ok)

        expect(response.body)
          .to include(teacher_student.name)
      end
    end

    context "when signed in as student" do
      before do
        sign_in(student_user)
      end

      it "allows viewing their own profile" do
        get student_path(student)

        expect(response)
          .to have_http_status(:ok)

        expect(response.body)
          .to include(student.name)
      end

      it "prevents viewing another student's profile" do
        get student_path(another_student)

        expect(response)
          .to redirect_to(root_path)

        expect(flash[:alert])
          .to eq(
            "Access denied. You can only view your own student profile."
          )
      end
    end
  end

  describe "Protected management actions" do
    before do
      sign_in(student_user)
    end

    it "prevents access to the new student page" do
      get new_student_path

      expect(response)
        .to redirect_to(root_path)

      expect(flash[:alert])
        .to eq("Access denied. Student account do not have access to this page.")
    end

    it "prevents creating a student" do
      expect do
        post students_path,
            params: {
              student: {
                name: "Unauthorized",
                email: "unauthorized@example.com",
                age: 20,
                city: "Chennai",
                course: "Ruby",
                marks: 80
              }
            }
      end.not_to change(Student, :count)

      expect(response)
        .to redirect_to(root_path)
    end

    it "prevents accessing the edit page" do
      get edit_student_path(student)

      expect(response)
        .to redirect_to(root_path)
    end

    it "prevents updating a student" do
      patch student_path(student),
            params: {
              student: {
                name: "Hacked Name"
              }
            }

      expect(response)
        .to redirect_to(root_path)

      expect(student.reload.name)
        .not_to eq("Hacked Name")
    end

    it "prevents deleting a student" do
      expect do
        delete student_path(student)
      end.not_to change(Student, :count)

      expect(response)
        .to redirect_to(root_path)
    end
  end
end