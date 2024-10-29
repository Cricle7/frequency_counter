`timescale 100ps/10ps

module tb_example_top ();
`include "../../ip/hbram/Testbench/hbram_define.vh"

wire test_done;
wire test_fail;

initial begin
`ifdef XRUN
    $shm_open("waveform.shm");
    $shm_probe(tb_hbram,"ACMTF"); 
`endif
    @ (posedge test_done)
    if (test_fail === 1'b0) begin
        $display("===============================================");
        $display("=============== SIMULATION DONE ===============");
        $display("===============================================");
    end
    else begin
        $display("===============================================");
        $display("=============== SIMULATION FAIL ===============");
        $display("===============================================");
    end
    # 10000;
    
    $finish;
end

localparam hdmi_pixel_MHZ           = 742.5;
localparam hdmi_pixel_10x_MHZ       = 148.5;
localparam sys_clk_MHZ              = 123.75;
localparam sensor_xclk_MHZ          = 27;
localparam dsi_serclk_MHZ           = 750.2344;

localparam	TCYC	 = 1000000/MHZ;
localparam      TS       = TCYC/100;//at 200Mhz -> 5000/100=50
localparam      U_DLY    = 0;
/////////////////////////////////////////////////////////////////////////////
reg				my_pll_locked		= 1'b0;
reg				clk_pll_locked		= 1'b0;
//define system signal
reg				io_rst;
wire				io_rst_n;
reg            			rst;
wire           			rst_n;
wire				io_clk;
wire           			clk;
wire           			clk_90;
reg				checkerd		= 'b0;
reg				checkerp		= 'b0;

//hyperbus signals
wire     			hbc_rst_n;
wire     			hbc_cs_n;
wire         			hbc_ck_p_HI;
wire         			hbc_ck_p_LO;
wire         			hbc_ck_n_HI;
wire         			hbc_ck_n_LO;
wire     [RAM_DBW/8-1:0] 	hbc_rwds_OUT_HI;
wire     [RAM_DBW/8-1:0] 	hbc_rwds_OUT_LO;
wire     [RAM_DBW/8-1:0] 	hbc_rwds_IN_HI;
wire     [RAM_DBW/8-1:0] 	hbc_rwds_IN_LO;
wire     [RAM_DBW/8-1:0] 	hbc_rwds_IN;
wire     [RAM_DBW/8-1:0] 	hbc_rwds_IN_delay;
wire     [RAM_DBW/8-1:0] 	hbc_rwds_OE;
wire     [RAM_DBW-1:0]   	hbc_dq_OUT_HI;
wire     [RAM_DBW-1:0]   	hbc_dq_OUT_LO;
wire     [RAM_DBW-1:0]   	hbc_dq_IN_HI;
wire     [RAM_DBW-1:0]   	hbc_dq_IN_LO;
wire     [RAM_DBW-1:0]   	hbc_dq_IN;
wire     [RAM_DBW-1:0]   	hbc_dq_OE;
wire	 [2:0]				hbc_cal_SHIFT;
wire	 [4:0]				hbc_cal_SHIFT_SEL;
wire	 [2:0]				hbc_cal_SHIFT_HI;
wire	 [4:0]				hbc_cal_SHIFT_SEL_HI;
wire	 [2:0]				hbc_cal_SHIFT_LO;
wire	 [4:0]				hbc_cal_SHIFT_SEL_LO;
wire						hbc_cal_SHIFT_ENA;
wire						hbc_cal_pass;
wire     [2:0] 				rwds_delay;
//hyperbus ram signals
wire          			ram_rst_n;
wire          			ram_cs_n;
wire          			ram_ck_p;
wire          			ram_ck_n;
wire     [RAM_DBW/8-1:0]  	ram_rwds;
reg      [RAM_DBW/8-1:0] 	ram_rds;
wire     [RAM_DBW-1:0]   	ram_dq;

wire hdmi_pixel_10x;
wire hdmi_pixel;
wire sensor_xclk_i;
wire hdmi_pll_lock;

wire dsi_serclk_i;
wire dsi_txcclk_i;
wire dsi_byteclk_i;
wire dsi_fb_i;
wire dsi_pll_lock;

//parameter
localparam LINEAR = 1'b1;
localparam WAPPED = 1'b0;
localparam REG    = 1'b1;
localparam MEM    = 1'b0;
localparam IR0    = 'b0000_0000_0000_0000;
localparam IR1    = 'b0000_0000_0000_0001;
localparam CR0    = 'b0000_1000_0000_0000;
localparam CR1    = 'b0000_1000_0000_0001;
integer	i,j;
/////////////////////////////////////////////////////////////////////////////
//system reset
initial begin
     rst = 1;
     io_rst = 1;
     #(100*TS);
     rst = 0;
     io_rst = 0;
end

//system clock
clock_gen #(
        .FREQ_CLK_MHZ(MHZ)
) clock_gen_inst (
        .rst            (rst   	  ),
        .clk_out0       (clk   	  ),
        .clk_out45      (      	  ),
        .clk_out90      (clk_90	  ),
        .clk_out135     (      	  ),
        .locked         (rst_n 	  )
);

