vlib work
vlog -f flist

#Load the design.
vsim -t ps +notimingchecks -gui -voptargs="+acc" work.tb_Top_Module
# add wave -position insertpoint sim:/tb_Top_Module/uut/*
# add wave -position insertpoint sim:/tb_Top_Module/uut/capture_inst/*
# add wave -position insertpoint sim:/tb_Top_Module/uut/processor/*
# add wave -position insertpoint sim:/tb_Top_Module/uut/processor/divider_inst/*
# add wave -position insertpoint sim:/tb_Top_Module/uut/bcd_freq/*
# add wave -position insertpoint sim:/tb_Top_Module/uut/seven_seg_display/*
#do wave.do
#Run simulation
#run 150ms
#run 150ms
