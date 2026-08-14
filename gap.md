# gap

`overlay_workflow_builder_generator` currently doesn't natively support automated updates for `https://which-browser-site.pages.dev/`. It should be extended to support grabbing versions directly from the Cloudflare Pages deployment or its underlying Github repository correctly, handling the `.deb` release file and the `+##` version format that Flutter adds without triggering ebuild linting issues due to unparsed parameter expansion bash code during ebuild evaluation.
