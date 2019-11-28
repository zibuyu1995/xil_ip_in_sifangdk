# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CACHE_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IMG_STRIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LINE_STRIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_LINE" -parent ${Page_0}


}

proc update_PARAM_VALUE.CACHE_WIDTH { PARAM_VALUE.CACHE_WIDTH } {
	# Procedure called to update CACHE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CACHE_WIDTH { PARAM_VALUE.CACHE_WIDTH } {
	# Procedure called to validate CACHE_WIDTH
	return true
}

proc update_PARAM_VALUE.IMG_STRIDE { PARAM_VALUE.IMG_STRIDE } {
	# Procedure called to update IMG_STRIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IMG_STRIDE { PARAM_VALUE.IMG_STRIDE } {
	# Procedure called to validate IMG_STRIDE
	return true
}

proc update_PARAM_VALUE.LINE_STRIDE { PARAM_VALUE.LINE_STRIDE } {
	# Procedure called to update LINE_STRIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LINE_STRIDE { PARAM_VALUE.LINE_STRIDE } {
	# Procedure called to validate LINE_STRIDE
	return true
}

proc update_PARAM_VALUE.NUM_LINE { PARAM_VALUE.NUM_LINE } {
	# Procedure called to update NUM_LINE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_LINE { PARAM_VALUE.NUM_LINE } {
	# Procedure called to validate NUM_LINE
	return true
}


proc update_MODELPARAM_VALUE.CACHE_WIDTH { MODELPARAM_VALUE.CACHE_WIDTH PARAM_VALUE.CACHE_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CACHE_WIDTH}] ${MODELPARAM_VALUE.CACHE_WIDTH}
}

proc update_MODELPARAM_VALUE.IMG_STRIDE { MODELPARAM_VALUE.IMG_STRIDE PARAM_VALUE.IMG_STRIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IMG_STRIDE}] ${MODELPARAM_VALUE.IMG_STRIDE}
}

proc update_MODELPARAM_VALUE.LINE_STRIDE { MODELPARAM_VALUE.LINE_STRIDE PARAM_VALUE.LINE_STRIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LINE_STRIDE}] ${MODELPARAM_VALUE.LINE_STRIDE}
}

proc update_MODELPARAM_VALUE.NUM_LINE { MODELPARAM_VALUE.NUM_LINE PARAM_VALUE.NUM_LINE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_LINE}] ${MODELPARAM_VALUE.NUM_LINE}
}

