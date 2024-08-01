{
	pkgs,
	src,
}: pkgs.stdenv.mkDerivation {
	__contentAddressed = true;

	name = "freenginx";
	version = "mainline";

	inherit src;

	nativeBuildInputs = [
		pkgs.pkgconf
		pkgs.gnumake
	];

	buildInputs = [
		(pkgs.zlib-ng.override {
			withZlibCompat = true;
		})
		pkgs.pcre2
		pkgs.libxcrypt
		pkgs.boringssl
	];

	configurePhase = ''
		./auto/configure \
			--with-cc-opt="-I${pkgs.boringssl.dev}/include" \
			--with-cc-opt="-I${pkgs.boringssl}/lib" \
			--with-threads \
			--with-http_ssl_module \
			--with-http_v2_module \
			--with-http_v3_module \
			--with-http_gzip_static_module \
			--with-stream \
			--with-stream_ssl_module \
			--with-stream_ssl_preread_module \
			--with-pcre-jit \
			--prefix=$out
	'';

	buildPhase = ''
		make -j$(nproc)	
	'';

	installPhase = ''
		make -j$(nproc) install
	'';
}
