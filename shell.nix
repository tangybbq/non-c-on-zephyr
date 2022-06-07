# Basic configuration for Rust development.
{ pkgs ? import <nixos> {} }:
let
  pp = pkgs.python3.pkgs;
  imgtool = pp.buildPythonPackage rec {
    version = "1.7.2";
    pname = "imgtool";

    src = pp.fetchPypi {
      inherit pname version;
      sha256 = "0vpdks8fg7dsjjb48xj18r70i95snq4z6j3m2p28lf8yyvrq953r";
    };

    propagatedBuildInputs = with pp; [
      cbor
      click
      intelhex
      cryptography
    ];
    doCheck = false;
    pythonImportsCheck = [
      "imgtool"
    ];
  };

  # Need an older version of pyyaml.
  pyyaml = pp.pyyaml.overridePythonAttrs (oldAttrs: rec {
    name = "${oldAttrs.pname}-${version}";
    version = "5.4.1";
    src = pkgs.fetchFromGitHub {
      owner = "yaml";
      repo = "pyyaml";
      rev = version;
      sha256 = "sha256-VUqnlOF/8zSOqh6JoEYOsfQ0P4g+eYqxyFTywgCS7gM=";
    };
    checkPhase = ''
      runHook preCheck
      PYTHONPATH="tests/lib3:$PYTHONPATH" ${pkgs.python3.interpreter} -m test_all
      runHook postCheck
    '';
  });

  python-packages = pkgs.python3.withPackages(p: with p; [
    autopep8
    pyelftools
    # pyyaml
    pykwalify
    canopen
    packaging
    progress
    psutil
    anytree
    intelhex
    west
    imgtool
    # doorstop

    cryptography
    intelhex
    click
    cbor

    # For mcuboot CI
    toml

    # For twister
    tabulate
    ply

    # For TFM
    pyasn1
    graphviz
    #imgtool
    jinja2

    requests
    beautifulsoup4

    # Github tools
    # github-to-sqlite

    # These are here because pip stupidly keeps trying to install
    # these in /nix/store.
    wcwidth
    sortedcontainers

    # For the unpackaged things.
    # pip setuptools
  ]);

  # Build the Zephyr SDK as a nix package.
  new-zephyr-sdk-pkg = { stdenv, fetchurl, which, python38, wget,
    file, cmake, libusb, autoPatchelfHook }:
  let
    version = "0.14.1";
    arch = "arm";
    sdk = fetchurl {
      url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/zephyr-sdk-${version}_linux-x86_64_minimal.tar.gz";
      hash = "sha256:1lrq8pf2awd9gh9qr06pzzkd0v37hkx093h9b3n0x9hall4np5h5";
    };
    toolchain = fetchurl {
      url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/toolchain_linux-x86_64_arm-zephyr-eabi.tar.gz";
      hash = "sha256:15s0yymdya3p83w0vhv5alrx0nw9476xjcy6wrdk9ghkdqzxs20p";
    };
  in
  stdenv.mkDerivation {
    name = "zephyr-sdk";
    inherit version;
    srcs = [ sdk toolchain ];
    srcRoot = ".";
    nativeBuildInputs = [
      which
      wget
      file
      python38
      autoPatchelfHook
      cmake
      libusb
    ];
    phases = [ "installPhase" "fixupPhase" ];
    installPhase = ''
      runHook preInstall
      echo out=$out
      mkdir -p $out
      set $srcs
      tar -xf $1 -C $out --strip-components=1
      tar -xf $2 -C $out
      (cd $out; bash ./setup.sh -h)
      rm $out/zephyr-sdk-x86_64-hosttools-standalone-0.9.sh
      runHook postInstall
    '';
  };
  zephyr-sdk = pkgs.callPackage new-zephyr-sdk-pkg {};

  packages = with pkgs; [
    # Tools for building the languages we are using
    clang
    # cargo
    gnat
    zig
    zls
    rustup

    # Dependencies of the Zephyr build system.
    (python-packages)
    cmake
    ninja
    gperf
    python3
    ccache
    dtc
    gmp.dev

    zephyr-sdk
  ];
in
pkgs.mkShell {
  nativeBuildInputs = packages;

  # For Zephyr work, we need to initialize some environment variables,
  # and then invoke the zephyr setup script.
  shellHook = ''
    export ZEPHYR_SDK_INSTALL_DIR=${zephyr-sdk}
    # export LD_LIBRARY_PATH=${pkgs.libusb}/lib
    # export PATH=~/go/bin:$PATH
    export PATH=$PATH:${zephyr-sdk}/arm-zephyr-eabi/bin
    # export PYTHONPATH="${python-packages}/lib/python3.9/site-packages:$PYTHONPATH"
    # export QEMU_BIN_PATH="$ {qemu-tip}/bin"
    source ~/linaro/zep/zephyr/zephyr-env.sh
    # source ~/linaro/zep/.venv/bin/activate
    # unset PS1
  '';
}
