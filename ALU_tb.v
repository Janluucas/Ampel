`timescale 1ns/1ps

module ALU_tb;

    // 1bit Volladdierer
    reg a1, b1, cin1;
    wire sum1, cout1;
    VollAddierer va1 (.in_a(a1), .in_b(b1), .in_carry(cin1), .out_sum(sum1), .out_carry(cout1));

    // 8bit Addierer
    reg [7:0] a8, b8;
    wire [7:0] sum8;
    wire cout8;
    add add8 (.in_a(a8), .in_b(b8), .out_sum(sum8), .out_carry(cout8));

    // 1bit Vollsubtrahierer
    reg sa1, sb1, scin1;
    wire sdiff1, scout1;
    halfsub vs1 (.in_a(sa1), .in_b(sb1), .in_carry(scin1), .out_diff(sdiff1), .out_carry(scout1));

    // 8bit Vollsubtrahierer
    reg [7:0] sa8, sb8;
    wire [7:0] sdiff8;
    wire scout8;
    sub sub8 (.in_a(sa8), .in_b(sb8), .out_diff(sdiff8), .out_carry(scout8));

    // 8bit Multiplizierer
    reg [7:0] ma, mb;
    wire [15:0] mprod;
    mul mul8 (.a(ma), .b(mb), .prod(mprod));

    initial begin
        $display("==== 1bit Volladdierer ====");
        a1=0; b1=0; cin1=0; #1; $display("0+0+0: sum=%b cout=%b", sum1, cout1);
        a1=1; b1=1; cin1=1; #1; $display("1+1+1: sum=%b cout=%b", sum1, cout1);

        $display("\n==== 8bit Addierer ====");
        a8=8'd5; b8=8'd3; #1; $display("5+3: sum=%d cout=%b", sum8, cout8);
        a8=8'd255; b8=8'd1; #1; $display("255+1: sum=%d cout=%b", sum8, cout8);

        $display("\n==== 1bit Vollsubtrahierer ====");
        sa1=1; sb1=0; scin1=0; #1; $display("1-0-0: diff=%b cout=%b", sdiff1, scout1);
        sa1=0; sb1=1; scin1=1; #1; $display("0-1-1: diff=%b cout=%b", sdiff1, scout1);

        $display("\n==== 8bit Vollsubtrahierer ====");
        sa8=8'd10; sb8=8'd3; #1; $display("10-3: diff=%d cout=%b", sdiff8, scout8);
        sa8=8'd3; sb8=8'd10; #1; $display("3-10: diff=%d cout=%b", sdiff8, scout8);

        $display("\n==== 8bit Multiplizierer ====");
        ma=8'd5; mb=8'd3; #1; $display("5*3: prod=%d", mprod);
        ma=8'd15; mb=8'd15; #1; $display("15*15: prod=%d", mprod);

        $finish;
    end
endmodule