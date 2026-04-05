# Super-linter summary

| Language                   | Validation result |
| -------------------------- | ----------------- |
| ANSIBLE                    | Fail ❌           |
| BASH                       | Pass ✅           |
| BASH_EXEC                  | Pass ✅           |
| BIOME_FORMAT               | Pass ✅           |
| BIOME_LINT                 | Pass ✅           |
| CHECKOV                    | Pass ✅           |
| GITHUB_ACTIONS             | Pass ✅           |
| GITHUB_ACTIONS_ZIZMOR      | Fail ❌           |
| GITLEAKS                   | Pass ✅           |
| GIT_MERGE_CONFLICT_MARKERS | Pass ✅           |
| JSCPD                      | Pass ✅           |
| JSON                       | Pass ✅           |
| JSON_PRETTIER              | Pass ✅           |
| MARKDOWN                   | Pass ✅           |
| MARKDOWN_PRETTIER          | Fail ❌           |
| NATURAL_LANGUAGE           | Pass ✅           |
| PRE_COMMIT                 | Pass ✅           |
| RENOVATE                   | Pass ✅           |
| SHELL_SHFMT                | Pass ✅           |
| SPELL_CODESPELL            | Fail ❌           |
| TRIVY                      | Pass ✅           |
| YAML                       | Fail ❌           |
| YAML_PRETTIER              | Fail ❌           |

Super-linter detected linting errors

