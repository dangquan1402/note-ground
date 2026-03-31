# Release Notes

- Keep `package.json` version and `bundle/manifest.json` version identical.
- In this repo, a release means both:
  - push a matching Git tag like `0.3.1`
  - create a public GitHub release in `note-ground`
  - publish the same version to npm
- The tag is the trigger. After pushing the tag, the release workflow should publish the GitHub release assets and the npm package.
- The expected npm package is `note-ground`.
- Before tagging, verify that `bundle/main.js`, `bundle/manifest.json`, `bundle/styles.css`, `install.sh`, and `install.mjs` are up to date.
