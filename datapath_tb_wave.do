onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /datapath_tb/DUT/clk
add wave -noupdate /datapath_tb/DUT/readnum
add wave -noupdate /datapath_tb/DUT/vsel
add wave -noupdate /datapath_tb/DUT/loada
add wave -noupdate /datapath_tb/DUT/loadb
add wave -noupdate /datapath_tb/DUT/shift
add wave -noupdate /datapath_tb/DUT/asel
add wave -noupdate /datapath_tb/DUT/bsel
add wave -noupdate /datapath_tb/DUT/ALUop
add wave -noupdate /datapath_tb/DUT/loadc
add wave -noupdate /datapath_tb/DUT/loads
add wave -noupdate /datapath_tb/DUT/writenum
add wave -noupdate /datapath_tb/DUT/write
add wave -noupdate /datapath_tb/DUT/sximm8
add wave -noupdate /datapath_tb/DUT/sximm5
add wave -noupdate /datapath_tb/DUT/status_out
add wave -noupdate /datapath_tb/DUT/datapath_out
add wave -noupdate /datapath_tb/DUT/PC
add wave -noupdate /datapath_tb/DUT/mdata
add wave -noupdate /datapath_tb/DUT/data_in
add wave -noupdate /datapath_tb/DUT/data_out
add wave -noupdate /datapath_tb/DUT/status
add wave -noupdate /datapath_tb/DUT/outALU
add wave -noupdate /datapath_tb/DUT/Ain
add wave -noupdate /datapath_tb/DUT/Bin
add wave -noupdate /datapath_tb/DUT/sout
add wave -noupdate /datapath_tb/DUT/outB
add wave -noupdate /datapath_tb/DUT/outA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {150 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
