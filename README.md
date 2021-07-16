# Tang-Nano-FIFO-IP-Example
Exploring the timing of the FIFO IP from Gowin, setup for the Tang Nano.

### The problem
After reading the documentation, I found there were no code examples and no explaination as to how many ticks I need to wait before releasing the fifo_read_enable or fifo_write_enable registers.
So I had to investigate.

### How to figure it out
Write a state machine to figure out when to turn on fifo_write_enable and fifo_read_enable and when to turn them off.  

### The state machine
Write 3 bytes to the FIFO.
Wait for fifo_empty to be turned off.
Read 3 bytes from the FIFO.
Confirm each byte by turning on one of the 3 Tang Nano LED elements.

### The result
For the Tang Nano FIFO IP to succeed, both the fifo_write_enable and fifo_read_enable have to be left alone for 3 ticks before they can be turned off.

### How to setup for testing
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
