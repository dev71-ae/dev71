RUST_RELEASE_FLAGS = [
    "-Ccodegen-units=1",
    "-Cpanic=unwind",
    "-Copt-level=s",
    "-Cstrip=symbols",
    "-Cdebuginfo=0",
    "-Cdebug-assertions=false",
    "-Coverflow-checks=false",
    "-Zlocation-detail=none",
    "-Zfmt-debug=none",    
    "-Zstaticlib-allow-rdylib-deps",
    "-Zstaticlib-prefer-dynamic"
]

RUST_DEBUG_FLAGS = [
    "-Copt-level=0",
]
