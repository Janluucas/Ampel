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
    input clk,
    input [2:0] counter,
    input knopf,
    output reg [1:0] ampelfarbe
);

    reg rot_extend = 0;
    reg rot_extend_request = 0;
    reg [2:0] rot_start = 0;
    reg [1:0] ampelfarbe_next;

    always @* begin
        // Normale Ampellogik
        ampelfarbe_next[0] = ~counter[0] & ~counter[1] | counter[0] & counter[1] & ~counter[2];
        ampelfarbe_next[1] = ~counter[0] & ~counter[1] & ~counter[2] | counter[0] & counter[2] | ~counter[0] & counter[1] & counter[2];
    end

    always @(posedge clk or posedge knopf) begin
        // Knopfdruck merken (asynchron), aber nur wenn keine Verlängerung aktiv ist
        if (knopf && !rot_extend)
            rot_extend_request <= 1;

        // Wenn Rotphase beginnt und ein Wunsch vorliegt: Verlängerung starten
        if (!rot_extend && rot_extend_request && ampelfarbe_next == 2'b10) begin
            rot_extend <= 1;
            rot_start <= counter;
            rot_extend_request <= 0; // Wunsch gelöscht
        end else if (rot_extend && counter == rot_start && !(knopf && ampelfarbe_next == 2'b10)) begin
            // Verlängerung beenden, wenn ein Zyklus vorbei ist (außer bei erneutem Knopfdruck in Rot)
            rot_extend <= 0;
        end

        if (rot_extend)
            ampelfarbe <= 2'b10; // Rot erzwingen
        else
            ampelfarbe <= ampelfarbe_next;
    end
endmodule

module main ();
    reg clk = 1; // Clock signal
    reg [2:0] cntr = 0; // 3-bit counter register
    reg knopf = 0;      // Knopf für Rotverlängerung
    wire [1:0] ampelfarbe_RTL;
    wire [1:0] ampelfarbe_Structural;
    wire [1:0] ampelfarbe_Behavioral;

    Ampel_RTL ampel_RTL_inst (.counter(cntr), .ampelfarbe(ampelfarbe_RTL));
    Ampel_Structural ampel_Structural_inst (.counter(cntr), .ampelfarbe(ampelfarbe_Structural));
    Ampel_Behavioral ampel_Behavioral_inst (.clk(clk), .counter(cntr), .knopf(knopf), .ampelfarbe(ampelfarbe_Behavioral));

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars;
        #1;
        $display("Initial: Clock: %b, Counter: %b, Knopf: %b, Ampel_RTL: %b, Ampel_Structural: %b, Ampel_Behavioral: %b",
            clk, cntr, knopf, ampelfarbe_RTL, ampelfarbe_Structural, ampelfarbe_Behavioral);

        // Knopf einmal bei Grün drücken (z.B. bei cntr==0)
        #60; // Warte bis nach dem ersten posedge clk (cntr==1)
        knopf = 1;
        #10; // Knopf für einen Takt gedrückt lassen
        knopf = 0;

        // Knopf einmal bei Rot drücken (z.B. bei cntr==7)
        wait (cntr == 7);
        #1;
        knopf = 1;
        #1;
        knopf = 0;
    end

    always #50 clk = ~clk;
    always @(posedge clk) begin
        cntr = cntr + 1;
        #1
        $display("Clock: %b, Counter: %b, Knopf: %b, Ampel_RTL: %b, Ampel_Structural: %b, Ampel_Behavioral: %b",
            clk, cntr, knopf, ampelfarbe_RTL, ampelfarbe_Structural, ampelfarbe_Behavioral);
    end
    always @(posedge knopf) begin
        
        $display("Knopf gedrückt bei Counter: %b", cntr);
        $display("Aktuelle Ampelfarbe: %b", ampelfarbe_Behavioral);
    end
    initial #4000 $finish;
endmodule