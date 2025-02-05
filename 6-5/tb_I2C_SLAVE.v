module tb_I2C_SLAVE;
    reg CLCK, SCL, DIN, WR;
    wire SDA;
    
    assign SDA=WR==1? DIN:1'bz;
    
    I2C_SLAVE DUT(
        .CLCK(CLCK),
        .SDA(SDA),
        .SCL(SCL)
    );
    initial
        begin 
        // Test SDA as input port
            CLCK=1'b0;
            WR=1;  
            DIN=1; //SDA actually
            SCL=1;
            #5000 DIN=0; //Start
            #10000 SCL=0; 
            #11000 DIN=1; //b7 of Slave Address
            #12000 SCL=1; 
            #13000 SCL=0; 
            #13000 DIN=1; //b6
            #14000 SCL=1;
            #15000 SCL=0; 
            #16000 DIN=0; //b5
            #17000 SCL=1;
            #18000 SCL=0;
            #19000 DIN=0; //b4
            #20000 SCL=1;
            #21000 SCL=0;
            #22000 DIN=0; //b3
            #23000 SCL=1;
            #24000 SCL=0;
            #25000 DIN=1; //b2
            #26000 SCL=1;
            #27000 SCL=0;
            #28000 DIN=0; //b1
            #29000 SCL=1;
            #30000 SCL=0;
            #31000 DIN=0; //Write Mode
            #32000 SCL=1;
            #33000 SCL=0;
            
            #34000 WR=0; //To wait ACK
            #35000 SCL=1;
            #36000 SCL=0;
            
            // ACK check codes should follow
            
            // Can send data to write into the slave.
            
                        
           $finish;
        end
    always #100 CLCK=~CLCK; //system clock
        

endmodule