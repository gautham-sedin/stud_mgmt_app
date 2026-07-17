require "rails_helper"

RSpec.describe StudentUserSyncService, type: :service do
  let(:teacher) do
    create(:user, :teacher)
  end

  let(:student) do
    build(
      :student,
      user: teacher,
      name: "Rahul",
      email: "rahul@example.com"
    )
  end

  subject(:service) do
    described_class.new(student)
  end

  describe "#create_user" do
    it "creates a new student user" do
      # Force lazy lets to be evaluated before measuring the change
      student
      service

      expect do
        service.create_user
      end.to change(User, :count).by(1)

      user = User.find_by(email: student.email)

      expect(user).to be_present
      expect(user.student?).to be(true)
      expect(user.name).to eq(student.name)
      expect(user.email).to eq(student.email)
    end

    it "does not create a duplicate user" do
      create(
        :user,
        :student,
        email: student.email
      )

      expect do
        service.create_user
      end.not_to change(User, :count)
    end
  end

  describe "#update_user" do
    let!(:student_user) do
      create(
        :user,
        :student,
        name: "Old Name",
        email: "old@example.com"
      )
    end

    before do
      student.name = "New Name"
      student.email = "new@example.com"

      allow(student)
        .to receive(:saved_change_to_name?)
        .and_return(true)

      allow(student)
        .to receive(:saved_change_to_email?)
        .and_return(true)

      allow(student)
        .to receive(:email_before_last_save)
        .and_return("old@example.com")
    end

    it "updates the existing student user" do
      service.update_user

      student_user.reload

      expect(student_user.name)
        .to eq("New Name")

      expect(student_user.email)
        .to eq("new@example.com")
    end

    it "does nothing when the user does not exist" do
      student_user.destroy

      expect {
        service.update_user
      }.not_to raise_error
    end

    it "does nothing when the matching user is not a student" do
      student_user.destroy

      create(
        :user,
        :teacher,
        email: "old@example.com",
        name: "Teacher"
      )

      teacher = User.find_by(email: "old@example.com")

      service.update_user

      expect(teacher.reload.name)
        .to eq("Teacher")
    end

    it "returns immediately when neither name nor email changed" do
      allow(student)
        .to receive(:saved_change_to_name?)
        .and_return(false)

      allow(student)
        .to receive(:saved_change_to_email?)
        .and_return(false)

      expect(User)
        .not_to receive(:find_by)

      service.update_user
    end
  end

  describe "#destroy_user" do
    context "when the student user exists" do
      before do
        create(
          :user,
          :student,
          email: student.email
        )
      end

      it "deletes the student user" do
        expect do
          service.destroy_user
        end.to change(User, :count).by(-1)

        expect(
          User.find_by(email: student.email)
        ).to be_nil
      end
    end

    context "when the student user does not exist" do
      it "does not raise an exception" do
        expect {
          service.destroy_user
        }.not_to raise_error
      end
    end

    context "when the matching user is a teacher" do
      before do
        create(
          :user,
          :teacher,
          email: student.email
        )
      end

      it "does not delete the teacher account" do
        expect {
          service.destroy_user
        }.not_to change(User, :count)

        expect(
          User.find_by(email: student.email)
        ).to be_present
      end
    end

    context "when the matching user is an admin" do
      before do
        create(
          :user,
          :admin,
          email: student.email
        )
      end

      it "does not delete the admin account" do
        expect {
          service.destroy_user
        }.not_to change(User, :count)

        expect(
          User.find_by(email: student.email)
        ).to be_present
      end
    end
  end
end
