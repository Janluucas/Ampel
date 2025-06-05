module Ampel_Behavioral (
    input clk,
    input [2:0] counter,
    input knopf,
    output reg [1:0] ampelfarbe
);
    reg wunsch_signalisiert = 0;
    reg [3:0] wie_lange_noch_rot = 4'b1000;

    // Ampelfarbe berechnen (wie bisher)
    function [1:0] ampel_farbe(input [2:0] c);
        ampel_farbe = { 
            (~c[0] & ~c[1]) | (c[0] & c[1] & ~c[2]),
            (~c[0] & ~c[1] & ~c[2]) | (c[0] & c[2]) | (~c[0] & c[1] & c[2])
        };
    endfunction

    always @(posedge clk) begin
        // Wunsch vormerken, aber noch nicht aktivieren
        if (knopf)
            wunsch_signalisiert <= 1'b1;

        // Rotverlängerung läuft
        if (wie_lange_noch_rot != 4'b1000) begin
            ampelfarbe <= 2'b10; // Rot
            if (wie_lange_noch_rot == 4'b0001) begin
                wie_lange_noch_rot <= 4'b1000;
                wunsch_signalisiert <= 0;
            end else begin
                wie_lange_noch_rot <= wie_lange_noch_rot - 1'b1;
            end
        end
        // Normale Ampelsteuerung
        else begin
            // Prüfe, ob jetzt Rotphase beginnt UND Wunsch signalisiert ist
            if (ampel_farbe(counter) == 2'b10 && wunsch_signalisiert) begin
                wie_lange_noch_rot <= 4'b0111; // 7 Takte Rotverlängerung
                ampelfarbe <= 2'b10; // Rot
                // wunsch_signalisiert bleibt 1 bis Rotverlängerung beendet
            end else begin
                ampelfarbe <= ampel_farbe(counter);
            end
        end
    end
endmodule

module main ();
    reg clk = 1;
    reg [2:0] cntr = 0;
    reg knopf = 0;
    wire [1:0] ampelfarbe_Behavioral;

    Ampel_Behavioral ampel_Behavioral_inst (.clk(clk), .counter(cntr), .knopf(knopf), .ampelfarbe(ampelfarbe_Behavioral));

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars;
        #1;
        $display("Initial: Clock: %b, Counter: %b, Knopf: %b, Ampel_Behavioral: %b",
            clk, cntr, knopf, ampelfarbe_Behavioral);

        // Knopf einmal bei Grün drücken (z.B. bei cntr==0)
        #60;
        knopf = 1;
        #10;
        knopf = 0;

        // Knopf einmal bei Rot drücken (z.B. bei cntr==7)
        wait (cntr == 7);
        #1;
        knopf = 1;
        #10;
        knopf = 0;
    end

    always #50 clk = ~clk;
    always @(posedge clk) begin
        cntr = cntr + 1;
        #1
        $display("Clock: %b, Counter: %b, Knopf: %b, Ampel_Behavioral: %b",
            clk, cntr, knopf, ampelfarbe_Behavioral);
    end
    always @(posedge knopf) begin
        $display("Knopf gedrückt bei Counter: %b", cntr);
        $display("Aktuelle Ampelfarbe: %b", ampelfarbe_Behavioral);
    end
    initial #4000 $finish;
endmodule