clock_gen #(
        .FREQ_CLK_MHZ(sys_clk_MHZ)
) clock_gen2_inst (
        .rst            (io_rst   ),
        .clk_out0       (io_clk   ),
        .clk_out45      (      	  ),
        .clk_out90      (	  ),
        .clk_out135     (      	  ),
        .locked         (io_rst_n )
);

clock_gen #(
        .FREQ_CLK_MHZ(hdmi_pixel_MHZ)
) clock_gen3_inst (
        .rst            (io_rst   ),
        .clk_out0       (hdmi_pixel),
        .clk_out45      (      	  ),
        .clk_out90      (	  ),
        .clk_out135     (      	  ),
        .locked         (hdmi_pll_lock )
);

clock_gen #(
        .FREQ_CLK_MHZ(sensor_xclk_MHZ)
) clock_gen4_inst (
        .rst            (io_rst   ),
        .clk_out0       (sensor_xclk_i),
        .clk_out45      (      	  ),
        .clk_out90      (	  ),
        .clk_out135     (      	  ),
        .locked         ( )
);

clock_gen #(
        .FREQ_CLK_MHZ(dsi_serclk_MHZ)
) clock_gen5_inst (
        .rst            (io_rst   ),
        .clk_out0       (dsi_serclk_i),
        .clk_out45      ( ),
        .clk_out90      (	  ),
        .clk_out135     (      	  ),
        .locked         (dsi_pll_lock )
);


generate 
if (CAL_MODE == 1) begin
    wire                    hbc_cal_pass;
    initial begin
    wait (hbc_cal_pass);
    $display($time,,"-----------------------------------------");
    $display($time,,"[EFX_INFO]: HBRAM CALIBRATION PASS");
    $display($time,,"-----------------------------------------");
    end

    always @ ( * ) begin //soft logic calibration SHIFTS
        case(soft_dut.DUT.hbram_top_inst.soft_cal_block.hbram_cal_axi_top_inst.hbc_rwds_delay)
          3'b000:	ram_rds <= #(0*TS/8) hbc_rwds_IN;
          3'b001:	ram_rds <= #(4*TS/8) hbc_rwds_IN;
          3'b010:	ram_rds <= #(5*TS/8) hbc_rwds_IN;
          3'b011:	ram_rds <= #(6*TS/8) hbc_rwds_IN;
          3'b100:	ram_rds <= #(7*TS/8) hbc_rwds_IN;
          3'b101:	ram_rds <= #(3*TS/8) hbc_rwds_IN;
          3'b110:	ram_rds <= #(2*TS/8) hbc_rwds_IN;
          3'b111:	ram_rds <= #(7*TS/8) hbc_rwds_IN;
          default	:ram_rds <= #(0*TS/8) hbc_rwds_IN;
        endcase
    end
    assign hbc_rwds_IN_delay = ram_rds;
end
else if (CAL_MODE == 2 || CAL_MODE == 3) begin
	initial begin
		wait (hbc_cal_pass);
		$display($time,,"-----------------------------------------");
		$display($time,,"[EFX_INFO]: HBRAM CALIBRATION PASS");
		$display($time,,"-----------------------------------------");
		//#50000;
		//$finish;
	end

	always @ ( * ) begin //auto acibration normal
		case(hbc_cal_SHIFT) //just to select the hbc_cal_SHIFT we had fixed
		  3'b000:	ram_rds <= #(0*TS/8) clk;
		  3'b001:	ram_rds <= #(1*TS/8) clk;
		  3'b010:	ram_rds <= #(2*TS/8) clk;
		  3'b011:	ram_rds <= #(3*TS/8) clk;
		  3'b100:	ram_rds <= #(4*TS/8) clk;
		  3'b101:	ram_rds <= #(5*TS/8) clk;
		  3'b110:	ram_rds <= #(6*TS/8) clk;
		  3'b111:	ram_rds <= #(7*TS/8) clk;
		  default	:ram_rds <= #(0*TS/8) clk;
		endcase
	end
