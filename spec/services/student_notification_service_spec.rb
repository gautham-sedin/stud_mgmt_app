require "rails_helper"

RSpec.describe StudentNotificationService, type: :service do
  let(:teacher) do
    create(:user, :teacher)
  end

  let(:student) do
    create(
      :student,
      user: teacher
    )
  end

  describe ".send_welcome_email" do
    let(:message_delivery) do
      instance_double(ActionMailer::MessageDelivery)
    end

    before do
      allow(StudentMailer)
        .to receive(:welcome_email)
        .with(student)
        .and_return(message_delivery)

      allow(message_delivery)
        .to receive(:deliver_later)
    end

    it "sends the welcome email asynchronously" do
      described_class.send_welcome_email(student)

      expect(StudentMailer)
        .to have_received(:welcome_email)
        .with(student)

      expect(message_delivery)
        .to have_received(:deliver_later)
    end
  end

  describe ".send_report_card_ready" do
    let(:message_delivery) do
      instance_double(ActionMailer::MessageDelivery)
    end

    before do
      allow(StudentMailer)
        .to receive(:report_card_ready)
        .with(student)
        .and_return(message_delivery)

      allow(message_delivery)
        .to receive(:deliver_later)
    end

    it "queues the report card ready email" do
      described_class.send_report_card_ready(student)

      expect(StudentMailer)
        .to have_received(:report_card_ready)
        .with(student)

      expect(message_delivery)
        .to have_received(:deliver_later)
    end
  end

  describe ".send_teacher_assignment_notification" do
    let(:student_delivery) do
      instance_double(ActionMailer::MessageDelivery)
    end

    let(:teacher_delivery) do
      instance_double(ActionMailer::MessageDelivery)
    end

    before do
      allow(StudentMailer)
        .to receive(:teacher_assigned_email)
        .with(student)
        .and_return(student_delivery)

      allow(student_delivery)
        .to receive(:deliver_later)

      allow(TeacherMailer)
        .to receive(:new_student)
        .with(student)
        .and_return(teacher_delivery)

      allow(teacher_delivery)
        .to receive(:deliver_later)
    end

    it "sends emails to both the student and teacher" do
      described_class.send_teacher_assignment_notification(student)

      expect(StudentMailer)
        .to have_received(:teacher_assigned_email)
        .with(student)

      expect(student_delivery)
        .to have_received(:deliver_later)

      expect(TeacherMailer)
        .to have_received(:new_student)
        .with(student)

      expect(teacher_delivery)
        .to have_received(:deliver_later)
    end
  end

  describe ".send_attachment_upload_notifications" do
    let(:student_delivery) do
      instance_double(ActionMailer::MessageDelivery)
    end

    let(:teacher_delivery) do
      instance_double(ActionMailer::MessageDelivery)
    end

    before do
      allow(StudentMailer)
        .to receive(:attachments_uploaded_email)
        .with(student)
        .and_return(student_delivery)

      allow(student_delivery)
        .to receive(:deliver_later)

      allow(TeacherMailer)
        .to receive(:student_uploaded_attachments)
        .with(student)
        .and_return(teacher_delivery)

      allow(teacher_delivery)
        .to receive(:deliver_later)
    end

    it "sends attachment upload notifications to both student and teacher" do
      described_class.send_attachment_upload_notifications(student)

      expect(StudentMailer)
        .to have_received(:attachments_uploaded_email)
        .with(student)

      expect(student_delivery)
        .to have_received(:deliver_later)

      expect(TeacherMailer)
        .to have_received(:student_uploaded_attachments)
        .with(student)

      expect(teacher_delivery)
        .to have_received(:deliver_later)
    end
  end
end
