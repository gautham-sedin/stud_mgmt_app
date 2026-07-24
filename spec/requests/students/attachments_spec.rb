require "rails_helper"

RSpec.describe "Student Attachments", type: :request do
  let(:teacher) { create(:user, :teacher) }

  let!(:student) do
    create(:student, user: teacher)
  end

  before do
    sign_in(teacher)
  end

  describe "DELETE /students/:id/remove_profile_photo" do
    before do
      student.profile_photo.attach(
        io: StringIO.new("dummy image"),
        filename: "profile.png",
        content_type: "image/png"
      )
    end

    it "removes the profile photo" do
      expect(student.profile_photo).to be_attached

      delete remove_profile_photo_student_path(student)

      expect(response)
        .to redirect_to(student_path(student))

      expect(flash[:notice])
        .to eq("Profile photo deleted successfully.")

      expect(student.reload.profile_photo)
        .not_to be_attached
    end
  end

  describe "DELETE /students/:id/documents/:attachment_id" do
    let!(:document) do
      student.documents.attach(
        io: StringIO.new("dummy pdf"),
        filename: "resume.pdf",
        content_type: "application/pdf"
      )

      student.documents.last
    end

    it "removes the selected document" do
      expect(student.documents.count)
        .to eq(1)

      delete remove_document_student_path(
        student,
        attachment_id: document.id
      )

      expect(response)
        .to redirect_to(student_path(student))

      expect(flash[:notice])
        .to eq("Document deleted successfully.")

      expect(student.reload.documents.count)
        .to eq(0)
    end

    it "shows an alert when the document does not exist" do
      delete remove_document_student_path(
        student,
        attachment_id: 999999
      )

      expect(response)
        .to redirect_to(student_path(student))

      expect(flash[:alert])
        .to eq("Document not found.")
    end
  end

  describe "PATCH /students/:id with blank attachment fields" do
    before do
      student.profile_photo.attach(
        io: StringIO.new("dummy image"),
        filename: "profile.png",
        content_type: "image/png"
      )

      student.documents.attach(
        io: StringIO.new("dummy pdf"),
        filename: "resume.pdf",
        content_type: "application/pdf"
      )
    end

    it "does not purge existing documents or profile photo when the file fields are submitted blank" do
      expect(student.profile_photo).to be_attached
      expect(student.documents.count).to eq(1)

      # Simulates the browser submitting the edit form's file fields with no
      # new file chosen: a blank string for profile_photo and a blank entry
      # in the documents array.
      patch student_path(student),
            params: {
              student: {
                city: "Bangalore",
                profile_photo: "",
                documents: [ "" ]
              }
            }

      student.reload

      expect(student.city).to eq("Bangalore")
      expect(student.profile_photo).to be_attached
      expect(student.documents.count).to eq(1)
      expect(student.documents.first.filename.to_s).to eq("resume.pdf")
    end

    it "appends new documents without removing the existing ones" do
      patch student_path(student),
            params: {
              student: {
                documents: [
                  fixture_file_upload("sample.pdf", "application/pdf")
                ]
              }
            }

      student.reload

      expect(student.documents.count).to eq(2)
      expect(student.documents.map { |d| d.filename.to_s })
        .to include("resume.pdf", "sample.pdf")
    end
  end
end
