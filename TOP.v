module TOP (CLOCK,LED_R,LED_G,LED_B);           // I/O from the constraints file

    input CLOCK;                                // inputs are naturally regs
    output LED_R,LED_G,LED_B;                   // outputs are naturally wires

    reg rR=1'b0;                                // create some regs for our LEDS
    reg rG=1'b0;
    reg rB=1'b0;

    assign LED_R = !rR;                         // assign the LED wire to the above reg's, but inversed
    assign LED_G = !rG;
    assign LED_B = !rB;

    reg [7:0] fifo_in;                         // all our FIFO requirements
    wire [7:0] fifo_out;
    reg fifo_read_enable;
    reg fifo_write_enable;
    wire fifo_empty;
    wire fifo_full;

    fifo_top your_instance_name (               // instantiate the FIFO IP from Gowin
        .RdClk(CLOCK),
        .WrClk(CLOCK),
        .RdEn(fifo_read_enable),
        .WrEn(fifo_write_enable),
        .Data(fifo_in),
        .Full(fifo_full),
        .Empty(fifo_empty),
        .Q(fifo_out)
    );

    reg [3:0] RSTATE;                       // Counter for the Read state machine below
    reg [3:0] WSTATE;                       // Counter for the Write state machine below

    initial                                 // Init the fifo registers and state machine
    begin
        fifo_write_enable <= 1'b0;
        fifo_read_enable <= 1'b0;
        WSTATE <= 0;
        RSTATE <= 0;
    end

    always @ (posedge CLOCK)      // On every clock edge start the Write state machine
    begin
        case (WSTATE)                       // Each tick only does one of the following cases
            0:
            begin
                fifo_write_enable = 1'b1;   // Enable writing
                fifo_in <= 8'h65;           // Write first byte
                WSTATE <= 1;
            end
            1:
            begin        
                fifo_in <= 8'h66;           // Write second byte
                WSTATE <= 2;
            end
            2:
            begin 
               fifo_in <= 8'h67;            // Write third byte
               WSTATE <= 3;                 // NOTE: Wait 3 more ticks before setting write enable to off
            end
            3:                              // First wait tick
            begin 
               WSTATE <= 4;
            end
            4:                              // Second wait tick
            begin 
               WSTATE <= 5;
            end
            5:                              // Third tick 
            begin 
               fifo_write_enable = 1'b0;    // *** End the write proccess after 3 ticks
               WSTATE <= 6;                 // 6 does't exist so the state machine stops
            end
        endcase

        if(!fifo_empty)          // if the fifo isn't empty run the Read state machine, one case per tick
            begin
            case (RSTATE)
                0:
                begin
                    fifo_read_enable = 1'b1;   // start the read proccess
                    RSTATE <= 1;               // NOTE: Wait 3 ticks before reading each byte
                end                            
                1:                             // First wait tick
                begin                          
                    RSTATE <= 2;               
                end                            
                2:                             // Second wait tick
                begin                          
                    RSTATE <= 3;               
                end                            
                3:                             // Third tick to start reading
                begin	                       
                    if(fifo_out == 8'h65)      // First byte read
                    begin	                   
                        rR = 1'b1;             // Turn the red LED on if the value is correct
                    end	                       
                    fifo_read_enable = 1'b0;   // *** End the read proccess (3 ticks behind and 2 more bytes to read)
                    RSTATE <= 4;	           
                end	                           
                4:                             // Second byte read
                begin	                       
                    if(fifo_out == 8'h66)      
                    begin	                   
                        rG = 1'b1;             // Turn the green LED on if the value is correct
                    end	                       
                    RSTATE <= 5;	           
                end	                           
                5:                             // Third byte read
                begin	                       
                    if(fifo_out == 8'h67)	   
                    begin	                   
                        rB = 1'b1;             // Turn the blue LED on if the value is correct
                    end	                       
                    RSTATE <= 6;               // 6 doesn't exist so the state machine stops
                end
            endcase
        end
    end
endmodule

