def fix_file(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # line 26: SRC_URI
    content = content.replace(
        'SRC_URI="https://which-browser-site.pages.dev/downloads/v0.2.6/which_browser-0.2.6+44-linux.deb"',
        'BASE_URL="https://which-browser-site.pages.dev/downloads/v0.2.6"\nSRC_URI="${BASE_URL}/${MY_DEB_ARCHIVE}"'
    )
    # line 43
    content = content.replace(
        'einfo "The GitHub repository is private and the host does not"',
        'einfo "The upstream repo is private and the host lacks files"'
    )
    # line 45
    content = content.replace(
        'einfo "to be configured before it can be installed automatically."',
        'einfo "to be set up before it can be installed automatically."'
    )
    # line 80
    content = content.replace(
        'einfo "Please set Which Browser? as the default HTTP and HTTPS handler."',
        'einfo "Please set it as the default HTTP and HTTPS handler."'
    )

    with open(filename, 'w') as f:
        f.write(content)

fix_file("www-misc/which_browser/which_browser-0.2.6.44-r2.ebuild")
fix_file("scripts/update_which_browser.py")
