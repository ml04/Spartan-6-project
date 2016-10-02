##############################################################################
## Filename:          D:\DRS\KV_Lekic\EDK/drivers/vga_controller_v1_00_a/data/vga_controller_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Tue Dec 08 13:49:15 2015 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "vga_controller" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
