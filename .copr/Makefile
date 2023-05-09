spec ?= openssl.spec
outdir ?= .

srpm:
	# Download source tarball
	cd "$$(dirname "$(spec)")" && spectool -g "$$(basename "$(spec)")"
	# Then build srpm
	cd "$$(dirname "$(spec)")" && fedpkg srpm
	# Then, move it to the output directory, if it is defined
	if [ -d "$(outdir)" ] && [ "$$(readlink -f "$$(dirname "$(spec)")")" != "$$(readlink -f "$(outdir)")" ]; then \
		cd "$$(dirname "$(spec)")" && mv openssl-*.src.rpm "$(outdir)"; \
	fi
