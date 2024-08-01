{
	rust,
	lib,
	pkgs,
	rustPlatform,
	rustToolchain,
	servo-src,
	servo-crown,
	servo-hashes,
}:

rustPlatform.buildRustPackage rec {
	name = "servo";
	version = "main";

	patches = [
		./servo-180.diff
	];

	nativeBuildInputs = with pkgs; [
		servo-crown
		pkg-config
		python3
		python3Packages.mako
	];

	buildInputs = with pkgs; [
		xorg.libX11
		xorg.libxcb
		fontconfig freetype
		llvmPackages.libunwind
		
		gst_all_1.gstreamer
		gst_all_1.gst-plugins-base
		gst_all_1.gst-plugins-good
		gst_all_1.gst-plugins-bad
		gst_all_1.gst-plugins-ugly

		eudev
	];

	src = servo-src;

	cargoLock = {
		lockFile = "${servo-src}/Cargo.lock";

		outputHashes = servo-hashes;
	};

	buildAndTestSubdir = "ports/servoshell";

	meta = {
		description = "";
		homepage = "https://github.com/servo/servo";
		license = lib.licenses.mpl20;
		maintainers = [];
	};
}

