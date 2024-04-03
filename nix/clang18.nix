{ wrapCC, stdenv, python38, cmake, ninja, fetchFromGitHub }:

wrapCC ( stdenv.mkDerivation rec {
    pname = "llvm-project";
    version = "c166a43";

    src = fetchFromGitHub {
    owner = "llvm";
    repo = pname;
    rev = "c166a43c6e6157b1309ea757324cc0a71c078e66";
    sha256 = "sha256-iveg9P2V7WQIQ/eL63vnYBFsR7Ob8a2Vahv8MXm4nyQ="; 
    };

    patchFile = ./preserve_none_no_save_rbp.patch;

    buildInputs = [ python38 ];
    nativeBuildInputs = [ cmake ninja ];
    dontUseCmakeConfigure=true;
    dontStrip=true;

    patchPhase = ''
    patch -p1 -i ${patchFile}
    '';

    buildPhase = ''
    cmake -S llvm -B build -G Ninja \
        -DLLVM_ENABLE_PROJECTS="clang" \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_TARGETS_TO_BUILD=X86
    ninja -C build
    '';

    installPhase = ''
    mkdir -p $out/bin
    cp build/bin/clang $out/bin
    cp build/bin/opt $out/bin
    cp build/bin/clang-format $out/bin
    cp -r build/lib $out/lib
    '';

    passthru.isClang = true;  
})