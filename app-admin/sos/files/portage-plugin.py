# Distributed under the terms of the GNU General Public License v2

from sos.report.plugins import IndependentPlugin, Plugin


class Portage(Plugin, IndependentPlugin):
    """Read-only Gentoo package management diagnostics."""

    plugin_name = "portage"
    short_desc = "Gentoo Portage configuration and installed packages"
    profiles = ("system", "packagemanager")
    commands = ("emerge",)

    def setup(self):
        self.add_cmd_output([
            "emerge --info",
            "qlist -ICv",
            "qlist -ICvU",
            "eselect profile show",
        ])
        self.add_copy_spec([
            "/var/lib/portage/world",
            "/var/lib/portage/world_sets",
        ])
