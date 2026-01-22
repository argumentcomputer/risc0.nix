use risc0_zkvm::guest::env;

fn main() {
    // Read the input data and number of hashes to compute
    let data: Vec<u8> = env::read();
    let num_hashes: u32 = env::read();

    // Compute the BLAKE3 hashes
    let mut hashes: Vec<[u8; 32]> = Vec::with_capacity(num_hashes as usize);
    for i in 0..num_hashes {
        // Use different data for each hash by appending index
        let mut input = data.clone();
        input.extend_from_slice(&i.to_le_bytes());
        let hash = blake3::hash(&input);
        hashes.push(*hash.as_bytes());
    }

    // Commit the hashes to the journal as public output
    env::commit(&hashes);
}
