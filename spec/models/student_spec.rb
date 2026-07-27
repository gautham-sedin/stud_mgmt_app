# spec/models/student_spec.rb

require "rails_helper"

RSpec.describe Student, type: :model do
  subject(:student) { build(:student) }

  describe "Factory" do
    it "has a valid factory" do
      expect(student).to be_valid
    end
  end

  describe "Associations" do
    it { should belong_to(:user) }

    it do
      should belong_to(:student_user)
        .class_name("User")
        .optional
    end

    it { should have_one_attached(:profile_photo) }

    it { should have_one_attached(:report_card) }

    it { should have_many_attached(:documents) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }

    it { should validate_presence_of(:email) }

    it { should validate_uniqueness_of(:email) }

    it do
      should allow_value("student@example.com")
        .for(:email)
    end

    it do
      should_not allow_value("invalid_email")
        .for(:email)
    end

    it "rejects an email with a single-character TLD" do
      should_not allow_value("student@example.c")
        .for(:email)
    end

    it "accepts an email with a valid multi-character TLD" do
      should allow_value("student@example.com")
        .for(:email)
    end

    it "rejects a name containing numbers" do
      should_not allow_value("Student123")
        .for(:name)
    end

    it "rejects a name containing symbols" do
      should_not allow_value("Student@#")
        .for(:name)
    end

    it "accepts a name with letters, spaces, apostrophes and hyphens" do
      should allow_value("Jean-Luc O'Brien")
        .for(:name)
    end

    it { should validate_presence_of(:age) }

    it do
      should validate_numericality_of(:age)
        .is_greater_than(0)
    end

    it { should validate_presence_of(:course) }

    it do
      should validate_inclusion_of(:course)
        .in_array(Student::COURSES)
    end

    it { should validate_presence_of(:city) }

    it do
      should validate_numericality_of(:marks)
        .is_greater_than_or_equal_to(0)
        .is_less_than_or_equal_to(100)
        .allow_nil
    end
  end

  describe "Constants" do
    it "defines supported courses" do
      expect(Student::COURSES)
        .to contain_exactly(
          "Ruby",
          "Rails",
          "React",
          "Java"
        )
    end
  end

  describe "Scopes" do
    describe ".search" do
      let!(:rahul) do
        create(
          :student,
          name: "Rahul Sharma",
          email: "rahul@example.com"
        )
      end

      let!(:priya) do
        create(
          :student,
          name: "Priya Iyer",
          email: "priya@example.com"
        )
      end

      it "returns students matching the name" do
        expect(Student.search("Rahul"))
          .to contain_exactly(rahul)
      end

      it "returns students matching the email" do
        expect(Student.search("priya@example.com"))
          .to contain_exactly(priya)
      end

      it "returns an empty relation when nothing matches" do
        expect(Student.search("Unknown"))
          .to be_empty
      end
    end

    describe ".by_course" do
      let!(:ruby_student) do
        create(:student, course: "Ruby")
      end

      let!(:rails_student) do
        create(:student, course: "Rails")
      end

      it "returns students belonging to the selected course" do
        expect(Student.by_course("Ruby"))
          .to contain_exactly(ruby_student)
      end

      it "does not return students from other courses" do
        expect(Student.by_course("Ruby"))
          .not_to include(rails_student)
      end
    end

    describe ".by_grade" do
      let!(:grade_a) { create(:student, marks: 90) }
      let!(:grade_b) { create(:student, marks: 75) }
      let!(:grade_c) { create(:student, marks: 65) }
      let!(:grade_d) { create(:student, marks: 55) }
      let!(:grade_e) { create(:student, marks: 40) }
      let!(:grade_f) { create(:student, marks: 20) }

      it "returns grade A students" do
        expect(Student.by_grade("A"))
          .to contain_exactly(grade_a)
      end

      it "returns grade B students" do
        expect(Student.by_grade("B"))
          .to contain_exactly(grade_b)
      end

      it "returns grade C students" do
        expect(Student.by_grade("C"))
          .to contain_exactly(grade_c)
      end

      it "returns grade D students" do
        expect(Student.by_grade("D"))
          .to contain_exactly(grade_d)
      end

      it "returns grade E students" do
        expect(Student.by_grade("E"))
          .to contain_exactly(grade_e)
      end

      it "returns grade F students" do
        expect(Student.by_grade("F"))
          .to contain_exactly(grade_f)
      end

      it "returns no students for an invalid grade" do
        expect(Student.by_grade("Z"))
          .to be_empty
      end
    end
  end

  describe "#result" do
    context "when marks are nil" do
      let(:student) { build(:student, :without_marks) }

      it "returns NA" do
        expect(student.result).to eq("NA")
      end
    end

    context "when marks are below passing marks" do
      let(:student) { build(:student, marks: 34) }

      it "returns Fail" do
        expect(student.result).to eq("Fail")
      end
    end

    context "when marks are exactly passing marks" do
      let(:student) { build(:student, marks: 35) }

      it "returns Pass" do
        expect(student.result).to eq("Pass")
      end
    end

    context "when marks are above passing marks" do
      let(:student) { build(:student, marks: 90) }

      it "returns Pass" do
        expect(student.result).to eq("Pass")
      end
    end
  end

  describe "Active Storage Validations" do
    describe "Profile Photo" do
      it "accepts a valid PNG image" do
        student = build(:student)

        student.profile_photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/profile.png")),
          filename: "profile.png",
          content_type: "image/png"
        )

        expect(student).to be_valid
      end

      it "rejects an unsupported file type" do
        student = build(:student)

        student.profile_photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/invalid.txt")),
          filename: "invalid.txt",
          content_type: "text/plain"
        )

        expect(student).not_to be_valid

        expect(student.errors[:profile_photo])
          .to include("must be a JPG, JPEG or PNG file")
      end

      it "rejects files larger than 5 MB" do
        student = build(:student)

        student.profile_photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/oversized.jpg")),
          filename: "oversized.jpg",
          content_type: "image/jpeg"
        )

        expect(student).not_to be_valid

        expect(student.errors[:profile_photo])
          .to include("size must be less than 5MB")
      end
    end

    describe "Documents" do
      it "accepts PDF documents" do
        student = build(:student)

        student.documents.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/sample.pdf")),
          filename: "sample.pdf",
          content_type: "application/pdf"
        )

        expect(student).to be_valid
      end

      it "rejects unsupported document types" do
        student = build(:student)

        student.documents.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/invalid.txt")),
          filename: "invalid.txt",
          content_type: "text/plain"
        )

        expect(student).not_to be_valid

        expect(student.errors[:documents].first)
          .to include("unsupported file type")
      end
    end
  end

  describe "Callbacks" do
    describe "after_create" do
      it "creates a student user through StudentUserSyncService" do
        service = instance_double(StudentUserSyncService)

        allow(StudentUserSyncService)
          .to receive(:new)
          .and_return(service)

        allow(service)
          .to receive(:create_user)

        student = create(:student)

        expect(StudentUserSyncService)
          .to have_received(:new)
          .with(student)

        expect(service)
          .to have_received(:create_user)
      end

      it "sends the welcome email" do
        allow(StudentNotificationService)
          .to receive(:send_welcome_email)

        student = create(:student)

        expect(StudentNotificationService)
          .to have_received(:send_welcome_email)
          .with(student)
      end
    end

    describe "after_update" do
      it "updates the student user through StudentUserSyncService" do
        student = create(:student)

        service = instance_double(StudentUserSyncService)

        allow(StudentUserSyncService)
          .to receive(:new)
          .and_return(service)

        allow(service)
          .to receive(:update_user)

        student.update!(name: "Updated Name")

        expect(StudentUserSyncService)
          .to have_received(:new)
          .with(student)

        expect(service)
          .to have_received(:update_user)
      end

      it "sends teacher assignment notification when teacher changes" do
        student = create(:student)

        allow(StudentNotificationService)
          .to receive(:send_teacher_assignment_notification)

        new_teacher = create(:user, :teacher)

        student.update!(user: new_teacher)

        expect(StudentNotificationService)
          .to have_received(:send_teacher_assignment_notification)
          .with(student)
      end
    end

    describe "after_destroy" do
      it "removes the linked student user" do
        student = create(:student)

        service = instance_double(StudentUserSyncService)

        allow(StudentUserSyncService)
          .to receive(:new)
          .and_return(service)

        allow(service)
          .to receive(:destroy_user)

        student.destroy

        expect(StudentUserSyncService)
          .to have_received(:new)
          .with(student)

        expect(service)
          .to have_received(:destroy_user)
      end
    end
  end
end
