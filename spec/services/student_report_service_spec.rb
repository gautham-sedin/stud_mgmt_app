require "rails_helper"

RSpec.describe StudentReportService, type: :service do
  describe ".queue" do
    let(:student) { create(:student) }

    it "enqueues the report generation job" do
      expect {
        described_class.queue(student)
      }.to have_enqueued_job(GenerateStudentReportJob)
        .with(student.id)
    end
  end

  describe ".queue_all" do
    let!(:students) { create_list(:student, 3) }

    it "enqueues one job for each student" do
      expect {
        described_class.queue_all
      }.to have_enqueued_job(GenerateStudentReportJob)
        .exactly(3).times
    end

    it "passes the correct student ids" do
      described_class.queue_all

      students.each do |student|
        expect(GenerateStudentReportJob)
          .to have_been_enqueued
          .with(student.id)
      end
    end
  end
end
