module stimulus ();

    logic           clk;
	logic 	        we3; 
	logic [4:0]     ra1, ra2, wa3;
	logic [31:0]    wd3;
	logic [31:0]    rd1, rd2;
   
   integer handle3;
   integer desc3;
   
   // Instantiate DUT
   RF dut (clk, we3, ra1, ra2, wa3, wd3, rd1, rd2); 
   // Setup the clock to toggle every 1 time units 
   initial 
        begin	
	clk = 1'b1;
	forever #5 clk = ~clk;
        end

   initial
        begin
	// Gives output file name
	handle3 = $fopen("test.out");
	// Tells when to finish simulation
	#2000 $finish;		
        end

   always 
        begin
	desc3 = handle3;
	#5 $fdisplay(desc3, "%b || %b %b %b || %b || %b %b", 
		     we3, ra1, ra2, wa3, wd3, rd1, rd2);
        end   
   
   initial 
        begin      
	#0 we3 = 1'b0; 
    #0 ra1 = 5'b00000;
    #0 ra2 = 5'b00000;
    #0 wa3 = 5'b00000;
    #0 wd3 = 32'h00000000;

	#12 we3 = 1'b1;	
	#0 wa3 = 5'b10101;
    #0 wd3 = 32'h0ba6781;
    #10 ra1 = 5'b10101;
	#10 ra2 = 5'b11101;

    #0 wa3 = 5'b00000;
    #0 wd3 = 32'h4639086;
    #10 ra1 = 5'b00000;
	#10 ra2 = 5'b00000;

    #12  we3 = 1'b0;
	#12 we3 = 1'b1;	
	#0  wa3 = 5'b11101;
    #0 wd3 = 32'hc745bef;
	#10 ra1 = 5'b11101;
	#10 ra2 = 5'b11101;

    #10 wa3 = 5'b11000;
    #0 wd3 = 32'hcbef6666;
    #0  ra1 = 5'b11000;

    #13 wa3 = 5'b11001;
    #0 wd3 = 32'habcd1234;
    #0  ra1 = 5'b11001;
    #0  ra2 = 5'b11001;

    #10 we3 = 1'b0; 
    #0 ra1 = 5'b00000;
    #0 ra2 = 5'b00000;
    #0 wa3 = 5'b00000;
    #0 wd3 = 32'h00000000;


        end

endmodule // FSM_tb