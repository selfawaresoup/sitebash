# Blog

Static site generator written in Bash.

## Editing the site

All content is in `/content`. Files that are not `.html` files are copied over as-is.

HTML files are first merged with the main template an then variables are replaced:

- `@TITLE@`
- `@DESCRIPTION@`
- `@PREVIEW_IMAGE@`

these can be set in a `.html.env` file right next to the respective `.html` file. ENV files are NOT copied into the final output.

Some variables are also available on ALL pages. These are defined in the `html.env` file in the root directory:

- `@SITE_NAME@`
- `@SITE_URL@`
- `@SITE_PREVIEW_IMAGE@`

The `posts` directory is special. Pages found there will be included in a index, sorted by filename descending, that can be embedded anywhere on the site with `@POSTS_INDEX@`. It's recommended to name these posts with the date leading the filename, e.g. `2022-12-01-this-is-a-post.html`.

## Build

- run `./scripts/build.sh`

built site will be in `output`
