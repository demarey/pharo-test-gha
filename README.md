# pharo-test-gha

GitHub reusable workflow to test a [Pharo](https://pharo.org) project with GitHub Actions.

This repository provides a reusable GitHub Actions workflow (`.github/workflows/pharo-test.yml`) that sets up a Pharo image, loads a project with Metacello, runs its SUnit tests, and publishes the results as GitHub check reports and downloadable artifacts.

## Features

- **Pharo setup** via [`pharo-project/pharo-setup-gha`](https://github.com/pharo-project/pharo-setup-gha)
- **Project loading with Metacello** from the local checkout (`gitlocal`), no remote repository needed
- **Multi-version support** — run the same workflow across several Pharo versions using a matrix
- **Optional clean-image export** — download a ready-to-use image after loading the project (without tests)
- **JUnit XML test reports** uploaded as artifacts and published as a unified GitHub check
- **Terminal test summary** with pass/fail/error counts

## Usage

Use the workflow as a **reusable workflow** via `workflow_call` from any repository. Point it at the project under test with `checkout-repository`, or leave that empty to test the calling repository.

Add a file such as `.github/workflows/ci.yml` to your project:

```yaml
name: CI

on:
  push:
  pull_request:

jobs:
  test:
    uses: demarey/pharo-test-gha/.github/workflows/pharo-test.yml@main
    with:
      pharo-version: "14"
      metacello-baseline: "MyProject"
      metacello-repository: "src"
      test-packages: "MyProject-*"
```

## Inputs

| Input | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `pharo-version` | string | yes | — | Pharo version to test, e.g. `11`, `12`, `13`, or `14`. |
| `export-image-name` | string | no | `""` | Name of the clean image to export. When set, produces an artifact `<name>-<version>` containing the loaded image (`<name>.image`, `<name>.changes`, `*.sources`). Empty means no export. |
| `metacello-baseline` | string | no | `MyProject` | Metacello baseline to load. For Pharo ≥ 14 the `BaselineOf` prefix is added automatically. |
| `metacello-repository` | string | no | `src` | Metacello repository path relative to the checkout (e.g. `src`). |
| `test-packages` | string | no | `""` | Packages to test (glob, e.g. `MyProject-*`). Empty runs all tests. |
| `test-fail-on-error` | string | no | `true` | Fail the job when tests fail. |
| `test-artifact-name` | string | no | `test-results` | Base name of the test-results artifact; the final artifact is `<name>-<version>`. |
| `checkout-repository` | string | no | `""` | `owner/repo` to checkout for the project under test (e.g. `demarey/Soup`). Empty checks out the calling repository. |

## Artifacts and checks

For each run the workflow produces:

- A **test-results artifact** named `<test-artifact-name>-<pharo-version>` containing the JUnit XML files produced by the test run.
- A **unified test report** published as a GitHub check (`Test Results <pharo-version> (...)`).
- An **exported clean image** artifact named `<export-image-name>-<pharo-version>` when `export-image-name` is set.

### Example with image export

```yaml
jobs:
  test:
    uses: demarey/pharo-test-gha/.github/workflows/pharo-test.yml@main
    with:
      pharo-version: "14"
      export-image-name: "MyProjectImage"
      metacello-baseline: "MyProject"
      metacello-repository: "src"
      test-packages: "MyProject-*"
```

## Self-testing

This repository also contains the workflows used to validate the reusable workflow itself, aggregated in `.github/workflows/run-all-tests.yml`:

- `test-single.yml` — single Pharo version
- `test-multi.yml` — matrix of Pharo versions
- `test-export.yml` — with clean-image export
- `test-no-export.yml` — without export

The helper action [`.github/actions/assert-xml-files/action.yml`](.github/actions/assert-xml-files/action.yml) asserts that an artifact directory contains exactly the expected JUnit XML files.

## License

[MIT](LICENSE)
