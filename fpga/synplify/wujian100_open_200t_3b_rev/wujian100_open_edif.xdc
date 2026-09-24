
#1002 : create_clock -name PIN_EHS [get_nets n:PIN_EHS] -period 20.0 -waveform {0 10.0}
# line 83 in /home/hanyuxin/Documents/Projects/T_head/wujian100_project/wujian100_open/fpga/synplify/FDC_constraints/wujian100_open_200t_3b_translated.fdc

create_clock -name {PIN_EHS} [get_pins {PIN_EHS_ibuf/O}] -period {20.000} -waveform {0.000 10.000}

#1003 : create_clock -name PAD_JTAG_TCLK [get_nets n:PAD_JTAG_TCLK] -period 500.0 -waveform {0 250.0}
# line 84 in /home/hanyuxin/Documents/Projects/T_head/wujian100_project/wujian100_open/fpga/synplify/FDC_constraints/wujian100_open_200t_3b_translated.fdc

create_clock -name {PAD_JTAG_TCLK} [get_pins {PAD_JTAG_TCLK_ibuf/O}] -period {500.000} -waveform {0.000 250.000}

#1004 : create_clock -name I_RTC_EXT_CLK [get_nets n:x_aou_top.x_rtc0_sec_top.x_rtc_aou_top.x_rtc_clk_div.i_rtc_ext_clk] -period 1000.0 -waveform {0 500.0}
# line 85 in /home/hanyuxin/Documents/Projects/T_head/wujian100_project/wujian100_open/fpga/synplify/FDC_constraints/wujian100_open_200t_3b_translated.fdc

create_clock -name {I_RTC_EXT_CLK} [get_pins {x_aou_top/x_rtc0_sec_top/x_rtc_aou_top/x_rtc_clk_div/i_rtc_ext_clk_keep/O}] -period {1000.000} -waveform {0.000 500.000}

#1005 : create_clock -name RTC_CLK_DIV [get_nets n:x_aou_top.x_rtc0_sec_top.x_rtc_aou_top.x_rtc_clk_div.rtc_clk_div] -period 2000.0 -waveform {0 1000.0}
# line 86 in /home/hanyuxin/Documents/Projects/T_head/wujian100_project/wujian100_open/fpga/synplify/FDC_constraints/wujian100_open_200t_3b_translated.fdc

create_clock -name {RTC_CLK_DIV} [get_pins {x_aou_top/x_rtc0_sec_top/x_rtc_aou_top/x_rtc_clk_div/x_gatecell/u_fpga_icg/O}] -period {2000.000} -waveform {0.000 1000.000}

#1006 : create_clock -name CLKDIV [get_nets n:x_pdu_top.x_sub_apb0_top.x_pwm_sec_top.x_pwm.x_pwm_ctrl.clkdiv] -period 200.0 -waveform {0 100.0}
# line 87 in /home/hanyuxin/Documents/Projects/T_head/wujian100_project/wujian100_open/fpga/synplify/FDC_constraints/wujian100_open_200t_3b_translated.fdc

create_clock -name {CLKDIV} [get_pins {x_pdu_top/x_sub_apb0_top/x_pwm_sec_top/x_pwm/x_pwm_ctrl/x_cpu_gated_clk/u_fpga_icg/O}] -period {200.000} -waveform {0.000 100.000}

#1010 : automatically generated

create_generated_clock -name {wujian100_open_top|dft_clk_derived_clock_CLKIN1} [get_pins {u_mmcm_50M_to_20M/CLKOUT0}]
#1011 : automatically generated

create_clock -name {wujian100_open_top|PAD_JTAG_TCLK} -period {1000.000} [get_ports {PAD_JTAG_TCLK}]


#1007 : set_clock_groups -derive -asynchronous -name clkgroup_2 -group {PIN_EHS CLKDIV}
# line 88 in /home/hanyuxin/Documents/Projects/T_head/wujian100_project/wujian100_open/fpga/synplify/FDC_constraints/wujian100_open_200t_3b_translated.fdc

set_clock_groups -asynchronous -name {clkgroup_2} -group [get_clocks -include_generated_clocks {CLKDIV PIN_EHS}]

#1008 : set_clock_groups -derive -asynchronous -name clkgroup_3 -group PAD_JTAG_TCLK
# line 90 in /home/hanyuxin/Documents/Projects/T_head/wujian100_project/wujian100_open/fpga/synplify/FDC_constraints/wujian100_open_200t_3b_translated.fdc

set_clock_groups -asynchronous -name {clkgroup_3} -group [get_clocks {PAD_JTAG_TCLK}]

#1009 : set_clock_groups -derive -asynchronous -name clkgroup_4 -group {I_RTC_EXT_CLK RTC_CLK_DIV}
# line 92 in /home/hanyuxin/Documents/Projects/T_head/wujian100_project/wujian100_open/fpga/synplify/FDC_constraints/wujian100_open_200t_3b_translated.fdc

set_clock_groups -asynchronous -name {clkgroup_4} -group [get_clocks {I_RTC_EXT_CLK RTC_CLK_DIV}]

#1012 : automatically generated

set_clock_groups -name {Autoconstr_clkgroup_0_1} -asynchronous -group [get_clocks {wujian100_open_top|PAD_JTAG_TCLK}]

set_property ASYNC_REG TRUE [get_cells {x_aou_top/x_rtc0_sec_top/x_rtc_pdu_top/x_rtc_cdr_sync/cnt_reg2}]
set_property ASYNC_REG TRUE [get_cells {x_aou_top/x_rtc0_sec_top/x_rtc_pdu_top/x_rtc_cdr_sync/cnt_reg1}]
set_property ASYNC_REG TRUE [get_cells {x_aou_top/x_rtc0_sec_top/x_rtc_pdu_top/x_rtc_clr_sync/pclk_load_sync2}]
set_property ASYNC_REG TRUE [get_cells {x_aou_top/x_rtc0_sec_top/x_rtc_pdu_top/x_rtc_clr_sync/rtc_load_sync2}]
set_property ASYNC_REG TRUE [get_cells {x_aou_top/x_rtc0_sec_top/x_rtc_pdu_top/x_rtc_clr_sync/pclk_load_sync1}]
set_property ASYNC_REG TRUE [get_cells {x_aou_top/x_rtc0_sec_top/x_rtc_pdu_top/x_rtc_clr_sync/rtc_load_sync1}]
set_property ASYNC_REG TRUE [get_cells {x_cpu_top/CPU/x_cr_had_top/A15d/A74/A10b}]
set_property ASYNC_REG TRUE [get_cells {x_cpu_top/CPU/x_cr_had_top/A15d/A74/A18597}]
set_property ASYNC_REG TRUE [get_cells {x_cpu_top/CPU/x_cr_had_top/A15d/A1862d/A10b}]
set_property ASYNC_REG TRUE [get_cells {x_cpu_top/CPU/x_cr_had_top/A15d/A1862d/A18597}]
set_property ASYNC_REG TRUE [get_cells {x_cpu_top/CPU/x_cr_had_top/A15d/A75/A10b}]
set_property ASYNC_REG TRUE [get_cells {x_cpu_top/CPU/x_cr_had_top/A15d/A75/A18597}]

set_property IOB true [get_cells {x_cpu_top/CPU/x_cr_had_top/A15d/A5b}]
#User specified region constraints
