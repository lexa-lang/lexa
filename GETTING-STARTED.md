## Getting Started

The artifact will likely not work on arm-based architechtures like Apple's M1 and M2.
It has been tested on x86_64 with linux.

### Kick-the-tires
Clone the artifact repository

```
git clone https://github.com/ps-tuebingen/oopsla-2023-liftinference-artifact.git
```

Change into the correct directory

```
cd oopsla-2023-liftinference-artifact
```

Make sure that the Docker service is running.
Build the docker image (note the period)

```
docker build -t liftinf-bench-image .
```

This will download and install the necessary languages, which will take roughly 15 minutes (depending on your connection and computer power).
It will take about 5GB of disk space.

Now start a container from the Docker image with the following command:

```
docker run -itd --init --name liftinf-bench-container liftinf-bench-image
```

The container should now show up when running

```
docker ps
```

#### Quick test
For a quick check that compilation and execution of all benchmark programs works properly for all languages, run

```
docker exec -it liftinf-bench-container bash -c "make test"
```

#### Running the benchmarks
To actually conduct the benchmarks, run

```
docker exec -it liftinf-bench-container bash -c "make && make show"
```

This will again take roughly 15 minutes.
In the end, this will print a somewhat prettified version of the results in Markdown-style tables.
The latter are available inside the container in the file `/home/ubuntu/benchmark-programs/results.md` and can also be copied out of the container with

```
docker cp liftinf-bench-container:/home/ubuntu/benchmark-programs/results.md /path/to/destination
```

The raw results are also available inside the container in the files `/home/ubuntu/benchmark-programs/LANG_results.csv` where `LANG` is one of `eff`, `effekt`, `koka`, `ocaml`, `sml`.

#### Entering the container
As an alternative (or for further inspection), the container can be entered with

```
docker exec -it liftinf-bench-container bash
```

This will start a shell in the `/home/ubuntu/benchmark-programs` directory.
From there the above make-commands can be run and the results will end up in this directory.

#### Cleanup
Run the following commands (after `exit`ing the interactive session) to remove the docker container and image.

```
docker rm -f liftinf-bench-container
docker image rm -f liftinf-bench-image
```

Note that this does not remove the Ubuntu base-image, as it may be shared with other images.
If you want to remove that one, too, run

```
docker image rm -f ubuntu:22.04
```
