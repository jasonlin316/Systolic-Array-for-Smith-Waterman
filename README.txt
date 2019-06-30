Software Simulation : 

1.To see one read, simply execute the “demo” program, by typing ./demo in the command line.
The result will be saved in ans.csv in the verilog code folder.

2.To execute many read, execute the “goldenDataGenerator”  
This program will automatically read in all the data saved in in_1.dat and convert them into encoded file and save in BinaryInput.dat.
If you want to test your own DNA sequences, change the contents in in_1.dat .
The answer will be saved in out_1.dat, which is the golden data we need to verify our hardware.

3.To change the scoring criteria of goldenDataGenerator, open Golden.cpp and change line14 ~ line17.
After that, type:

g++ -o goldenDataGenerator -O3 generator.cpp Golden.cpp

to compile.

4.To change the scoring criteria of demo, open algorithm.cpp and c change line13 ~ line16.
After that, type:

g++ -o demo -O3 algorithm.cpp

to compile.

Hardware Simulation:

1.The RTL simulation can be done by typing:
ncverilog testfixture.v core.v +notimingchecks

2.The APR level simulation can be done by typing:
ncverilog -f run_APR.f 
Note that you need to open systolic.v and disable “ `include sram_1024x8_t13.v” first.
Also, core_APR.v, core_APR.sdf have to be download and put into this Final Project folder.

APR files download: https://www.space.ntu.edu.tw/navigate/s/38FAE878950F4C3889B478B1D051B345QQY