// Part 2 skeleton

module fill
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,
		// On Board Keys
		SW,
		// On Board Switches
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					
	// Declare your inputs and outputs here
	input	[9:0]	SW;	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	assign colour[2:0] = SW[9:7];
	wire go, go_plot;
	assign go = ~KEY[3];
	assign go_plot = ~KEY[1];
	wire ld_x, ld_y, plot_screen;
	
	datapath D0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.position(SW[6:0]),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.X(x),
		.Y(y)
		);
	control C0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.go(go),
		.go_plot(go_plot),
		load_x(ld_x),
		load_y(ld_y),
		plot_screen(plot_screen)
	);
	
	//at this point, I think my datapath and control modules have some functionality
		//therefore I need to consider how to use plot_screen to actually plot the
			//values into the screen.
		//this seems like it'll be done somewhere within this (the "fill") module,
		//as it has all of the switches/inputs/outputs here listed in the same keywords
			//as the FPGA
		//all right, the loading of the X and Y registers should work now, therefore
			//the thing to do now is to write code to properly output to the VGA
			
		//the vga_adapter module has already been written within the skeleton code, therefore I just need to set some of the variables accordingly with my stored values
		//that is, resetn, clock, colour, x, and y
		//literally everything else has been given
		//I have now assigned a value for colour, a value for x, a value for y, clock is already given, and resetn is already given
			//therefore this code, in its current state, should be able to output a single pixel at location (x,y) (0,0 being top left corner) to the monitor
		
			
			
	
endmodule

module datapath(
	input clk, 	
	input resetn,
	input [6:0] position,
	input ld_x,
	input ld_y,
	//list any other inputs that seem to come up here
	
	//assuming the outputs for X and Y will need to be decided via an always block
	output reg [7:0] X,
	output reg [6:0] Y;
	//I don't think colour will need to come through the data path, as there's nothing in the
		//process that says that you need to load colour
	//though making a colour register and loading it in time isn't that difficult, it's just
		//another input and a modification on the ld_y block
	);
	
	//registers for loading x and y
	always @(posedge clk) begin
		if(!resetn) begin
			X = 8'b0;
			Y = 7'b0;
		end
		else begin
			if(ld_x)
				x <= {0, position};
			if(ld_y)
				y <= position;
		end
	end
	
	
	//the datapath is literally just taking x and y, storing them into respective registers
	//therefore I currently don't see anything else that I need to add here
	//maybe something to do with clearing the screen, but that can come later if need be
	
			
			
			
	
	
	
endmodule

module control(
	input clk,
	input resetn,
	input go,
	input go_plot,
	//list any other inputs to the control module here as they come up
	//the control module also requires the input that shifts between loading x and y
		//as well as ts he input that goes from loading y to plotting the square onto the screen
	output reg load_x,
	output reg load_y,
	output reg plot_screen;
	//list any other outputs from the control module here as they come up
	);
	//will need something for the current "state"
	
	reg [5:0] current_state, next_state; 	//variables of type reg because their values will
												//be assigned within always blocks
	//localparams used within the always blocks in state logic (to make the state logic easier to
		//to read without having to memorize exactly which string of bits corresponds to which state
	localparam 	S_LOAD_X 		=	5'd0,
				S_LOAD_X_WAIT 	=	5'd1,
				S_LOAD_Y		=	5'd2,
				S_LOAD_Y_WAIT 	= 	5'd3,
				S_PLOT			=	5'd4;
				//n'dx means n bits of binary holding x (in base 10)
				
	always @(*)
	begin: state_table //assigning a name for this always block, I think	
		case (current_state)
			S_LOAD_X: begin
				if(go)
					next_state = S_LOAD_X_WAIT;
				else
					next_state = S_LOAD_X;
				if(go_plot)
					next_state = S_LOAD_Y;
				else
					next_state = S_LOAD_X;
			end
				//next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;	//note: with the way that I've set this up, I need to make sure that go = ~KEY[3]
			S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y;
			S_LOAD_Y: next_state = go_plot ? S_LOAD_Y_WAIT : S_LOAD_Y; //much like above, plot = ~KEY[1]
			S_LOAD_Y_WAIT: next_state = go_plot ? S_LOAD_Y_WAIT : S_PLOT;
			S_PLOT: next_state = S_LOAD_X;								//this line may have to be modified after the functionality for clearing the board is added
		default: next_state = S_LOAD_X;
		endcase
	end //state_table
	
	always @(*)
	begin: enable_signals 
		//making all output (enable) signals 0 to avoid latches
		load_x = 0;
		load_y = 0;
		plot_screen = 0;
		//there will probably be other output enable signals that you have to add here later on
		//i.e. an output that tells the program to plot to the screen
		case (current_state)
			S_LOAD_X: begin
				load_x = 1'b1;
				end
			S_LOAD_Y: begin
				load_y = 1'b1;
				end
			S_PLOT: begin
				plot = 1'b1;
				end
			//no default needed because the default values set above
		endcase
	end //enable signals
	
	always @(posedge clk)
	begin: state_FFs //once again, state_FFs seems to be the name that is assigned to this always block
		if (!resetn)
			current_state <= S_LOAD_X;
		else
			current_state <= next_state;
	end
endmodule
			
	