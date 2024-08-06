module tb_ddr_ctrl;

	reg	clk, rstn;

	reg			cpu_req, cpu_write;
	wire		cpu_ack;
	reg [7:0] 	cpu_addr;
	reg [63:0]	cpu_wdata;
	wire		cpu_rd_en;
	wire [63:0]	cpu_rdata;

	reg [3:0]	cpu_ptr;

	reg [1+8+64:0] cmd [10:0];

	initial begin
		clk	= 0;
		forever #5 clk = ~clk;
	end

	initial begin
		rstn = 1;
		#20 rstn = 0;
		#30 rstn = 1;
	end
//CPU PART
	initial begin
		cmd[0] = {1'b1, 8'h04, 64'h040};	//WRITE	0,4
		cmd[1] = {1'b1, 8'h05, 64'h050};	//WRITE 0,5
		cmd[2] = {1'b0, 8'h04, 64'h000};	//READ  0,4
		cmd[3] = {1'b0, 8'h05, 64'h000};	//READ  0,5

		cmd[4] = {1'b1, 8'h14, 64'h140};	//WRITE 1,4
		cmd[5] = {1'b1, 8'h15, 64'h150};	//WRITE 1,5
		cmd[6] = {1'b0, 8'h14, 64'h000};	//READ  1,4
		cmd[7] = {1'b0, 8'h05, 64'h000};	//READ  0,5

		cmd[8] = 0;
	end
	
	wire cpu_en = cpu_req & cpu_ack ;

	always @(posedge clk, negedge rstn)
	if	(!rstn)	{cpu_write,cpu_addr,cpu_wdata} <= 0;
	else		{cpu_write,cpu_addr,cpu_wdata} <= cmd[cpu_ptr];

	always @(posedge clk, negedge rstn)
	if	(!rstn)			cpu_ptr	<= 0;
	else if (cpu_en)	cpu_ptr	<= cpu_ptr + 1;

	always @(posedge clk, negedge rstn)
	if		(!rstn)		cpu_req	<= 0;
	else if (cpu_en)	cpu_req <= 0;
	else if (cpu_ptr<8)	cpu_req <= 1;

	wire			ck_t, ck_c;
	wire			cke;
	wire			csn, actn;
	wire	[1:0]	bg, ba;
	wire	[17:0]  a;	//rasn 16, casn 15, wen 14, bcn 12, ap 10

	wire	[7:0]	dq;
	wire			dqs_t, dqs_c;

	ddr_ctrl u_ddr_ctrl (
		clk, rstn,	
		cpu_req, cpu_ack,
		cpu_write,
	 	cpu_addr,
		cpu_wdata,
	 	cpu_rd_en, cpu_rdata,

		ck_t, ck_c,
	 	cke,
	 	csn, actn,
	 	bg, ba,
	 	a,	//rasn 16, casn 15, wen 14, bcn 12, ap 10
		dq,
		dqs_t, dqs_c
	);
	
	dram u_dram (
		ck_t, ck_c,
	 	cke,
	 	csn, actn,
	 	bg, ba,
	 	a,	//rasn 16, casn 15, wen 14, bcn 12, ap 10
		dq,
		dqs_t, dqs_c
	);

	initial begin
		#2000
		$finish;
	end
endmodule
