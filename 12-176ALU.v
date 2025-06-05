// 1bit Volladdierer als Submodul 
module VollAddierer (
	input wire in_a,
	input wire in_b,
	input wire in_carry,
	output wire out_sum,
	output wire out_carry
);
	assign out_sum = in_a ^ in_b ^ in_carry;
	assign out_carry = (in_a & in_b) | (in_b & in_carry) | (in_a & in_carry); 
endmodule

// 8bit Volladdierer
module add (
	input wire [7:0] in_a,
	input wire [7:0] in_b,
	output wire [7:0] out_sum,
	output wire out_carry
);
	// bit 0
	wire carry0;
	VollAddierer va0 (.in_a(in_a[0]), .in_b(in_b[0]), .in_carry(1'b0), .out_sum(out_sum[0]), .out_carry(carry0));

	// bit 1
	wire carry1;
	VollAddierer va1 (.in_a(in_a[1]), .in_b(in_b[1]), .in_carry(carry0), .out_sum(out_sum[1]), .out_carry(carry1));

	// bit 2
	wire carry2;
	VollAddierer va2 (.in_a(in_a[2]), .in_b(in_b[2]), .in_carry(carry1), .out_sum(out_sum[2]), .out_carry(carry2));

	// bit 3
	wire carry3;
	VollAddierer va3 (.in_a(in_a[3]), .in_b(in_b[3]), .in_carry(carry2), .out_sum(out_sum[3]), .out_carry(carry3));

	// bit 4
	wire carry4;
	VollAddierer va4 (.in_a(in_a[4]), .in_b(in_b[4]), .in_carry(carry3), .out_sum(out_sum[4]), .out_carry(carry4));

	// bit 5
	wire carry5;
	VollAddierer va5 (.in_a(in_a[5]), .in_b(in_b[5]), .in_carry(carry4), .out_sum(out_sum[5]), .out_carry(carry5));

	// bit 6
	wire carry6;
	VollAddierer va6 (.in_a(in_a[6]), .in_b(in_b[6]), .in_carry(carry5), .out_sum(out_sum[6]), .out_carry(carry6));

	// bit 7
	VollAddierer va7 (.in_a(in_a[7]), .in_b(in_b[7]), .in_carry(carry6), .out_sum(out_sum[7]), .out_carry(out_carry));
endmodule


/*
1. Wertetabelle für den Halbsubtrahierer (eigentlich ein 1bit Vollsubtrahierer, da cin)
a	b	cin	d	cout
0	0	0	0	0
0	0	1	1	1
0	1	0	1	1
0	1	1	0	1
1	0	0	1	0
1	0	1	0	0
1	1	0	0	0
1	1	1	1	1
*/

//1bit Vollsubtrahierer als Submodul
module halfsub (
	input wire in_a,
	input wire in_b,
	input wire in_carry,
	output wire out_diff,
	output wire out_carry
);
	assign out_diff = in_a ^ in_b ^ in_carry;
	assign out_carry = (~in_a & in_b) | (in_b & in_carry) | (~in_a & in_carry);
endmodule

// 8bit Vollsubtrahierer
module sub (
	input wire [7:0] in_a,
	input wire [7:0] in_b,
	output wire [7:0] out_diff,
	output wire out_carry
);
	// bit 0
	wire carry0;
	halfsub vs0 (.in_a(in_a[0]), .in_b(in_b[0]), .in_carry(1'b0), .out_diff(out_diff[0]), .out_carry(carry0));

	// bit 1
	wire carry1;
	halfsub vs1 (.in_a(in_a[1]), .in_b(in_b[1]), .in_carry(carry0), .out_diff(out_diff[1]), .out_carry(carry1));

	// bit 2
	wire carry2;
	halfsub vs2 (.in_a(in_a[2]), .in_b(in_b[2]), .in_carry(carry1), .out_diff(out_diff[2]), .out_carry(carry2));

	// bit 3
	wire carry3;
	halfsub vs3 (.in_a(in_a[3]), .in_b(in_b[3]), .in_carry(carry2), .out_diff(out_diff[3]), .out_carry(carry3));

	// bit 4
	wire carry4;
	halfsub vs4 (.in_a(in_a[4]), .in_b(in_b[4]), .in_carry(carry3), .out_diff(out_diff[4]), .out_carry(carry4));

	// bit 5
	wire carry5;
	halfsub vs5 (.in_a(in_a[5]), .in_b(in_b[5]), .in_carry(carry4), .out_diff(out_diff[5]), .out_carry(carry5));

	// bit 6
	wire carry6;
	halfsub vs6 (.in_a(in_a[6]), .in_b(in_b[6]), .in_carry(carry5), .out_diff(out_diff[6]), .out_carry(carry6));

	// bit 7
	halfsub vs7 (.in_a(in_a[7]), .in_b(in_b[7]), .in_carry(carry6), .out_diff(out_diff[7]), .out_carry(out_carry));
endmodule

// 8bit Multiplizierer
module mul (
	input wire [7:0] a,
	input wire [7:0] b,
	output wire [15:0] prod
);
	wire [7:0] a0_and_b = {8{a[0]}} & b;
	wire [7:0] a1_and_b = {8{a[1]}} & b;
	wire [7:0] a2_and_b = {8{a[2]}} & b;
	wire [7:0] a3_and_b = {8{a[3]}} & b;
	wire [7:0] a4_and_b = {8{a[4]}} & b;
	wire [7:0] a5_and_b = {8{a[5]}} & b;
	wire [7:0] a6_and_b = {8{a[6]}} & b;
	wire [7:0] a7_and_b = {8{a[7]}} & b;

	// ADD0
	wire [7:0] sum0;
	wire c0;
	add add0 (.in_a(a0_and_b), .in_b(8'b00000000), .out_sum(sum0), .out_carry(c0));
	assign prod[0] = sum0[0];
	wire [7:0] out0;
	assign out0 = {c0, sum0[7:1]};

	// ADD1
	wire [7:0] sum1;
	wire c1;
	add add1 (.in_a(a1_and_b), .in_b(out0), .out_sum(sum1), .out_carry(c1));
	assign prod[1] = sum1[0];
	wire [7:0] out1;
	assign out1 = {c1, sum1[7:1]};

	// ADD2
	wire [7:0] sum2;
	wire c2;
	add add2 (.in_a(a2_and_b), .in_b(out1), .out_sum(sum2), .out_carry(c2));
	assign prod[2] = sum2[0];
	wire [7:0] out2;
	assign out2 = {c2, sum2[7:1]};

	// ADD3
	wire [7:0] sum3;
	wire c3;
	add add3 (.in_a(a3_and_b), .in_b(out2), .out_sum(sum3), .out_carry(c3));
	assign prod[3] = sum3[0];
	wire [7:0] out3;
	assign out3 = {c3, sum3[7:1]};

	// ADD4
	wire [7:0] sum4;
	wire c4;
	add add4 (.in_a(a4_and_b), .in_b(out3), .out_sum(sum4), .out_carry(c4));
	assign prod[4] = sum4[0];
	wire [7:0] out4;
	assign out4 = {c4, sum4[7:1]};

	// ADD5
	wire [7:0] sum5;
	wire c5;
	add add5 (.in_a(a5_and_b), .in_b(out4), .out_sum(sum5), .out_carry(c5));
	assign prod[5] = sum5[0];
	wire [7:0] out5;
	assign out5 = {c5, sum5[7:1]};

	// ADD6
	wire [7:0] sum6;
	wire c6;
	add add6 (.in_a(a6_and_b), .in_b(out5), .out_sum(sum6), .out_carry(c6));
	assign prod[6] = sum6[0];
	wire [7:0] out6;
	assign out6 = {c6, sum6[7:1]};

	// ADD7
	wire [7:0] sum7;
	add add7 (.in_a(a7_and_b), .in_b(out6), .out_sum(sum7), .out_carry(prod[15]));
	assign prod[7] = sum7[0];
	assign prod[8] = sum7[1];
	assign prod[9] = sum7[2];
	assign prod[10] = sum7[3];
	assign prod[11] = sum7[4];
	assign prod[12] = sum7[5];
	assign prod[13] = sum7[6];
	assign prod[14] = sum7[7];
	
endmodule