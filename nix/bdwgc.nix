{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
# doc: https://github.com/ivmai/bdwgc/blob/v8.2.6/doc/README.macros (LARGE_CONFIG)
, enableLargeConfig ? false
, enableMmap ? true
, enableStatic ? false
, nixVersions
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "boehm-gc";
  version = "latest";

  src = fetchFromGitHub {
    owner = "ivmai";
    repo = "bdwgc";
    rev = "02c9d85a1740a301d0e0dd35b62ef3621a65ef25";
    hash = "sha256-PgjNtiJ8EZKgZo/mRtF7ppqfJafKGm4AzMy98X6DrA4=";
  };

  patches = [ ./bdwgc.patch ];

  outputs = [ "out" "dev" "doc" ];
  separateDebugInfo = stdenv.isLinux && stdenv.hostPlatform.libc != "musl";

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    "--with-libatomic-ops=none"
  ]
  ++ lib.optional enableStatic "--enable-static"
  ++ lib.optional enableMmap "--enable-mmap"
  ++ lib.optional enableLargeConfig "--enable-large-config";

  makeFlags =
    [
      "CFLAGS_EXTRA=-DALWAYS_SMALL_CLEAR_STACK"
    ];

  doCheck = false;

  enableParallelBuilding = true;

  passthru.tests = nixVersions;

  meta = {
    homepage = "https://hboehm.info/gc/";
    description = "The Boehm-Demers-Weiser conservative garbage collector for C and C++";
    longDescription = ''
      The Boehm-Demers-Weiser conservative garbage collector can be used as a
      garbage collecting replacement for C malloc or C++ new.  It allows you
      to allocate memory basically as you normally would, without explicitly
      deallocating memory that is no longer useful.  The collector
      automatically recycles memory when it determines that it can no longer
      be otherwise accessed.

      The collector is also used by a number of programming language
      implementations that either use C as intermediate code, want to
      facilitate easier interoperation with C libraries, or just prefer the
      simple collector interface.

      Alternatively, the garbage collector may be used as a leak detector for
      C or C++ programs, though that is not its primary goal.
    '';
    changelog = "https://github.com/ivmai/bdwgc/blob/v${finalAttrs.version}/ChangeLog";
    license = "https://hboehm.info/gc/license.txt"; # non-copyleft, X11-style license
    maintainers = with lib.maintainers; [ AndersonTorres ];
    platforms = lib.platforms.all;
  };
})