# VibeShop

A deliberately vulnerable storefront for a disposable Debian 12 lab. It uses fake users, fake identity documents, a stub payment function and a mock metadata endpoint. No real cloud, payment or OAuth account is needed.

## Requirements

- Debian 12 amd64 VM, sudo access, 4 GB RAM recommended, at least 10 GiB free disk.
- A LAN IPv4 address reachable from your browser computer.
- Outbound access to Debian mirrors, GitHub, GHCR, Docker Hub and npm during setup.
- An isolated lab network. The app deliberately serves vulnerable endpoints, fixture credentials and Git history.

The default example is `10.3.10.137`. Substitute the VM's real address in the bootstrap command and client hosts entry. Setup writes `.lab.env`; tracked source files keep their original contents.

## Clone and start

```bash
sudo apt-get update
sudo apt-get install -y git sudo
git clone https://github.com/mattclemons/vibeshop.git
cd vibeshop
./bootstrap.sh --plan
./bootstrap.sh --local --host-ip 10.3.10.137
```

Run those commands on the Debian VM, using an account allowed to use sudo. If logged in as root, omit `sudo` from the first two commands. The bootstrap script installs Docker if absent, installs a verified Compose v2.29.7 binary if Compose is absent, sets up lab networking, builds and starts the containers, loads fixtures and runs smoke checks. It uses sudo without adding your user to the Docker group.

Setup prints `Ready` only after those readiness checks pass. It does not assert that twenty exploit/fix modules passed.

## Browser computer

Add this entry to `/etc/hosts` on macOS/Linux, or `C:\Windows\System32\drivers\etc\hosts` on Windows, using administrator privileges:

```text
10.3.10.137 vibeshop.test attacker.test legacy.vibeshop.test evil.test
```

Open <http://vibeshop.test:8080/>. The bootstrap also adds these names on the VM. Use the names for hostname-dependent exercises.

| Service | URL |
| --- | --- |
| Shop | http://vibeshop.test:8080/ |
| Admin | http://vibeshop.test:8080/admin |
| Attacker fixtures | http://attacker.test:8081/ |
| Fake sign-in fixture | http://evil.test/phish |
| MailHog | http://10.3.10.137:8025/ |
| Upload index | http://10.3.10.137:9000/uploads/index.txt |
| MinIO console | http://10.3.10.137:9001/ |

| Account | Password |
| --- | --- |
| maya@vibeshop.test | sunshine |
| admin@vibeshop.test | admin123 |
| MinIO root user `vibeshop` | vibeshop |

## Operations

```bash
make ps             # container status
make smoke          # initial fixture readiness checks
make logs           # recent service logs
make down           # stop containers, retain data and lab networking
make up             # reapply networking and start, including after a VM reboot
make reset          # discard database rows and reload fixtures
make clean          # remove containers/volumes and this lab's networking
```

`make smoke` expects the initial eight users and forty products. After adding users, run `make reset` to restore those counts. `make clean` leaves installed packages and the checkout in place; remove the hosts entry from your browser computer separately. Other Docker projects and firewall chains are not flushed. Use only one VibeShop checkout per VM because the Compose project and firewall chain names are shared.

To allow clients arriving through a non-RFC1918 tunnel exit, set the real client network explicitly:

```bash
./bootstrap.sh --local --host-ip 10.3.10.137 --client-net 198.51.100.0/24
```

`198.51.100.0/24` is a documentation example, not an address to copy blindly. The lab allows RFC1918 source ranges by default. Host networking and the link-local alias require native Linux, so Docker Desktop is not the runtime target.

## Optional deployment over SSH

From a macOS/Linux checkout with Bash, SSH and tar:

```bash
./bootstrap.sh --target maint@10.3.10.137 --host-ip 10.3.10.137
```

This copies the checkout, including `.git`, to a fresh directory under the login user's `~/vibeshop-labs` on the VM. Existing directories are not replaced. Subsequent operations should run in the printed remote checkout. A normal clone on the VM remains the simplest reader workflow.

## What is included

The storefront, routes, libraries, Compose stack, fixtures, lockfile, bootstrap and operational scripts are included. The upstream post's twenty `exploits/NN`, `tests/NN`, `modules/NN` directories and `fix/NN` branches were not supplied. Neither is the original attacking companion post. See `RELEASE-CHECKLIST.md` before advertising those as included.

`bash scripts/audit.sh` runs core smoke checks. `bash scripts/audit.sh --modules` fails explicitly if original module artifacts or local fix branches are missing. It never substitutes an empty passing test. A normal clone creates only the default local branch; if original fix branches are later published, create local branches from the corresponding remote refs before module auditing.

## Version and image choices

Next.js is deliberately pinned to `15.2.2` to retain CVE-2025-29927. Version `15.2.3` patched that particular middleware bypass. This lab pin is not production guidance. The lockfile is committed so readers use `npm ci` during the Docker build.

MinIO server and client use pinned Teable GHCR mirror tags because upstream Docker Hub availability changed. Their publisher documents those images in [its image guide](https://github.com/teableio/teable-deployment/blob/main/images/README.md). To use another registry, export `MINIO_IMAGE` and `MINIO_MC_IMAGE` before invoking the Compose wrapper, or change the defaults in `compose.yaml`. First-run pulls must still be tested on the target VM.

## Troubleshooting

- `make logs` and `bash scripts/compose.sh config` show runtime/configuration failures.
- Port conflicts: use a fresh VM; ports 80, 8080, 8081, 3000, 5432, 8025, 9000 and 9001 are needed.
- Sudo errors: run with a sudo-capable account, or root.
- An npm/registry download failure is a dependency/network failure, not a passing readiness check.
- If changing the VM IP, run `make clean` before rerunning bootstrap, then update the browser computer's hosts entry.
- A shallow clone omits history required by the Git-history exercise. Use a normal clone and preserve the fake-key rotation commits if created by the maintainer generator.
- For an ordinary application update, run `make up`; use `make reset` when the schema or seed changes. Bootstrap reseeds the database on every run.

