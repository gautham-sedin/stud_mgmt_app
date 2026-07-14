require "rails_helper"

RSpec.describe "API Authentication", type: :request do
  describe "POST /api/v1/auth/login" do
    let!(:user) do
      create(
        :user,
        :admin,
        email: "admin@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    context "with valid credentials" do
      before do
        post "/api/v1/auth/login",
            params: {
              email: user.email,
              password: "password123"
            }
      end

      it "returns http success" do
        expect(response)
          .to have_http_status(:ok)
      end

      it "returns a JWT token" do
        body = JSON.parse(response.body)

        expect(body["token"])
          .to be_present
      end

      it "returns the logged in user" do
        body = JSON.parse(response.body)

        expect(body["user"]["id"])
          .to eq(user.id)

        expect(body["user"]["email"])
          .to eq(user.email)

        expect(body["user"]["role"])
          .to eq(user.role)
      end

      it "returns a success message" do
        body = JSON.parse(response.body)

        expect(body["message"])
          .to eq("Login successful")
      end
    end

    context "with an incorrect password" do
      before do
        post "/api/v1/auth/login",
            params: {
              email: user.email,
              password: "wrongpassword"
            }
      end

      it "returns unauthorized" do
        expect(response)
          .to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        body = JSON.parse(response.body)

        expect(body["errors"])
          .to eq(["Invalid email or password"])
      end

      it "does not return a token" do
        body = JSON.parse(response.body)

        expect(body["token"])
          .to be_nil
      end
    end

    context "with an unknown email address" do
      before do
        post "/api/v1/auth/login",
            params: {
              email: "unknown@example.com",
              password: "password123"
            }
      end

      it "returns unauthorized" do
        expect(response)
          .to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        body = JSON.parse(response.body)

        expect(body["errors"])
          .to eq(["Invalid email or password"])
      end

      it "does not return a token" do
        body = JSON.parse(response.body)

        expect(body["token"])
          .to be_nil
      end
    end

  end
end