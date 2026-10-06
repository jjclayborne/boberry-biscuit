require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "authenticates with the right password" do
    assert users(:nate).authenticate("letmein-studio")
    assert_not users(:nate).authenticate("wrong")
  end

  test "email is normalized and has to be unique" do
    user = User.create!(name: "New", email: "  MiXeD@Example.test ", password: "password1")
    assert_equal "mixed@example.test", user.email

    duplicate = User.new(name: "Other", email: "MIXED@example.test", password: "password1")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "passwords have to be at least eight characters" do
    user = User.new(name: "Short", email: "short@example.test", password: "abc")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end
end
