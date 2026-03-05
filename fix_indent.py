import re

with open('.github/workflows/gui-apps-tuigreet-bin-update.yaml', 'r') as f:
    content = f.read()

# Instead of actual tabs everywhere (which messes up YAML parsing),
# we use `cat << 'EOF' > "$metadata_file"` and put the EOF tag without ANY spaces/tabs
# but that breaks YAML parsing if the EOF is at column 0.
# The solution is to use `cat << 'EOF' > "$metadata_file"` and indent the block inside the bash script
# then use sed or similar, OR we use `cat <<-EOF` but only use tabs for the heredoc lines and EOF,
# while making sure the YAML indents (spaces) are preserved for the action definition.
# Wait, actionlint complains if the block scalar string contains a mix or whatever?
# Ah! GitHub Actions allows block scalars with standard YAML indentation. `bash -n` complains if it's not a real script. BUT we can write the script to a file, then check it. Or just put EOF at the correct indentation if we use `cat <<- 'EOF'` WITH TABS ONLY FOR THE HEREDOC!
# BUT YAML doesn't allow TABS for indentation.
# Best approach: create the file with echoes, or use a block scalar but with `sed 's/^ *//'` to strip spaces.

old_heredoc = "            cat <<-EOF > \"$metadata_file\"\n" + \
              "\t\t\t<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + \
              "\t\t\t<!DOCTYPE pkgmetadata SYSTEM \"http://www.gentoo.org/dtd/metadata.dtd\">\n" + \
              "\t\t\t<pkgmetadata>\n" + \
              "\t\t\t\t<upstream>\n" + \
              "\t\t\t\t\t<remote-id type=\"github\">apognu/tuigreet</remote-id>\n" + \
              "\t\t\t\t</upstream>\n" + \
              "\t\t\t</pkgmetadata>\n" + \
              "\t\t\tEOF"

new_heredoc = """            cat << 'EOF' > "$metadata_file"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">
<pkgmetadata>
  <upstream>
    <remote-id type="github">apognu/tuigreet</remote-id>
  </upstream>
</pkgmetadata>
EOF"""

content = content.replace(old_heredoc, new_heredoc)

# Fix the actionlint error by indenting the heredoc properly WITH SPACES,
# and NOT using a heredoc, but rather echo commands.
new_echoes = """            echo '<?xml version="1.0" encoding="UTF-8"?>' > "$metadata_file"
            echo '<!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">' >> "$metadata_file"
            echo '<pkgmetadata>' >> "$metadata_file"
            echo '  <upstream>' >> "$metadata_file"
            echo '    <remote-id type="github">apognu/tuigreet</remote-id>' >> "$metadata_file"
            echo '  </upstream>' >> "$metadata_file"
            echo '</pkgmetadata>' >> "$metadata_file" """

content = content.replace(new_heredoc, new_echoes)

with open('.github/workflows/gui-apps-tuigreet-bin-update.yaml', 'w') as f:
    f.write(content)
