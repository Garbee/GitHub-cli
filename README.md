# Minimal GitHub CLI (gh) Image

Ultra-minimal, multi-architecture container image that packages the GitHub CLI (`gh`) for Linux `amd64` and `arm64` on top of a `scratch` final layer. Intended to be consumed as a build stage or lightweight base providing `/opt/bin/gh`.

## Why

- Avoid repeating download/verify steps in every Dockerfile.
- Deterministic, checksum-verified supply of `gh`.
- Final image contains only the extracted `gh` distribution (no shell).

## Supported Architectures

Only 64bit ARM and AMD are supported.

## Layout

```text
/opt/
  bin/gh
  share/... (man pages, etc.)
  LICENSE
```

`PATH` is set so `gh` is directly invokable when using the image as a base or running it directly with a command override.

## Using as a Build Stage

```Dockerfile
FROM gh-scratch:2.78.0 AS gh
FROM alpine:3.20
COPY --from=gh /opt/bin/gh /usr/local/bin/gh
RUN gh --version
```

## Rationale for `scratch`

- Minimizes attack surface & size.
- Forces explicit layering decisions in downstream images.
- Suitable where only `gh` binary is required (e.g., release workflows, metadata queries).

## Updating Version

1. Change `GH_VERSION` default in `Dockerfile` (optional).
2. Acquire new checksums and update inline values.
3. Rebuild & push with a matching tag (`:2.x.y` and optionally `:latest`).

## Security Notes

- SHA256 of download is verified during build (fail-fast on mismatch).
- Final image has no package manager or shell; supply chain risk reduced.
- Trust still depends on GitHub release asset integrity.

## License

GitHub CLI is MIT licensed (see upstream). This repository's Docker build logic: MIT.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Build fails: "Unsupported TARGETARCH" | Building for an unsupported arch | Limit platforms to amd64,arm64 |
| sha256sum mismatch | Wrong checksum provided | Re-fetch checksums file |
| Need shell inside image | `scratch` final has none | Multi-stage COPY into alpine/debian |

---

Questions or improvements welcome.