For more information, see the [GitHub Actions workflow run](https://github.com/thost96/infra/actions/runs/24003266994)

Powered by [Super-linter](https://github.com/super-linter/super-linter)

<details>

<summary>ANSIBLE</summary>

```text
internal-error: Unexpected error code 1 from execution of: ansible-playbook --syntax-check -vv run.yaml (warning)
run.yaml:1 ansible-playbook [core 2.20.4]
  config file = /github/workspace/ansible/ansible.cfg
  configured module search path = ['/action/lib/.automation/.ansible/modules', '/github/home/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /venvs/ansible-lint/lib/python3.14/site-packages/ansible
  ansible collection location = /github/home/.ansible/collections:/usr/share/ansible/collections:/venvs/ansible-lint/lib/python3.14/site-packages
  executable location = /venvs/ansible-lint/bin/ansible-playbook
  python version = 3.14.3 (main, Feb  4 2026, 20:07:43) [GCC 15.2.0] (/venvs/ansible-lint/bin/python)
  jinja version = 3.1.6
  pyyaml version = 6.0.3 (with libyaml v0.2.5)
Using /github/workspace/ansible/ansible.cfg as config file
[WARNING]: Error getting vault password file (default): The vault password file /github/workspace/ansible/.vaultpassword was not found
[ERROR]: The vault password file /github/workspace/ansible/.vaultpassword was not found
[/]

fqcn[action-core]: Use FQCN for builtin module actions (stat).
tasks/check-reboot.yaml:3:3 Use `ansible.builtin.stat` or `ansible.legacy.stat` instead.

fqcn[action-core]: Use FQCN for builtin module actions (debug).
tasks/check-reboot.yaml:8:3 Use `ansible.builtin.debug` or `ansible.legacy.debug` instead.

fqcn[action-core]: Use FQCN for builtin module actions (reboot).
tasks/reboot.yaml:4:3 Use `ansible.builtin.reboot` or `ansible.legacy.reboot` instead.

fqcn[action-core]: Use FQCN for builtin module actions (wait_for_connection).
tasks/reboot.yaml:8:3 Use `ansible.builtin.wait_for_connection` or `ansible.legacy.wait_for_connection` instead./usr/local/lib/python3.14/tempfile.py:484: ResourceWarning: Implicitly cleaning up <HTTPError 304: 'Not Modified'>
  _warnings.warn(self.warn_message, ResourceWarning)
[WARNING]: Error loading plugin 'community.docker.docker_compose_v2': No module named 'ansible_collections.community'
WARNING  Unable to load module community.docker.docker_compose_v2 at tasks/compose-update.yaml:2 for options validation
WARNING  Invalid value (None)for resolved_fqcn attribute of community.docker.docker_compose_v2 module.
[WARNING]: Error loading plugin 'community.docker.docker_prune': No module named 'ansible_collections.community'
WARNING  Unable to load module community.docker.docker_prune at tasks/docker-prune.yaml:2 for options validation
WARNING  Invalid value (None)for resolved_fqcn attribute of community.docker.docker_prune module.
WARNING  Listing 5 violation(s) that are fatal
::warning file=run.yaml,line=1,severity=VERY_HIGH,title=internal-error::Unexpected error code 1 from execution of: ansible-playbook --syntax-check -vv run.yaml
::error file=tasks/check-reboot.yaml,line=3,col=3,severity=MEDIUM,title=fqcn[action-core]::Use FQCN for builtin module actions (stat).
::error file=tasks/check-reboot.yaml,line=8,col=3,severity=MEDIUM,title=fqcn[action-core]::Use FQCN for builtin module actions (debug).
::error file=tasks/reboot.yaml,line=4,col=3,severity=MEDIUM,title=fqcn[action-core]::Use FQCN for builtin module actions (reboot).
::error file=tasks/reboot.yaml,line=8,col=3,severity=MEDIUM,title=fqcn[action-core]::Use FQCN for builtin module actions (wait_for_connection).
```

</details>

<details>

<summary>GITHUB_ACTIONS_ZIZMOR</summary>

```text
[1m[33mwarning[secrets-outside-env][0m[1m: secrets referenced without a dedicated environment[0m
  [1m[94m--> [0m/github/workspace/.github/workflows/lint.yaml:36:22
   [1m[94m|[0m
[1m[94m22[0m [1m[94m|[0m   super-lint:
   [1m[94m|[0m   [1m[94m----------[0m [1m[94mthis job[0m
[1m[94m...[0m
[1m[94m36[0m [1m[94m|[0m           token: ${{ secrets.GH_TOKEN }}
   [1m[94m|[0m                      [1m[33m^^^^^^^^^^^^^^^^[0m [1m[33msecret is accessed outside of a dedicated environment[0m
   [1m[94m|[0m
   [1m[94m= [0m[1mnote[0m: audit confidence → High
   [1m[94m= [0m[1mhelp[0m: audit documentation → [32mhttps://docs.zizmor.sh/audits/#secrets-outside-env[39m

[1m[33mwarning[secrets-outside-env][0m[1m: secrets referenced without a dedicated environment[0m
  [1m[94m--> [0m/github/workspace/.github/workflows/lint.yaml:44:29
   [1m[94m|[0m
[1m[94m22[0m [1m[94m|[0m   super-lint:
   [1m[94m|[0m   [1m[94m----------[0m [1m[94mthis job[0m
[1m[94m...[0m
[1m[94m44[0m [1m[94m|[0m           github_token: ${{ secrets.GH_TOKEN }}
   [1m[94m|[0m                             [1m[33m^^^^^^^^^^^^^^^^[0m [1m[33msecret is accessed outside of a dedicated environment[0m
   [1m[94m|[0m
   [1m[94m= [0m[1mnote[0m: audit confidence → High
   [1m[94m= [0m[1mhelp[0m: audit documentation → [32mhttps://docs.zizmor.sh/audits/#secrets-outside-env[39m

[1m[33mwarning[secrets-outside-env][0m[1m: secrets referenced without a dedicated environment[0m
  [1m[94m--> [0m/github/workspace/.github/workflows/lint.yaml:63:29
   [1m[94m|[0m
[1m[94m22[0m [1m[94m|[0m   super-lint:
   [1m[94m|[0m   [1m[94m----------[0m [1m[94mthis job[0m
[1m[94m...[0m
[1m[94m63[0m [1m[94m|[0m           GITHUB_TOKEN: ${{ secrets.GH_TOKEN }}
   [1m[94m|[0m                             [1m[33m^^^^^^^^^^^^^^^^[0m [1m[33msecret is accessed outside of a dedicated environment[0m
   [1m[94m|[0m
   [1m[94m= [0m[1mnote[0m: audit confidence → High
   [1m[94m= [0m[1mhelp[0m: audit documentation → [32mhttps://docs.zizmor.sh/audits/#secrets-outside-env[39m

[1m[33mwarning[secrets-outside-env][0m[1m: secrets referenced without a dedicated environment[0m
  [1m[94m--> [0m/github/workspace/.github/workflows/lint.yaml:91:22
   [1m[94m|[0m
[1m[94m79[0m [1m[94m|[0m   packer-validate:
   [1m[94m|[0m   [1m[94m---------------[0m [1m[94mthis job[0m
[1m[94m...[0m
[1m[94m91[0m [1m[94m|[0m           token: ${{ secrets.GH_TOKEN }}
   [1m[94m|[0m                      [1m[33m^^^^^^^^^^^^^^^^[0m [1m[33msecret is accessed outside of a dedicated environment[0m
   [1m[94m|[0m
   [1m[94m= [0m[1mnote[0m: audit confidence → High
   [1m[94m= [0m[1mhelp[0m: audit documentation → [32mhttps://docs.zizmor.sh/audits/#secrets-outside-env[39m

[32m13[39m findings ([1m[93m9[39m suppressed[0m): [35m0[39m informational, [36m0[39m low, [33m4[39m medium, [31m0[39m high🌈 zizmor v1.23.1
[32m INFO[0m [1maudit[0m[2m:[0m [2mzizmor[0m[2m:[0m 🌈 completed /github/workspace/.github/workflows/lint.yaml
No fixes available to apply.
```

</details>

<details>

<summary>MARKDOWN_PRETTIER</summary>

```text
Checking formatting...[[33mwarn[39m] README.md
[[33mwarn[39m] Code style issues found in the above file. Run Prettier with --write to fix.
```

</details>

<details>

<summary>SPELL_CODESPELL</summary>

```text
/github/workspace/README.md:11: comming ==> coming
```

</details>

<details>

<summary>YAML</summary>

```text
/github/workspace/.github/workflows/lint.yaml:100:33: [warning] too few spaces before comment: expected 2 (comments)
/github/workspace/ansible/tasks/filesystem-trim.yaml:8:14: [error] no new line character at the end of file (new-line-at-end-of-file)
```

</details>

<details>

<summary>YAML_PRETTIER</summary>

```text
Checking formatting...[[33mwarn[39m] ansible/tasks/filesystem-trim.yaml
[[33mwarn[39m] Code style issues found in the above file. Run Prettier with --write to fix.
```

</details>
