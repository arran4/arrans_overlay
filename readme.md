# arrans_overlay_workflow_builder_generator

This is a generator for some of the github actions in [my gentoo overlay](https://github.com/arran4/arrans_overlay/tree/main/.github/workflows)'s
workflow directory. - Which check for updates to various applications then generates ebuilds for them.

## Installation

To install this application, run the following command:
```bash
go install github.com/arran4/arrans_overlay_workflow_builder@latest
```
This will install the `arrans_overlay_workflow_builder` binary in your `$GOPATH/bin` directory.

The purpose of this application is (currently) to quickly generate binary ebuild files for 2 use cases:
* Github repositories with AppImage binary releases
* Github repositories with normal elf binaries releases (such as those generated with `goreleaser`)

The general idea is that this is to be used to quickly get specific binary apps.

Some considerations:
* alternative executables (such as with `hugo` and it's `extended` version which comes up as a use flag to switch between them.)
* manual pages
* documents
* shell completion scripts (bash, zsh, fish and powershell)

## Usage:

The basic flow of using the app is that:
* Find a list of github URLs for applicable programs that you want to generate ebuilds for in your overlay
* Feed the URL to the appropriate `config generation` step (See the appropriate section below)
* Modify the configuration as appropriate
* Run the `generate workflows` step
* Install the `./output/*.yaml` files in your overlay's github repo's `./github/workflows` directory
* Commit and push. Staggered to 1 at a time with a 1-minute wait between each commit & push.
* Watch the ebuilds (or errors) come through
* Install your tools

## Config generation

The configuration files sections look as follows: (See [mine here](https://github.com/arran4/arrans_overlay/blob/main/current.config) for more)

For AppImages released on GitHub:
```
Type Github AppImage Release
GithubProjectUrl https://github.com/anyproto/anytype-ts
Category app-text
EbuildName anytype-ts-appimage
Description Official Anytype client for MacOS, Linux, and Windows
Workaround Semantic Version Prerelease Hack 1
Homepage https://anytype.io
License Other
ProgramName Anytype
DesktopFile anytype.desktop
Icons hicolor-apps root
Dependencies sys-libs/glibc sys-libs/zlib
Binary amd64=>Anytype-${VERSION}.AppImage > Anytype.AppImage
```

For other binary files being released on GitHub:

```
Type Github Binary Release
GithubProjectUrl https://github.com/twpayne/chezmoi
EbuildName chezmoi-bin
Category app-admin
Description Manage your dotfiles across multiple diverse machines, securely.
Homepage https://www.chezmoi.io/
License MIT License
Workaround Programs as Alternatives => amd64:glibc amd64:loong64 arm64:android ppc64:le
ProgramName android
Binary arm64=>chezmoi_${VERSION}_android_arm64.tar.gz > chezmoi > chezmoi
ProgramName chezmoi
Dependencies sys-libs/glibc
Binary amd64=>chezmoi_${VERSION}_linux-musl_amd64.tar.gz > chezmoi > chezmoi
Binary arm=>chezmoi_${VERSION}_linux_arm.tar.gz > chezmoi > chezmoi
Binary arm64=>chezmoi_${VERSION}_linux_arm64.tar.gz > chezmoi > chezmoi
Binary ppc64=>chezmoi_${VERSION}_linux_ppc64.tar.gz > chezmoi > chezmoi
Binary riscv=>chezmoi_${VERSION}_linux_riscv64.tar.gz > chezmoi > chezmoi
Binary s390=>chezmoi_${VERSION}_linux_s390x.tar.gz > chezmoi > chezmoi
Binary x86=>chezmoi_${VERSION}_linux_i386.tar.gz > chezmoi > chezmoi
ProgramName glibc
Dependencies sys-libs/glibc
Binary amd64=>chezmoi_${VERSION}_linux-glibc_amd64.tar.gz > chezmoi > chezmoi
ProgramName le
Binary ppc64=>chezmoi_${VERSION}_linux_ppc64le.tar.gz > chezmoi > chezmoi
ProgramName loong64
Binary amd64=>chezmoi_${VERSION}_linux_loong64.tar.gz > chezmoi > chezmoi
```

Ideally you would have 1 file, with multiple of these entries in it. See [mine here](https://github.com/arran4/arrans_overlay/blob/main/current.config)

### Config Generation for an AppImage binary in a GitHub Release

There are 2 commands to generate the AppImage section, one outputs to STDOUT and the other outputs to a specified config file

#### STDOUT version:

You need to provide a github URL as such:

```bash
go run github.com/arran4/arrans_overlay_workflow_builder@latest config view github-release-appimage -github-url https://github.com/anyproto/anytype-ts
```

#### Append to config file version

You will need to provide the GitHub URL for the target project, and optionally the input file which defaults to `input.config`

```bash
go run github.com/arran4/arrans_overlay_workflow_builder@latest config add github-release-appimage -github-url https://github.com/anyproto/anytype-ts -to input.config
```

### Config Generation for a binary in a GitHub Release

There are 2 commands to generate the AppImage section, one outputs to STDOUT and the other outputs to a specified config file

#### STDOUT version:

You need to provide a github URL as such:

```bash
go run github.com/arran4/arrans_overlay_workflow_builder@latest config view github-release-binary -github-url https://github.com/goreleaser/goreleaser
```

#### Append to config file version

You will need to provide the GitHub URL for the target project, and optionally the input file which defaults to `input.config`

```bash
go run github.com/arran4/arrans_overlay_workflow_builder@latest config add github-release-binary -github-url https://github.com/goreleaser/goreleaser -to input.config
```

## `ebuild` Generator GitHub Action Generator

To generate the workflows from an `input.config` file run:

```bash
go run github.com/arran4/arrans_overlay_workflow_builder@latest generate workflows -input-file input.config
```

Look in the `output/` directory for the generated file(s) these should be copied to your github overlay's `./.github/workflows`
directory after being modified. Remember to add: `Category` with the appropriate Gentoo ebuild [category](https://packages.gentoo.org/categories).

## Additional options and work-arounds

There are a couple workarounds. At the moment the application assumes semantic versions, and using GitHub releases. Some will be automatically detected, some won't.

In some cases, multiple workarounds are supported.

### Version doesn't have a `v` preceding it:

The program will automatically detect this.

Add `Workaround Semantic Version Without V` to the config after `License`

### Version is semantic and doesn't match Gentoo version requirements

This mostly impacts projects that have releases like `alpha` `beta` etc. The program will automatically detect this.

Add `Workaround Semantic Version Prerelease Hack 1` to the config after `License`

### Multiple applications are in one repo using a tag prefix to distinguish between them

The program will NOT detect this, you will have to craft a config to match this, or attempt to use the appropriate commandline flag.

The work around is:
```
Workaround Tag Prefix => prefix-
```

Such as in Ente's Auth:

```
Type Github AppImage Release
GithubProjectUrl https://github.com/ente-io/ente
EbuildName ente-auth-appimage
Description Ente's 2FA solution
Homepage https://ente.io/blog/auth/
License GNU Affero General Public License v3.0
Workaround Semantic Version Prerelease Hack 1
Workaround Tag Prefix => auth-
ProgramName ente_auth
DesktopFile ente_auth.desktop
Icons hicolor-apps root
Dependencies sys-libs/glibc sys-libs/zlib
Binary amd64=>ente-${TAG}-x86_64.AppImage > ente_auth.AppImage
```

The flag for this is `-tag-prefix` used as such:

```bash
go run github.com/arran4/arrans_overlay_workflow_builder@latest config view github-release-appimage -github-url https://github.com/anyproto/anytype-ts -tag-prefix auth-
```

Due to assumption in the program you WILL have to modify the `EbuildName`, `Description`, `Homepage` and `Category` at minimum.

#### The application uses some other system for versioning

This is not really supported but you can manually specify the tag to base the configuration off with `-version-tag` this is used in cases such as: https://github.com/probonopd/go-appimage
itself, as currently it uses a snapshot system where the snapshot tag is `continuous` which is hard to work with.

If it was working this is what it would look like.
```
Type Github AppImage
GithubProjectUrl https://github.com/probonopd/go-appimage
EbuildName go-appimage
Description Go implementation of AppImage tools
License MIT License
Workaround Nightly Build in 'Continuous' With Build Number as version with offset '646'
ProgramName appimaged-838
DesktopFile appimaged.desktop
InstalledFilename appimaged-838.AppImage
ReleasesFilename amd64=>appimaged-838-x86_64.AppImage
ReleasesFilename arm=>appimaged-838-armhf.AppImage
ReleasesFilename arm64=>appimaged-838-aarch64.AppImage
ReleasesFilename x86=>appimaged-838-i686.AppImage
ProgramName appimagetool-838
DesktopFile appimagetool.desktop
InstalledFilename appimagetool-838.AppImage
ReleasesFilename amd64=>appimagetool-838-x86_64.AppImage
ReleasesFilename arm=>appimagetool-838-armhf.AppImage
ReleasesFilename arm64=>appimagetool-838-aarch64.AppImage
ReleasesFilename x86=>appimagetool-838-i686.AppImage
ProgramName mkappimage-838
DesktopFile mkappimage.desktop
InstalledFilename mkappimage-838.AppImage
ReleasesFilename amd64=>mkappimage-838-x86_64.AppImage
ReleasesFilename arm=>mkappimage-838-armhf.AppImage
ReleasesFilename arm64=>mkappimage-838-aarch64.AppImage
ReleasesFilename x86=>mkappimage-838-i686.AppImage
```

Please note: `838` should be the `${TAG}` and this removed from the program name. `'646'` is specified as though we could
grab the current build number, which we don't. This will remain unsupported for the mean time.

# Notes

* The program has been extended without being refactored beyond its original purpose, I am keen to get someone who has a better design to weigh in, create a PR, or a discussion
* In the future, the app should (hopefully will) call itself or my app [g2](https://github.com/arran4/g2) for the ebuild generation component of the workflow
* this tool is for VERY specific use cases. You will have to be prepared to modify it for yours if not included
* This program is provided under the "good enough for my itch" philosophy. You're welcome to fork, create pull requests and extend as needed.
* I will be concerned mostly with the apps of my interest, the list can be found here: https://github.com/arran4/arrans_overlay/blob/main/current.config
* The entire `main.go` is to completely rebuilt with generated code. But until then do what is necessary but in a way which is compatible with that idea
* I am considering generating more files such as the metadata.xml file too