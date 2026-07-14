require "rails_helper"

RSpec.describe StudentReportPdfService, type: :service do
  subject(:pdf_service) do
    described_class.new(student)
  end

  let(:teacher) do
    create(
      :user,
      :teacher,
      name: "John Teacher"
    )
  end

  let(:student) do
    create(
      :student,
      user: teacher,
      name: "Rahul Sharma",
      email: "rahul@example.com",
      age: 21,
      city: "Chennai",
      course: "Rails",
      marks: 85
    )
  end

  describe "#generate" do
    let(:pdf) do
      pdf_service.generate
    end

    it "returns a PDF document" do
      expect(pdf)
        .to be_present

      expect(pdf)
        .to be_a(String)
    end

    it "starts with the PDF file signature" do
      expect(pdf)
        .to start_with("%PDF")
    end

    it "returns a non-empty PDF" do
      expect(pdf.bytesize)
        .to be > 100
    end
    
  end

  describe "#generate when the student has no teacher" do
    let(:student) do
      build(
        :student,
        user: nil
      )
    end

    it "still generates a valid PDF" do
      pdf = described_class.new(student).generate

      expect(pdf)
        .to start_with("%PDF")

      expect(pdf.bytesize)
        .to be > 100
    end
  end
end