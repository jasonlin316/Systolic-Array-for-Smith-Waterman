# Systolic Array for Smith-Waterman
This work implements the Smith-Waterman, a dynamic programming algorithm for performing local sequence alignment. The process can be accelerated through parallelism.  
An architecture called systolic array was implemented to realize parallel computing, resulting the complexity to drop from O(mn) to O(m+n) where m and n is the length of reference genome and short read.By doing so, we decrease the execution time sharply.  
Still, the amount of PEs is limited so we need to divide the similarity matrix into sub- matrices and finish the calculation in several iteration,resulting a fall in performance.  

## Usage
