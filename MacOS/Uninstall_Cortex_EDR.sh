#!/bin/bash

XDRDirectory="/Applications/Cortex XDR.app/"

if [[ -d $XDRDirectory ]]; then

    echo "## Cortex XDR Is Installed – Uninstalling Cortex XDR ##"
    
    #### Uninstall Script ####
    sudo /Library/Application\ Support/PaloAltoNetworks/Traps/bin/cortex_xdr_uninstaller_tool  <Uninstalling code>
    
else

    echo "Cortex is Not Installed, aborting XDR removal"
    exit 0

fi
