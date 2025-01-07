{
  lib,
  writeShellApplication,
  zig,
  tuist,
}:
writeShellApplication {
  name = "xcgen";
  text = "(zig build ios; TUIST_ZIG=${lib.getExe zig} tuist generate)";
  runtimeInputs = [
    zig
    tuist
  ];
}
