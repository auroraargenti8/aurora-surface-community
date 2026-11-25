# Maintaining this repository

Notes for whoever maintains the image (today: the repository owner, working with an AI assistant).

## The rule of thumb

The image should stay **as close to official Aurora as possible**. Every package added or removed is something that can drift from upstream. Change the recipe only when there is a Surface-specific reason, and write the reason down.

## Every change to the recipe

1. Build locally first: `just build`, then check `bootc container lint` passed (it runs at the end of the build) and that `/usr/lib/modules/` holds exactly one kernel with `vmlinuz` and `initramfs.img`.
2. Commit with a message that says **what** changed and **why**.
3. Add an entry to [`CHANGELOG.md`](./CHANGELOG.md) in the same commit.
4. For notable changes (a new Fedora release, a package added or removed) consider a GitHub Release with a short human-readable note.

## Regular checks

- **Build badge** in the README — look every week or two. A red build means nothing was published; installed systems stay on the last good image. Typical cause: a new Fedora release before linux-surface publishes a matching kernel. Usually it fixes itself within days; if not, look at the job log.
- **Dependabot pull requests** (weekly check) propose newer versions of the GitHub Actions used by the workflow. Read the release notes, merge if nothing looks risky. Merging also counts as repository activity.
- **Issues** from users — answer; ask for the Surface model and `uname -r`.

## Things that keep the automation alive

- The `keepalive` job re-enables the workflow on every scheduled run, because GitHub disables schedules in public repositories after 60 days without commits. If the schedule is ever disabled anyway, re-enable it in the Actions tab.
- The signing key: the private half is the repository secret `SIGNING_SECRET`, a backup copy is kept offline by the owner. **Never commit `cosign.key`** (it is in `.gitignore`). Losing the backup is not fatal, but rotating the key means publishing a new `cosign.pub`.

## Where things come from

- Base image: `ghcr.io/ublue-os/aurora:stable`.
- Kernel and Surface tools: the linux-surface Fedora repository, `https://pkg.surfacelinux.com/fedora/linux-surface.repo`.
- Template: [ublue-os/image-template](https://github.com/ublue-os/image-template) (this repository started from it on 2026-11-25; upstream changes are not pulled automatically).
