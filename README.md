# Boberry Biscuit

Nate Kammerer's portfolio, and the studio behind it.

## The shape of things

- **Project** — the organizational layer, like a section of a gallery: one theme, one
  throughline, one client. Lives in either the `commission` section (made for someone,
  so it names a `commission`) or the `artwork` section (the artist's own).
- **Work** — the art itself. Always belongs to a project, and always carries a picture;
  there is nothing to show without one.
- **User** — the single account that gets into the studio. The site is Nate's and so is
  the back of it: there is no sign-up, no roles, and no way to add a second person
  through the app.

## The two halves

| Path | What it is |
| --- | --- |
| `/` | The public portfolio. Lists published projects that hold at least one work. |
| `/sign_in` | The way in. Not linked from the public site. |
| `/dashboard` | Projects grouped by section, with the modals for creating and editing. |
| `/projects/:slug` | One project and every work hanging in it. |
| `/account` | The name, email and password you sign in with. |

## Getting it running

```sh
bin/setup              # dependencies and database
bin/rails db:seed      # an admin account plus the projects the portfolio was designed around
bin/dev
```

The seed sets up the one account as `nate@boberrybiscuit.test` with the password
`letmein-studio` (override with `SEED_PASSWORD`). Change it from `/account` before this
goes anywhere real. If the password is ever lost, reset it from the console:

```sh
bin/rails runner 'User.first.update!(password: "something-new")'
```

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
