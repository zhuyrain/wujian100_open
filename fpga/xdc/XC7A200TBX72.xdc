#Copyright (c) 2019 Alibaba Group Holding Limited
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#===========================================================
# BX72
# Xilinx Artix-7 XC7A200T-FBG484
# Pin assignment constraint file
#
# Pin source: BX72管脚分配表V2.1.xlsx
# Mapping:
#   PAD_GPIO[0:31] -> GPIO0-0 .. GPIO0-31
#   PWM             -> GPIO1-0 .. GPIO1-12
#   USI             -> GPIO1-13 .. GPIO1-24
#   C-SKY JTAG      -> GPIO1-25 .. GPIO1-26
#===========================================================

#===========================================
# Set I/O standard
#===========================================
set_property IOSTANDARD LVCMOS33 [get_ports]


#===========================================
# Global clock and reset source
#===========================================
set_property PACKAGE_PIN Y18 [get_ports PIN_EHS];       # FPGA_CLK
set_property PACKAGE_PIN P20 [get_ports PAD_MCURST];    # KEY0

# The original design timing constraint is 20 MHz. Keep the clock constraint
# disabled here, as in XC7A200T3B.xdc, until the BX72 oscillator frequency and
# the design clock configuration are confirmed.
#create_clock -period 50.000 -name MAIN_CLK [get_ports PIN_EHS]


#===========================================
# C-SKY JTAG interface (GPIO1-25 .. GPIO1-26)
#===========================================
set_property PACKAGE_PIN E18 [get_ports PAD_JTAG_TCLK]; # GPIO1-25
set_property PACKAGE_PIN E19 [get_ports PAD_JTAG_TMS];  # GPIO1-26
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PAD_JTAG_TCLK]


#===========================================
# GPIO (GPIO0-0 .. GPIO0-31)
#===========================================
set_property PACKAGE_PIN G17 [get_ports PAD_GPIO_0];    # GPIO0-0
set_property PACKAGE_PIN G18 [get_ports PAD_GPIO_1];    # GPIO0-1
set_property PACKAGE_PIN H17 [get_ports PAD_GPIO_2];    # GPIO0-2
set_property PACKAGE_PIN H18 [get_ports PAD_GPIO_3];    # GPIO0-3
set_property PACKAGE_PIN N22 [get_ports PAD_GPIO_4];    # GPIO0-4
set_property PACKAGE_PIN M22 [get_ports PAD_GPIO_5];    # GPIO0-5
set_property PACKAGE_PIN K17 [get_ports PAD_GPIO_6];    # GPIO0-6
set_property PACKAGE_PIN J17 [get_ports PAD_GPIO_7];    # GPIO0-7
set_property PACKAGE_PIN K18 [get_ports PAD_GPIO_8];    # GPIO0-8
set_property PACKAGE_PIN K19 [get_ports PAD_GPIO_9];    # GPIO0-9
set_property PACKAGE_PIN L19 [get_ports PAD_GPIO_10];   # GPIO0-10
set_property PACKAGE_PIN L20 [get_ports PAD_GPIO_11];   # GPIO0-11
set_property PACKAGE_PIN N20 [get_ports PAD_GPIO_12];   # GPIO0-12
set_property PACKAGE_PIN M20 [get_ports PAD_GPIO_13];   # GPIO0-13
set_property PACKAGE_PIN N18 [get_ports PAD_GPIO_14];   # GPIO0-14
set_property PACKAGE_PIN N19 [get_ports PAD_GPIO_15];   # GPIO0-15
set_property PACKAGE_PIN M18 [get_ports PAD_GPIO_16];   # GPIO0-16
set_property PACKAGE_PIN L18 [get_ports PAD_GPIO_17];   # GPIO0-17
set_property PACKAGE_PIN L16 [get_ports PAD_GPIO_18];   # GPIO0-18
set_property PACKAGE_PIN K16 [get_ports PAD_GPIO_19];   # GPIO0-19
set_property PACKAGE_PIN M15 [get_ports PAD_GPIO_20];   # GPIO0-20
set_property PACKAGE_PIN M16 [get_ports PAD_GPIO_21];   # GPIO0-21
set_property PACKAGE_PIN L14 [get_ports PAD_GPIO_22];   # GPIO0-22
set_property PACKAGE_PIN L15 [get_ports PAD_GPIO_23];   # GPIO0-23
set_property PACKAGE_PIN M13 [get_ports PAD_GPIO_24];   # GPIO0-24
set_property PACKAGE_PIN L13 [get_ports PAD_GPIO_25];   # GPIO0-25
set_property PACKAGE_PIN K13 [get_ports PAD_GPIO_26];   # GPIO0-26
set_property PACKAGE_PIN K14 [get_ports PAD_GPIO_27];   # GPIO0-27
set_property PACKAGE_PIN J15 [get_ports PAD_GPIO_28];   # GPIO0-28
set_property PACKAGE_PIN H15 [get_ports PAD_GPIO_29];   # GPIO0-29
set_property PACKAGE_PIN G15 [get_ports PAD_GPIO_30];   # GPIO0-30
set_property PACKAGE_PIN G16 [get_ports PAD_GPIO_31];   # GPIO0-31


