# ==============================================================================
# 1. 物理晶振约束 (50MHz -> 周期20ns)
# ==============================================================================
create_clock -name CLK_IN_50M -period 20.000 [get_ports {PIN_EHS}]

# 外部 JTAG 调试时钟
create_clock -name PAD_JTAG_TCLK -period 500.000 -waveform {0.000 250.000} [get_ports {PAD_JTAG_TCLK}]

# ==============================================================================
# 2. 内部衍生时钟层 (Generated Clocks)
# ==============================================================================
# 2.1 核心主频：将其精准锚定在 EDIF 确认过的 MMCM 引脚上。
# 为了匹配网表中的实际地位，将其命名为 dft_clk_c

# #注释掉MMCM原语生成时钟，由编译器自行分析
# create_generated_clock -name dft_clk_c -source [get_ports {PIN_EHS}] [get_pins {u_mmcm_50M_to_20M/CLKOUT0}]

# 2.2 逻辑分频时钟：必须级联约束！源端紧扣刚定义的 MMCM 输出引脚。
# 注意：由于这是交接给 Vivado 的约束，且承接的是 Synplify 的 EDIF，
# 所以目标引脚必须使用 Synplify 在网表中留下的 _keep/O 实例。
create_generated_clock -name I_RTC_EXT_CLK -divide_by 20 -source [get_pins {u_mmcm_50M_to_20M/CLKOUT0}] [get_pins {x_aou_top/x_rtc0_sec_top/x_rtc_aou_top/x_rtc_clk_div/i_rtc_ext_clk_keep/O}]

create_generated_clock -name RTC_CLK_DIV -divide_by 40 -source [get_pins {u_mmcm_50M_to_20M/CLKOUT0}] [get_pins {x_aou_top/x_rtc0_sec_top/x_rtc_aou_top/x_rtc_clk_div/rtc_clk_div_keep/O}]

# #PWM最大为系统时钟，将其约束为一个10MHz，1/4占空比的系统时钟派生时钟
# create_generated_clock -name CLKDIV \
#     -source [get_pins {u_mmcm_50M_to_20M/CLKOUT0}] \
#     -edges {1 2 5} \
#     [get_pins {x_pdu_top/x_sub_apb0_top/x_pwm_sec_top/x_pwm/x_pwm_ctrl/clkdiv_keep/O}]

# ==============================================================================
# 3. 异步时钟域分组 (Clock Groups)
# ==============================================================================
# 使用最新的精确命名进行域切分，还原真实的流片物理隔离
set_clock_groups -asynchronous \
    -name async_groups \
    -group "[get_clocks {CLK_IN_50M}] [get_clocks -of_objects [get_pins {u_mmcm_50M_to_20M/CLKOUT0}]]" \
    -group [get_clocks {PAD_JTAG_TCLK}] \
    -group [get_clocks {I_RTC_EXT_CLK RTC_CLK_DIV}]
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
