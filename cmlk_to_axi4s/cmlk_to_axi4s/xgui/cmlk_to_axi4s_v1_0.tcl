# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"


}

proc update_PARAM_VALUE.HIDE_STATUS { PARAM_VALUE.HIDE_STATUS } {
	# Procedure called to update HIDE_STATUS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HIDE_STATUS { PARAM_VALUE.HIDE_STATUS } {
	# Procedure called to validate HIDE_STATUS
	return true
}


