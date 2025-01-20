# starter-lab-7

See the Lab 7 handout on Piazza for details of what you need to do and what files
need to be included.  

The directory "assembler" includes source code for 'sas', a program you can use
to automatically convert assembly code into programs to load into memory.  See
further details in assembler/README.txt.  To build 'sas' from the provided source
on your Windows computer, you may need to install cygwin.  Instructions for doing
this can be found in the file cygwinlab7.pdf availalbe on Piazza.

DE1_SoC.qsf includes pins assignments (import in Quartus before synthesis using the 
same procedure used for pb-pins.csv outline in the HDL tutorial). Do not modify this
file.

You will need to create your own lab7_top.sv to demo/test your design on your
DE1-SoC.

Use lab7_autograder_check.sv to test your code is compatible with the
autograder that will be used to assign marks for your submission.  WARNING: The
purpose of the checker file is NOT to tell you if your code is ``correct''.  If
your code does not passing the checks in this file means your code will
certainly get zero marks for the autograded portion.  Passing the checks in
this file DOES NOT mean your code will get full marks.  Your code can pass
these checks and get zero marks.  You still need to test your code using your
own test benches!

Below is a (potentially incomplete) summary of files you need to add (check the 
lab 5, 6 and 7 handout instructions for details on what goes in these and any other
necessary files):

1. Your synthesizable and testbench code in files named:
- cpu.sv
- cpu_tb.sv
- regfile.sv
- alu.sv
- shifter.sv
- datapath.sv
- datapath_tb.sv

You can also include additional (system)verilog files for the logic instantiated in cpu.sv
(e.g., for your controller and/or instruction register).

2. A Quartus Project File (.qpf) and the associated Quartus Settings File
   (.qsf) that indicates which Verilog files are part of your project when
compiling for your DE1-SoC. This .qsf file is created by Quartus when you
create a project.  It is typically named <top_leve_module_name>.qsf (e.g.,
lab6_top.qsf) and contains lines indicating which Verilog files are to be
synthesized.

2. A Modelsim Project File (.mpf) for your testbench simulations including
all synthesizable code files.

3. The binary output file (.sof), generated from your synthesizable SystemVerilog
 used to program your DE1-SoC.  Your TAs may ask you to use the .sof generated when the 
autograder synthesizes your design, if we have it available in time. However, include
the one you generated as a backup to speed up the marking process during your demo.  

