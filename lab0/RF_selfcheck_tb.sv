module stimulus();
    logic clk, reset;
    logic [31:0] vectornum, errors;
    logic [111:0] testvectors[10000:0];
    logic 	        we3; 
	logic [4:0]     ra1, ra2, wa3;
	logic [31:0]    wd3, rd1expected, rd2expected;
	logic [31:0]    rd1, rd2;

    // instantiate device under test
    RF dut(clk, we3, ra1, ra2, wa3, wd3, rd1, rd2);

    // generate clock
    always
        begin
        clk = 1; #5; clk = 0; #5;
        end

    // at start of test, load vectors and pulse reset
    initial
        begin
            $readmemb("RF.txt", testvectors);
            vectornum = 0; errors = 0;
            reset = 1; #22; reset = 0;
        end

    // apply test vectors on rising edge of clk
    always @(posedge clk)
        begin
            #10; {we3, wa3, ra1, ra2, wd3, rd1expected, rd2expected} = testvectors[vectornum];
        end

    // check results on falling edge of clk
    always @(negedge clk)
        if (~reset) begin // skip during reset
            if (rd1 !== rd1expected | rd2 !== rd2expected) begin // check result
                $display("Error: inputs = %b", {we3, ra1, ra2, wa3, wd3});
                $display(" outputs rd1 rd2 = %b%b (%b%b expected)", rd1, rd2, rd1expected, rd2expected);
            errors = errors + 1;
            end
            vectornum = vectornum + 1;
            if (testvectors[vectornum] === 'bx) begin
                $display("%d tests completed with %d errors", vectornum, errors);
                $stop;
            end
        end
endmodule

