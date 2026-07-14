require "rails_helper"

RSpec.describe TeacherMailer, type: :mailer do
  let(:teacher) do
    create(
      :user,
      :teacher,
      name: "Anand Sir",
      email: "anand@example.com"
    )
  end

  let(:student) do
    create(
      :student,
      user: teacher,
      name: "Rahul Sharma",
      email: "rahul@example.com"
    )
  end

  describe "#new_student" do
    subject(:mail) do
      described_class.new_student(student)
    end

    it "sends the email to the assigned teacher" do
      expect(mail.to)
        .to eq([teacher.email])
    end

    it "has the correct dynamic subject" do
      expect(mail.subject)
        .to eq("New Student Assigned: #{student.name}")
    end

    it "contains the teacher name" do
      expect(mail.body.encoded)
        .to include(teacher.name)
    end

    it "contains the student name" do
      expect(mail.body.encoded)
        .to include(student.name)
    end
  end

  describe "#student_uploaded_attachments" do
    subject(:mail) do
      described_class.student_uploaded_attachments(student)
    end

    it "sends the email to the assigned teacher" do
      expect(mail.to)
        .to eq([teacher.email])
    end

    it "has the correct dynamic subject" do
      expect(mail.subject)
        .to eq("New Attachments Uploaded by #{student.name}")
    end

    it "contains the teacher name" do
      expect(mail.body.encoded)
        .to include(teacher.name)
    end

    it "contains the student name" do
      expect(mail.body.encoded)
        .to include(student.name)
    end
  end
end