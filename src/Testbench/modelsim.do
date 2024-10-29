vlib work
vlog -f flist

#Load the design.
vsim -t ps +notimingchecks -gui -voptargs="+acc" work.tb_Seven_Segment_Display
#do wave.do
#Run simulation
#run 150ms
#run 150ms
