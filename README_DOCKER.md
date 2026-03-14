# Run mini-swe-agent via Docker

To build and run `mini-swe-agent` inside a Docker container, follow these steps:

### 1. Build the Docker Image

Run the following command from the repository root:

```bash
docker build -t mini-swe-agent-local .
```

### 2. Run the Container

Once built, you can run the `mini` CLI interactively:

```bash
docker run -it --rm \
    -v ~/.config/mini-swe-agent:/root/.config/mini-swe-agent \
    -v ~/.cache/mini-swe-agent:/root/.cache/mini-swe-agent \
    mini-swe-agent-local
```

### Note on Docker-in-Docker

If you intend for the `mini` agent to use its `DockerEnvironment` to execute commands, you must modify the `Dockerfile` to also install the `docker` CLI client and ensure you mount `/var/run/docker.sock:/var/run/docker.sock` when running the container.
