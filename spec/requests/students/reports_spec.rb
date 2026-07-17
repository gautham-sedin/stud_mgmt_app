require "rails_helper"

RSpec.describe "Student Reports", type: :request do
  let(:admin) { create(:user, :admin) }

  let(:teacher) { create(:user, :teacher) }

  let!(:student) do
    create(:student, user: teacher)
  end

  describe "POST /students/:id/generate_report" do
    context "when signed in as admin" do
      before do
        sign_in(admin)
      end

      it "queues report generation" do
        expect(StudentReportService)
          .to receive(:queue)
          .with(student)

        post generate_report_student_path(student)
      end

      it "redirects back after queueing" do
        post generate_report_student_path(student),
             headers: {
               "HTTP_REFERER" => students_path
             }

        expect(response)
          .to redirect_to(students_path)
      end

      it "shows a success flash message" do
        post generate_report_student_path(student),
             headers: {
               "HTTP_REFERER" => students_path
             }

        expect(flash[:notice])
          .to eq("Report generation has been queued successfully.")
      end
    end
    context "when signed in as teacher" do
      before do
        sign_in(teacher)
      end

      it "queues report generation successfully" do
        post generate_report_student_path(student),
             headers: {
               "HTTP_REFERER" => students_path
             }

        expect(response)
          .to redirect_to(students_path)

        expect(flash[:notice])
          .to eq("Report generation has been queued successfully.")
      end
    end

    context "when signed in as student" do
      let!(:student_profile) do
        create(
          :student,
          email: "student@example.com"
        )
      end

      let(:student_user) do
        User.find_by!(email: student_profile.email)
      end

      let!(:another_student) do
        create(:student)
      end

      before do
        sign_in(student_user)
      end

      it "queues report generation for the logged in student" do
        post generate_report_student_path(student_profile),
             headers: {
               "HTTP_REFERER" => root_path
             }

        expect(response)
          .to redirect_to(root_path)

        expect(flash[:notice])
          .to eq("Report generation has been queued successfully.")
      end

      it "ignores the requested student id and uses the logged in student's profile" do
        post generate_report_student_path(another_student),
             headers: {
               "HTTP_REFERER" => root_path
             }

        expect(response)
          .to redirect_to(root_path)

        expect(flash[:notice])
          .to eq("Report generation has been queued successfully.")
      end
    end
  end

  describe "POST /students/generate_all_reports" do
    context "when signed in as admin" do
      before do
        sign_in(admin)
      end

      it "queues report generation for all students" do
        post generate_all_reports_students_path

        expect(response)
          .to redirect_to(students_path)

        expect(flash[:notice])
          .to eq("Report generation has been queued successfully.")
      end
    end

    context "when signed in as teacher" do
      before do
        sign_in(teacher)
      end

      it "queues report generation" do
        post generate_all_reports_students_path

        expect(response)
          .to redirect_to(students_path)

        expect(flash[:notice])
          .to eq("Report generation has been queued successfully.")
      end
    end
  end

  describe "GET /students/:id/download_report" do
    before do
      sign_in(admin)
    end

    context "when the report card exists" do
      before do
        student.report_card.attach(
          io: StringIO.new("Dummy Report"),
          filename: "report.pdf",
          content_type: "application/pdf"
        )
      end

      it "redirects to the Active Storage download URL" do
        get download_report_student_path(student)

        expect(response)
          .to have_http_status(:redirect)

        expect(response.location)
          .to include("/rails/active_storage")
      end
    end

    context "when the report card does not exist" do
      it "redirects back with an alert" do
        get download_report_student_path(student),
            headers: {
              "HTTP_REFERER" => students_path
            }

        expect(response)
          .to redirect_to(students_path)

        expect(flash[:alert])
          .to eq("Report card has not been generated yet.")
      end
    end
  end
end
