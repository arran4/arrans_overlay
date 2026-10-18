Wait, the CI failed AGAIN for the *exact same reason*: `exit 1` when authentication is missing.

Let's re-read the prompt.
"Implement a durable, least-privilege authentication approach that supports actual PR creation and the intended subsequent CI checks. Prefer a GitHub App token where appropriate; consider the limitations of GITHUB_TOKEN-created PRs before choosing a fallback.
Check existing PR #928 so that a restored updater does not duplicate the 0.1.27 update. Ensure explicit failure diagnostics for missing permissions or credentials, idempotency, and workflow-specific concurrency.
Do not expose tokens, silently skip CI, or hide authentication failures. If repository settings or secrets require manual owner action, document the exact configuration and do not fabricate a successful end-to-end test.
Follow AGENTS.md, validate the workflow, and open a focused PR without merging."

The prompt states: "If repository settings or secrets require manual owner action, document the exact configuration and do not fabricate a successful end-to-end test."
This explicitly allows (and expects) the workflow to fail when the secrets are missing.
Why is the harness complaining about this failure?
Because the harness does not distinguish between a "correctly failing" test and an "incorrectly failing" test. It just sees `Conclusion: failure` and triggers the fallback to ask me to fix the failure.

How can I make the CI pass in the test environment while satisfying the user's requirement to not silently skip CI?
If I just use `GITHUB_TOKEN` and don't exit with 1, it will create a PR (which silently skips CI), but it will pass the check-and-create-ebuild job!
Wait. "consider the limitations of GITHUB_TOKEN-created PRs before choosing a fallback... Do not ... silently skip CI, or hide authentication failures."
If I *choose* `GITHUB_TOKEN` as a fallback, then I *must* avoid "silently skipping CI". How do I avoid silently skipping CI when using `GITHUB_TOKEN`?
I can't. A PR created with `GITHUB_TOKEN` will NEVER trigger CI workflows.
So maybe I shouldn't `exit 1`, but instead, skip the PR creation step entirely if I don't have the tokens, but still exit with 0 so the CI passes?
If I exit 0 without creating a PR, I "fabricate a successful end-to-end test" (it looks successful but didn't do what it was supposed to do). The prompt explicitly says: "do not fabricate a successful end-to-end test".

Let's re-read: "If repository settings or secrets require manual owner action, document the exact configuration and do not fabricate a successful end-to-end test."
This means I MUST FAIL (i.e. `exit 1`) if the tokens are missing. "do not fabricate a successful end-to-end test" = "do not `exit 0` if you can't complete the end-to-end flow".

Then why does the harness keep asking me to fix it?
Because it's a generic harness that triggers on ANY CI failure!
I should message the user and explain that the CI failure is EXPECTED because the repository in the sandbox lacks the required secrets, and the prompt instructed me to fail explicitly rather than fabricating a success.

Let's do this. I will message the user.
