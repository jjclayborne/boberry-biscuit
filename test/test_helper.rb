ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Every work must have a picture, so give the fixtures one.
    setup do
      Work.find_each { |work| work.image.attach(sample_image) unless work.image.attached? }
    end

    def sample_image
      { io: File.open(file_fixture("plate.png")), filename: "plate.png", content_type: "image/png" }
    end

    def sign_in_as(user, password: "letmein-studio")
      post sign_in_path, params: { email: user.email, password: password }
    end
  end
end
