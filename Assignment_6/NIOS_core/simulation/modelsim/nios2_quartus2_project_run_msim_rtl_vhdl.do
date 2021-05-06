transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlib first_nios2_system
vmap first_nios2_system first_nios2_system
vlog -vlog01compat -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_reset_controller.v}
vlog -vlog01compat -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_reset_synchronizer.v}
vlog -vlog01compat -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0.v}
vlog -vlog01compat -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_sysid.v}
vlog -vlog01compat -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_sys_clock_timer.v}
vlog -vlog01compat -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_jtag_uart.v}
vlog -vlog01compat -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_onchip_mem.v}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_irq_mapper.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_merlin_arbitrator.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_rsp_xbar_mux_001.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_rsp_xbar_mux.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_rsp_xbar_demux_002.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_rsp_xbar_demux.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_cmd_xbar_mux_002.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_cmd_xbar_mux.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_cmd_xbar_demux_001.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_cmd_xbar_demux.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_merlin_traffic_limiter.sv}
vlog -vlog01compat -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_avalon_sc_fifo.v}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_id_router_002.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_id_router.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_addr_router_001.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/first_nios2_system_mm_interconnect_0_addr_router.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_merlin_slave_agent.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_merlin_burst_uncompressor.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_merlin_master_agent.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_merlin_slave_translator.sv}
vlog -sv -work first_nios2_system +incdir+/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/altera_merlin_master_translator.sv}
vcom -93 -work first_nios2_system {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/first_nios2_system.vhd}
vcom -93 -work first_nios2_system {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/esl_bus_demo.vhdl}
vcom -93 -work first_nios2_system {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/timer.vhdl}
vcom -93 -work first_nios2_system {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/PWM.vhdl}
vcom -93 -work first_nios2_system {/home/esl21/Documents/EmbeddedSystemLaboratoy/Assignment_6/NIOS_core/first_nios2_system/synthesis/submodules/QuadratureEncoder.vhdl}
