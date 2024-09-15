`include "VX_define.vh"

module VX_socket_top import VX_gpu_pkg::*;(
    input wire clk,
    input wire reset,

    output cache_perf_t mem_perf_icache,
    output cache_perf_t mem_perf_dcache,
    output cache_perf_t mem_perf_l2cache,
    output cache_perf_t mem_perf_l3cache,
    output cache_perf_t mem_perf_lmem,
    output mem_perf_t   mem_perf_mem,

    // Memory request
    output wire                             mem_req_valid,
    output wire                             mem_req_rw,
    output wire [`VX_MEM_BYTEEN_WIDTH-1:0]  mem_req_byteen,
    output wire [`VX_MEM_ADDR_WIDTH-1:0]    mem_req_addr,
    output wire [`VX_MEM_DATA_WIDTH-1:0]    mem_req_data,
    output wire [`VX_MEM_TAG_WIDTH-1:0]     mem_req_tag,
    input  wire                             mem_req_ready,

    // Memory response
    input wire                              mem_rsp_valid,
    input wire [`VX_MEM_DATA_WIDTH-1:0]     mem_rsp_data,
    input wire [`VX_MEM_TAG_WIDTH-1:0]      mem_rsp_tag,
    output wire                             mem_rsp_ready,

    // DCR write request
    input  wire                             dcr_wr_valid,
    input  wire [`VX_DCR_ADDR_WIDTH-1:0]    dcr_wr_addr,
    input  wire [`VX_DCR_DATA_WIDTH-1:0]    dcr_wr_data,

    // Status
    output wire                             busy
);

    // Performance Interface (Conditionally instantiated if PERF_ENABLE is defined)
`ifdef PERF_ENABLE
    VX_mem_perf_if mem_perf_if();
    assign mem_perf_if.icache  = mem_perf_icache;
    assign mem_perf_if.dcache  = mem_perf_dcache;
    assign mem_perf_if.l2cache = mem_perf_l2cache;
    assign mem_perf_if.lmem    = mem_perf_lmem;
`endif

    // DCR Bus Interface
    VX_dcr_bus_if dcr_bus_if();
    assign dcr_bus_if.write_valid = dcr_wr_valid;
    assign dcr_bus_if.write_addr  = dcr_wr_addr;
    assign dcr_bus_if.write_data  = dcr_wr_data;


    // Memory Bus Interface
    VX_mem_bus_if #(
        .DATA_SIZE (`L2_LINE_SIZE),
        .TAG_WIDTH (L2_MEM_TAG_WIDTH)
    ) mem_bus_if();


    // Global Barrier Interface (Conditionally instantiated if GBAR_ENABLE is defined)
`ifdef GBAR_ENABLE
    wire gbar_req_valid_zero = 0;
    wire [`NB_WIDTH-1:0] gbar_req_id_zero = 'b0;
    wire [`NC_WIDTH-1:0] gbar_req_size_m1_zero = 'b0;
    wire [`NC_WIDTH-1:0] gbar_req_core_id_zero = 'b0;
    wire gbar_rsp_ready_zero = 0;

    VX_gbar_bus_if gbar_bus_if_zero();
    assign gbar_bus_if_zero.req_valid = gbar_req_valid_zero;
    assign gbar_bus_if_zero.req_id = gbar_req_id_zero;
    assign gbar_bus_if_zero.req_size_m1 = gbar_req_size_m1_zero;
    assign gbar_bus_if_zero.req_core_id = gbar_req_core_id_zero;
    assign gbar_bus_if_zero.rsp_ready = gbar_rsp_ready_zero;

`endif

    // Instantiate the VX_socket module
    VX_socket #(
        .SOCKET_ID(0),
        .INSTANCE_ID("socket_instance")
    ) socket_inst (
        .clk(clk),
        .reset(reset),
`ifdef PERF_ENABLE
        .mem_perf_if(mem_perf_if),
`endif
        .dcr_bus_if(dcr_bus_if),
        .mem_bus_if(mem_bus_if),
`ifdef GBAR_ENABLE
        .gbar_bus_if(gbar_bus_if_zero),
`endif
        .busy()
    );

endmodule
