class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:gmail, :username) || "noreply@sedstudents.com"
  layout "mailer"
end
