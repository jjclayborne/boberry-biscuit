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

    # The accounts on the test roster, set in config/environments/test.rb. Two
    # of them on purpose: the suite asserts they open the same gallery.
    TEST_PASSWORDS = {
      "nate@example.test" => "letmein-studio",
      "second@example.test" => "a-different-password"
    }.freeze

    def studio_account(which = :first)
      which == :first ? StudioAccount.roster.first : StudioAccount.roster.second
    end

    def credentials_for(account)
      { email: account.email, password: TEST_PASSWORDS.fetch(account.email) }
    end

    def sample_image
      { io: File.open(file_fixture("plate.png")), filename: "plate.png", content_type: "image/png" }
    end

    def sign_in_as(account = studio_account)
      post signin_path, params: credentials_for(account)
    end

    # Swap the roster for the duration of a block, then put it back.
    def with_roster(entries)
      original = Rails.application.config.x.studio_accounts
      Rails.application.config.x.studio_accounts = entries
      yield
    ensure
      Rails.application.config.x.studio_accounts = original
    end
  end
end
