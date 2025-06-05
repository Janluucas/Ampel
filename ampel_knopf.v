
module Ampel_Behavioral (
	input clk,
	input [2:0] counter,
	input knopf,
	output reg [1:0] ampelfarbe
);
	reg wunsch_signalisiert = 0;
	reg [3:0] wie_lange_noch_rot = 4'b1000;

	always @* begin
		if (wie_lange_noch_rot == 4'b0000) begin
			wunsch_erfullt <= 0;
			wie_lange_noch_rot <= 4'b1000;
			ampelfarbe[0] <= ~counter[0] & ~counter[1] | counter[0] & counter[1] & ~counter[2];
			ampelfarbe[1] <= ~counter[0] & ~counter[1] & ~counter[2] | counter[0] & counter[2] | ~counter[0] & counter[1] & counter[2];
		end else if (knopf && !wunsch_signalisiert) begin
			wunsch_signalisiert <= 1'b1;
			ampelfarbe[0] <= ~counter[0] & ~counter[1] | counter[0] & counter[1] & ~counter[2];
			ampelfarbe[1] <= ~counter[0] & ~counter[1] & ~counter[2] | counter[0] & counter[2] | ~counter[0] & counter[1] & counter[2];

		end else if (wunsch_signalisiert && wie_lange_noch_rot != 4'b1000) begin
			ampelfarbe <= 2'b10;
			wie_lange_noch_rot <= wie_lange_noch_rot - 1'b1;

		end else begin
			if (ampelfarbe != 2'b10 && (counter[0] == 0 && counter[1] == 0 && counter[2] == 0 || counter[0] == 1 && counter[2] == 1 || counter[0] == 0 && counter[1] == 1 && counter[2] == 1) && !(counter[0] == 0 && counter[1] == 0 || counter[0] == 1 && counter[1] == 1 && counter[2] == 0) && wunsch_signalisiert) begin // => wenn gerade von Nicht-Rot auf Rot geschaltet wird & Wunsch signalisiert wurde
				wunsch_signalisiert <= 0;
				wie_lange_noch_rot <= 4'b0111;
				ampelfarbe <= 2'b10;
			end else if (wie_lange_noch_rot == 4'b0000) begin // => wenn Wunsch-Zyklus vorbei ist
				wie_lange_noch_rot == 4'1000;
				ampelfarbe[0] <= ~counter[0] & ~counter[1] | counter[0] & counter[1] & ~counter[2];
				ampelfarbe[1] <= ~counter[0] & ~counter[1] & ~counter[2] | counter[0] & counter[2] | ~counter[0] & counter[1] & counter[2];
			end else if (wie_lange_noch_rot !=4'b1000) begin // => wenn Wunsch-Zyklus am laufen ist
				wie_lange_noch_rot <= wie_lange_noch_rot - 1'b1;
				ampelfarbe <= 2'b10;
			end
		end
	end
endmodule

module main ();
	reg clk = 1; // Clock signal
	reg [2:0] cntr = 0; // 3-bit counter register
	reg knopf = 0;      // Knopf für Rotverlängerung
	wire [1:0] ampelfarbe_Behavioral;

	Ampel_Behavioral ampel_Behavioral_inst (.clk(clk), .counter(cntr), .knopf(knopf), .ampelfarbe(ampelfarbe_Behavioral));

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars;
		#1;
		$display("Initial: Clock: %b, Counter: %b, Knopf: %b, Ampel_Behavioral: %b",
			clk, cntr, knopf, ampelfarbe_Behavioral);

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