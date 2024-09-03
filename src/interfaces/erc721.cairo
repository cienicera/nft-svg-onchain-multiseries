use starknet::ContractAddress;
use nicera_svg_poc::base::types::ArtistMetadata;
use nicera_svg_poc::base::types::Series;

#[starknet::interface]
trait IERC721<TContractState> {
    // Views
    fn name(self: @TContractState) -> ByteArray;
    fn symbol(self: @TContractState) -> ByteArray;
    // fn owner(self: @TContractState) -> ContractAddress;
    fn token_uri(self: @TContractState, token_id: u256) -> ByteArray;
    fn balance_of(self: @TContractState, owner: ContractAddress) -> u256;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn transfer_from(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256
    );

    // Externals
    fn approve(ref self: TContractState, approved: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approval: bool);
    fn mint(ref self: TContractState, to: ContractAddress);
    fn get_series(self: @TContractState, series_id: u256) -> Series;
    fn get_artist(self: @TContractState, artist_id: u256) -> ArtistMetadata;
    fn create_series(
        ref self: TContractState,
        name: felt252,
        description: felt252,
        artist_info: ArtistMetadata,
        base_uri: felt252,
    ) -> u256;
}
