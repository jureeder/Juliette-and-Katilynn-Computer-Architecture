# Copyright 1991-2007 Mentor Graphics Corporation
# 
# Modification by Oklahoma State University
# Use with Testbench 
# James Stine, 2008
# Go Cowboys!!!!!!
#
# All Rights Reserved.
#
# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION
# WHICH IS THE PROPERTY OF MENTOR GRAPHICS CORPORATION
# OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.

# This RF.do file is associated with Katilynn Mar and Juliette Reeder's Lab 0
# Either bring up ModelSim and type the following at the "ModelSim>" prompt:
#     do RF.do
# or, to run from a shell, type the following at the shell prompt:
#     vsim -do RF.do -c
# (omit the "-c" to see the GUI while running from the shell)

# Note that this testbench can be run with either RF_tb.sv or RF_selfcheck_tb.sv. 
# It is currently configured for a self-checking testbench

onbreak {resume}
# create library
if [file exists work] {
    vdel -all
}
vlib work
# compile source files

#uncomment this to run normal testbench:
#vlog RF.sv RF_tb.sv

#uncomment this to run self-checking testbench:
vlog RF.sv RF_selfcheck_tb.sv

# start and run simulation
vsim -voptargs=+acc work.stimulus 
view list
view wave
-- display input and output signals as hexidecimal values
# Diplays All Signals recursively
#add wave -hex -r /stimulus/*

add wave -noupdate -divider -height 32 "Input"
add wave -hex /stimulus/clk
add wave -hex /stimulus/we3
add wave -hex /stimulus/ra1
add wave -hex /stimulus/ra2
add wave -hex /stimulus/wa3
add wave -hex /stimulus/wd3

#this only applies if using self checking testbench
add wave -noupdate -divider -height 32 "Expected Output"
add wave -hex /stimulus/rd1expected
add wave -hex /stimulus/rd2expected

add wave -noupdate -divider -height 32 "Output"
add wave -hex /stimulus/rd1
add wave -hex /stimulus/rd2

-- Set Wave Output Items 
TreeUpdate [SetDefaultTree]
WaveRestoreZoom {0 ps} {75 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
-- Run the Simulation
run 600ns