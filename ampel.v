// Colors: 00 - green, 01 - yellow, 10 - red, 11 - red & yellow
// Counter: 3 bits, counts from 0 to 7

module Ampel_RTL (
	input [2:0] counter, // 3-bit counter
	output [1:0] ampelfarbe // Traffic light color output
);
	assign ampelfarbe[0] = ~counter[0] & ~counter[1] | counter[0] & counter[1] & ~counter[2]; // least significant bit for colors
	assign ampelfarbe[1] = ~counter[0] & ~counter[1] & ~counter[2] | counter[0] & counter[2] |~counter[0] & counter[1] & counter[2]; // most significant bit for colors
endmodule


module Ampel_Structural (
	input [2:0] counter, // 3-bit counter
	output [1:0] ampelfarbe // Traffic light color output
);
	not not0 (cntr0, counter[0]);
	not not1 (cntr1, counter[1]);
	not not2 (cntr2, counter[2]);
	and and0 (and00, cntr0, cntr1);	//first and for least significant bit
	and and1 (and01, counter[0], counter[1], cntr2);	//second and for least significant bit
	and and2 (and10, cntr0, cntr1, cntr2);	//first and for most significant bit
	and and3 (and11, counter[0], counter[2]);	//second and for most significant bit
	and and4 (and12, cntr0, counter[1], counter[2]);	//third and for most significant bit
	or or0 (ampelfarbe[0], and00, and01);	// or for least significant bit
	or or1 (ampelfarbe[1], and10, and11, and12);	// or for most significant bit
endmodule


module Ampel_Behavioral (
	input [2:0] counter, // 3-bit counter input
	output reg [1:0] ampelfarbe // Traffic light color output
);

	always @(counter) begin
		ampelfarbe[0] = ~counter[0] & ~counter[1] | counter[0] & counter[1] & ~counter[2]; // least significant bit for colors
		ampelfarbe[1] = ~counter[0] & ~counter[1] & ~counter[2] | counter[0] & counter[2] |~counter[0] & counter[1] & counter[2]; // most significant bit for colors
	end
endmodule

module main ();
    reg clk = 1; // Clock signal
    reg [2:0] cntr = 0; // 3-bit counter register
    wire [1:0] ampelfarbe_RTL; // Traffic light color output for RTL style
    wire [1:0] ampelfarbe_Structural; // Traffic light color output for Structural style
    wire [1:0] ampelfarbe_Behavioral; // Traffic light color output for Behavioral style
    Ampel_RTL ampel_RTL_inst (.counter(cntr), .ampelfarbe(ampelfarbe_RTL)); // Instantiate the RTL style module
    Ampel_Structural ampel_Structural_inst (.counter(cntr), .ampelfarbe(ampelfarbe_Structural)); // Instantiate the Structural style module
    Ampel_Behavioral ampel_Behavioral_inst (.counter(cntr), .ampelfarbe(ampelfarbe_Behavioral)); // Instantiate the Behavioral style module

    initial begin
        $dumpfile("testbench.vcd"); // VCD-Datei für gtkwave
        $dumpvars;                  // Alle Variablen aufzeichnen
        #1; // Wait 1 time unit for outputs to settle
        $display("Initial: Clock: %b, Counter: %b, Ampel_RTL: %b, Ampel_Structural: %b, Ampel_Behavioral: %b", clk, cntr, ampelfarbe_RTL, ampelfarbe_Structural, ampelfarbe_Behavioral);
    end

    always #50 clk = ~clk; // Toggle clock every 50 time units
    always @(posedge clk) begin
        cntr = cntr + 1;
		#1
        $display("Clock: %b, Counter: %b, Ampel_RTL: %b, Ampel_Structural: %b, Ampel_Behavioral: %b", clk, cntr, ampelfarbe_RTL, ampelfarbe_Structural, ampelfarbe_Behavioral);
    end
    initial #4000 $finish; // Stop simulation after 4000 time units
endmodule