end
endgenerate

//RST_N
assign ram_rst_n = hbc_rst_n;
                   
wire hbc_cal_done;
initial
begin:system
	$display($time,,"-----------------------------------------");
	$display($time,,"[EFX_INFO]: Start HBRAM TEST");
	$display($time,,"-----------------------------------------");
	clk_pll_locked	= 1'b0;
	my_pll_locked 	= 1'b0;
	#3000
	clk_pll_locked	= 1'b1;
	#5000;
	my_pll_locked 	= 1'b1;
	#5000;
    io_rst = 1;
    #2000;
    io_rst = 0;
    wait (hbc_cal_done);

    repeat (100) begin @(posedge clk); end
    if(hbc_cal_pass == 0) begin
    $display($time,,"-----------------------------------------");
	$display($time,,"CALIBRATION FAILED");
	$display($time,,"-----------------------------------------");
	$finish;
    end
end

    wire               dyn_pll_phase_en;
    wire [2:0]         dyn_pll_phase_sel;
    wire [15:0]        hbc_cal_debug_info;
    wire [2:0]         hbc_cal_SHIFT_int;
    wire               hbc_cal_SHIFT_ENA_int;
    wire               override;
    wire [28:0]        clk_monitor;

    assign reset             = io_rst;
    assign hbramClk_pll_rstn = 1'b1;
    assign sysClk_pll_rstn   = 1'b1;
    assign intosc_en         = 1'b1;
    assign hbc_cal_done = hbc_cal_debug_info[0];

    // Instantiate the DUT (Design Under Test)
    example_top u_dut (
        .hbramClk_pll_rstn_o(),
        .hbramClk(clk),
        .hbramClk_Cal(ram_rds[0]),//LO
        .hbramClk_pll_lock(),
        .hbramClk_shift(hbc_cal_SHIFT),
        .hbramClk_shift_ena(hbc_cal_SHIFT_ENA),
        .hbramClk_shift_sel(hbc_cal_SHIFT_SEL),

        //hyperbus_1
        .hbram_RST_N(hbc_rst_n),
        .hbram_CS_N(hbc_cs_n),
        .hbram_CK_P_HI(hbc_ck_p_HI),
        .hbram_CK_P_LO(hbc_ck_p_LO),
        .hbram_CK_N_HI(hbc_ck_n_HI),
        .hbram_CK_N_LO(hbc_ck_n_LO),
        .hbram_RWDS_OUT_HI(hbc_rwds_OUT_HI),
        .hbram_RWDS_OUT_LO(hbc_rwds_OUT_LO),
        .hbram_RWDS_IN_HI(hbc_rwds_IN_HI),
        .hbram_RWDS_IN_LO(hbc_rwds_IN_LO),
        .hbram_RWDS_OE(hbc_rwds_OE),
        .hbram_DQ_OUT_HI(hbc_dq_OUT_HI),
        .hbram_DQ_OUT_LO(hbc_dq_OUT_LO),
        .hbram_DQ_OE(hbc_dq_OE),
        .hbram_DQ_IN_HI(hbc_dq_IN_HI),
        .hbram_DQ_IN_LO(hbc_dq_IN_LO),


        .hdmi_pll_rstn_o(),
        .hdmi_pixel_10x(hdmi_pixel_10x),
        .hdmi_pixel(hdmi_pixel),
        .sensor_xclk_i(sensor_xclk_i),
        .sys_clk_i(io_clk),
        .hdmi_pll_lock(hdmi_pll_lock),

        .dsi_pll_rstn_o(),
        .dsi_serclk_i(dsi_serclk_i),
        .dsi_txcclk_i(dsi_serclk_i),
        .dsi_byteclk_i(dsi_byteclk_i),
        .dsi_fb_i(dsi_fb_i),
        .dsi_pll_lock(dsi_pll_lock),
        .uart_rx_i(),
        .uart_tx_o()
    );


