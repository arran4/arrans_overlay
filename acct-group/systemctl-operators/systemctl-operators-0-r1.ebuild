# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-group

DESCRIPTION="Shared group for delegated systemctl access via Polkit rules"

ACCT_GROUP_ID=-1

pkg_postinst() {
	elog "To allow a user to use these delegated rules, add them to the systemctl-operators group:"
	elog "gpasswd -a <username> systemctl-operators"
	elog ""
	elog "Users must log out and log back in for group membership to apply."
}
