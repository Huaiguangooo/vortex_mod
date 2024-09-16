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
   $ cd vortex_mod
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
6. An error will be raised
   ```
    Generating RTLIL representation for module `$paramod$02ebeaaba3aa0519d7f252fbf0c762a441a16060\VX_fpu_sqrt'.
    project.v:1323: ERROR: Can't resolve task name `\dpi_fsqrt'.
    make: *** [Makefile:87: build] Error 1
   ```

### How FPU_FPNEW is not instantiated

Default defined macros.
```
`define NDEBUG
`define SYNTHESIS
`define YOSYS
`define XLEN_32
`define NUM_CLUSTERS 1
`define NUM_CORES 1
```

In `hw/rtl/VX_config.vh`, we have:
```
`ifdef XLEN_64
`ifndef FPU_DSP
`ifndef EXT_D_DISABLE
`define EXT_D_ENABLE
`endif
`endif
`endif
```

Here `EXT_D_ENABLE` is not defined.

```
`ifdef EXT_D_ENABLE
`define FLEN_64
`else
`define FLEN_32
`endif
```

Here `FLEN_64` is defined.

```
`ifndef FPU_FPNEW
`ifndef FPU_DSP
`ifndef FPU_DPI
`ifndef SYNTHESIS
`ifndef DPI_DISABLE
`define FPU_DPI
`else
`define FPU_DSP
`endif
`else
`define FPU_DSP
`endif
`endif
`endif
`endif
```

Here **FPU_DSP** is defined.

Herefore, in `./hw/rtl/core/VX_fpu_unit.sv`, we have this.
```
    `ifdef FPU_DPI

        VX_fpu_dpi #(
            .NUM_LANES  (NUM_LANES),
            .TAG_WIDTH  (TAG_WIDTH),
            .OUT_BUF    (PARTIAL_BW ? 1 : 3)
        ) fpu_dpi (
            .clk        (clk),
            .reset      (block_reset),

            .valid_in   (fpu_req_valid),
            .mask_in    (per_block_execute_if[block_idx].data.tmask),
            .op_type    (per_block_execute_if[block_idx].data.op_type),
            .fmt        (fpu_fmt),
            .frm        (fpu_req_frm),
            .dataa      (per_block_execute_if[block_idx].data.rs1_data),
            .datab      (per_block_execute_if[block_idx].data.rs2_data),
            .datac      (per_block_execute_if[block_idx].data.rs3_data),
            .tag_in     (fpu_req_tag),
            .ready_in   (fpu_req_ready),

            .valid_out  (fpu_rsp_valid),
            .result     (fpu_rsp_result),
            .has_fflags (fpu_rsp_has_fflags),
            .fflags     (fpu_rsp_fflags),
            .tag_out    (fpu_rsp_tag),
            .ready_out  (fpu_rsp_ready)
        );

    `elsif FPU_FPNEW

        VX_fpu_fpnew #(
            .NUM_LANES  (NUM_LANES),
            .TAG_WIDTH  (TAG_WIDTH),
            .OUT_BUF    (PARTIAL_BW ? 1 : 3)
        ) fpu_fpnew (
            .clk        (clk),
            .reset      (block_reset),

            .valid_in   (fpu_req_valid),
            .mask_in    (per_block_execute_if[block_idx].data.tmask),
            .op_type    (per_block_execute_if[block_idx].data.op_type),
            .fmt        (fpu_fmt),
            .frm        (fpu_req_frm),
            .dataa      (per_block_execute_if[block_idx].data.rs1_data),
            .datab      (per_block_execute_if[block_idx].data.rs2_data),
            .datac      (per_block_execute_if[block_idx].data.rs3_data),
            .tag_in     (fpu_req_tag),
            .ready_in   (fpu_req_ready),

            .valid_out  (fpu_rsp_valid),
            .result     (fpu_rsp_result),
            .has_fflags (fpu_rsp_has_fflags),
            .fflags     (fpu_rsp_fflags),
            .tag_out    (fpu_rsp_tag),
            .ready_out  (fpu_rsp_ready)
        );

    `elsif FPU_DSP

        VX_fpu_dsp #(
            .NUM_LANES  (NUM_LANES),
            .TAG_WIDTH  (TAG_WIDTH),
            .OUT_BUF    (PARTIAL_BW ? 1 : 3)
        ) fpu_dsp (
            .clk        (clk),
            .reset      (block_reset),

            .valid_in   (fpu_req_valid),
            .mask_in    (per_block_execute_if[block_idx].data.tmask),
            .op_type    (per_block_execute_if[block_idx].data.op_type),
            .fmt        (fpu_fmt),
            .frm        (fpu_req_frm),
            .dataa      (per_block_execute_if[block_idx].data.rs1_data),
            .datab      (per_block_execute_if[block_idx].data.rs2_data),
            .datac      (per_block_execute_if[block_idx].data.rs3_data),
            .tag_in     (fpu_req_tag),
            .ready_in   (fpu_req_ready),

            .valid_out  (fpu_rsp_valid),
            .result     (fpu_rsp_result),
            .has_fflags (fpu_rsp_has_fflags),
            .fflags     (fpu_rsp_fflags),
            .tag_out    (fpu_rsp_tag),
            .ready_out  (fpu_rsp_ready)
        );

    `endif
```

