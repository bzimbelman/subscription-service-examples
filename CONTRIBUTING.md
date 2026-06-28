# Contributing a recipe

Recipes here aim for **the smallest working example**, not exhaustive
production-readiness. If you want to add or modify a recipe, please:

1. **Open an issue first** describing the deployment shape, target platform,
   and what makes it different from the existing recipes.
2. **Keep it small.** A recipe should be readable end-to-end in 5 minutes.
   Cross-link to the engine repo's docs for the heavy lifting; do not
   duplicate them here.
3. **Synthetic data only.** No real MRNs, names, DOBs, or PHI. Use obvious
   placeholders (`Test Patient One`, `MRN-EXAMPLE-001`, `1900-01-01`).
4. **Each recipe must include:**
   - `README.md` with prerequisites, deploy steps, and a "knobs to change
     before going live" section
   - The artifacts (`docker-compose.yml`, `values.yaml`, etc.)
   - A `verify.sh` that returns 0 on a healthy deploy and non-zero otherwise
5. **CI must pass.** The workflow in `.github/workflows/ci.yml` lints YAML,
   validates compose files, and runs `helm lint` on chart references. It
   does not actually deploy anything — that's on the contributor.

## File layout

```
NN-recipe-name/
|-- README.md
|-- docker-compose.yml         (or values.yaml + install.sh)
`-- verify.sh                  executable, shellcheck-clean
```

## Style

- Markdown: one paragraph per line, no hard wrap.
- Shell: `set -euo pipefail`, shellcheck-clean.
- YAML: 2-space indent.

## License

By contributing, you agree your contribution is licensed under Apache 2.0.
