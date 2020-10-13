`include "VX_define.vh"

module VX_fetch #(
    parameter CORE_ID = 0
) (
    `SCOPE_IO_VX_fetch

    input wire clk,
    input wire reset,

    // Icache interface
    VX_cache_core_req_if icache_req_if,
    VX_cache_core_rsp_if icache_rsp_if,

    // inputs
    VX_wstall_if        wstall_if,
    VX_join_if          join_if,
    VX_branch_ctl_if    branch_ctl_if,
    VX_warp_ctl_if      warp_ctl_if,

    // outputs
    VX_ifetch_rsp_if    ifetch_rsp_if,

    output wire         busy
);

    VX_ifetch_req_if  ifetch_req_if();

    VX_warp_sched #(
        .CORE_ID(CORE_ID)
    ) warp_sched (
        `SCOPE_BIND_VX_fetch_warp_sched

        .clk              (clk),
        .reset            (reset),        
        .warp_ctl_if      (warp_ctl_if),
        .wstall_if        (wstall_if),
        .join_if          (join_if),
        .branch_ctl_if    (branch_ctl_if),
        .ifetch_req_if    (ifetch_req_if),
        .ifetch_rsp_if    (ifetch_rsp_if),
        .busy             (busy)
    ); 

    VX_icache_stage #(
        .CORE_ID(CORE_ID)
    ) icache_stage (
        `SCOPE_BIND_VX_fetch_icache_stage

        .clk            (clk),
        .reset          (reset),        
        
        .icache_rsp_if  (icache_rsp_if),
        .icache_req_if  (icache_req_if),

        .ifetch_req_if  (ifetch_req_if),
        .ifetch_rsp_if  (ifetch_rsp_if)   
    );

endmodule