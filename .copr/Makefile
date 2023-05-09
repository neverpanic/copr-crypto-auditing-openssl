spec ?= openssl.spec
outdir ?= .

srpm:
	# Install spectool and rpmbuild, if they are not yet present
	command -v spectool || dnf install -y rpmdevtools
	command -v fedpkg || dnf install -y fedpkg
	# Download source tarball
	cd "$$(dirname "$(spec)")" && spectool -g "$$(basename "$(spec)")"
	# Then build srpm
	cd "$$(dirname "$(spec)")" && fedpkg --release rawhide srpm
	# Then, move it to the output directory, if it is defined
	if [ -d "$(outdir)" ] && [ "$$(readlink -f "$$(dirname "$(spec)")")" != "$$(readlink -f "$(outdir)")" ]; then \
		cd "$$(dirname "$(spec)")" && mv openssl-*.src.rpm "$(outdir)"; \
	fi
