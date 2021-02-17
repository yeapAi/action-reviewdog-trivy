# GitHub Action: Run trivy with reviewdog 🐶

This action runs [trivy](https://github.com/aquasecurity/trivy) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests

## Inputs

### `github_token`

Optional. `${{ github.token }}` is used by default.

### `trivy_flags`

Optional. Pass trivy flags:

```yml
with:
  trivy_flags: --ignore-unfixed
```

### `trivy_image`

Pass a docker image to trivy:

```yml
with:
  trivy_image: busybox:1.33
```

### `file_name`

Optional. Name of the file to attach trivy CVE in the reviewdog report. By default `Dockerfile`

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `level`

Optional. Report level for reviewdog [`info`, `warning`, `error`].
It's same as `-level` flag of reviewdog.

### `reporter`

Optional. Reporter of reviewdog command [`github-pr-check`, `github-pr-review`].
The default is `github-pr-check`.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [`added`, `diff_context`, `file`, `nofilter`].
Default is `added`.

### `fail_on_error`

Optional.  Exit code for reviewdog when errors are found [`true`, `false`]
Default is `false`.

### `reviewdog_flags`

Optional. Additional reviewdog flags.

### `debug`

Optional. Debug mode
Default is `false`.

## Example usage

```yml
name: reviewdog
on: [pull_request]
jobs:
  trivy:
    name: runner / trivy
    runs-on: ubuntu-latest
    steps:
      - name: Build image
        run: docker build . -t test:latest
      - name: trivy
        uses: yeapAi/action-reviewdog-trivy@v1
        with:
          github_token: ${{ secrets.github_token }}
          trivy_image: test:latest
```
