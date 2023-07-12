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

| Name                   | Description                                                                                                                                         | Default                          |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| `directory`            | The directory to scan                                                                                                                               | ./\_site **(required)**          |
| `allow_hash_href`      | If `true`, assumes `href="#"` anchors are valid                                                                                                     | `true`                           |
| `allow_missing_href`   | If `true`, does not flag `a` tags missing `href`. In HTML5, this is technically allowed, but could also be human error.                             | `false`                          |
| `assume_extension`     | Automatically add specified extension to files for internal links, to allow extensionless URLs (as supported by most servers)                       | `.html`                          |
| `checks`               | An array of Strings indicating which checks you want to run                                                                                         | `['Links', 'Images', 'Scripts']` |
| `check_external_hash`  | Checks whether external hashes exist (even if the webpage exists)                                                                                   | `true`                           |
| `check_internal_hash`  | Checks whether internal hashes exist (even if the webpage exists)                                                                                   | `true`                           |
| `check_sri`            | Check that `<link>` and `<script>` external resources use SRI                                                                                       | false                            |
| `directory_index_file` | Sets the file to look for when a link refers to a directory.                                                                                        | `index.html`                     |
| `disable_external`     | If `true`, does not run the external link checker                                                                                                   | `false`                          |
| `enforce_https`        | Fails a link if it's not marked as `https`.                                                                                                         | `true`                           |
| `extensions`           | An array of Strings indicating the file extensions you would like to check (including the dot)                                                      | `['.html']`                      |
| `ignore_empty_alt`     | If `true`, ignores images with empty/missing alt tags (in other words, `<img alt>` and `<img alt="">` are valid; set this to `false` to flag those) | `true`                           |
| `ignore_files`         | An array of Strings or RegExps containing file paths that are safe to ignore.                                                                       | `[]`                             |
| `ignore_empty_mailto`  | If `true`, allows `mailto:` `href`s which do not contain an email address.                                                                          | `false`                          |
| `ignore_missing_alt`   | If `true`, ignores images with missing alt tags                                                                                                     | `false`                          |
| `ignore_status_codes`  | An array of numbers representing status codes to ignore.                                                                                            | `[]`                             |
| `ignore_urls`          | An array of Strings or RegExps containing URLs that are safe to ignore. This affects all HTML attributes, such as `alt` tags on images.             | `[]`                             |
| `swap_urls`            | A hash containing key-value pairs of `RegExp => String`. It transforms URLs that match `RegExp` into `String` via `gsub`.                           | `{}`                             |
| `retries`              | Number of times to retry checking links                                                                                                             | 3                                |

The following options are currently not supported by this action

| Name                   | Description                                                                                                                                         | Default                          |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| `log_level`            | Sets the logging level, as determined by [Yell](https://github.com/rudionrails/yell). One of `:debug`, `:info`, `:warn`, `:error`, or `:fatal`.     | `:info`                          |
| `only_4xx`             | Only reports errors for links that fall within the 4xx status code range.                                                                           | `false`                          |
| `swap_attributes`      | JSON-formatted config that maps element names to the preferred attribute to check                                                                   | `{}`                             |

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

### Swap a url

This swaps urls so that local base name and version numbers are disregarded in url links

```yaml
- name: Htmlproofer
  uses: athackst/htmlproofer-action@main
  with:
    directory: site
    url_swap: |
      ^https.?\/\/.*.github.io\/${{ github.event.repository.name }}:
      ^\/${{ github.event.repository.name }}:
      ^\/dev:
      ^\/v\d+\.\d+\.\d+:
```

## Local docker

You can also run this locally using the docker image. This can be helpful in understanding errors.

I make a local alias that calls the docker file with environment variables set based on my common use cases.

```sh
function htmlproofer_action() {
        curr_dir="$PWD/$1"
        echo "Running on $curr_dir"
        base_dir=$(basename "$PWD")
        url_swap="^\/${base_dir}:,^\/dev:,^\/v\d+\.\d+\.\d+:"
        docker run -v ${curr_dir}:/site -e INPUT_URL_SWAP=${url_swap} althack/htmlproofer:latest
}
```

Then I can just go to the folder the site is built in and run the htmlproofer.

```bash
htmlproofer _site
```

## License

This software is licensed under [Apache 2.0](https://github.com/athackst/htmlproofer-action/blob/main/LICENSE).
