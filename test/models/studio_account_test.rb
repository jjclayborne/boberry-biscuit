require "test_helper"

class StudioAccountTest < ActiveSupport::TestCase
  test "an account on the roster authenticates" do
    account = StudioAccount.authenticate("nate@example.test", "letmein-studio")
    assert_equal "nate@example.test", account.email
  end

  test "email is matched however it was typed" do
    assert StudioAccount.authenticate("  NATE@Example.TEST ", "letmein-studio")
  end

  test "the wrong password is refused" do
    assert_nil StudioAccount.authenticate("nate@example.test", "letmein-studi")
  end

  test "an email that is not on the list is refused" do
    assert_nil StudioAccount.authenticate("stranger@example.test", "letmein-studio")
  end

  test "one account's password does not open another's email" do
    assert_nil StudioAccount.authenticate("nate@example.test", "a-different-password")
    assert_nil StudioAccount.authenticate("second@example.test", "letmein-studio")
  end

  test "blank credentials are refused" do
    assert_nil StudioAccount.authenticate("", "")
    assert_nil StudioAccount.authenticate(nil, nil)
  end

  test "entries missing an email or password are dropped from the roster" do
    with_roster([ { email: "ok@example.test", password: "x" }, { email: "", password: "x" }, { email: "y@example.test", password: "" } ]) do
      assert_equal [ "ok@example.test" ], StudioAccount.roster.map(&:email)
    end
  end

  test "with no test override in play, the hardcoded ROSTER is what is used" do
    # config.x hands back an empty OrderedOptions, not nil, when never assigned --
    # mistaking that for "unset" once made the real list unreachable.
    with_roster(ActiveSupport::OrderedOptions.new) do
      assert_equal StudioAccount::ROSTER.map { |entry| entry[:email] },
                   StudioAccount.roster.map(&:email)
    end
  end

  test "the shipped roster is usable and its pairs actually match" do
    with_roster(ActiveSupport::OrderedOptions.new) do
      assert_predicate StudioAccount::ROSTER, :any?, "nobody could sign in"

      StudioAccount::ROSTER.each do |entry|
        assert StudioAccount.authenticate(entry[:email], entry[:password]),
               "#{entry[:email]} cannot sign in with its own password"
      end
    end
  end

  test "one account's password does not open another's email in the shipped roster" do
    with_roster(ActiveSupport::OrderedOptions.new) do
      StudioAccount::ROSTER.combination(2) do |a, b|
        assert_nil StudioAccount.authenticate(a[:email], b[:password])
        assert_nil StudioAccount.authenticate(b[:email], a[:password])
      end
    end
  end

  test "an empty roster lets nobody in" do
    with_roster([]) do
      assert_empty StudioAccount.roster
      assert_nil StudioAccount.authenticate("nate@example.test", "letmein-studio")
    end
  end
end
