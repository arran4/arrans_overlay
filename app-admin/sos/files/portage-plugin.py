# Distributed under the terms of the GNU General Public License v2

from sos.report.plugins import IndependentPlugin, Plugin


class Portage(Plugin, IndependentPlugin):
    """Read-only Gentoo package management diagnostics."""

    plugin_name = "portage"
    short_desc = "Gentoo Portage configuration and installed packages"
    profiles = ("system", "packagemanager")
    commands = ("emerge",)

    def setup(self):
        for command, filename in (
            ("emerge --info", "emerge-info"),
            ("qlist -ICv", "installed-packages"),
            ("qlist -ICvU", "installed-use-flags"),
            ("eselect profile show", "profile"),
        ):
            self.add_cmd_output(command, suggest_filename=filename)
        self.add_copy_spec([
            "/var/lib/portage/world",
            "/var/lib/portage/world_sets",
        ])
