#[derive(Drop, Serde, starknet::Store)]
pub struct ArtistMetadata {
    name: felt252,
    bio: felt252,
    // wallet_address: ContractAddress,
    profile_link: felt252,
}

#[derive(Drop, Serde, starknet::Store)]
pub struct Series {
    name: felt252,
    description: felt252,
    base_uri: felt252,
}
