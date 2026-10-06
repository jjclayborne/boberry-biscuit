# The one account that gets into the studio. There is no sign-up and no way to
# add a second person through the app -- the portfolio is Nate's, and so is the
# back of it. Change the name, email or password from /account.
class User < ApplicationRecord
  has_secure_password

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :name, with: ->(name) { name.to_s.strip }

  validates :name, presence: true, length: { maximum: 80 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid address" }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
