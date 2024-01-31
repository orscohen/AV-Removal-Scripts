#!/bin/zsh

# location of the Cortex XDR app
uninstaller="/Applications/Cortex XDR Uninstaller.app"

# Obtain the uninstaller password from the console
password="Removal_key"

# Run the uninstaller with the provided removal key 
if "$uninstaller/Contents/Resources/cortex_xdr_uninstaller_tool" "$password"; then
    echo "Cortex XDR uninstallation completed successfully"
else
    echo "Cortex XDR uninstallation failed"
    exit 1
fi

# Remove the uninstaller from all locations if Cortex XDR has been deleted
if [[ ! -d "/Applications/Cortex XDR.app" ]]; then
    rm -rf "$uninstaller" ||:
    rm -rf "/Library/Management/PaloAlto" ||:
else
    echo "Cortex uninstallation failed"
    chflags nohidden "$uninstaller"
    exit 1
fi

# Attempt to Forget the packages if a match is found
/usr/sbin/pkgutil --pkgs=com.paloaltonetworks.pkg.cortex && /usr/sbin/pkgutil --forget com.paloaltonetworks.pkg.cortex

echo "Cortex XDR uninstaller script executed successfully"
