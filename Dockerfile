FROM busybox:1.36.1-musl AS build
ARG TARGETARCH
ARG GH_VERSION=2.78.0
ARG GH_SHA256_AMD64=ac309f70c5d6b122c82e6138ce82cb65ca5d8595cc09d11751fbc4e3907e1a05
ARG GH_SHA256_ARM64=9e3ca75b227a5503f6ef92c4b8b6dbf94e34bfdd8069ac0f16b8739856ebba7b

WORKDIR /work
RUN set -eux; \
	case "${TARGETARCH}" in \
		amd64) gh_arch=amd64; expected="${GH_SHA256_AMD64}" ;; \
		arm64) gh_arch=arm64; expected="${GH_SHA256_ARM64}" ;; \
		*) echo "Unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
	esac; \
	url="https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${gh_arch}.tar.gz"; \
	echo "Downloading $url"; \
	wget -q -O gh.tgz "$url"; \
	echo "${expected}  gh.tgz" | sha256sum -c -; \
	mkdir /out; \
	tar -xzf gh.tgz -C /out --strip-components=1; \
	rm gh.tgz; \
	/out/bin/gh --version; \
	test -x /out/bin/gh

FROM scratch
ARG GH_VERSION=2.78.0
LABEL org.opencontainers.image.title="GitHub CLI" \
			org.opencontainers.image.description="Minimal scratch image supplying GitHub CLI in /opt/bin/gh" \
			org.opencontainers.image.source="https://github.com/cli/cli" \
			org.opencontainers.image.version="${GH_VERSION}" \
			org.opencontainers.image.licenses="MIT" \
			maintainer="Jonathan Garbee"

COPY --from=build /out /opt
ENV PATH=/opt/bin:$PATH \
		GH_SUPPLIER_NOTE="Image contains gh; copy /opt/bin/gh into final stage if desired."

# Data-only image; no entrypoint.
