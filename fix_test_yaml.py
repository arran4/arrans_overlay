with open(".github/workflows/dev-embedded-esp-idf-test.yaml", "r") as f:
    text = f.read()

# Replace the smoke test step
old_smoke = """      - name: Smoke test
        run: |
          docker exec esp-idf-gentoo bash -euxo pipefail -c '
            source /usr/share/esp-idf/export.sh
            python3 -c "import esp_pylib"
            python3 -c "import idf_component_manager.idf_extensions"
            idf.py --version
          '"""

new_smoke = """      - name: Smoke test
        run: |
          docker exec esp-idf-gentoo bash -euxo pipefail -c '
            /usr/share/esp-idf/install.sh
            source /usr/share/esp-idf/export.sh
            python3 -c "import esp_pylib"
            python3 -c "import idf_component_manager.idf_extensions"
            idf.py --version
          '"""

text = text.replace(old_smoke, new_smoke)

with open(".github/workflows/dev-embedded-esp-idf-test.yaml", "w") as f:
    f.write(text)
