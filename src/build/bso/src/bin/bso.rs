use std::io::Result;

use bso::jsonrpc;

fn main() -> Result<()> {
    let stdin = std::io::stdin();
    let mut reader = stdin.lock();

    let value = jsonrpc::parse_message(&mut reader)?;

    std::eprintln!("{:#?}", value);

    Ok(())
}
