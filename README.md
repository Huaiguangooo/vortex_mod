# Vortex GPGPU

Vortex is a full-stack open-source RISC-V GPGPU.

## Update

- add VX_socket_top which allows sv2v to generate project.v at socket level.

### Install development tools
1. Install the following dependencies:

   ```
   sudo apt-get install build-essential zlib1g-dev libtinfo-dev libncurses5 uuid-dev libboost-serialization-dev libpng-dev libhwloc-dev
   ```

2. Upgrade GCC to 11:

   ```
   sudo apt-get install gcc-11 g++-11
   ```

   Multiple gcc versions on Ubuntu can be managed with update-alternatives, e.g.:

   ```
   sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9
   sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9
   sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11
   sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11
   ```

3. Download the Vortex codebase:

   ```
   git clone --depth=1 --recursive https://github.com/Huaiguangooo/vortex_mod.git
   ```
4. Build Vortex

   ```
   $ cd vortex
   $ mkdir -p build
   $ cd build
   $ ../configure --xlen=32 --tooldir=$HOME/tools
   $ ./ci/toolchain_install.sh --all
   $ source ./ci/toolchain_env.sh
   $ make -s
   ```
5. Get project.v of VX_socket_top
   ```
   $ cd build/hw/syn/yosys
   $ make
   ```