# htmlproofer-action

A [Github Action](https://github.com/features/actions) that runs [htmlproofer](https://github.com/gjtorikian/html-proofer).

Defaults are set up to support jekyll + Github Pages websites.

## Usage

Add this snippet to a github workflow after the step that builds your site.

```yaml
- uses: athackst/htmlproofer-action@main
```

### Example

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
      - uses: helaili/jekyll-action@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
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
| `url_ignore`          | Newline-separated list of URLs to ignore                 | `https://fonts.gstatic.com`       |
| `url_ignore_re`       | Newline-separated list of URL regexes to ignore          | (empty)                           |
| `url_swap`            | Newline-separated list of URL regexes to swap to a value | `/{repo}:`                        |
| `retries`             | Number of times to retry checking links                  | 3                                 |

## License

This software is licensed under [Apache 2.0](https://github.com/athackst/htmlproofer-action/blob/main/LICENSE).
