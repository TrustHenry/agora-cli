# Agora CLI

Comand line interface for BOA CoinNet

# Building on POSIX

You need a recent D compiler, and `dub`.
On Linux, we recommend you install gcc-9 so that you can also get `gdc`.
On OSX, the latest `llvm` package should do the job.

```console
# Install the latest DMD compiler
curl https://dlang.org/install.sh | bash -s
# Clone this repository
git clone https://github.com/bpfkorea/agora-cli.git
# Use the git root as working directory
cd agora-cli/
# Initialize and update the list of submodules
git submodule update --init
# Build the application
dub build --skip-registry=all
# Build & run the tests
dub test --skip-registry=all
```
