RUST_RELEASE_FLAGS = [
    "-Ccodegen-units=1",
    "-Cpanic=abort",
    "-Copt-level=z",
    "-Cstrip=symbols",
    "-Cdebuginfo=0",
    "-Cdebug-assertions=false",
    "-Coverflow-checks=false",
]

RUST_DEBUG_FLAGS = [
    "-Copt-level=0",
]
