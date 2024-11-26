onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab7_top_tb/DUT/KEY
add wave -noupdate /lab7_top_tb/DUT/SW
add wave -noupdate /lab7_top_tb/DUT/LEDR
add wave -noupdate /lab7_top_tb/DUT/HEX0
add wave -noupdate /lab7_top_tb/DUT/HEX1
add wave -noupdate /lab7_top_tb/DUT/HEX2
add wave -noupdate /lab7_top_tb/DUT/HEX3
add wave -noupdate /lab7_top_tb/DUT/HEX4
add wave -noupdate /lab7_top_tb/DUT/HEX5
add wave -noupdate /lab7_top_tb/DUT/clk
add wave -noupdate /lab7_top_tb/DUT/mem_addr
add wave -noupdate /lab7_top_tb/DUT/write
add wave -noupdate /lab7_top_tb/DUT/dout
add wave -noupdate /lab7_top_tb/DUT/write_data
add wave -noupdate /lab7_top_tb/DUT/mem_cmd
add wave -noupdate /lab7_top_tb/DUT/read_data
add wave -noupdate /lab7_top_tb/DUT/load_ledr
add wave -noupdate /lab7_top_tb/DUT/Z
add wave -noupdate /lab7_top_tb/DUT/N
add wave -noupdate /lab7_top_tb/DUT/V
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {468 ps} {532 ps}
