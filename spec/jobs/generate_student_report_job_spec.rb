require "rails_helper"

RSpec.describe GenerateStudentReportJob, type: :job do
  describe "#perform" do
    let(:student) do
      create(:student)
    end

    let(:service_instance) do
      instance_double(StudentReportGenerationService)
    end

    before do
      allow(StudentReportGenerationService)
        .to receive(:new)
        .with(student.id)
        .and_return(service_instance)

      allow(service_instance)
        .to receive(:call)
    end

    it "initializes the report generation service" do
      described_class.perform_now(student.id)

      expect(StudentReportGenerationService)
        .to have_received(:new)
        .with(student.id)
    end

    it "calls the report generation service" do
      described_class.perform_now(student.id)

      expect(service_instance)
        .to have_received(:call)
    end
  end
end