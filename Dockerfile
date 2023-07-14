FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Set locale for UTF-8 encoding
ENV LANG=C.UTF-8

# Get the basic stuff
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
    sudo

# Create ubuntu user with sudo privileges
RUN useradd -ms /bin/bash ubuntu && \
    usermod -aG sudo ubuntu
# Disable sudo password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set as default user
USER ubuntu


# Install hyperfine
WORKDIR /home/ubuntu
RUN sudo apt-get install -y wget
RUN wget https://github.com/sharkdp/hyperfine/releases/download/v1.15.0/hyperfine_1.15.0_amd64.deb
RUN sudo dpkg -i hyperfine_1.15.0_amd64.deb

# Configure tzdata
RUN echo 'tzdata tzdata/Areas select Europe' | sudo debconf-set-selections
RUN echo 'tzdata tzdata/Zones/Europe select London' | sudo debconf-set-selections
RUN sudo apt-get install -qq --no-install-recommends tzdata

# Install tools for running, viewing and editing benchmarks
RUN sudo apt-get install -y make csvkit vim


# Install languages

# Install sbt
RUN sudo apt-get install apt-transport-https curl gnupg -yqq
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
RUN curl -sSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
RUN sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
RUN sudo apt-get update
RUN sudo apt-get install -y sbt

# Install Effekt
WORKDIR /home/ubuntu
RUN sudo apt-get install -y git default-jre npm
RUN git clone https://github.com/effekt-lang/effekt.git
WORKDIR /home/ubuntu/effekt
RUN git submodule set-url kiama https://github.com/effekt-lang/kiama.git
RUN git submodule update --init --recursive
RUN git checkout 72f0064f105d79a44e4593c63cfc9bebd84babf9
RUN sudo sbt install


# Install MLton
WORKDIR /home/ubuntu
#RUN sudo apt install -y curl
RUN sudo apt install -y libgmp-dev
RUN curl -sSL https://github.com/MLton/mlton/releases/download/on-20210117-release/mlton-20210117-1.amd64-linux-glibc2.31.tgz --output mlton.tgz
RUN tar -xzf mlton.tgz
WORKDIR /home/ubuntu/mlton-20210117-1.amd64-linux-glibc2.31
RUN sudo make install


# Install opam
#RUN sudo apt-get install -y wget git curl make
RUN sudo apt-get install -y gcc m4 unzip bubblewrap bzip2
RUN curl -sSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh > /tmp/install.sh
RUN ["/bin/bash", "-c", "sudo /bin/bash /tmp/install.sh <<< /usr/local/bin"]

RUN opam init -y --disable-sandboxing --bare
RUN echo "test -r /home/ubuntu/.opam/opam-init/init.sh && . /home/ubuntu/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true" >> /home/ubuntu/.profile


# Install Multicore OCaml
RUN opam switch create -y 4.12.0+domains+effects
RUN eval $(opam env)

RUN opam install dune


# Install OCaml
RUN opam switch create -y 4.12.0
RUN eval $(opam env)

RUN opam install dune

# Install Eff
WORKDIR /home/ubuntu
RUN git clone https://github.com/matijapretnar/eff.git
WORKDIR /home/ubuntu/eff
RUN git checkout c27ffee3ddaaf6de383328d90750311508512ba6

RUN opam install . -y
RUN opam exec -- dune build src/eff/

ENV PATH="/home/ubuntu/eff:${PATH}"


# Install Koka
WORKDIR /home/ubuntu
#RUN sudo apt install -y curl
RUN curl -sSL https://github.com/koka-lang/koka/releases/download/v2.4.0/install.sh | sudo sh


# Enable syntax highlighting for Effekt in vim
COPY --chown=ubuntu:ubuntu .vim /home/ubuntu/.vim

# Copy benchmark programs
COPY --chown=ubuntu:ubuntu benchmark-programs /home/ubuntu/benchmark-programs


# Final steps
WORKDIR /home/ubuntu/benchmark-programs
ENV DEBIAN_FRONTEND teletype
CMD ["/bin/bash"]
