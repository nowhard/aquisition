onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /logic_tb/adc_busy
add wave -noupdate /logic_tb/adc_cnv
add wave -noupdate /logic_tb/adc_miso
add wave -noupdate /logic_tb/adc_shift_reg
add wave -noupdate /logic_tb/analog_mux_chn
add wave -noupdate /logic_tb/clk
add wave -noupdate /logic_tb/cs_dac_reg
add wave -noupdate /logic_tb/dac_reg_mosi
add wave -noupdate /logic_tb/dac_reg_sck
add wave -noupdate /logic_tb/enable
add wave -noupdate /logic_tb/rst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5180671 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {46363617 ps} {60717705 ps}
