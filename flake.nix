{
	# TODO: support systems other than x86_64-linux
	# See https://github.com/NixOS/nix/issues/5663
	# DO NOT HARD CODE SUPPORTED SYSTEMS

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/master";
		# TODO: use rust 1.80 without fenix, see https://github.com/NixOS/nixpkgs/issues/331429
		fenix = {
			url = "github:nix-community/fenix";
			inputs.nixpkgs.follows = "/nixpkgs";
		};
	};

	nixConfig = {
		extra-substituters = [
			"https://nix-community.cachix.org"
		];
		extra-trusted-public-keys = [
			"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
		];
	};

	outputs = { nixpkgs, fenix, ... }@inputs:
	let
		system = "x86_64-linux";

		rustToolchain = (fenix.packages.${system}.stable.withComponents [
			"rust-src"
			"rustc"
			"rustfmt"
			"cargo"
			"clippy"
			"llvm-tools-preview"
			"rustc-dev"
		]);

		pkgs = import nixpkgs {
			inherit system;
			overlays = [
				fenix.overlays.default
			];
		};
		
		# We can't use flake inputs because there is no 'patches' support
		# See https://github.com/NixOS/nix/issues/3920
		servo-src = builtins.fetchTree {
			type = "tarball";
			url = "https://github.com/servo/servo/archive/b4e1ec441254daf2df75f84347480a9afb9f4779.tar.gz";
			narHash = "sha256-/DMNnNQ0ksSeYg58K1mVQC0Xiy8QF86nHOBKkOjgtoI=";
		};

		servo-hashes = {
			"d3d12-22.0.0" = "sha256-Dku6WVsrHE8IQD5SWMN48aha1cP5eZb3eMw5NnOVXsY="; 
			"derive_common-0.0.1" = "sha256-JxCCfaU6LWJfmyPeaxtA8eWng0sMlrEDvDebKsfUyV0=";
			"fontsan-0.5.2" = "sha256-4id66xxQ8iu0+OvJKH77WYPUE0eoVa9oUHmr6lRFPa8=";
			"gilrs-0.10.6" = "sha256-RIfowFShWTPqgVWliK8Fc4cJw0YKITLvmexmTC0SwQk=";
			"libz-sys-1.1.18" = "sha256-tvi+Ot5EX5NfszbKlY+UK0N/Hnd6XdoMf1tT0LVxyz4=";
			"mozjs-0.14.1" = "sha256-7P72FTCzIW0GgsGyDnTGmidzJDplwIXEhy766bWLKWk=";
			"peek-poke-0.3.0" = "sha256-WaRzBAgKlKMiWIb6D2nOHxVnFnobhfIAfnsVyOPqP3Q=";
			"servo-media-0.1.0" = "sha256-nsnveORE1YEek+wrkRIwfPJoF/cd436SxlS9EgB5G50=";
			"signpost-0.1.0" = "sha256-xRVXwW3Gynace9Yk5r1q7xA60yy6xhC5wLAyMJ6rPRs=";
			"webxr-0.0.1" = "sha256-83+Dq5GtBSC4sUgbS5MFPwq/5yBx2AKzHjInfRtCfXk=";
		};
	in {
		packages.${system} = rec {
			servo-crown = pkgs.callPackage ./crown.nix {
				rustPlatform = (pkgs.makeRustPlatform {
					cargo = rustToolchain;
					rustc = rustToolchain;
				});
				inherit servo-src servo-hashes rustToolchain;
			};
			servo-shell = pkgs.callPackage ./servo.nix {
				rustPlatform = (pkgs.makeRustPlatform {
					cargo = rustToolchain;
					rustc = rustToolchain;
				});
				inherit servo-src servo-hashes rustToolchain servo-crown;
			};
		};
	};
}
