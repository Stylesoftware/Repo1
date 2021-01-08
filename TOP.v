module TOP (CLOCK,LED_R,LED_G,LED_B);

    input CLOCK;
    output LED_R,LED_G,LED_B;

    reg rR=1'b0;
    reg rG=1'b0;
    reg rB=1'b0;

    assign LED_R = !rR;
    assign LED_G = !rG;
    assign LED_B = !rB;

    reg fifo1_reset;

    reg [7:0] fifo1_in;
    wire [7:0] fifo1_out;
    reg fifo1_read_enable;
    reg fifo1_write_enable;
    wire fifo1_empty;
    wire fifo1_full;

    fifo_top your_instance_name (
        .RdClk(CLOCK),
        .WrClk(CLOCK),
//        .Reset(fifo1_reset),
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
        fifo1_reset <= 1'b0;
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
                WSTATE <= 10;
            end
            10:
            begin
                WSTATE <= 11;
            end
            11:
            begin
                WSTATE <= 12;
            end
            12:
            begin
                fifo1_write_enable = 1'b1;
                fifo1_in <= 8'h65;
                WSTATE <= 1;
            end
            1:
            begin        
                fifo1_in <= 8'h66;
                WSTATE <= 2;
            end
            2:
            begin 
               fifo1_in <= 8'h67;
               WSTATE <= 3;             // Wait 3 more ticks before setting write enable to off
            end
            3:                          // First wait tick
            begin 
               WSTATE <= 4;
            end
            4:                          // Second wait tick
            begin 
               WSTATE <= 5;
            end
            5:                          // Third tick: Set write enable off
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
                    rR = 1'b0;
                    rG = 1'b0;
                    rB = 1'b0;
                    fifo1_read_enable = 1'b1;
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
                    if(fifo1_out == 8'h65)
                    begin
                        rR = 1'b1;
                    end
                    fifo1_read_enable = 1'b0;       // read_enable off on the 3rd tick from read_enable on, if you want only 3 bytes
                    RSTATE <= 4;
                end
                4:                                  // Second byte
                begin
                    if(fifo1_out == 8'h66)        
                    begin
                        rG = 1'b1;
                    end
                    RSTATE <= 5;
                end
                5:                                  // Third byte
                begin
                    if(fifo1_out == 8'h67)
                    begin
                        rB = 1'b1;
                    end
                    RSTATE <= 6;
                end
            endcase
        end
    end
endmodule

