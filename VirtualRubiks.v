//things that I need to work on today
// i) drawing the cube state (and getting the pixels to draw correctly, in the 3d rep)
		//a) adjusting the state table so that the FSM goes to draw 3d after every draw net after every move
		//b) adjusting the datapath to allow for a counter that draws the net and draws the 3d representation
//ii) updating the top level module to reflect the changes within datapath and control module

	//the datapath module in lab 7 part 3 used the plot_screen input to choose when to increment plot_count
	//in this case, plot_count can be used to plot both the 3d visualization of the cube, as well as the 2d net of the cube
	//the 2d net is almost certainly easier, and it can be done by printing white when the count is not at a value that should be
	//printed as a colour, and printing black on a piece boundary, and printing the piece colour on a piece
	//it seems like the colour is also defined within the datapath, which will make the implementation of the changing of the values of 
		//colour through the different values of plot_count pretty ok
		//basically the logic will be if (x_count and y_count correspond to a pixel within one of the piece representations, print the colour
			//of the piece
	//I believe that the datapath is now in the right state outputting a 39x29 block of one solid colour in place of where the net will be drawn
	//the challenge now is to plot the 3D representation of the Rubik's cube current state to the screen
	//this can probably best be done with a ROM
	//and the top level module to reflect all of the changes that were made to the datapath and control module
		//list any other top level module changes here
module VirtualRubiks
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
	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//the code should now take colour from the datapath, rather than directly from the switches
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//my code, which currently is the code from lab 7
	// for the VGA controller, in addition to any other functionality your design may require.
	//wires serving as outputs from datapath to inputs into control
	//wires for x and y already written in skele code

	//wires serving as outputs from control to inputs into datapath and other places
	wire plot_screen;
	wire [10:0] plot_count;
	wire go;
	assign go = ~KEY[1];
	wire eU, eUi, eD, eDi, eL, eLi, eR, eRi, eF, eFi, eB, eBi, eX, eXi, eY, eYi, eZ, eZi;
	wire waiting_for_move;
	wire [4:0] move_to_make;
	assign move_to_make = SW[4:0];
	//I think the following wires may be needed, but possibly not as the piece colours will only be used in plotting the appropriate colours
		//to the screen, which will be taken as output from the datapath in the form of the colour register
	/*
	wire [2:0] p0, p1, p2, p3;
	wire [2:0] p4, p5, p6, p7;
	wire [2:0] p8, p9, p10, p11;
	wire [2:0] p12, p13, p14, p15;
	wire [2:0] p16, p17, p18, p19;
	wire [2:0] p20, p21, p22, p23;
	*/
	
	//this statement should stay, as the screen should be plotted whenever we are in the draw state
	assign writeEn = plot_screen;	//plot_screen isn't actually worthless; it is needed because writeEn needs to be high for all
												//time when the state is "plot", otherwise the plot won't plot everything it should be plotting
	/*
	always @(*)begin	//always block to consider the clear state
		if (erase_block == 1)
			assign colour[2:0] = 3'b000;
		else
			assign colour[2:0] = SW[9:7];
	end*/
	//the input to position in datapath needs to be changed.
	
	datapath D0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.plot_screen(plot_screen),
		.waiting_for_move(waiting_for_move),
		
		.eU(eU),
		.eUi(eUi),
		
		.eD(eD),
		.eDi(eDi),
		
		.eR(eR),
		.eRi(eRi),
		
		.eL(eL),
		.eLi(eLi),
		
		.eF(eF),
		.eFi(eFi),
		
		.eB(eB),
		.eBi(eBi),
		
		.eX(eX),
		.eXi(eXi),
		
		.eY(eY),
		.eYi(eYi),
		
		.eZ(eZ),
		.eZi(eZi),
		
		.X(x),
		.Y(y),
		.colour(colour),
		.plot_count(plot_count)
		);

	control C0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.plot_count(plot_count),
		.move_to_make(move_to_make),
		.go(go),
		
		.plot_screen(plot_screen),
		.eU(eU),
		.eUi(eUi),
		
		.eD(eD),
		.eDi(eDi),
		
		.eR(eR),
		.eRi(eRi),
		
		.eL(eL),
		.eLi(eLi),
		
		.eF(eF),
		.eFi(eFi),
		
		.eB(eB),
		.eBi(eBi),
		
		.eX(eX),
		.eXi(eXi),
		
		.eY(eY),
		.eYi(eYi),
		
		.eZ(eZ),
		.eZi(eZi),
		.waiting_for_move(waiting_for_move)

	);
	

	
endmodule

