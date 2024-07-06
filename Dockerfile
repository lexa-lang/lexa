FROM nixos/nix

WORKDIR /WorkDir
COPY ./flake.nix ./flake.lock .
COPY ./nix ./nix
RUN nix --extra-experimental-features "nix-command flakes" develop -j4 --cores 8
RUN nix --extra-experimental-features "nix-command flakes" develop --command bash -c "opam init --disable-sandboxing && eval $(opam env) && opam switch create -y 4.12.0+domains+effects"

COPY lib lib
COPY bin bin
COPY stacktrek stacktrek
COPY test test
COPY racket-artifact racket-artifact
COPY benchmark-programs benchmark-programs
COPY artifact_eval artifact_eval
COPY nix nix
COPY artifact_eval/README README
COPY dune-project .

RUN echo -e '#!/usr/bin/env bash\n\
nix --extra-experimental-features "nix-command flakes" develop' > /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]