Here, because `FPU_DSP` is defined, in `./hw/rtl/fpu/VX_fpu_dsp.sv`, `VX_fpu_sqrt` is instantiated.

In `hw/rtl/fpu/VX_fpu_sqrt.sv`, we have
```
`ifdef QUARTUS

    for (genvar i = 0; i < NUM_PES; ++i) begin
        acl_fsqrt fsqrt (
            .clk    (clk),
            .areset (1'b0),
            .en     (pe_enable),
            .a      (pe_data_in[i]),
            .q      (pe_data_out[i][0 +: 32])
        );
        assign pe_data_out[i][32 +: `FP_FLAGS_BITS] = 'x;
    end

    assign has_fflags = 0;
    assign per_lane_fflags = 'x;
    `UNUSED_VAR (fflags_out)

`elsif VIVADO

    for (genvar i = 0; i < NUM_PES; ++i) begin
        wire tuser;

        xil_fsqrt fsqrt (
            .aclk                (clk),
            .aclken              (pe_enable),
            .s_axis_a_tvalid     (1'b1),
            .s_axis_a_tdata      (pe_data_in[i]),
            `UNUSED_PIN (m_axis_result_tvalid),
            .m_axis_result_tdata (pe_data_out[i][0 +: 32]),
            .m_axis_result_tuser (tuser)
        );
                                                      // NV, DZ, OF, UF, NX
        assign pe_data_out[i][32 +: `FP_FLAGS_BITS] = {tuser, 1'b0, 1'b0, 1'b0, 1'b0};
    end

    assign has_fflags = 1;
    assign per_lane_fflags = fflags_out;

`else

    for (genvar i = 0; i < NUM_PES; ++i) begin
        reg [63:0] r;
        `UNUSED_VAR (r)
        fflags_t f;

        always @(*) begin
            dpi_fsqrt (
                pe_enable,
                int'(0),
                {32'hffffffff, pe_data_in[i]},
                frm,
                r,
                f
            );
        end

        VX_shift_register #(
            .DATAW  (32 + $bits(fflags_t)),
            .DEPTH  (`LATENCY_FSQRT)
        ) shift_req_dpi (
            .clk      (clk),
            `UNUSED_PIN (reset),
            .enable   (pe_enable),
            .data_in  ({f, r[31:0]}),
            .data_out (pe_data_out[i])
        );
    end

    assign has_fflags = 1;
    assign per_lane_fflags = fflags_out;

`endif
```

Because we don't specify implementation platform, DPI function is called, preventing us from successful synthesis and implementation.

### How to instantiate FPU_FPNEW

We define `XLEN` to be 64 by modifying `./build/common.mk`

```
XLEN ?= 64
```

We define `FPU_FPNEW` in `./hw/rtl/VX_config.vh` at the beginning.

We modify `./build/hw/syn/yosys/Makefile`.
```
# include paths
FPU_INCLUDE = -I$(RTL_DIR)/fpu
# ifneq (,$(findstring FPU_FPNEW,$(CONFIGS)))
# 	FPU_INCLUDE += -J$(THIRD_PARTY_DIR)/fpnew/src/common_cells/include -J$(THIRD_PARTY_DIR)/fpnew/src/common_cells/src -J$(THIRD_PARTY_DIR)/fpnew/src/fpu_div_sqrt_mvp/hdl -J$(THIRD_PARTY_DIR)/fpnew/src
# endif

FPU_INCLUDE += -J$(THIRD_PARTY_DIR)/fpnew/src/common_cells/include -J$(THIRD_PARTY_DIR)/fpnew/src/common_cells/src -J$(THIRD_PARTY_DIR)/fpnew/src/fpu_div_sqrt_mvp/hdl -J$(THIRD_PARTY_DIR)/fpnew/src
FPU_INCLUDE += -I$(THIRD_PARTY_DIR)/fpnew/src/common_cells/include -I$(THIRD_PARTY_DIR)/fpnew/src/common_cells/src -I$(THIRD_PARTY_DIR)/fpnew/src/fpu_div_sqrt_mvp/hdl -I$(THIRD_PARTY_DIR)/fpnew/src

RTL_INCLUDE = -I$(RTL_DIR) -I$(RTL_DIR)/libs -I$(RTL_DIR)/interfaces -I$(RTL_DIR)/core -I$(RTL_DIR)/mem -I$(RTL_DIR)/cache
RTL_INCLUDE += $(FPU_INCLUDE)
```

Then we run `make gen-sources`, which will copy needed files to build_top_module/src and expand MACRO definitions.
This should be enough for further synthesis and implementation.

### How to modify the number of cores, sockets and clusters

In `./hw/rtl/VX_config.vh`, we have the following.
```
`ifndef NUM_CLUSTERS
`define NUM_CLUSTERS 1
`endif

`ifndef NUM_CORES
`define NUM_CORES 1
`endif

`ifndef SOCKET_SIZE
`define SOCKET_SIZE `MIN(4, `NUM_CORES)
`endif
```

