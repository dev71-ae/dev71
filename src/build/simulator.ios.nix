{
  writeShellApplication,
  xcode,
  bundle,
  name,
  id,
}:
writeShellApplication {
  name = "run-${bundle.pname}";
  text = ''
    # xcrun simctl list (default: iPhone 16 Pro Max 18.2)
    DEVICE="7193FCD2-E677-4C48-B1E2-A702AC2861AE"

    if [ "''${1:-}" != "booted"  ]; then
      # Open the simulator instance
      open -a ${xcode}/Contents/Developer/Applications/Simulator.app --args -CurrentDeviceUDID "$DEVICE"

      # Wait for the simulator to start
      echo "Press enter when the simulator is started..."
      read -r
    fi

    # Install the app
    xcrun simctl install "$DEVICE" ${bundle}/Applications/${name}.app

    # Launch the app in the simulator
    xcrun simctl launch "$DEVICE" "${id}"
  '';
}
