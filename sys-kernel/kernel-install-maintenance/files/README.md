# kernel-install-maintenance

Optional systemd kernel-install hooks for Gentoo BLS (Type #1) entries.
They never mount filesystems, modify fstab, change EFI variables, delete
kernel images, or touch entries belonging to other operating systems.

- mount-guard (default): refuses add/remove if the configured BLS boot root
  is not itself mounted. A root-relative boot directory is deliberately not
  supported by this guard; disable it for such installations. Optionally put
  the expected filesystem UUID on one line in /etc/kernel/maintenance-boot-uuid.
- recovery (default): creates two small entry files per kernel after the normal
  BLS entry exists. Supports the standard filename and boot-counted entries.
  Requires the boot root to be mounted independently of the guard flag.
  Removes only its own marked recovery entries when kernel-install removes
  the corresponding kernel. No additional kernel or initramfs copies.
  Emergency RO requests an initially read-only root, disables resume and masks
  systemd-remount-fs.service; it is not a guarantee that other services or
  manual commands cannot remount it. Bash recovery uses init=/bin/bash.
  Test both modes on your machine before relying on them.

The hooks apply only to BLS add/remove. UKIs and legacy layouts are unchanged.
Installing the package will not generate entries for older kernels. To create
them, run kernel-install add for the corresponding installed kernel during
normal maintenance (which may recreate its initramfs), or invoke the recovery
hook explicitly with the correct layout, boot root, token and version. Check
bootctl list afterwards. Existing local hooks and recovery entries are not
removed; review any duplicates, including local 95-recovery.install, first.
Do not use this as a substitute for a separately bootable recovery environment.

Automatic pruning is deliberately not implemented in this release. A future
opt-in feature should compute required space after initramfs staging, protect
the booted kernel and retained fallback versions, and fail without deleting
anything when there is no eligible candidate. Manual ESP mounting is supported.

## Verification and release gate

The optional `test` USE flag runs `files/test-hooks.sh` as a **small synthetic
regression only**. It checks BLS text transformations, file references, managed
entry cleanup and collision handling using a mocked mount probe. It does not
test real mounts, dracut, signing, firmware bootability, the kernel's root
mount state or a functioning recovery shell. There is intentionally no
dedicated GitHub Actions workflow for these mock tests.

Ordinary overlay CI checks ebuild packaging and dependencies, **not whether
these recovery choices boot**. Before enabling this package on production
boot media or considering it verified, perform and record on-hardware
verification as tracked in:
https://github.com/arran4/arrans_overlay/issues/1056

Preserve a known-working default and independent recovery path until both
new entries are tested. The ESP remains explicitly mounted by the operator
for maintenance; this package does not change fstab or mount it for you.
