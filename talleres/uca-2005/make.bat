sdcc -S -mpic14 -p16f877 %1.c  
gpasm -c %1.asm 
gplink -o %1.hex -a inhx8m %1.o
