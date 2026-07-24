# htmlproofer-action

A [GitHub Action](https://github.com/features/actions) that runs
[HTMLProofer](https://github.com/gjtorikian/html-proofer) against a built static
site. Its defaults are tailored to Jekyll sites hosted on GitHub Pages.

## Usage

Add the action after the step that builds your site:

```yaml
- uses: athackst/htmlproofer-action@main
```

HTMLProofer can cache link-check results. Persisting that cache reduces repeated
external requests:

```yaml
- name: Restore HTMLProofer cache
  uses: actions/cache/restore@v6
  with:
    path: tmp/.htmlproofer
    key: ${{ runner.os }}-htmlproofer-${{ github.run_id }}-${{ github.run_attempt }}
    restore-keys: |
      ${{ runner.os }}-htmlproofer-

- name: Check site
  uses: athackst/htmlproofer-action@main

- name: Save HTMLProofer cache
  if: always()
  uses: actions/cache/save@v6
  with:
    path: tmp/.htmlproofer
    key: ${{ runner.os }}-htmlproofer-${{ github.run_id }}-${{ github.run_attempt }}
```

### Inputs

The defaults below are the effective defaults when the project is run as a
GitHub Action. Boolean inputs accept `true` or `false`. List inputs accept
comma-separated or newline-separated values.

#### Site and checks

| Input | Description | Default |
| --- | --- | --- |
| `directory` | Directory containing the built site | `./_site` |
| `allow_hash_href` | Treat `href="#"` as valid | `true` |
| `allow_missing_href` | Allow `a` elements without an `href` | `false` |
| `assume_extension` | Add this extension when resolving extensionless internal URLs | `.html` |
| `check_favicon` | Check whether favicons are valid | `false` |
| `check_links` | Check `a` and `link` elements | `true` |
| `check_images` | Check `img` elements | `true` |
| `check_scripts` | Check `script` elements | `true` |
| `check_opengraph` | Check images and URLs in Open Graph metadata | `false` |
| `check_external_hash` | Check fragments on external URLs | `true` |
| `check_internal_hash` | Check fragments on internal URLs | `true` |
| `check_sri` | Require SRI on external `link` and `script` resources | `false` |
| `directory_index_file` | File used when a URL refers to a directory | `index.html` |
| `disable_external` | Disable external URL checks | `false` |
| `enforce_https` | Fail HTTP links | `true` |
| `extensions` | File extensions to check, including the leading dot | `.html` |
| `ignore_empty_alt` | Allow images whose `alt` attribute is empty | `true` |
| `ignore_missing_alt` | Allow images whose `alt` attribute is missing | `false` |
| `ignore_empty_mailto` | Allow `mailto:` links without an email address | `false` |
| `ignore_files` | File paths or `/regular expressions/` to skip | none |
| `ignore_status_codes` | HTTP status codes to ignore | none |
| `ignore_urls` | Additional URLs or `/regular expressions/` to skip | none |
| `ignore_common` | Ignore URLs that commonly reject automated link checks | `true` |
| `ignore_new_files` | On pull requests, ignore new or renamed files detected by Git | `false` |

HTMLProofer treats empty and missing alt attributes independently.
`ignore_empty_alt` controls empty attributes, while `ignore_missing_alt`
controls missing attributes.

When `ignore_common` is enabled, the action entrypoint adds
`https://fonts.gstatic.com` to `ignore_urls`. Set `ignore_common: false` to
check that URL normally. User-provided `ignore_urls` are preserved in either
mode.

#### URL mapping

| Input | Description | Default |
| --- | --- | --- |
| `host` | Public host used to resolve absolute site URLs as local | `${{ github.repository_owner }}.github.io` |
| `base_path` | Path below the host where the site is published | `/${{ github.event.repository.name }}` |
| `site_url_swap` | Generate URL substitutions from `host` and `base_path` | `true` |
| `swap_urls` | Additional URL substitutions in `regular-expression:replacement` form | none |

When `site_url_swap` is enabled, the action entrypoint generates substitutions
that remove the configured host and base path before HTMLProofer resolves local
URLs. User-provided `swap_urls` entries are added to those substitutions.
Separate multiple entries with commas or newlines. Escape a literal colon as
`\:`.

#### HTTP and action behavior

| Input | Description | Default |
| --- | --- | --- |
| `max_concurrency` | Maximum number of concurrent HTTP requests | `2` |
| `connect_timeout` | Connection timeout in seconds | `10` |
| `followlocation` | Follow HTTP redirects | `true` |
| `ssl_verifypeer` | Verify the remote TLS certificate | `false` |
| `ssl_verifyhost` | curl host-verification setting | `0` |
| `timeout` | HTTP request timeout in seconds | `30` |
| `retries` | Total attempts before the action fails; retries wait 60 seconds | `6` |
| `cache` | JSON object configuring HTMLProofer's cache; use an empty input to disable it | `{ "timeframe": { "external": "2w", "internal": "1w" } }` |
| `gh_token` | Token used to inspect pull-request changes for `ignore_new_files` | `${{ github.token }}` |

> [!CAUTION]
> TLS peer and host verification are disabled by default. Set
> `ssl_verifypeer: true` and `ssl_verifyhost: 2` when the sites you check use
> publicly trusted certificates.

### Deprecated inputs

These aliases remain available for compatibility but should not be used in new
workflows:

| Deprecated input | Replacement |
| --- | --- |
| `check_html` | `check_links` |
| `check_img_http` | `check_images` |
| `empty_alt_ignore` | `ignore_empty_alt` |
| `missing_alt_ignore` | `ignore_missing_alt` |
| `url_ignore`, `url_ignore_re` | `ignore_urls` |
| `url_swap` | `swap_urls` |

`internal_domains` and the misspelled `max_paralell` are accepted by the action
metadata but no longer affect HTMLProofer.

The HTMLProofer options `log_level`, `only_4xx`, and `swap_attributes` are not
currently exposed as action inputs.

## Examples

### MkDocs

```yaml
name: Check MkDocs site

on:
  push:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: Build documentation
        uses: athackst/mkdocs-simple-plugin@main
      - name: Restore HTMLProofer cache
        uses: actions/cache/restore@v6
        with:
          path: tmp/.htmlproofer
          key: ${{ runner.os }}-htmlproofer-${{ github.run_id }}-${{ github.run_attempt }}
          restore-keys: |
            ${{ runner.os }}-htmlproofer-
      - name: Check site
        uses: athackst/htmlproofer-action@main
        with:
          directory: site
      - name: Save HTMLProofer cache
        if: always()
        uses: actions/cache/save@v6
        with:
          path: tmp/.htmlproofer
          key: ${{ runner.os }}-htmlproofer-${{ github.run_id }}-${{ github.run_attempt }}
```

### Jekyll and GitHub Pages

`actions/configure-pages` provides the correct host and base path for user,
organization, and project sites:

```yaml
name: Build and check Jekyll site

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: Configure Pages
        id: pages
        uses: actions/configure-pages@v5
      - name: Build
        uses: actions/jekyll-build-pages@v1
      - name: Restore HTMLProofer cache
        uses: actions/cache/restore@v6
        with:
          path: tmp/.htmlproofer
          key: ${{ runner.os }}-htmlproofer-${{ github.run_id }}-${{ github.run_attempt }}
          restore-keys: |
            ${{ runner.os }}-htmlproofer-
      - name: Check site
        uses: athackst/htmlproofer-action@main
        with:
          host: ${{ steps.pages.outputs.host }}
          base_path: ${{ steps.pages.outputs.base_path }}
      - name: Save HTMLProofer cache
        if: always()
        uses: actions/cache/save@v6
        with:
          path: tmp/.htmlproofer
          key: ${{ runner.os }}-htmlproofer-${{ github.run_id }}-${{ github.run_attempt }}
      - uses: actions/upload-pages-artifact@v3

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy
        id: deployment
        uses: actions/deploy-pages@v4
```

### Ignore URLs

Plain strings are matched literally. Surround an entry with `/` to treat it as
a regular expression:

```yaml
- uses: athackst/htmlproofer-action@main
  with:
    ignore_urls: |
      /https:\/\/(www\.)?twitter\.com/
      https://example.com/expected-404
```

### Add URL substitutions

This removes version prefixes from root-relative URLs:

```yaml
- uses: athackst/htmlproofer-action@main
  with:
    swap_urls: |
      ^/dev:
      ^/v\d+\.\d+\.\d+:
```

### Configure or disable the HTMLProofer cache

```yaml
- uses: athackst/htmlproofer-action@main
  with:
    cache: '{ "timeframe": { "external": "1w", "internal": "3d" } }'
```

To disable HTMLProofer caching, pass an empty value and omit the `actions/cache`
step:

```yaml
- uses: athackst/htmlproofer-action@main
  with:
    cache: ""
```

When caching is enabled, the action prints cache statistics in its log and in
the GitHub step summary.

The examples use separate restore and save actions so the cache is saved even
when HTMLProofer reports broken links. HTMLProofer writes `cache.json` before
reporting its failures, and `if: always()` lets the save step run after the
failed check.

The run ID and attempt number make each saved key unique, including workflow
reruns. The restore prefix selects the newest cache visible to the current
branch or pull-request scope. GitHub restricts cache access by Git ref, so a
cache created for one pull request is not available to a different pull
request.

## Local Docker usage

The Docker image runs from `/site`, so mount the built site there. GitHub
expressions from `action.yml` are unavailable locally; pass any required inputs
as `INPUT_*` environment variables. The entrypoint enables `site_url_swap` by
default, but generates no substitutions when `INPUT_HOST` is empty.

```bash
docker run --rm \
  --volume "$PWD/_site:/site" \
  --env INPUT_HOST=example.github.io \
  --env INPUT_BASE_PATH=/example \
  althack/htmlproofer:latest
```

When used directly through Docker, `directory` defaults to `.`, retries default
to `1`, caching is disabled, and `host` and `base_path` are empty. The
HTMLProofer option defaults implemented by the Ruby library are the same as
those listed above.

## Where defaults live

There are two runtime layers:

- The Ruby library owns HTMLProofer defaults such as enabled checks,
  concurrency, and HTTP timeouts. These defaults also apply to direct Docker
  usage and unit tests.
- `action.yml` owns GitHub-specific and wrapper defaults such as repository
  expressions, retry count, token, cache policy, and the default build
  directory.

Keeping a Ruby-owned default out of `action.yml` avoids two sources of truth:
an omitted input reaches the library as unset, and the library applies its
default. If a library default is repeated in `action.yml`, GitHub always sends
that value and can hide later library changes. The tradeoff is that GitHub's
Marketplace UI does not display those implicit defaults, so this table is the
complete user-facing reference.

## License

This software is licensed under the
[Apache License 2.0](https://github.com/athackst/htmlproofer-action/blob/main/LICENSE).
