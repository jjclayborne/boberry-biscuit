# Who is allowed into the studio.
#
# ---------------------------------------------------------------------------
#  THE LIST. Add or remove people by editing it. That is the whole process --
#  no commands to run, no separate file, no database, no editor to configure.
#  Changes take effect on the next page load in development; restart the
#  server in production.
# ---------------------------------------------------------------------------
class StudioAccount
  ROSTER = [
    { email: "natekammerer1@gmail.com", password: "MyWebsite11!/" },
    { email: "jack@milktruck.io", password: "boberry-biscuit" },
    { email: "jackson.harshbarger@icloud.com", password: "nateisdoodooeater" }
  ].freeze

  # Every account above signs into the SAME studio and the SAME gallery.
  # Nothing in this app is scoped to whoever is signed in -- projects and works
  # belong to the site, not to an account, and there is no user_id anywhere in
  # the schema -- so adding an email grants access to the existing gallery and
  # can never spin up a second one. test/controllers/one_gallery_test.rb holds
  # that line.
  #
  # An email and its password go together: the pair has to match a single row
  # above. One person's password will not open another person's email.
  #
  # This file is committed, so treat these passwords as readable by anyone with
  # access to the repository. Keep the repo private, and use passphrases that
  # aren't reused anywhere else.
  #
  # This is not an Active Record model and there is no users table: an account
  # is only a credential, so there is nowhere for per-account data to collect.

  attr_reader :email

  def initialize(email:, password:)
    @email = self.class.normalize(email)
    @password = password.to_s
  end

  class << self
    # Returns the account for these credentials, or nil. An unknown email and a
    # wrong password are indistinguishable from the outside, and both are
    # compared in constant time so neither can be guessed by timing the reply.
    def authenticate(email, password)
      candidate = normalize(email)
      typed = password.to_s

      roster.select { |account| account.email_matches?(candidate) }
            .find { |account| account.password_matches?(typed) }
    end

    def find(email)
      candidate = normalize(email)
      roster.find { |account| account.email_matches?(candidate) }
    end

    def roster
      entries.filter_map do |entry|
        entry = entry.symbolize_keys
        next if entry[:email].blank? || entry[:password].blank?

        new(email: entry[:email], password: entry[:password])
      end
    end

    def normalize(email)
      email.to_s.strip.downcase
    end

    private

    # ROSTER above is the list. The test suite swaps in its own through
    # `config.x.studio_accounts` so the tests don't depend on whatever the real
    # list happens to say.
    #
    # Only an actual Array counts as a swap -- `config.x.anything` hands back an
    # empty OrderedOptions rather than nil when it was never set, so testing for
    # nil here would ignore ROSTER and lock everyone out.
    def entries
      override = Rails.application.config.x.studio_accounts
      override.is_a?(Array) ? override : ROSTER
    end
  end

  def email_matches?(candidate)
    secure_equal?(email, candidate)
  end

  def password_matches?(typed)
    secure_equal?(@password, typed)
  end

  def to_s
    email
  end

  private

  def secure_equal?(known, given)
    ActiveSupport::SecurityUtils.secure_compare(known.to_s, given.to_s)
  end
end