/*module datapath(
	input clk, 	
	input resetn,
	input plot_screen,	//not sure if this input is truly necessary at the moment
	input flip_up_down,
	input flip_left_right,
	//input enable_delay_count,	//enabler for delay_count is useless as it should be incrementing on every clock edge without fail
	input enable_frame_count,
	input enable_move,
	//list any future inputs that arise here

	/*input [6:0] position,
	input ld_x,
	input ld_y,
	input plot_screen,
	input incX,
	input incY,
	
	//depreciated inputs from part 2
	
	output reg [7:0] X,
	output reg [6:0] Y,
	output reg up_down,
	output reg left_right,
	output reg [19:0] delay_count,
	output reg [3:0] frame_count
	output reg [4:0] plot_count
	//list any future outputs that arise here

	);*/
	//the above is the old version of the header

	
	
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	
module datapath(
	//list inputs here
	input clk,
	input resetn,
	input eU, eUi, eD, eDi, eL, eLi, eR, eRi, eF, eFi, eB, eBi, eX, eXi, eY, eYi, eZ, eZi,
	input waiting_for_move,
	input plot_screen,

	//list outputs here
	/*
	output reg[2:0] p0, p1, p2, p3,		//registers for the top face
	output reg[2:0] p4, p5, p6, p7,		//registers for the right face
	output reg[2:0] p8, p9, p10, p11,	//registers for the front face
	output reg[2:0] p12, p13, p14, p15,	//registers for the down face 
	output reg[2:0] p16, p17, p18, p19,	//registers for the left face 
	output reg[2:0] p20, p21, p22, p23,	//registers for the back face
	*/
	output reg[10:0]plot_count,
	output reg[7:0] X,
	output reg[6:0] Y,
	output reg[2:0] colour
	);
	reg[2:0] p0, p1, p2, p3;		//registers for the top face
	reg[2:0] p4, p5, p6, p7;		//registers for the right face
	reg[2:0] p8, p9, p10, p11;	//registers for the front face
	reg[2:0] p12, p13, p14, p15;	//registers for the down face 
	reg[2:0] p16, p17, p18, p19;	//registers for the left face 
	reg[2:0] p20, p21, p22, p23;	//registers for the back face
	//assign local parameters for the colours
		//re-assigning the local parameters for the colours to match
			//with the actual colour codes
		//also going to modify orange into magenta because there is 
			//no orange colour within  the 8 colours that they give us
	localparam	WHITE 	=	3'b111,	//RGB colour code for white
			ORANGE	=	3'b101,	//still calling it "orange" even though
											//it is magenta
			BLUE	=	3'b011,		//making the blue a light blue for
											//better contrast
			RED	=	3'b100,		//RGB colour code for red
			GREEN	=	3'b010,		//RGB colour code for green
			YELLOW	=	3'b110,	//RGB colour code for yellow
			
			net_top_left_x = 4'd4,
			net_top_left_y = 4'd4,
			TEST_COLOUR = 3'b001, //make the test colour dark blue (not being used anywhere else within the program)
			tile_width = 2'd3, //test to make tile size
			border_width = 1'd1, //test var for border width
			spacing_width = 1'd1, //test var for spacing width
			face_width = 4'd9;
		
	always @(posedge clk) begin
		if(!resetn) begin
			colour <= TEST_COLOUR;
			//reset the top face to white
			p0 <= WHITE;
			p1 <= WHITE;
			p2 <= WHITE;
			p3 <= WHITE;
			
			//reset the right face to red
			p4 <= RED;
			p5 <= RED;
			p6 <= RED;
			p7 <= RED;

			//reset the front face to green
			p8 <= GREEN;
			p9 <= GREEN;
			p10 <= GREEN;
			p11 <= GREEN;
			
			//reset the down face to yellow
			p12 <= YELLOW;
			p13 <= YELLOW;
			p14 <= YELLOW;
			p15 <= YELLOW;

			//reset the left face to orange
			p16 <= ORANGE;
			p17 <= ORANGE;	
			p18 <= ORANGE;
			p19 <= ORANGE;
			
			//reset the back face to blue
			p20 <= BLUE;
			p21 <= BLUE;
			p22 <= BLUE;
			p23 <= BLUE;
		
			plot_count = 11'b0;
			X = 8'b0;
			Y = 7'b0;
		end	//reset
		else begin
			//*****Determine if you need to set the values that will not be changing to themselves
			if(plot_screen) begin	//the first step in plotting the screen is just plotting the part of the screen out that will be used for the cube net
				
				if(plot_count[5:0] <= 6'd38)
					X <= (net_top_left_x + plot_count[5:0]);
				else
					X <= (net_top_left_x + 6'd38);
				if(plot_count[10:6] <= 5'd28)
					Y <= (net_top_left_y + plot_count[10:6]);
				if(plot_count[5:0] >= (1) && plot_count[5:0] <= (3)) begin
					if(plot_count[10:6] >= (face_width+border_width+spacing_width) && plot_count[10:6] <= (face_width+border_width+spacing_width+2))
						colour <= p16;
					if(plot_count[10:6] >= (face_width+2*border_width+spacing_width+tile_width) && plot_count[10:6] <= (face_width+2*border_width+spacing_width+tile_width + 2))
						colour <= p18;
				end//column for p16, p18
				else if (plot_count[5:0] >= (border_width+tile_width+border_width) && plot_count[5:0] <= (border_width+tile_width+border_width + 2)) begin
					if(plot_count[10:6] >= (face_width+border_width+spacing_width) && plot_count[10:6] <= (face_width+border_width+spacing_width+2))
						colour <= p17;
					if(plot_count[10:6] >= (face_width+2*border_width+spacing_width+tile_width) && plot_count[10:6] <= (face_width+2*border_width+spacing_width+tile_width + 2))
						colour <= p19;
				end//column for p17, p19
				else if(plot_count[5:0] >= (face_width + 1*spacing_width+border_width) && plot_count[5:0] <= (face_width + 1*spacing_width+border_width + 2))begin
					if(plot_count[10:6] >= (1) && plot_count[10:6] <= 3)
						colour <= p0;
					if(plot_count[10:6] >= (border_width*2 + tile_width) && plot_count[10:6] <= (border_width*2 + tile_width + 2))
						colour <= p2;
					if(plot_count[10:6] >= (face_width+border_width+spacing_width) && plot_count[10:6] <= (face_width+border_width+spacing_width+2))
						colour <= p8;
					if(plot_count[10:6] >= (face_width+2*border_width+spacing_width+tile_width) && plot_count[10:6] <= (face_width+2*border_width+spacing_width+tile_width + 2))
						colour <= p10;
					if(plot_count[10:6] >= (2*face_width + 2*spacing_width +border_width) && plot_count[10:6] <= (2*face_width + 2*spacing_width +border_width + 2))
						colour <= p12;
					if(plot_count[10:6] >= (2*face_width + 2*spacing_width + border_width + tile_width + border_width) && plot_count[10:6] <= (2*face_width + 2*spacing_width + border_width + tile_width + border_width + 2))
						colour <= p14;
				end//column for p0, p2, p8, p10, p12, p14
				else if(plot_count[5:0] >= (face_width + 1*spacing_width + 2*border_width+tile_width) && plot_count[5:0] <= (face_width + 1*spacing_width + 2*border_width+tile_width + 2))begin
					if(plot_count[10:6] >= (1) && plot_count[10:6] <= 3)
						colour <= p1;
					if(plot_count[10:6] >= (border_width*2 + tile_width) && plot_count[10:6] <= (border_width*2 + tile_width + 2))
						colour <= p3;
					if(plot_count[10:6] >= (face_width+border_width+spacing_width) && plot_count[10:6] <= (face_width+border_width+spacing_width+2))
						colour <= p9;
					if(plot_count[10:6] >= (face_width+2*border_width+spacing_width+tile_width) && plot_count[10:6] <= (face_width+2*border_width+spacing_width+tile_width + 2))
						colour <= p11;
					if(plot_count[10:6] >= (2*face_width + 2*spacing_width +border_width) && plot_count[10:6] <= (2*face_width + 2*spacing_width +border_width + 2))
						colour <= p13;
					if(plot_count[10:6] >= (2*face_width + 2*spacing_width + border_width + tile_width + border_width) && plot_count[10:6] <= (2*face_width + 2*spacing_width + border_width + tile_width + border_width + 2))
						colour <= p15;
				end//column for p1, p3, p9, p11, p13, p15
				else if(plot_count[5:0] >= (2*face_width + 2*spacing_width) && plot_count[5:0] <= (2*face_width + 2*spacing_width + 2)) begin
					if(plot_count[10:6] >= (face_width+border_width+spacing_width) && plot_count[10:6] <= (face_width+border_width+spacing_width+2))
						colour <= p4;
					if(plot_count[10:6] >= (face_width+2*border_width+spacing_width+tile_width) && plot_count[10:6] <= (face_width+2*border_width+spacing_width+tile_width + 2))
						colour <= p6;
				end//column for p4, p6
				else if(plot_count[5:0] >= (2*face_width + 2*spacing_width + 2*border_width + tile_width) && plot_count[5:0] <= (2*face_width + 2*spacing_width + 2*border_width + tile_width + 2)) begin
					if(plot_count[10:6] >= (face_width+border_width+spacing_width) && plot_count[10:6] <= (face_width+border_width+spacing_width+2))
						colour <= p5;
					if(plot_count[10:6] >= (face_width+2*border_width+spacing_width+tile_width) && plot_count[10:6] <= (face_width+2*border_width+spacing_width+tile_width + 2))
						colour <= p7;
				end //column for p5, p7
				else if (plot_count[5:0] >= (3*face_width + 3*spacing_width + border_width) && plot_count[5:0] <= (3*face_width + 3*spacing_width + border_width + 2)) begin
					if(plot_count[10:6] >= (face_width+border_width+spacing_width) && plot_count[10:6] <= (face_width+border_width+spacing_width+2))
						colour <= p20;
					if(plot_count[10:6] >= (face_width+2*border_width+spacing_width+tile_width) && plot_count[10:6] <= (face_width+2*border_width+spacing_width+tile_width + 2))
						colour <= p22;
				end //column for p20, p22
				else if(plot_count[5:0] >= (3*face_width + 3*spacing_width + 2*border_width + tile_width) && plot_count[5:0] <= (3*face_width + 3*spacing_width + 2*border_width + tile_width + 2)) begin
					if(plot_count[10:6] >= (face_width+border_width+spacing_width) && plot_count[10:6] <= (face_width+border_width+spacing_width+2))
						colour <= p21;
					if(plot_count[10:6] >= (face_width+2*border_width+spacing_width+tile_width) && plot_count[10:6] <= (face_width+2*border_width+spacing_width+tile_width + 2))
						colour <= p23;
				end//column for p21, p23
				else
				colour <= TEST_COLOUR;
				plot_count = plot_count + 1;	//the location of this line of code may not matter
			end	//plot screen

			
			if(waiting_for_move)
				plot_count = 0;
			if(eU) begin
				//changes to the top face
				p0 <= p2;
				p1 <= p0;
				p3 <= p1;
				p2 <= p3;
				
				//no changes to the bottom face

				//changes to the front face
				p8 <= p4;
				p9 <= p5;

				//changes to the right face
				p4 <= p20;
				p5 <= p21;
				
				//changes to the back face
				p20 <= p16;
				p21 <= p17;
				
				//changes to the left face
				p16 <= p8;
				p17 <= p9;
			end//eU
			if (eUi) begin
				//changes to the top face
				p2 <= p0;
				p0 <= p1;
				p1 <= p3;
				p3 <= p2;
				
				//no change to the bottom face
			
				//changes to the front face
				p8 <= p16;
				p9 <= p17;
			
				//changes to the right face
				p4 <= p8;
				p5 <= p9;
		
				//changes to the back face
				p20 <= p4;
				p21 <= p5;
				
				//changes to the left face
				p16 <= p20;
				p17 <= p21;
			end //eUi
			   // down move	
			if(eD) begin
					// top face
					// no change
					
					// down face
					p12 <= p14;
					p13 <= p12;
					p14 <= p15;
					p15 <= p13;
					
					// front face
					p10 <= p18;
					p11 <= p19;
					
					// right face
					p6  <= p10;
					p7  <= p11;
					
					// back face
					p22 <= p6;
					p23 <= p7;
					
					// left face
					p18 <= p22;
					p19 <= p23;
			end //eD
				// Down inverse move
			if(eDi) begin
					// top face
					// no change
					
					// down face
					p12 <= p13;
					p13 <= p15;
					p14 <= p12;
					p15 <= p14;
					
					// front face
					p10 <= p6;
					p11 <= p7;
					
					// right face
					p6  <= p22;
					p7  <= p23;
					
					// back face
					p22 <= p18;
					p23 <= p19;
					
					// left face
					p18 <= p10;
					p19 <= p11;
			end //eDi		
					
				// Left move
         if(eL) begin
					// top face
               				p0  <= p23;
					p2  <= p21;
					
					// down face
					p12 <= p8;
					p14 <= p10;

					// front face
					p8  <= p0;
					p10 <= p2;
					
					// right face
					// NC
		
					// back face
					p21 <= p14;
					p23 <= p12;
					
					// left face
					p16 <= p18;
					p17 <= p16;
					p18 <= p19;
					p19 <= p17;
			end //eL
				// Left inverse move	
         if(eLi) begin
					// top face
   				        p0  <= p8;
					p2  <= p10;
					
					// down face
					p12 <= p23;
					p14 <= p21;
					
					// front face
					p8  <= p12;
					p10 <= p14;
					
					// right face
					// NC

					// back face
					p21 <= p2;
					p23 <= p0;
					
					// left face
					p16 <= p17;
					p17 <= p19;
					p18 <= p16;
					p19 <= p18;
			end //eLi
				
				// Right move
         if(eR) begin
					// top face
					p1  <= p9;
					p3  <= p11;
					
					// down face
					p13 <= p22;
					p15 <= p20;
					
					// front face
					p9  <= p13;
					p11 <= p15;
					
					// right face
					p4  <= p6;
					p5  <= p4;
					p6  <= p7;
					p7  <= p5;
					
					// back face
					p20 <= p3;
					p22 <= p1;
					
					// left face
					// NC
			end//eR	
				// Right inverse move	
         if(eRi) begin
					// top face
					p1  <= p22;
					p3  <= p20;
					
					// down face
					p13 <= p9;
					p15 <= p11;
					
					// front face
					p9  <= p1;
					p11 <= p3;
					
					// right face
					p4  <= p5;
					p5  <= p7;
					p6  <= p4;
					p7  <= p6;
					
					// back face
					p20 <= p15;;
					p22 <= p13;
					
					// left face
					// NC
			end //eRi
				// Front move
         if(eF) begin
					// top face
					p2  <= p19;
					p3  <= p17;
					
					// down face
					p12 <= p6;
					p13 <= p4;
					
					// front face
					p8  <= p10;
					p9  <= p8;
					p10 <= p11;
					p11 <= p9;
					
					// right face
					p4  <= p2;
					p6  <= p3;
					
					// back face
					// NC
					
					// left face
					p17 <= p12;
					p19 <= p13;
			end//eF		
				// Front inverse move	
         if(eFi) begin
					// top face
					p2  <= p4;
					p3  <= p6;
					
					// down face
					p12 <= p17;
					p13 <= p19;
					
					// front face
					p8  <= p9;
					p9  <= p11;
					p10 <= p8;
					p11 <= p10;
					
					// right face
					p4  <= p13;
					p6  <= p12;
					
					// back face
					// NC
					
					// left face
					p17 <= p3;
					p19 <= p2;
			end//eFi
			if(eB) begin
				//changes to the top face
				p0 <= p5;
				p1 <= p7;
				
				//changes to the bottom face
				p15 <= p18;
				p14 <= p16;
				
				//no changes to the front face

				//changes to the right face
				p5 <= p15;
				p7 <= p14;
				
				//changes to the back face
				p20 <= p22;
				p21 <= p20;
				p23 <= p21;
				p22 <= p23;
				
				//changes to the left face
				p16 <= p1;
				p18 <= p0;
			end//eB
			if (eBi) begin
				//changes to the top face
				p0 <= p18;
				p1 <= p16;
				
				//changes to the bottom face
				p15 <= p5;
				p14 <= p7;
				
				//no changes to the front face

				//changes to the right face
				p5 <= p0;
				p7 <= p1;
				
				//changes to the back face
				p20 <= p21;
				p21 <= p23;
				p23 <= p22;
				p22 <= p20;
				
				//changes to the left face
				p16 <= p14;
				p18 <= p15;
			end //eBi
			if(eX) begin
				//changes to the top face
				p0 <= p8;
				p1 <= p9;
				p2 <= p10;
				p3 <= p11;
				
				//changes to the bottom face
				p12 <= p23;
				p13 <= p22;
				p15 <= p20;
				p14 <= p21;
				
				//changes to the front face
				p8 <= p12;
				p9 <= p13;
				p10 <= p14;
				p11 <= p15;

				//changes to the right face
				p4 <= p6;			
				p5 <= p4;
				p7 <= p5;
				p6 <= p7;
				
				//changes to the back face
				p20 <= p3;
				p21 <= p2;
				p23 <= p0;
				p22 <= p1;
				
				//changes to the left face
				p16 <= p17;
				p18 <= p16;
				p17 <= p19;
				p19 <= p18;
			end //eX
			if(eXi) begin
				//changes to the top face
				p0 <= p23;
				p1 <= p22;
				p2 <= p21;
				p3 <= p20;
				
				//changes to the bottom face
				p12 <= p8;
				p13 <= p9;
				p15 <= p11;
				p14 <= p10;
				
				//changes to the front face
				p8 <= p0;
				p9 <= p1;
				p10 <= p2;
				p11 <= p3;

				//changes to the right face
				p4 <= p5;			
				p5 <= p7;
				p7 <= p6;
				p6 <= p4;
				
				//changes to the back face
				p20 <= p15;
				p21 <= p14;
				p23 <= p12;
				p22 <= p13;
				
				//changes to the left face
				p16 <= p18;
				p18 <= p19;
				p17 <= p16;
				p19 <= p17;
			end //eXi
			if (eY) begin
				//changes to the top face
				p0 <= p2;
				p1 <= p0;
				p2 <= p3;
				p3 <= p1;
				
				//changes to the bottom face
				p12 <= p13;
				p13 <= p15;
				p15 <= p14;
				p14 <= p12;
				
				//changes to the front face
				p8 <= p4;
				p9 <= p5;
				p10 <= p6;
				p11 <= p7;

				//changes to the right face
				p4 <= p20;			
				p5 <= p21;
				p7 <= p23;
				p6 <= p22;
				
				//changes to the back face
				p20 <= p16;
				p21 <= p17;
				p23 <= p19;
				p22 <= p18;
				
				//changes to the left face
				p16 <= p8;
				p18 <= p10;
				p17 <= p9;
				p19 <= p11;
			end // eY
			if (eYi) begin
				//changes to the top face
				p0 <= p1;
				p1 <= p3;
				p2 <= p0;
				p3 <= p2;
				
				//changes to the bottom face
				p12 <= p14;
				p13 <= p12;
				p15 <= p13;
				p14 <= p15;
				
				//changes to the front face
				p8 <= p16;
				p9 <= p17;
				p10 <= p18;
				p11 <= p19;

				//changes to the right face
				p4 <= p8;			
				p5 <= p9;
				p7 <= p11;
				p6 <= p10;
				
				//changes to the back face
				p20 <= p4;
				p21 <= p5;
				p23 <= p7;
				p22 <= p6;
				
				//changes to the left face
				p16 <= p20;
				p18 <= p22;
				p17 <= p21;
				p19 <= p23;
			end	//eYi
			if (eZ) begin
				//changes to the top face
				p0 <= p18;
				p1 <= p16;
				p2 <= p19;
				p3 <= p17;
				
				//changes to the bottom face
				p12 <= p6;
				p13 <= p4;
				p15 <= p5;
				p14 <= p7;
				
				//changes to the front face
				p8 <= p10;
				p9 <= p8;
				p10 <= p11;
				p11 <= p9;

				//changes to the right face
				p4 <= p2;			
				p5 <= p0;
				p7 <= p1;
				p6 <= p3;
				
				//changes to the back face
				p20 <= p21;
				p21 <= p23;
				p23 <= p22;
				p22 <= p20;
				
				//changes to the left face
				p16 <= p14;
				p18 <= p15;
				p17 <= p12;
				p19 <= p13;
			end//eZ
			if(eZi) begin				
				//changes to the top face
				p0 <= p5;
				p1 <= p7;
				p2 <= p4;
				p3 <= p6;
				
				//changes to the bottom face
				p12 <= p17;
				p13 <= p19;
				p15 <= p18;
				p14 <= p16;
				
				//changes to the front face
				p8 <= p9;
				p9 <= p11;
				p10 <= p8;
				p11 <= p10;

				//changes to the right face
				p4 <= p13;			
				p5 <= p15;
				p7 <= p14;
				p6 <= p12;
				
				//changes to the back face
				p20 <= p22;
				p21 <= p20;
				p23 <= p21;
				p22 <= p23;
				
				//changes to the left face
				p16 <= p1;
				p18 <= p0;
				p17 <= p3;
				p19 <= p2;
			end//eZi
		end	//non-reset
	end	//always block
	//I think this is solid datapath logic, onto the control module (i.e. the FSM)
			
	//depreciated part 2 datapath logic
			/*
			if(plot_screen == 1 && incX == 1) begin
					x_count <= x_count + 1;
				X <= X + 1;	//X+x_count will fail in logic
				Y <= Y;
			end
			else if(plot_screen == 1 && incY == 1) begin
				y_count <= y_count + 1;
				x_count <= 2'b0;
				Y <= Y + 1;
				X <= X - 4;

			end
			else if (plot_screen == 1) begin
				y_count <= 2'b0;
				x_count <= 2'b0;
				Y <= Y - 4;
				X <= X - 4;
			end
			else if(ld_x) begin
				X <= {1'b0, position[6:0]};
			end
			else if(ld_y)
				Y <= position;
			*/
endmodule

module control(
	//the inputs of the control module should at least encompass the outputs of the datapath module
	input clk,
	input resetn,
	
	/*
	input [19:0] delay_count,
	input [3:0] frame_count,
	input left_right,
	input up_down,
	input [7:0] X,
	input [6:0] Y,
	input [4:0] plot_count,
	//the above inputs encompass everything that datapath is outputting

	output reg enable_move,
	output reg enable_frame_count,
	output reg flip_up_down,
	output reg flip_left_right,
	output reg plot_screen,
	output reg erase_block
	//list of depreciated inputs and outputs from part 2
*/
	input go,
	input [10:0] plot_count,
	input [4:0] move_to_make,
	//list any other inputs to the control module here as they come up
	//the control module also requires the input that shifts between loading x and y
		//as well as ts he input that goes from loading y to plotting the square onto the screen
	output reg plot_screen,
	output reg eU, eUi, eD, eDi, eL, eLi, eR, eRi, eF, eFi, eB, eBi, eX, eXi, eY, eYi, eZ, eZi, 
	output reg waiting_for_move
	
	//output reg [1:0] x_count, y_count
	//list any other outputs from the control module here as they come up
	);
	//the header for this module needs to be updated based on the new inputs and outputs for this program




	//will need something for the current "state"
	
	reg [6:0] current_state, next_state; 	//variables of type reg because their values will
												//be assigned within always blocks
	//reg [1:0]x_count;	//not sure if these shall be reg or wire, but i think they need to be reg as they will be incremented within an always block
	//reg [1:0]y_count;	//not sure if these shall be reg or wire, but I think they need to be reg as they will be incremented within an always block
	//you CANNOT assign a value for x_count and y_count here, otherwise it'll stay that value forever.
		//this is NOT software. (welcome to hardware!)
	
	
	//localparams used within the always blocks in state logic (to make the state logic easier to
		//to read without having to memorize exactly which string of bits corresponds to which state
	localparam 	S_WAIT 		=	6'd0,
				S_M_LEFT 	=	6'd1,
				S_M_LEFT_WAIT	= 	6'd2,
				S_M_LEFT_P	=	6'd3,
				S_M_LEFT_P_WAIT	=	6'd4,
				S_M_RIGHT 	= 	6'd5,
				S_M_RIGHT_WAIT	=	6'd6,
				S_M_RIGHT_P	=	6'd7,
				S_M_RIGHT_P_WAIT=	6'd8,
				S_M_UP		= 	6'd9,
				S_M_UP_WAIT	=	5'd10,
				S_M_UP_P 	= 	6'd11,
				S_M_UP_P_WAIT	=	6'd12,
				S_M_DOWN	=	6'd13,
				S_M_DOWN_WAIT	=	6'd14,
				S_M_DOWN_P	=	6'd15,
				S_M_DOWN_P_WAIT	=	6'd16,
				S_M_FRONT	=	6'd17,
				S_M_FRONT_WAIT	= 	6'd18,
				S_M_FRONT_P	=	6'd19,
				S_M_FRONT_P_WAIT=	6'd20,
				S_M_BACK 	=	6'd21,
				S_M_BACK_WAIT	=	6'd22,
				S_M_BACK_P	=	6'd23,
				S_M_BACK_P_WAIT	=	6'd24,
				S_ROTATE_X	=	6'd25,
				S_ROTATE_X_WAIT = 	6'd26,
				S_ROTATE_X_P	=	6'd27,
				S_ROTATE_X_P_WAIT = 	6'd28,
				S_ROTATE_Y	=	6'd29,
				S_ROTATE_Y_WAIT	=	6'd30,
				S_ROTATE_Y_P	=	6'd31,
				S_ROTATE_Y_P_WAIT = 	6'd32,
				S_ROTATE_Z	=	6'd33,
				S_ROTATE_Z_WAIT	=	6'd34,
				S_ROTATE_Z_P	=	6'd35,
				S_ROTATE_Z_P_WAIT = 6'd36,
				S_PLOT_SCREEN = 6'd37; //this plot may or may not need to be split up into plot_net and plot_3d

				//may need to add two more states, one per each flip of the up/down
				//n'dx means n bits of binary holding x (in base 10)
				
	always @(*)	//this is triggered whenever an input change is detected
			//the state table should now be done, and it should work for whatever we are asking for
	begin: state_table 
		case (current_state)
			S_WAIT: begin
				//
				if(go == 0)
					next_state = S_WAIT;
				else begin
					case (move_to_make)
						5'd0: next_state = S_M_UP_WAIT;
						5'd1: next_state = S_M_UP_P_WAIT;
						5'd2: next_state = S_M_DOWN_WAIT;
						5'd3: next_state = S_M_DOWN_P_WAIT;
						5'd4: next_state = S_M_LEFT_WAIT;
						5'd5: next_state = S_M_LEFT_P_WAIT;
						5'd6: next_state = S_M_RIGHT_WAIT;
						5'd7: next_state = S_M_RIGHT_P_WAIT;
						5'd8: next_state = S_M_FRONT_WAIT;
						5'd9: next_state = S_M_FRONT_P_WAIT;
						5'd10: next_state = S_M_BACK_WAIT;
						5'd11: next_state = S_M_BACK_P_WAIT;
						5'd12: next_state = S_ROTATE_X_WAIT;
						5'd13: next_state = S_ROTATE_X_P_WAIT;
						5'd14: next_state = S_ROTATE_Y_WAIT;
						5'd15: next_state = S_ROTATE_Y_P_WAIT;
						5'd16: next_state = S_ROTATE_Z_WAIT;
						5'd17: next_state = S_ROTATE_Z_P_WAIT;
						default: next_state =  S_M_UP_WAIT;
					endcase
				end
			end
				//next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;	//note: with the way that I've set this up, I need to make sure that go = ~KEY[3]
			//code that determines next state for up and up inverse
			S_M_UP_WAIT: next_state = go ? S_M_UP_WAIT : S_M_UP;
			S_M_UP: next_state = S_PLOT_SCREEN;
			S_M_UP_P_WAIT: next_state = go ? S_M_UP_P_WAIT : S_M_UP_P;
			S_M_UP_P: next_state = S_PLOT_SCREEN;
	
			//code that determines next state for down and down inverse
			S_M_DOWN_WAIT: next_state = go ? S_M_DOWN_WAIT : S_M_DOWN;
			S_M_DOWN: next_state = S_PLOT_SCREEN;
			S_M_DOWN_P_WAIT: next_state = go ? S_M_DOWN_P_WAIT : S_M_DOWN_P;
			S_M_DOWN_P: next_state = S_PLOT_SCREEN;
			
			//code that determines next state for left and let inverse
			S_M_LEFT_WAIT: next_state = go ? S_M_LEFT_WAIT : S_M_LEFT;
			S_M_LEFT: next_state = S_PLOT_SCREEN;
			S_M_LEFT_P_WAIT: next_state = go ? S_M_LEFT_P_WAIT : S_M_LEFT_P;
			S_M_LEFT_P: next_state = S_PLOT_SCREEN;
				
			//code that determines next state for right and right inverse
			S_M_RIGHT_WAIT: next_state = go ? S_M_RIGHT_WAIT : S_M_RIGHT;
			S_M_RIGHT: next_state = S_PLOT_SCREEN;
			S_M_RIGHT_P_WAIT: next_state = go ? S_M_RIGHT_P_WAIT : S_M_RIGHT_P;
			S_M_RIGHT_P: next_state = S_PLOT_SCREEN;
	
			//code that determines the next state for the front and front inverse moves
			S_M_FRONT_WAIT: next_state = go ? S_M_FRONT_WAIT : S_M_FRONT;
			S_M_FRONT: next_state = S_PLOT_SCREEN;
			S_M_FRONT_P_WAIT: next_state = go ? S_M_FRONT_P_WAIT : S_M_FRONT_P;
			S_M_FRONT_P: next_state = S_PLOT_SCREEN;

			//code that determines the next state for the back and back inverse moves
			S_M_BACK_WAIT: next_state = go ? S_M_BACK_WAIT : S_M_BACK;
			S_M_BACK: next_state = S_PLOT_SCREEN;
			S_M_BACK_P_WAIT: next_state = go ? S_M_BACK_P_WAIT : S_M_BACK_P;
			S_M_BACK_P: next_state = S_PLOT_SCREEN;

			//code that determines the next state for the rotate x and x inverse moves
			S_ROTATE_X_WAIT: next_state = go ? S_ROTATE_X_WAIT : S_ROTATE_X;
			S_ROTATE_X: next_state = S_PLOT_SCREEN;
			S_ROTATE_X_P_WAIT: next_state = go ? S_ROTATE_X_P_WAIT : S_ROTATE_X_P;
			S_ROTATE_X_P: next_state = S_PLOT_SCREEN;

			//code that determines the next state for the rotate Y and Y inverse moves
			S_ROTATE_Y_WAIT: next_state = go ? S_ROTATE_Y_WAIT : S_ROTATE_Y;
			S_ROTATE_Y: next_state = S_PLOT_SCREEN;
			S_ROTATE_Y_P_WAIT: next_state = go ? S_ROTATE_Y_P_WAIT : S_ROTATE_Y_P;
			S_ROTATE_Y_P: next_state = S_PLOT_SCREEN;

			//code that determines the next state for the rotate Z and Z inverse moves
			S_ROTATE_Z_WAIT: next_state = go ? S_ROTATE_Z_WAIT : S_ROTATE_Z;
			S_ROTATE_Z: next_state = S_PLOT_SCREEN;
			S_ROTATE_Z_P_WAIT: next_state = go ? S_ROTATE_Z_P_WAIT : S_ROTATE_Z_P;
			S_ROTATE_Z_P: next_state = S_PLOT_SCREEN;
			
			S_PLOT_SCREEN: next_state = (plot_count[10:6] >= 5'd29) ? S_WAIT : S_PLOT_SCREEN;
			//next_state = S_LOAD_X;								//this line may have to be modified after the functionality for clearing the board is added
		default: next_state = S_WAIT;
		endcase
	end //state_table
	
	always @(*)
	begin: enable_signals 
		//making all output (enable) signals 0 to avoid latches
		eU = 0;
		eUi = 0;
		eD = 0;
		eDi = 0;
		eL = 0;		
		eLi = 0;
		eR = 0;
		eRi = 0;
		eF = 0;
		eFi = 0;
		eB = 0;
		eBi = 0;
		eX = 0;
		eXi = 0;
		eY = 0;
		eYi = 0;
		eZ = 0;
		eZi = 0;
		plot_screen = 0;
		waiting_for_move = 0;
		//may have to add default values for x_count and y_count here
		//x_screen = x_position;	//if the state is not the plot state, then the outputs to the screen should be the same as the inputs to the module
		//y_screen = y_position;
		//x_count = 2'b0;
		//y_count = 2'b0;
		
		//I don't think x_count and y_count need to be reset to zero every time, seeing as though they need to be incremented every clock cycle
			//maybe it would be correct to put the x_count and y_count default values here to be zero, as they are incremented in succession within
				//plot => the default values won't be invoked until it goes through the entire plot cycle
		//x_count = 0;
		//y_count = 0;
		//there will probably be other output enable signals that you have to add here later on
		//i.e. an output that tells the program to plot to the screen
		case (current_state)
			S_WAIT: waiting_for_move = 1;
			S_M_UP: eU = 1;
			S_M_UP_P: eUi = 1;
			S_M_DOWN: eD = 1;
			S_M_DOWN_P: eDi = 1;
			S_M_LEFT: eL = 1;
			S_M_LEFT_P: eLi = 1;
			S_M_RIGHT: eR = 1;
			S_M_RIGHT_P: eRi = 1;
			S_M_FRONT: eF = 1;
			S_M_FRONT_P: eFi = 1;
			S_M_BACK: eB = 1;
			S_M_BACK_P: eBi = 1;
			S_ROTATE_X: eX = 1;
			S_ROTATE_X_P: eXi = 1;	
			S_ROTATE_Y: eY = 1;
			S_ROTATE_Y_P: eYi = 1;
			S_ROTATE_Z: eZ = 1;
			S_ROTATE_Z_P: eZi = 1;
			S_PLOT_SCREEN: plot_screen = 1;
			//no default needed because the default values set above
		endcase
	end //enable signals
	
	always @(posedge clk)
	begin: state_FFs //once again, state_FFs seems to be the name that is assigned to this always block
		if (!resetn) begin
			current_state <= S_WAIT;
		end
		else
			current_state <= next_state;
	end
endmodule
//that should do it for the control module => all of my nitty gritty verilog code is now done
	//so the last thing I should finish is getting my fill module to reflect these changes

//Zaman's code
/*
`timescale 1 ns/ 1 ns

module control (
					input [4:0] move,
					output reg ld_x
					);
	
	reg [5:0] current_state, next_state;
	
	localparam  Wait =        6'd0,
					mLeft =       6'd1,
					mLeftwait =   6'd2, 
					mLeftP =      6'd3,
					mLeftPWait =  6'd4,
					mRight =      6'd5,
					mRightWait =  6'd6,
					mRightP =     6'd7,
					mRightPWait = 6'd8,
					mUp =         6'd9,
					mUpWait =     6'd10,
					mUpP =        6'd11,
					mUpPWait =    6'd12,
					mDown =       6'd13,
					mDownWait =   6'd14,
					mDownP =      6'd15,
					mDownPWait =  6'd16,
					mFront =      6'd17,
					mFrontWait =  6'd18,
					mFrontP =     6'd19,
					mFrontPWait = 6'd20,
					mBack =       6'd21,
					mBackWait =   6'd22,
					mBackP =      6'd23,
					mBackPWait =  6'd24,
					rotX =        6'd25,
					rotXWait =    6'd26,
					rotXP=        6'd27,
					rotXPWait =   6'd28,
					rotY =        6'd29,
					rotYWait =    6'd30,
					rotYP =       6'd31,
					rotYPWait =   6'd32,
					rotZ =        6'd33,
					rotZWait =    6'd34,
					rotZP =       6'd35,
					rotZPWait =   6'd36;
	
	
	always @(*)
	begin: state_table
		case (current_state)
            
				Wait: begin 
				
				if (go) 
				else
					case (move)
							5'd0: next_state = mUp;
							5'd1: next_state = mUpP;
							5'd2: next_state = mDown;
							5'd3: next_state = mDownP;
							5'd4: next_state = mLeft;
							5'd5: next_state = mLeftP;
							5'd6: next_state = mRight;
							5'd7: next_state = mRightP;
							5'd8: next_state = mFront;
							5'd9: next_state = mFrontP;
							5'd10: next_state = mBack;
							5'd11: next_state = mBackP;
							5'd12: next_state = rotX;
							5'd13: next_state = rotXP;
							5'd14: next_state = rotY;
							5'd15: next_state = rotYP;
							5'd16: next_state = rotZ;
							5'd17: next_state = rotZP;
							default: next_state =  mUp
               
					end
            
				B: begin
                   if(!plt) next_state = B;
                   else next_state = C;
               end
				B_wait: begin
                   if (plt) next_state = B_wait;
                   else next_state = C;
               end
            C: begin
                   if(cnt < 4'b1111) next_state = C;
                   else next_state = A;
               end
				D: begin
                   if(cnt < 4'b1111) next_state = D;
                   else next_state = A;
               end
            /*C_wait: begin
                   //if() next_state = C_wait;
                   //else next_state = A;
						 next_state = A;
               end
            default: next_state = A;
        endcase
    end
*/
