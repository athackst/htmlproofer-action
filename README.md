# htmlproofer-action

A [Github Action](https://github.com/features/actions) that runs [htmlproofer](https://github.com/gjtorikian/html-proofer).

Defaults are set up to support jekyll + Github Pages websites.

## Usage

Add this snippet to a github workflow after the step that builds your site.

```yaml
- uses: athackst/htmlproofer-action@main
```

### Quickstart

```yaml
name: Build and deploy Jekyll site to GitHub Pages

on:
  push:
    branches:
      - main

jobs:
  github-pages:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
          cache-version: 0
      - name: Build with Jekyll
        # Outputs to the './_site' directory by default
        run: bundle exec jekyll build
        env:
          JEKYLL_GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - uses: athackst/htmlproofer-action@main
```

### Options

| Name                  | Description                                              | Default                           |
| --------------------- | -------------------------------------------------------- | --------------------------------- |
| `directory`           | The directory to scan                                    | ./\_site **(required)**           |
| `allow_missing_href`  | Do not flag a tags missing href                          | false                             |
| `assume_extension`    | Automatically add extension (e.g. .html) to file paths   | true                              |
| `check_external_hash` | Check whether external anchors exist                     | true                              |
| `check_favicon`       | Check whether favicons are valid                         | true                              |
| `check_html`          | Validate HTML                                            | true                              |
| `check_img_http`      | Enforce that images use HTTPS                            | true                              |
| `check_opengraph`     | Check images and URLs in Open Graph metadata             | true                              |
| `empty_alt_ignore`    | Allow images with empty alt tags                         | false                             |
| `enforce_https`       | Require that links use HTTPS                             | true                              |
| `max_concurrency`     | Maximum number of concurrent requests                    | 50                                |
| `internal_domains`    | Newline-separated list of internal domains               | `https://{user}.github.io/{repo}` |
| `connect_timeout`     | HTTP connection timeout                                  | 30                                |
| `ssl_verifypeer`      | Enable peer verification.                                | false                             |
| `ssl_verifyhost`      | Enable host verification                                 | 0                                 |
| `timeout`             | HTTP request timeout                                     | 120                               |
| `ignore_urls`         | Newline-separated list of URLs to ignore                 | `https://fonts.gstatic.com`       |
| `url_ignore`          | Newline-separated list of URLs to ignore                 | (deprecated)                      |
| `url_ignore_re`       | Newline-separated list of URL regexes to ignore          | (deprecated)                      |
| `url_swap`            | Newline-separated list of URL regexes to swap to a value | `/{repo}:`                        |
| `retries`             | Number of times to retry checking links                  | 3                                 |

## Examples

### Use with mkdocs

```yaml
name: Build and deploy Jekyll site to GitHub Pages

on:
  push:
    branches:
      - main

jobs:
  github-pages:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and push docs
        uses: athackst/mkdocs-simple-plugin@main
      - name: Htmlproofer
        uses: athackst/htmlproofer-action@main
        with:
          directory: site
```

### Ignore a url

This uses the same syntax as htmlproofer, but you can either use a comma or new line to separate values.

```yaml
- name: Htmlproofer
  uses: athackst/htmlproofer-action@main
  with:
    ignore_urls: |
      /twitter.com/
      https://fonts.gstatic.com
```

## Local docker

You can also run this locally using the docker image. This can be helpful in understanding errors.

I make a local alias that calls the docker file with environment variables set based on my common use cases.

```sh
function htmlproofer() {
        curr_dir=$PWD
        ignore="https://www.linkedin.com/in/allisonthackston,http://sdformat.org,/gazebosim.org/docs/citadel/"
        url_swap="^https.?\/\/www.allisonthackston.com:"
        docker run -v ${curr_dir}:/app -e INPUT_DIRECTORY=/app -e INPUT_IGNORE_URLS=${ignore} -e INPUT_URL_SWAP=${url_swap} althack/htmlproofer:latest
}
```

Then I can just go to the folder the site is built in and run the htmlproofer.

```bash
cd site
htmlproofer
```

## License

This software is licensed under [Apache 2.0](https://github.com/athackst/htmlproofer-action/blob/main/LICENSE).
