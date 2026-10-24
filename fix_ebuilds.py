import re

header = """# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

"""

def fix_file(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # Fix header
    if "Copyright 2026 Gentoo Authors" not in content:
        content = content.replace("EAPI=8\n\n", f"{header}EAPI=8\n\n")

    # Fix line length in ebuild
    content = content.replace(
        'einfo "The GitHub repository is private and the Cloudflare Pages host does not"',
        'einfo "The GitHub repository is private and the host does not"'
    )
    content = content.replace(
        'einfo "to be configured upstream before it can be installed automatically."',
        'einfo "to be configured before it can be installed automatically."'
    )
    content = content.replace(
        'patchelf --replace-needed libappindicator3.so.1 libayatana-appindicator3.so.1 usr/share/which_browser/lib/libtray_manager_plugin.so || die',
        'patchelf --replace-needed libappindicator3.so.1 \\\n\t\tlibayatana-appindicator3.so.1 \\\n\t\tusr/share/which_browser/lib/libtray_manager_plugin.so || die'
    )
    content = content.replace(
        'sed -i -e \'/^Version=/d\' "${D}/usr/share/applications/which_browser.desktop" || die',
        'sed -i -e \'/^Version=/d\' \\\n\t\t"${D}/usr/share/applications/which_browser.desktop" || die'
    )

    with open(filename, 'w') as f:
        f.write(content)

fix_file("www-misc/which_browser/which_browser-0.2.6.44-r2.ebuild")
fix_file("scripts/update_which_browser.py")
