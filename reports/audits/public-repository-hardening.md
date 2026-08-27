# Public repository hardening audit

## Summary

The current tree was hardened for public distribution without changing Android runtime
behavior or adding GitHub Actions. The repository now has an official Apache-2.0 license,
derived-app licensing guidance, broader local-secret ignore rules, deterministic tracked
content scanning, and a sanitized semantic/visual evidence report.

## License

| Item | Result |
|---|---|
| Old state | No `LICENSE` file existed in the current checkout; the historical candidate contained an unrelated license. |
| New state | Added the official Apache License 2.0 text with `Copyright 2026 Nazareno De Francesco`. |
| Derived apps | `new-app.sh` retains `LICENSE` for inherited template material and records that original app code may use a separate license, including a proprietary one. |

The README explains that copied Apache-licensed material remains subject to its Apache-2.0
conditions and that deriving an app does not require the entire app to be open source.

## Leak review

- Current tracked tree: no cross-project provenance references found.
- Current tracked tree: no PEM private keys, GitHub/OpenAI/AWS/Telegram token values,
  Google service-account private key material, signing files, or credential assignments
  found by the built-in scan.
- Environment variable names used by the Telegram publishing script remain documented
  placeholders and no values are committed.
- `gitleaks`: NOT RUN — executable is not installed; the built-in deterministic scan is
  the mandatory baseline.
- Historical review: an old reachable commit contains
  `scripts/__pycache__/task.cpython-313.pyc`.
- Historical review: the old semantic/visual report content included cross-project
  provenance references; the current report is sanitized.

## Files changed

| File | Reason |
|---|---|
| `LICENSE` | Add official Apache-2.0 license. |
| `README.md` | Clarify template and derived-application licensing. |
| `.gitignore` | Ignore common environment, credential, certificate and signing formats. |
| `scripts/repo-check.sh` | Add tracked-content secret checks and optional Gitleaks integration. |
| `scripts/new-app.sh` | Explain inherited license material and separate original-app licensing. |
| `scripts/template-self-test.sh` | Verify license inheritance and derivation guidance. |
| `reports/audits/v0.1.2-semantic-visual-evidence.md` | Remove private cross-project provenance. |
| `reports/audits/public-repository-hardening.md` | Record this audit and remaining risks. |

## Validation

| Check | Result |
|---|---|
| `./scripts/repo-check.sh` | PASS |
| `./scripts/template-self-test.sh` | PASS |
| `git diff --check` | PASS |
| `git fsck --no-progress` | PASS |
| Current-tree built-in secret scan | PASS |
| Gitleaks | NOT RUN — unavailable in PATH |
| Android build/device gate | NOT RUN — Java/Android build toolchain unavailable in this environment |
| Git status | CLEAN before this report commit; report is included in the final commit |

## Tag and history assessment

The existing `v0.1.2-candidate` tag remains unchanged and points to
`0a026ce19ae9b55d7f4fb54127b4773a1a1a5472`, before this cleanup. `master` originally
pointed to `570ec6a3973d0b3a0a553c1cf5e3da80ec69f00b`; the cleanup commits are local
until explicitly pushed.

No destructive history rewrite was performed. Rewriting would remove the historical
`.pyc` and old provenance text from reachable branch/tag history, require force-pushing
rewritten refs, invalidate existing clones/forks and commit links, and still could not
guarantee removal from third-party caches or already cloned copies.

## Remaining risks

- The old candidate tag still exposes the pre-cleanup snapshot and should not be
  presented as the hardened release.
- The historical `.pyc` remains reachable in Git history.
- The historical provenance text may remain in existing clones, mirrors or caches.
- GitHub security settings could not be inspected from this environment because `gh` is
  unavailable. For the public repository, verify Secret Scanning and Push Protection in
  GitHub settings; enable them if the account/plan exposes those controls.

## Recommendation

Keep the old tag immutable. Publish the cleanup commits and create a new candidate tag,
for example `v0.1.3-candidate`, at the hardened commit. Do not rewrite history unless
the repository owner explicitly accepts force-push and clone/fork disruption; current
tree hygiene plus Secret Scanning/Push Protection is the lower-risk public hardening
path.