In `./hw/rtl/VX_define.vh`, we have the following.
```
`define NUM_SOCKETS     `UP(`NUM_CORES / `SOCKET_SIZE)
```

This is the static definition of hardware parameters.
So one socket has a maximum of four cores.
The `NUM_SOCKETS` parameter is defined by `NUM_CORES` and `SOCKET_SIZE`

In `/build/hw/syn/yosys/Makefile`, we can pass different configurations to add macro definitions.
```
NUM_CORES ?= 1

# cluster configuration
CONFIGS_1c  := -DNUM_CLUSTERS=1 -DNUM_CORES=1
CONFIGS_2c  := -DNUM_CLUSTERS=1 -DNUM_CORES=2
CONFIGS_4c  := -DNUM_CLUSTERS=1 -DNUM_CORES=4  -DL2_ENABLE
CONFIGS_8c	:= -DNUM_CLUSTERS=1 -DNUM_CORES=8  -DL2_ENABLE
CONFIGS_16c	:= -DNUM_CLUSTERS=1 -DNUM_CORES=16 -DL2_ENABLE
CONFIGS_32c := -DNUM_CLUSTERS=2 -DNUM_CORES=16 -DL2_ENABLE
CONFIGS_64c := -DNUM_CLUSTERS=4 -DNUM_CORES=16 -DL2_ENABLE
CONFIGS += $(CONFIGS_$(NUM_CORES)c)
```

By defining the number of clusters and cores, the number of sockets is naturally defined.
For the implementation of an equivalent SM, we use `CONFIGS_4c`.

**So we set `NUM_CORES=4` when invoking `Makefile`**.

```bash
make NUM_CORES=4 gen-sources
```

### How to modify the number of warps and threads.

In `./hw/rtl/VX_config.vh`, we have the following.
```
`ifndef NUM_WARPS
`define NUM_WARPS 4
`endif

`ifndef NUM_THREADS
`define NUM_THREADS 4
`endif

`ifndef NUM_BARRIERS
`define NUM_BARRIERS `UP(`NUM_WARPS/2)
`endif
```
#### Vortex GPGPU Execution Model

Vortex uses the SIMT execution model with a single warp issued per cycle.

- **Threads**
  - Smallest unit of computation
  - Each thread has its own register file (32 int + 32 fp registers)
  - Threads execute in parallel
- **Warps**
  - A logical clster of threads
  - Each thread in a warp execute the same instruction
    - The PC is shared; maintain thread mask for Writeback
  - Warp's execution is time-multiplexed at log steps
    - Ex. warp 0 executes at cycle 0, warp 1 executes at cycle 1

#### NVIDIA A100 Execution Model

* Threads / Warp: 32
* Max Warps / SM: 64 

#### Our modification

So `NUM_THREADS` should be changed to 32, `NUM_WARPS` should be changed to 64.

This affects the pipeline configuration. In `./hw/rtl/VX_config.vh`, we have the following.
```
// Issue width
`ifndef ISSUE_WIDTH
`define ISSUE_WIDTH     `UP(`NUM_WARPS / 8)
`endif

// Number of ALU units
`ifndef NUM_ALU_LANES
`define NUM_ALU_LANES   `NUM_THREADS
`endif
`ifndef NUM_ALU_BLOCKS
`define NUM_ALU_BLOCKS  `ISSUE_WIDTH
`endif

// Number of FPU units
`ifndef NUM_FPU_LANES
`define NUM_FPU_LANES   `NUM_THREADS
`endif
`ifndef NUM_FPU_BLOCKS
`define NUM_FPU_BLOCKS  `ISSUE_WIDTH
`endif
```

