RUST_RELEASE_FLAGS = [
    "-Clto",
    "-Ccodegen-units=1",
    "-Cpanic=abort",
    "-Copt-level=z",
    "-Clto=fat",
    "-Cstrip=symbols",
]

RUST_DEBUG_FLAGS = [
    "-Copt-level=0",
]
