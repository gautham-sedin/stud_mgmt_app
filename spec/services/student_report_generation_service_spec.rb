require "rails_helper"

RSpec.describe StudentReportGenerationService, type: :service do
  let!(:student) do
    create(:student)
  end

  subject(:service) do
    described_class.new(student.id)
  end

  describe "#call" do
    context "when the student exists" do
      let(:pdf_service) do
        instance_double(StudentReportPdfService)
      end

      before do
        allow(StudentReportPdfService)
          .to receive(:new)
          .with(student)
          .and_return(pdf_service)

        allow(pdf_service)
          .to receive(:generate)
          .and_return("%PDF fake report")

        allow(StudentNotificationService)
          .to receive(:send_report_card_ready)
      end

      it "generates the report PDF" do
        service.call

        expect(StudentReportPdfService)
          .to have_received(:new)
          .with(student)

        expect(pdf_service)
          .to have_received(:generate)
      end
    end

    context "when the student does not already have a report card" do
      let(:pdf_service) do
        instance_double(StudentReportPdfService)
      end

      before do
        allow(StudentReportPdfService)
          .to receive(:new)
          .and_return(pdf_service)

        allow(pdf_service)
          .to receive(:generate)
          .and_return("%PDF Dummy Report")

        allow(StudentNotificationService)
          .to receive(:send_report_card_ready)
      end

      it "attaches the generated report" do
        expect(student.report_card)
          .not_to be_attached

        service.call

        student.reload

        expect(student.report_card)
          .to be_attached

        expect(student.report_card.filename.to_s)
          .to eq("#{student.name.parameterize}_report_card.pdf")
      end
    end

    context "when the student already has a report card" do
      let(:pdf_service) do
        instance_double(StudentReportPdfService)
      end

      before do
        student.report_card.attach(
          io: StringIO.new("Old Report"),
          filename: "old_report.pdf",
          content_type: "application/pdf"
        )

        allow(StudentReportPdfService)
          .to receive(:new)
          .and_return(pdf_service)

        allow(pdf_service)
          .to receive(:generate)
          .and_return("%PDF Updated Report")

        allow(StudentNotificationService)
          .to receive(:send_report_card_ready)
      end

      it "replaces the previous report card" do
        expect(student.report_card)
          .to be_attached

        old_blob_id = student.report_card.blob.id

        service.call

        student.reload

        expect(student.report_card)
          .to be_attached

        expect(student.report_card.blob.id)
          .not_to eq(old_blob_id)
      end
    end

    context "when the report is generated successfully" do
      let(:pdf_service) do
        instance_double(StudentReportPdfService)
      end

      before do
        allow(StudentReportPdfService)
          .to receive(:new)
          .and_return(pdf_service)

        allow(pdf_service)
          .to receive(:generate)
          .and_return("%PDF Final Report")

        allow(StudentNotificationService)
          .to receive(:send_report_card_ready)
      end

      it "sends the report ready notification" do
        service.call

        expect(StudentNotificationService)
          .to have_received(:send_report_card_ready)
          .with(student)
      end
    end

    context "when the student does not exist" do
      subject(:service) do
        described_class.new(-999)
      end

      before do
        allow(StudentReportPdfService)
          .to receive(:new)

        allow(StudentNotificationService)
          .to receive(:send_report_card_ready)
      end

      it "returns without generating a report" do
        expect {
          service.call
        }.not_to raise_error
      end

      it "does not initialize the PDF service" do
        service.call

        expect(StudentReportPdfService)
          .not_to have_received(:new)
      end

      it "does not send a notification" do
        service.call

        expect(StudentNotificationService)
          .not_to have_received(:send_report_card_ready)
      end
    end
  end
end
