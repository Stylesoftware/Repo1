# Tang-Nano-FIFO-IP-Example
Exploring the timing of the FIFO IP from Gowin, setup for the Tang Nano.

### The problem
After reading the documentation, I found there were no code examples and no explaination as to how many ticks I need to wait before releasing the fifo_read_enable or fifo_write_enable registers.
So I had to investigate.

### How to figure it out
Write a state machine to find out when to trigger fifo_write_enable and fifo_read_enable and when to turn them off.  

### How it works
Write 3 bytes to the FIFO.
Wait for fifo_empty to be turned off.
Read 3 bytes from the FIFO.
Confirm each byte by turning on one of the 3 Tang Nano LED elements.

### Conclusion
For the Tang Nano FIFO IP to succeed, both the fifo_write_enable and fifo_read_enable have to be left alone for 3 ticks before they can be turned off.

### Check the timing
Change the position of write_enable=0 or read_enable=0 up one or more case positions.
Each case up-change will 

### Setup
In the GOWIN FPGA Designer, start a new project.
Add the FIFO IP by clicking on the Tools Menu / IP Core Generator.
Untick Almost Full and Almost Empty.
Tick Output Registers Selected.
Set Read and Write Depth to 16.
Set Read and Write Width to 8.
Click OK, then Add to your project when asked.
Add the two files in this GIT (TOP.v and constrains.cst) to your FPGA project.

### Literature
Search for the "Gowin FIFO User guide".
