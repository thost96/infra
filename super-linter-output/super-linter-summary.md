# Super-linter summary

| Language                   | Validation result |
| -------------------------- | ----------------- |
| BASH                       | Pass ✅           |
| BASH_EXEC                  | Pass ✅           |
| BIOME_FORMAT               | Pass ✅           |
| BIOME_LINT                 | Pass ✅           |
| CHECKOV                    | Pass ✅           |
| ENV                        | Pass ✅           |
| GITHUB_ACTIONS             | Pass ✅           |
| GITHUB_ACTIONS_ZIZMOR      | Fail ❌           |
| GITLEAKS                   | Pass ✅           |
| GIT_MERGE_CONFLICT_MARKERS | Pass ✅           |
| JSCPD                      | Pass ✅           |
| JSON                       | Fail ❌           |
| JSON_PRETTIER              | Fail ❌           |
| MARKDOWN                   | Pass ✅           |
| MARKDOWN_PRETTIER          | Pass ✅           |
| NATURAL_LANGUAGE           | Pass ✅           |
| PRE_COMMIT                 | Pass ✅           |
| RENOVATE                   | Pass ✅           |
| SHELL_SHFMT                | Pass ✅           |
| SPELL_CODESPELL            | Pass ✅           |
| TRIVY                      | Pass ✅           |
| YAML                       | Pass ✅           |
| YAML_PRETTIER              | Pass ✅           |

Super-linter detected linting errors

For more information, see the [GitHub Actions workflow run](https://github.com/thost96/infra/actions/runs/21535663133)

Powered by [Super-linter](https://github.com/super-linter/super-linter)

<details>

<summary>GITHUB_ACTIONS_ZIZMOR</summary>

```text
🌈 zizmor v1.22.0
[1m[31mfatal[39m[0m: no audit was performed
'known-vulnerable-actions' audit failed on file:///github/workspace/.github/actions/setup-ansible/action.yml

Caused by:
    0: error in 'known-vulnerable-actions' audit
    1: request error while accessing GitHub API
    2: Cache error: Cache error: error sending request for url (https://api.github.com/advisories?ecosystem=actions&affects=actions%2Fsetup-python%40v6.2.0)
```

</details>

<details>

<summary>JSON</summary>

```text

Oops! Something went wrong! :(

ESLint: 9.39.2

No files matching the pattern "/github/workspace/github_conf/branch_protection_rules.json" were found.
Please check for typing mistakes in the pattern.
```

</details>

<details>

<summary>JSON_PRETTIER</summary>

```text
.github/linters/.jscpd.json 41ms
.vscode/extensions.json 2ms
.vscode/settings.json 1ms
renovate.json 5ms[[31merror[39m] No files matching the pattern were found: "/github/workspace/github_conf/branch_protection_rules.json".
```

</details>
