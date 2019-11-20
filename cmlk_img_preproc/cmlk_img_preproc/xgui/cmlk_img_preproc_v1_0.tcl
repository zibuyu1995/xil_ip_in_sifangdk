# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ENABLE_EXT_TRIG_CNT" -parent ${Page_0} -widget comboBox


}

proc update_PARAM_VALUE.ENABLE_EXT_TRIG_CNT { PARAM_VALUE.ENABLE_EXT_TRIG_CNT } {
	# Procedure called to update ENABLE_EXT_TRIG_CNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_EXT_TRIG_CNT { PARAM_VALUE.ENABLE_EXT_TRIG_CNT } {
	# Procedure called to validate ENABLE_EXT_TRIG_CNT
	return true
}


proc update_MODELPARAM_VALUE.ENABLE_EXT_TRIG_CNT { MODELPARAM_VALUE.ENABLE_EXT_TRIG_CNT PARAM_VALUE.ENABLE_EXT_TRIG_CNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_EXT_TRIG_CNT}] ${MODELPARAM_VALUE.ENABLE_EXT_TRIG_CNT}
}

