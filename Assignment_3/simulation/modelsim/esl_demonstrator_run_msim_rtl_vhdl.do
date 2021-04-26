transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_3/timer.vhd}
vcom -93 -work work {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_3/QuadratureEncoder.vhd}
vcom -93 -work work {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_3/esl_demonstrator.vhd}

