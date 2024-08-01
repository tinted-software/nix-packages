{
	rust,
	lib,
	stdenv,
	rustPlatform,
	servo-src,
	servo-hashes,
	rustToolchain,
}:

rustPlatform.buildRustPackage rec {
	__contentAddressed = true;

  name = "crown";
  version = "main";

	patches = [
		./servo-180.diff
	];

	buildInputs = [
		rustToolchain
	];

	# We need this so that librustc_driver* and libLLVM.so* can be found 🙃
	fixupPhase = ''
		patchelf \
			--set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
			--set-rpath ${stdenv.cc.cc.lib}/lib:${rustToolchain}/lib:${rustToolchain}/lib/rustlib/${rust.toRustTarget stdenv.buildPlatform}/lib \
			$out/bin/crown || true
	'';

	src = servo-src;

	cargoLock = {
		lockFile = "${servo-src}/Cargo.lock";

		outputHashes = servo-hashes;
	};

	buildAndTestSubdir = "support/crown";

  meta = {
    description = "";
    homepage = "https://github.com/servo/servo";
    license = lib.licenses.mpl20;
    maintainers = [];
  };
}