/////////////////////////////////////////////////////////////////////////////////
//CS_N
EFX_GPIO_model #(
	.BUS_WIDTH   (1     	  ), // define ddio bus width
	.TYPE        ("OUT" 	  ), // "IN"=input "OUT"=output "INOUT"=inout
	.OUT_REG     (1     	  ), // 1: enable 0: disable
	.OUT_DDIO    (0     	  ), // 1: enable 0: disable
	.OUT_RESYNC  (0     	  ), // 1: enable 0: disable
	.OUTCLK_INV  (0     	  ), // 1: enable 0: disable
	.OE_REG      (0     	  ), // 1: enable 0: disable
	.IN_REG      (0     	  ), // 1: enable 0: disable
	.IN_DDIO     (0     	  ), // 1: enable 0: disable
	.IN_RESYNC   (0     	  ), // 1: enable 0: disable
	.INCLK_INV   (0     	  )  // 1: enable 0: disable
) cs_n_inst (
	.out_HI      (hbc_cs_n    ), // tx HI data input from internal logic
	.out_LO      (1'b0 	      ), // tx LO data input from internal logic
	.outclk      (clk         ), // tx data clk input from internal logic
	.oe          (1'b1        ), // tx data output enable from internal logic
	.in_HI       (            ), // rx HI data output to internal logic
	.in_LO       (            ), // rx LO data output to internal logic
	.inclk       (1'b0        ), // rx data clk input from internal logic
	.io          (ram_cs_n    )  // outside io signal
);
//CK_P
EFX_GPIO_model #(
	.BUS_WIDTH   (1     	  ), 
	.TYPE        ("OUT" 	  ), 
	.OUT_REG     (1     	  ), 
	.OUT_DDIO    (1     	  ), 
	.OUT_RESYNC  (0     	  ), 
	.OUTCLK_INV  (1     	  ), 
	.OE_REG      (0     	  ), 
	.IN_REG      (0     	  ), 
	.IN_DDIO     (0     	  ), 
	.IN_RESYNC   (0     	  ), 
	.INCLK_INV   (0     	  )  
) ck_p_inst (
	.out_HI      (hbc_ck_p_HI ), 
	.out_LO      (hbc_ck_p_LO ), 
	.outclk      (clk_90      ), 
	.oe          (1'b1        ), 
	.in_HI       (            ), 
	.in_LO       (            ), 
	.inclk       (1'b0        ), 
	.io          (ram_ck_p    )  
);
//CK_N
EFX_GPIO_model #(
	.BUS_WIDTH   (1           ), 
	.TYPE        ("OUT"       ), 
	.OUT_REG     (1           ), 
	.OUT_DDIO    (1           ), 
	.OUT_RESYNC  (0           ), 
	.OUTCLK_INV  (1           ), 
	.OE_REG      (0           ), 
	.IN_REG      (0           ), 
	.IN_DDIO     (0           ), 
	.IN_RESYNC   (0           ), 
	.INCLK_INV   (0           )  
) ck_n_inst (
	.out_HI      (hbc_ck_n_HI ), 
	.out_LO      (hbc_ck_n_LO ), 
	.outclk      (clk_90      ), 
	.oe          (1'b1        ), 
	.in_HI       (            ), 
	.in_LO       (            ), 
	.inclk       (1'b0        ), 
	.io          (ram_ck_n    )  
);

generate 
if(CAL_MODE == 1)
begin
//RWDS
EFX_GPIO_model #(
	.BUS_WIDTH   (RAM_DBW/8  ), 
	.TYPE        ("INOUT"     ), 
	.OUT_REG     (1           ), 
	.OUT_DDIO    (1           ), 
	.OUT_RESYNC  (0           ), 
	.OUTCLK_INV  (0           ), 
	.OE_REG      (1           ), 
	.IN_REG      (0           ), 
	.IN_DDIO     (0           ), 
	.IN_RESYNC   (0           ), 
	.INCLK_INV   (0           )  
) rwds_inst (
	.out_HI      (hbc_rwds_OUT_HI), 
	.out_LO      (hbc_rwds_OUT_LO), 
	.outclk      (clk            ), 
	.oe          (hbc_rwds_OE[0] ), 
	.in_HI       (hbc_rwds_IN    ), 
	.in_LO       (		     ), 
	.inclk       (1'b0	     ), 
	.io          (ram_rwds       )  
);

//DQ
EFX_GPIO_model #(
	.BUS_WIDTH   (RAM_DBW   ), 
	.TYPE        ("INOUT"    ), 
	.OUT_REG     (1          ), 
	.OUT_DDIO    (1          ), 
	.OUT_RESYNC  (0          ), 
	.OUTCLK_INV  (1          ), 
	.OE_REG      (1          ), 
	.IN_REG      (0          ), 
	.IN_DDIO     (0          ), 
	.IN_RESYNC   (0          ), 
	.INCLK_INV   (0          )  
) dq_inst (
	.out_HI      (hbc_dq_OUT_HI ), 
	.out_LO      (hbc_dq_OUT_LO ), 
	.outclk      (clk           ), 
	.oe          (hbc_dq_OE[0]  ), 
	.in_HI       (hbc_dq_IN	    ), 
	.in_LO       (		    ), 
	.inclk       (1'b0	    ), 
	.io          (ram_dq        )  
);
end
else
begin
//RWDS
EFX_GPIO_model #(
	.BUS_WIDTH   (RAM_DBW/8  ), 
	.TYPE        ("INOUT"     ), 
	.OUT_REG     (1           ), 
	.OUT_DDIO    (1           ), 
	.OUT_RESYNC  (0           ), 
	.OUTCLK_INV  (0           ), 
	.OE_REG      (1           ), 
	.IN_REG      (1           ), 
	.IN_DDIO     (1           ), 
	.IN_RESYNC   (1           ), 
	.INCLK_INV   (0           )  
) rwds_inst (
	.out_HI      (hbc_rwds_OUT_HI), 
	.out_LO      (hbc_rwds_OUT_LO), 
	.outclk      (clk            ), 
	.oe          (hbc_rwds_OE[0] ), 
	.in_HI       (hbc_rwds_IN_HI ), 
	.in_LO       (hbc_rwds_IN_LO ), 
	.inclk       (ram_rds[0]     ), 
	.io          (ram_rwds       )  
);

//DQ
EFX_GPIO_model #(
	.BUS_WIDTH   (RAM_DBW   ), 
	.TYPE        ("INOUT"    ), 
	.OUT_REG     (1          ), 
	.OUT_DDIO    (1          ), 
	.OUT_RESYNC  (0          ), 
	.OUTCLK_INV  (1          ), 
	.OE_REG      (1          ), 
	.IN_REG      (1          ), 
	.IN_DDIO     (1          ), 
	.IN_RESYNC   (1          ), 
	.INCLK_INV   (0          )  
) dq_inst (
	.out_HI      (hbc_dq_OUT_HI ), 
	.out_LO      (hbc_dq_OUT_LO ), 
	.outclk      (clk           ), 
	.oe          (hbc_dq_OE[0]  ), 
	.in_HI       (hbc_dq_IN_HI  ), 
	.in_LO       (hbc_dq_IN_LO  ), 
	.inclk       (ram_rds[0]    ), 
	.io          (ram_dq        )  
);
end
endgenerate

/////////////////////////////////////////////////////////////////////////////////
//Hyperbus RAM_1
generate
     pullup p0 (ram_cs_n   );
     pullup p1 (ram_rst_n  );
     if (RAM_DBW == 8) begin
     s27kl0642 ram_x8_inst
     (
     .DQ7      (ram_dq[7]  ),
     .DQ6      (ram_dq[6]  ),
     .DQ5      (ram_dq[5]  ),
     .DQ4      (ram_dq[4]  ),
     .DQ3      (ram_dq[3]  ),
     .DQ2      (ram_dq[2]  ),
     .DQ1      (ram_dq[1]  ),
     .DQ0      (ram_dq[0]  ),
     .RWDS     (ram_rwds   ),
     .CSNeg    (ram_cs_n   ),
     .CK       (ram_ck_p   ),
     .CKn      (1'b0       ),
     .RESETNeg (ram_rst_n  )
     );
     end
     else begin
     W958D6NKY ram_x16_inst(
    .adq	(ram_dq		), 		
    .clk	(ram_ck_p	),		
    .clk_n	(1'b0		),      
    .csb	(ram_cs_n	),		
    .rwds	(ram_rwds	),        
    .VCC	(1'b1		),
    .VSS	(1'b0		),
    .resetb	(ram_rst_n	),
    .die_stack	(1'b0		),
    .optddp	(1'b0		)
    );
    end
endgenerate 

endmodule