Take ALU as an example. After the modification, we have `NUM_ALU_LANES=32` and `NUM_ALU_BLOCKS=8`.

So we add the following to the top of `VX_config.vh`.
```
`define NUM_WARPS 64
`define NUM_THREADS 32
```
### How to replace SRAM

#### Vortex Cache Instantiation Hierarchy

* In `VX_cache_cluster`, `VX_cache_wrap` is instantiated.
    * In `VX_cache_wrap`, `VX_cache` is instantiated.
        * In `VX_cache`, `VX_cache_bank` is instantiated. So each bank is instantiated seperately.
            * In `VX_cache_bank`, `VX_cache_tag`, `VX_cache_data`, `VX_cache_mshr` is instantiated.
                * In `VX_cache_data`, `VX_sp_ram` is instantiated.

So, we use SRAM compiler to generate single-port SRAM macro and replace the content in `VX_sp_ram`.

#### How to replace Socket-level SRAM

In `./hw/rtl/VX_socket.sv`, mainly two SRAMs are instantiated.
```
    VX_cache_cluster #(
        .INSTANCE_ID    ($sformatf("%s-icache", INSTANCE_ID)),
        .NUM_UNITS      (((((((4) < (4)) ? (4) : (4)) / 4) != 0) ? ((((4) < (4)) ? (4) : (4)) / 4) : 1)),
        .NUM_INPUTS     ((((4) < (4)) ? (4) : (4))),
        .TAG_SEL_IDX    (0),
        .CACHE_SIZE     (16384),
        .LINE_SIZE      (ICACHE_LINE_SIZE),
        .NUM_BANKS      (1),
        .NUM_WAYS       (1),
        .WORD_SIZE      (ICACHE_WORD_SIZE),
        .NUM_REQS       (1),
        .CRSQ_SIZE      (2),
        .MSHR_SIZE      (16),
        .MRSQ_SIZE      (0),
        .MREQ_SIZE      (4),
        .TAG_WIDTH      (ICACHE_TAG_WIDTH),
        .UUID_WIDTH     (1),
        .WRITE_ENABLE   (0),
        .NC_ENABLE      (0),
        .CORE_OUT_BUF   (2),
        .MEM_OUT_BUF    (2)
    ) icache (
        .clk            (clk),
        .reset          (icache_reset),
        .core_bus_if    (per_core_icache_bus_if),
        .mem_bus_if     (icache_mem_bus_if)
    );

    VX_cache_cluster #(
        .INSTANCE_ID    ($sformatf("%s-dcache", INSTANCE_ID)),
        .NUM_UNITS      (((((((4) < (4)) ? (4) : (4)) / 4) != 0) ? ((((4) < (4)) ? (4) : (4)) / 4) : 1)),
        .NUM_INPUTS     ((((4) < (4)) ? (4) : (4))),
        .TAG_SEL_IDX    (0),
        .CACHE_SIZE     (16384),
        .LINE_SIZE      (DCACHE_LINE_SIZE),
        .NUM_BANKS      ((((32) < (4)) ? (32) : (4))),
        .NUM_WAYS       (1),
        .WORD_SIZE      (DCACHE_WORD_SIZE),
        .NUM_REQS       (DCACHE_NUM_REQS),
        .CRSQ_SIZE      (2),
        .MSHR_SIZE      (16),
        .MRSQ_SIZE      (0),
        .MREQ_SIZE      (0 ? 16 : 4),
        .TAG_WIDTH      (DCACHE_TAG_WIDTH),
        .UUID_WIDTH     (1),
        .WRITE_ENABLE   (1),
        .WRITEBACK      (0),
        .DIRTY_BYTES    (0),
        .NC_ENABLE      (1),
        .CORE_OUT_BUF   (2),
        .MEM_OUT_BUF    (2)
    ) dcache (
        .clk            (clk),
        .reset          (dcache_reset),
        .core_bus_if    (per_core_dcache_bus_if),
        .mem_bus_if     (dcache_mem_bus_if)
    );
```

So we define two verilog files to replace the functionality of `VX_sp_ram` to represent ICache and DCache.

#### How to replace Core-level SRAM

* In `VX_core`, `VX_lmem_unit` is instantiated.
    * In `VX_lmem_unit`, `VX_local_mem` is instantiated.
        * In `VX_local_mem`, `VX_sp_ram` is instantiated for each separate bank.

Interestingly, I don't see the ICache instantiation.