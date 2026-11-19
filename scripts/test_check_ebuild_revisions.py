import unittest
from check_ebuild_revisions import validate, version_key

ROOT = "app-portage/portage-sync-notifier/"
OLD = ROOT + "portage-sync-notifier-1.0.ebuild"
R1 = ROOT + "portage-sync-notifier-1.0-r1.ebuild"
SCRIPT = ROOT + "files/portage-sync-notifier"
NEW_SCRIPT = ROOT + "files/portage-notifier"

class RevisionGuardTests(unittest.TestCase):
    def test_original_pr_rejected(self):
        result = validate([OLD, SCRIPT], [OLD, NEW_SCRIPT], [OLD, SCRIPT, NEW_SCRIPT])
        self.assertEqual(len(result), 2)

    def test_fixed_pr_accepted(self):
        self.assertEqual(validate([OLD, SCRIPT], [OLD, R1, SCRIPT, NEW_SCRIPT],
                                  [R1, NEW_SCRIPT]), [])

    def test_payload_without_new_ebuild_rejected(self):
        self.assertEqual(len(validate([OLD, SCRIPT], [OLD, SCRIPT], [SCRIPT])), 1)

    def test_higher_version_accepted(self):
        new = ROOT + "portage-sync-notifier-1.1.ebuild"
        self.assertEqual(validate([OLD, SCRIPT], [OLD, SCRIPT, new],
                                  [new, SCRIPT]), [])

    def test_older_version_rejected(self):
        new = ROOT + "portage-sync-notifier-0.9.ebuild"
        self.assertEqual(len(validate([OLD, SCRIPT], [OLD, SCRIPT, new],
                                      [new, SCRIPT])), 1)

    def test_docs_not_requiring_bump(self):
        self.assertEqual(validate([OLD], [OLD], [ROOT + "metadata.xml"]), [])

    def test_first_install_no_bump(self):
        self.assertEqual(validate([], [OLD, SCRIPT], [OLD, SCRIPT]), [])

    def test_release_beside_live(self):
        live = ROOT + "portage-sync-notifier-9999.ebuild"
        self.assertEqual(validate([live, SCRIPT], [live, OLD, SCRIPT],
                                  [OLD, SCRIPT]), [])

    def test_revision_and_suffix_order(self):
        self.assertLess(version_key("x-1.0.ebuild", "x"), version_key("x-1.0-r1.ebuild", "x"))
        self.assertLess(version_key("x-1.0_rc1.ebuild", "x"), version_key("x-1.0.ebuild", "x"))
        self.assertLess(version_key("x-1.0.ebuild", "x"), version_key("x-1.0_p1.ebuild", "x"))

if __name__ == "__main__":
    unittest.main()
