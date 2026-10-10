# Boberry Biscuit

Nate Kammerer's portfolio, and the studio behind it.

## The shape of things

- **Project** — the organizational layer, like a section of a gallery: one theme, one
  throughline, one client. Lives in either the `commission` section (made for someone,
  so it names a `commission`) or the `artwork` section (the artist's own).
- **Work** — the art itself. Always belongs to a project, and always carries a picture;
  there is nothing to show without one.
- **StudioAccount** — an email and password that may sign in. Not an Active Record
  model and there is no users table: an account is *only* a credential, so there is
  nowhere for per-account data to collect.

## The two halves

| Path | What it is |
| --- | --- |
| `/` | The public portfolio. Lists published projects that hold at least one work. |
| `/sign_in` | The way in. Not linked from the public site. |
| `/dashboard` | Projects grouped by section, with the modals for creating and editing. |
| `/projects/:slug` | One project and every work hanging in it. |

## Who can sign in

The list is hardcoded at the top of `app/models/studio_account.rb`. Edit it and save —
that is the whole process. No commands, no editor to configure, no database.

```ruby
ROSTER = [
  { email: "nate@example.com",     password: "a-long-passphrase" },
  { email: "someone@example.com",  password: "another-long-passphrase" }
].freeze
```

An email and its password go together: the pair has to match one row. One person's
password will not open another person's email.

**Every account on this list opens the same gallery.** Projects and works belong to the
site, not to whoever signed in — nothing in the app is scoped by account, and there is
no `user_id` anywhere in the schema — so adding an email grants access to the existing
gallery and can never create a second one. `test/controllers/one_gallery_test.rb` holds
that line, including a test that fails if a per-account column is ever added.

A few consequences worth knowing:

- No sign-up, no password reset, no account page. The list is the only way in, and
  editing it is the only way to change a password.
- An empty list means **nobody** can sign in. It fails closed.
- The session stores only the signed-in email and re-checks it against the list on
  every request, so removing someone locks them out immediately, even mid-session.
- **This file is committed.** Anyone who can read the repository can read these
  passwords, so keep the repo private and use passphrases that aren't reused anywhere
  else. If that ever stops being good enough, the one change that fixes it is to store
  a `BCrypt::Password.create(...)` digest per row instead of the plain password and
  compare with `BCrypt::Password.new(digest) == typed`.

## Getting it running

```sh
bin/setup              # dependencies and database
bin/rails db:seed      # the projects the portfolio was designed around
bin/dev
```

The list ships with two placeholder entries (`nate@example.com` and
`second-person@example.com`, both with obvious `change-me-before-launch` passwords).
**Replace them with real addresses and real passphrases before this goes anywhere.**

## Tests

```sh
bin/rails test          # models and controllers
bin/rails test:system   # the modals and uploads, in a real browser
bin/ci                  # everything, plus rubocop and brakeman
```

## A note on image sizes

Resized variants need libvips or ImageMagick installed. Where neither is present the
app serves the original upload instead of blowing up, and the work's proportions come
from the dimensions the upload form measures in the browser (`image_width` /
`image_height`), so the portfolio still hangs each piece at its true shape.
