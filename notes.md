# Host changes

Bootstrap installs Debian packages: docker.io if Docker is absent, iptables, iproute2, Python 3, ca-certificates, curl, jq, git, make and dnsutils. If Compose is absent it installs the checksum-verified v2.29.7 binary at `/usr/local/lib/docker/cli-plugins/docker-compose`.

It enables Docker, writes ignored `.lab.env`, maintains a marked `/etc/hosts` block and adds `169.254.169.254/32` to loopback if absent. It creates lab-owned `VIBESHOP-IN` and `VIBESHOP-FWD` chains and links them from INPUT and DOCKER-USER, scoped to the VM IP and lab ports. It never flushes DOCKER-USER. A marker records ownership of an alias created by the lab.

It builds the app image, pulls supporting images, creates the Compose network and `vibeshop_pgdata`/`vibeshop_miniodata` volumes, loads fixtures and starts services. Bootstrap reseeds on every run. `make clean` removes the lab containers/volumes, its firewall links/chains and the marked host block, plus the alias only if this checkout created it. It retains installed packages and the checkout. The runtime is one checkout per VM.

RFC1918 networks are allowed clients by default. A non-RFC1918 tunnel exit requires `--client-net`. These rules isolate lab services from other sources but do not turn an intentionally vulnerable app into a production service.
