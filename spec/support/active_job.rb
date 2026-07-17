require "active_job/test_helper"

RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.before(:each) do
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
