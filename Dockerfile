FROM nixos/nix

WORKDIR /WorkDir
COPY ./flake.nix ./flake.lock .
COPY ./nix ./nix
RUN nix --extra-experimental-features "nix-command flakes" build .#clang_18_preserve_none --cores 20
RUN nix --extra-experimental-features "nix-command flakes" build nixpkgs#texliveSmall
RUN nix --extra-experimental-features "nix-command flakes" develop -j5 --cores 4
RUN nix --extra-experimental-features "nix-command flakes" develop --command bash -c "opam init --disable-sandboxing && eval $(opam env) && opam switch create -y 5.3.0+trunk && opam install -y multicont"
RUN nix-env -iA nixpkgs.util-linux nixpkgs.time

COPY src src
COPY test test
COPY benchmarks benchmarks
COPY casestudies casestudies
COPY scripts scripts
COPY nix nix
COPY README.md README.md
COPY lexa lexa
COPY LICENSE LICENSE
COPY dune-project .

RUN echo -e '#!/usr/bin/env bash\n\
nix --extra-experimental-features "nix-command flakes" develop' > /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]