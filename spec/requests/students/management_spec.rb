# spec/requests/students/management_spec.rb

require "rails_helper"

RSpec.describe "Student Management", type: :request do
  let(:admin) { create(:user, :admin) }

  let(:teacher) { create(:user, :teacher) }

  describe "POST /students" do
    context "when signed in as admin" do
      before do
        sign_in(admin)
      end

      let(:assigned_teacher) do
        create(:user, :teacher)
      end

      let(:valid_params) do
        {
          student: {
            name: "Rahul Sharma",
            email: "rahul@example.com",
            age: 21,
            city: "Chennai",
            course: "Rails",
            marks: 85,
            user_id: assigned_teacher.id
          }
        }
      end

      it "creates a student successfully" do
        expect do
          post students_path,
               params: valid_params
        end.to change(Student, :count).by(1)
      end

      it "redirects to the student profile" do
        post students_path,
             params: valid_params

        expect(response)
          .to redirect_to(student_path(Student.last))
      end

      it "shows a success flash message" do
        post students_path,
             params: valid_params

        expect(flash[:notice])
          .to eq("Student created successfully.")
      end
    end

    context "when signed in as teacher" do
      before do
        sign_in(teacher)
      end

      let(:valid_params) do
        {
          student: {
            name: "Rahul Sharma",
            email: "rahul@example.com",
            age: 21,
            city: "Chennai",
            course: "Rails",
            marks: 85
          }
        }
      end

      it "creates a student under the logged in teacher" do
        post students_path,
             params: valid_params

        expect(Student.last.user)
          .to eq(teacher)
      end

      it "creates a new student record" do
        expect do
          post students_path,
               params: valid_params
        end.to change(Student, :count).by(1)
      end

      it "redirects after creation" do
        post students_path,
             params: valid_params

        expect(response)
          .to redirect_to(student_path(Student.last))
      end
    end

    context "with invalid parameters" do
      before do
        sign_in(admin)
      end

      let(:assigned_teacher) do
        create(:user, :teacher)
      end

      let(:invalid_params) do
        {
          student: {
            name: "",
            email: "",
            age: nil,
            city: "",
            course: "",
            marks: 150,
            user_id: assigned_teacher.id
          }
        }
      end

      it "does not create a student" do
        expect do
          post students_path,
               params: invalid_params
        end.not_to change(Student, :count)
      end

      it "returns unprocessable content" do
        post students_path,
             params: invalid_params

        expect(response)
          .to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /students/:id" do
    let!(:student) do
      create(:student, user: teacher)
    end

    context "when signed in as teacher" do
      before do
        sign_in(teacher)
      end

      let(:update_params) do
        {
          student: {
            name: "Updated Student",
            city: "Bangalore",
            marks: 95
          }
        }
      end

      it "updates the student successfully" do
        patch student_path(student),
              params: update_params

        student.reload

        expect(student.name)
          .to eq("Updated Student")

        expect(student.city)
          .to eq("Bangalore")

        expect(student.marks)
          .to eq(95)
      end

      it "redirects to the student profile" do
        patch student_path(student),
              params: update_params

        expect(response)
          .to redirect_to(student_path(student))
      end

      it "shows a success flash message" do
        patch student_path(student),
              params: update_params

        expect(flash[:notice])
          .to eq("Student updated successfully.")
      end
    end

    context "with invalid parameters" do
      before do
        sign_in(teacher)
      end

      let(:invalid_params) do
        {
          student: {
            name: "",
            marks: 150
          }
        }
      end

      it "does not update the student" do
        original_name = student.name

        patch student_path(student),
              params: invalid_params

        expect(student.reload.name)
          .to eq(original_name)
      end

      it "returns unprocessable content" do
        patch student_path(student),
              params: invalid_params

        expect(response)
          .to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /students/:id" do
    context "when signed in as admin" do
      let!(:student) do
        create(:student)
      end

      before do
        sign_in(admin)
      end

      it "deletes the student" do
        expect do
          delete student_path(student)
        end.to change(Student, :count).by(-1)
      end

      it "redirects to the students index" do
        delete student_path(student)

        expect(response)
          .to redirect_to(students_path)
      end

      it "shows a success flash message" do
        delete student_path(student)

        expect(flash[:notice])
          .to eq("Student deleted successfully.")
      end
    end

    context "when signed in as teacher" do
      let!(:student) do
        create(:student, user: teacher)
      end

      before do
        sign_in(teacher)
      end

      it "deletes the assigned student" do
        expect do
          delete student_path(student)
        end.to change(Student, :count).by(-1)
      end

      it "redirects to the students index" do
        delete student_path(student)

        expect(response)
          .to redirect_to(students_path)
      end
    end
  end

  describe "Turbo Stream CRUD" do
    before do
      sign_in(teacher)
    end

    let!(:student) do
      create(:student, user: teacher)
    end

    let(:headers) do
      {
        "ACCEPT" => "text/vnd.turbo-stream.html"
      }
    end

    describe "POST /students" do
      let(:params) do
        {
          student: {
            name: "Turbo Student",
            email: "turbo@example.com",
            age: 20,
            city: "Chennai",
            course: "Ruby",
            marks: 90
          }
        }
      end

      it "creates the student" do
        expect do
          post students_path,
              params: params,
              headers: headers
        end.to change(Student, :count).by(1)
      end

      it "returns a turbo stream response" do
        post students_path,
            params: params,
            headers: headers

        expect(response.media_type)
          .to eq(Mime[:turbo_stream].to_s)
      end
    end

    describe "PATCH /students/:id" do
      it "updates the student" do
        patch student_path(student),
              params: {
                student: {
                  city: "Bangalore"
                }
              },
              headers: headers

        expect(student.reload.city)
          .to eq("Bangalore")
      end

      it "returns a turbo stream response" do
        patch student_path(student),
              params: {
                student: {
                  city: "Bangalore"
                }
              },
              headers: headers

        expect(response.media_type)
          .to eq(Mime[:turbo_stream].to_s)
      end
    end

    describe "DELETE /students/:id" do
      it "deletes the student" do
        expect do
          delete student_path(student),
                headers: headers
        end.to change(Student, :count).by(-1)
      end

      it "returns a turbo stream response" do
        student_to_delete = create(:student, user: teacher)

        delete student_path(student_to_delete),
              headers: headers

        expect(response.media_type)
          .to eq(Mime[:turbo_stream].to_s)
      end
    end
  end
end