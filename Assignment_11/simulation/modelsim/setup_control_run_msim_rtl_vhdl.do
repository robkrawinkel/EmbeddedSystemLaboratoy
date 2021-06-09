transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_11/gpmc_fpga_template/fpga/QuadratureEncoder.vhdl}
vcom -93 -work work {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_11/gpmc_fpga_template/fpga/PWM.vhdl}
vcom -93 -work work {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_11/gpmc_fpga_template/fpga/Communication.vhdl}
vcom -93 -work work {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_11/gpmc_fpga_template/fpga/calibrate.vhdl}
vcom -93 -work work {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_11/gpmc_fpga_template/fpga/ramstix_gpmc_driver.vhd}
vcom -93 -work work {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_11/gpmc_fpga_template/fpga/setup_control.vhd}

