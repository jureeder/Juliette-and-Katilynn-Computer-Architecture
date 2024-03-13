module RF (input logic         clk, 
		input logic 	    we3, 
		input logic [4:0]   ra1, ra2, wa3, 
		input logic [31:0]  wd3, 
		output logic [31:0] rd1, rd2);
   
    logic [31:0] 		    rf[31:0];
   
    // three ported register file

    always_ff @(posedge clk)
    begin
        if (we3) rf[wa3] = wd3;
        
        rd1 <= ra1 ? rf[ra1] : 0;
        rd2 <= ra2 ? rf[ra2] : 0;

        //rf[5'b00000] = 32'h00000000;
    end

    // read two ports combinationally
    // write third port on rising edge of clock

    //assign rd1 = rf[ra1];
   //assign rd2 = rf[ra2];

    // register 0 hardwired to 0
 
endmodule // regfile