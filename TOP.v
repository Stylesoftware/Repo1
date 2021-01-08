module TOP (CLOCK,LED_R,LED_G,LED_B);

    input CLOCK;
    output LED_R,LED_G,LED_B;

    reg rR=1'b0;
    reg rG=1'b0;
    reg rB=1'b0;

    assign LED_R = !rR;
    assign LED_G = !rG;
    assign LED_B = !rB;

    reg [7:0] fifo1_in;
    wire [7:0] fifo1_out;
    reg fifo1_read_enable;
    reg fifo1_write_enable;
    wire fifo1_empty;
    wire fifo1_full;

    fifo_top your_instance_name (
        .RdClk(CLOCK),
        .WrClk(CLOCK),
        .RdEn(fifo1_read_enable),
        .WrEn(fifo1_write_enable),
        .Data(fifo1_in),
        .Full(fifo1_full),
        .Empty(fifo1_empty),
        .Q(fifo1_out)
    );

    reg [3:0] RSTATE;
    reg [3:0] WSTATE;

    initial
    begin
        fifo1_write_enable <= 1'b0;
        fifo1_read_enable <= 1'b0;
        WSTATE <= 0;
        RSTATE <= 0;
    end

    always @ (posedge CLOCK) 
    begin
        case (WSTATE)
            0:
            begin
                fifo1_write_enable = 1'b1;  // Enable writing
                fifo1_in <= 8'h65;          // Write first byte
                WSTATE <= 1;
            end
            1:
            begin        
                fifo1_in <= 8'h66;          // Write second byte
                WSTATE <= 2;
            end
            2:
            begin 
               fifo1_in <= 8'h67;           // Write thrid byte
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
            5:                              // Third tick: Set write enable off
            begin 
               fifo1_write_enable = 1'b0;
               WSTATE <= 6;
            end
        endcase

        if(!fifo1_empty)
            begin
            case (RSTATE)
                0:
                begin
                    fifo1_read_enable = 1'b1;       // Start the read proccess by enabling this register (fifo1_read_enable)
                    RSTATE <= 1;                    // Wait 3 ticks before reading each byte
                end
                1:                                  // First wait tick
                begin
                    RSTATE <= 2;
                end
                2:                                  // Second wait tick
                begin
                    RSTATE <= 3;
                end
                3:                                  // Third tick to start reading
                begin
                    if(fifo1_out == 8'h65)          // First byte read
                    begin
                        rR = 1'b1;                  // Turn the red LED on if the vaule is correct
                    end
                    fifo1_read_enable = 1'b0;       // End the read proccess by disabling this register (fifo1_read_enable),
                                                    // three ticks from when it was turned on, if you wish to read three bytes.
                    RSTATE <= 4;
                end
                4:                                  // Second byte read
                begin
                    if(fifo1_out == 8'h66)        
                    begin
                        rG = 1'b1;                  // Turn the green LED on if the vaule is correct
                    end
                    RSTATE <= 5;
                end
                5:                                  // Third byte read
                begin
                    if(fifo1_out == 8'h67)
                    begin
                        rB = 1'b1;                  // Turn the green LED on if the vaule is correct
                    end
                    RSTATE <= 6;
                end
            endcase
        end
    end
endmodule