#===========================================
# PWM (GPIO1-0 .. GPIO1-12)
#===========================================
set_property PACKAGE_PIN F13 [get_ports PAD_PWM_CH0];   # GPIO1-0
set_property PACKAGE_PIN F14 [get_ports PAD_PWM_CH1];   # GPIO1-1
set_property PACKAGE_PIN E13 [get_ports PAD_PWM_CH2];   # GPIO1-2
set_property PACKAGE_PIN E14 [get_ports PAD_PWM_CH3];   # GPIO1-3
set_property PACKAGE_PIN D14 [get_ports PAD_PWM_CH4];   # GPIO1-4
set_property PACKAGE_PIN D15 [get_ports PAD_PWM_CH5];   # GPIO1-5
set_property PACKAGE_PIN F16 [get_ports PAD_PWM_CH6];   # GPIO1-6
set_property PACKAGE_PIN E17 [get_ports PAD_PWM_CH7];   # GPIO1-7
set_property PACKAGE_PIN E16 [get_ports PAD_PWM_CH8];   # GPIO1-8
set_property PACKAGE_PIN D16 [get_ports PAD_PWM_CH9];   # GPIO1-9
set_property PACKAGE_PIN A13 [get_ports PAD_PWM_CH10];  # GPIO1-10
set_property PACKAGE_PIN A14 [get_ports PAD_PWM_CH11];  # GPIO1-11
set_property PACKAGE_PIN C13 [get_ports PAD_PWM_FAULT]; # GPIO1-12


#===========================================
# USI (GPIO1-13 .. GPIO1-24)
#===========================================
set_property PACKAGE_PIN B13 [get_ports PAD_USI0_NSS];  # GPIO1-13
set_property PACKAGE_PIN C14 [get_ports PAD_USI0_SCLK]; # GPIO1-14
set_property PACKAGE_PIN C15 [get_ports PAD_USI0_SD0];  # GPIO1-15
set_property PACKAGE_PIN B15 [get_ports PAD_USI0_SD1];  # GPIO1-16

set_property PACKAGE_PIN B16 [get_ports PAD_USI1_NSS];  # GPIO1-17
set_property PACKAGE_PIN A15 [get_ports PAD_USI1_SCLK]; # GPIO1-18
set_property PACKAGE_PIN A16 [get_ports PAD_USI1_SD0];  # GPIO1-19
set_property PACKAGE_PIN B17 [get_ports PAD_USI1_SD1];  # GPIO1-20

set_property PACKAGE_PIN B18 [get_ports PAD_USI2_NSS];  # GPIO1-21
set_property PACKAGE_PIN D17 [get_ports PAD_USI2_SCLK]; # GPIO1-22
set_property PACKAGE_PIN C17 [get_ports PAD_USI2_SD0];  # GPIO1-23
set_property PACKAGE_PIN F18 [get_ports PAD_USI2_SD1];  # GPIO1-24


#===========================================
# User LED
#===========================================
set_property PACKAGE_PIN Y19 [get_ports POUT_EHS];      # LED0


#===========================================
# FPGA configuration properties
#===========================================
set_property CONFIG_VOLTAGE  3.3   [current_design]
set_property CFGBVS          VCCO  [current_design]
set_property CONFIG_MODE     SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH      4     [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE        40    [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN  DIV-2 [current_design]
