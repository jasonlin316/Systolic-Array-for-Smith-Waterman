# Systolic Array for Smith-Waterman
This work implements the Smith-Waterman, a dynamic programming algorithm for performing local sequence alignment. The process can be accelerated through parallelism.  
An architecture called systolic array was implemented to realize parallel computing, resulting the complexity to drop from O(mn) to O(m+n) where m and n is the length of reference genome and short read.By doing so, we decrease the execution time sharply.  
Still, the amount of PEs is limited so we need to divide the similarity matrix into sub- matrices and finish the calculation in several iteration,resulting a fall in performance.  

## Usage
### Software Simulation : 
1. To see one read, simply execute the “demo” program, by typing ./demo in the command line.
The result will be saved in ans.csv in the verilog code folder.
2. To execute many read, execute the “goldenDataGenerator”  
This program will automatically read in all the data saved in in_1.dat and convert them into encoded file and save in BinaryInput.dat.  
If you want to test your own DNA sequences, change the contents in in_1.dat .   
3. To change the scoring criteria of goldenDataGenerator, open Golden.cpp and change line14 ~ line17.  
After that, type: _g++ -o goldenDataGenerator -O3 generator.cpp Golden.cpp_ to compile. 
4. To change the scoring criteria of demo, open algorithm.cpp and c change line13 ~ line16.   
After that, type: _g++ -o demo -O3 algorithm.cpp_ to compile. 
### Hardware Simulation:
The hardware was simulated using ncverilog, and APR done by Innovus, using TSMC 130nm technology.  
1. The RTL simulation can be done by typing:  
_ncverilog testfixture.v core.v +notimingchecks_
2. The APR level simulation can be done by typing:  
_ncverilog -f run_APR.f_  
Note that you need to open systolic.v and disable “ \`include sram_1024x8_t13.v” first. 

## Block Diagram

## Layout
## Design Specification
|   Spec   |  Value   |
|-----------|---|
| Frequency | 70MHz  |
| Chip size |  803737 µm^2  |
| PEs | 32  |
| SRAM | 1024x8  |
|  Power    |  13.9 mW |
|  Techonlogy | TSMC 130nm |
## Background
This is originally a course project of Special Project at National Taiwan University,  
lectured by Prof. [Yi-Chang Lu](http://www.ee.ntu.edu.tw/profile?id=709)  
## Reference
1. Implementation of the Smith-Waterman Algorithm on a Reconfigurable Supercomputing Platform, Altera Corporation  
2. C. B. Olson et al., "Hardware Acceleration of Short Read Mapping," 2012 IEEE 20th International Symposium on Field-Programmable Custom Computing Machines, Toronto, ON, 2012, pp. 161-168.  
3. Homer N, Merriman B, Nelson SF (2009) BFAST: An Alignment Tool for Large Scale Genome Resequencing.
