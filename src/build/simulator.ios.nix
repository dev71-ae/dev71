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
    # Default device (iPhone 16 Pro Max 18.2)
    DEVICE="7193FCD2-E677-4C48-B1E2-A702AC2861AE"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
      case $1 in
        --device)
          DEVICE="$2"
          shift # past argument
          shift # past value
          ;;
        booted)
          BOOTED=1
          shift # past argument
          ;;
        *)
          echo "Unknown parameter: $1"
          exit 1
          ;;
      esac
    done

    # Show available devices if requested
    if [ "$DEVICE" = "list" ]; then
      xcrun simctl list devices
      exit 0
    fi

    if [ -z "''${BOOTED:-}" ]; then
      # Open the simulator instance
      open -a ${xcode}/Contents/Developer/Applications/Simulator.app --args -CurrentDeviceUDID "$DEVICE"

      # Wait for the simulator to start
      echo "Press enter when the simulator is started..."
      read -r
    fi

    echo "Installing..."

    # Create a temporary copy with correct permissions (To support older devices)
    TEMP_APP=$(mktemp -d)/$(basename ${name}.app)
    cp -R ${bundle}/Applications/${name}.app "$TEMP_APP"
    chmod -R +w "$TEMP_APP"

    # Install the app
    xcrun simctl install "$DEVICE" "$TEMP_APP"

    rm -rf "$(dirname "$TEMP_APP")"

    # Launch the app in the simulator
    xcrun simctl launch "$DEVICE" ${id}
  '';
}
