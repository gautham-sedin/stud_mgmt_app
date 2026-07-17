require "rails_helper"

RSpec.describe StudentMailer, type: :mailer do
  let(:teacher) do
    create(
      :user,
      :teacher,
      name: "Anand Sir"
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

  describe "#welcome_email" do
    subject(:mail) do
      described_class.welcome_email(student)
    end

    it "sends the email to the student" do
      expect(mail.to)
        .to eq([ student.email ])
    end

    it "has the correct subject" do
      expect(mail.subject)
        .to eq("Welcome to SedCollege!")
    end

    it "contains the student name" do
      expect(mail.body.encoded)
        .to include(student.name)
    end
  end

  describe "#teacher_assigned_email" do
    subject(:mail) do
      described_class.teacher_assigned_email(student)
    end

    it "sends the email to the student" do
      expect(mail.to)
        .to eq([ student.email ])
    end

    it "has the correct dynamic subject" do
      expect(mail.subject)
        .to eq("New Teacher Assigned: #{teacher.name}")
    end

    it "contains the student name" do
      expect(mail.body.encoded)
        .to include(student.name)
    end

    it "contains the teacher name" do
      expect(mail.body.encoded)
        .to include(teacher.name)
    end
  end

  describe "#attachments_uploaded_email" do
    subject(:mail) do
      described_class.attachments_uploaded_email(student)
    end

    it "sends the email to the student" do
      expect(mail.to)
        .to eq([ student.email ])
    end

    it "has the correct subject" do
      expect(mail.subject)
        .to eq("New Attachments Uploaded")
    end

    it "contains the student name" do
      expect(mail.body.encoded)
        .to include(student.name)
    end
  end

  describe "#report_card_ready" do
    subject(:mail) do
      described_class.report_card_ready(student)
    end

    it "sends the email to the student" do
      expect(mail.to)
        .to eq([ student.email ])
    end

    it "has the correct subject" do
      expect(mail.subject)
        .to eq("Your Report Card is Ready")
    end

    it "contains the student name" do
      expect(mail.body.encoded)
        .to include(student.name)
    end
  end
end
