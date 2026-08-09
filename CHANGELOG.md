# nf-core/fastqrepair: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.1.0dev - [unreleased]

nf-core/tools v4.0.3 update

### `Changed`

- Template update for nf-core/tools v4.0.3 (supersedes the pending v3.4.1, v3.5.1 and v4.0.2 template merges). Conflicts resolved in: `.github/PULL_REQUEST_TEMPLATE.md`, `.gitignore`, `README.md`, `modules.json`, `modules/nf-core/multiqc/*`, `nextflow.config`, `ro-crate-metadata.json`, `subworkflows/local/utils_nfcore_fastqrepair_pipeline/main.nf`, `tests/nextflow.config`, `workflows/fastqrepair.nf`
- Minimum Nextflow version raised to `25.10.4`; `nf-schema` bumped to `2.5.1`; `MultiQC` bumped to `1.34`
- `FASTQREPAIR` now takes `multiqc_config`, `multiqc_logo`, `multiqc_methods_description` and `outdir` as explicit workflow inputs, and collates software versions through the `versions` channel topic

### `Removed`

- `--hook_url` parameter and the Slack/Microsoft Teams notification assets (`assets/slackreport.json`, `assets/adaptivecard.json`), dropped by the template
- `gitpod` profile and `.gitpod.yml`; the `arm` profile is replaced by `arm64` plus `emulate_amd64`

## v[1.1.0](https://github.com/nf-core/fastqrepair/releases/tag/1.1.0) - Trento YellowBlue [19/08/2025]

nf-core/tools v3.3.2 update

### `Changed`

- [PR #22](https://github.com/nf-core/fastqrepair/pull/22) - Template update for nf-core/tools v3.3.2. Solve conflicts for: .editorconfig, CHANGELOG.md, README.md, assets/multiqc_config.yml, assets/schema_input.json, nextflow.config, nf-test.config, ro-crate-metadata.json, tests/nextflow.config

- [#17](https://github.com/nf-core/fastqrepair/issues/17) - Improved nextflow_schema.json setting a minimum of 1 split to `num_splits` and remnoving a regex

<!--
Added
Fixed
Dependencies
Deprecated
-->

## v[1.0.0](https://github.com/nf-core/fastqrepair/releases/tag/1.1.0dev) - Catanzaro YellowRed [04/02/2025]

Initial release of nf-core/fastqrepair, created with the [nf-core](https://nf-co.re/) template.

### `Fixed`

- [PR #2](https://github.com/nf-core/fastqrepair/pull/2) - First release

### `Dependencies`

| Dependency   | Old version | New version |
| ------------ | ----------- | ----------- |
| `BBmap`      |             | 39.13       |
| `FastQC`     |             | 0.12.1      |
| `gzrt`       |             | 0.9.1       |
| `Wipertools` |             | 1.1.5       |
| `MultiQC`    |             | 1.26        |

> **NB:** Dependency has been **updated** if both old and new version information is present.
>
> **NB:** Dependency has been **added** if just the new version information is present.
>
> **NB:** Dependency has been **removed** if new version information isn't present.

### Credits

Special thanks to the following for their contributions to the release:

- [Sateesh Peri](https://github.com/sateeshperi)
- [Louis Le Nézet](https://github.com/LouisLeNezet) - reviewer
- [Anabella Trigila](https://github.com/atrigila) - reviewer
- [James A. Fellows Yates](https://github.com/jfy133) - reviewer
- [Charles Plessy](https://github.com/charles-plessy) - reviewer
