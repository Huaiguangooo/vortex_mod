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