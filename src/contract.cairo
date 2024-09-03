use starknet::ContractAddress;

// *************************************************************************
//                             OZ IMPORTS
// *************************************************************************
use openzeppelin::{
    token::erc721::{ERC721Component::{ERC721Metadata, HasComponent}},
    introspection::src5::SRC5Component,
};

#[starknet::interface]
trait IERC721Metadata<TState> {
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
}

#[starknet::embeddable]
impl IERC721MetadataImpl<
    TContractState,
    +HasComponent<TContractState>,
    +SRC5Component::HasComponent<TContractState>,
    +Drop<TContractState>
> of IERC721Metadata<TContractState> {
    fn name(self: @TContractState) -> ByteArray {
        let component = HasComponent::get_component(self);
        ERC721Metadata::name(component)
    }

    fn symbol(self: @TContractState) -> ByteArray {
        let component = HasComponent::get_component(self);
        ERC721Metadata::symbol(component)
    }
}

#[starknet::contract]
pub mod SeriesPoc {
    use openzeppelin::token::erc721::interface::IERC721Metadata;
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

    use core::traits::TryInto;
    // use core::num::traits::zero::Zero;

    use nicera_svg_poc::interfaces::erc721::IERC721;
    use nicera_svg_poc::base::types::Series;
    use nicera_svg_poc::base::types::ArtistMetadata;

    use openzeppelin::{
        token::erc721::{
            ERC721Component, erc721::ERC721Component::InternalTrait as ERC721InternalTrait
        },
        introspection::{src5::SRC5Component}
    };
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);


    // allow to check what interface is supported
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    impl SRC5InternalImpl = SRC5Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataCamelOnly =
        ERC721Component::ERC721MetadataCamelOnlyImpl<ContractState>;

    #[storage]
    struct Storage {
        _series_counter: u256,
        _series_data: LegacyMap<u256, Series>,
        _artists_counter: u256,
        _artists_data: LegacyMap<u256, ArtistMetadata>,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    // Events
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        approved: ContractAddress,
        token_id: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        owner: ContractAddress,
        operator: ContractAddress,
        approved: bool,
    }


    #[constructor]
    fn constructor(ref self: ContractState, name: ByteArray, symbol: ByteArray,) {
        let base_uri = "";
        self.erc721.initializer(name, symbol, base_uri);
    }

    #[abi(embed_v0)]
    impl SeriesImpl of IERC721<ContractState> {
        fn name(self: @ContractState) -> ByteArray {
            self.erc721.name()
        }

        /// @notice returns the collection symbol
        fn symbol(self: @ContractState) -> ByteArray {
            self.erc721.symbol()
        }

        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self.erc721.token_uri(token_id)
        }
        fn balance_of(self: @ContractState, owner: ContractAddress) -> u256 {
            self.erc721.balance_of(owner)
        }
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            self.erc721.owner_of(token_id)
        }
        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            self.erc721.get_approved(token_id)
        }
        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.erc721.is_approved_for_all(owner, operator)
        }
        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            self.erc721.transfer_from(from, to, token_id)
        }


        fn approve(ref self: ContractState, approved: ContractAddress, token_id: u256) {
            self.erc721.approve(approved, token_id)
        }
        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approval: bool
        ) {
            self.erc721.set_approval_for_all(operator, approval)
        }
        fn mint(ref self: ContractState, to: ContractAddress) {
            assert(!to.is_zero(), 'ERC721: invalid receiver');
            let mut token_id = self.erc721.balanceOf(to) + 1.into();
            self.erc721._mint(to, token_id);

            // Emit Event
            self.emit(Event::Transfer(Transfer { from: Zeroable::zero(), to, token_id }));
        }
        fn get_series(self: @ContractState, series_id: u256) -> Series {
            self._series_data.read(series_id)
        }
        fn get_artist(self: @ContractState, artist_id: u256) -> ArtistMetadata {
            self._artists_data.read(artist_id)
        }
        fn create_series(
            ref self: ContractState,
            name: felt252,
            description: felt252,
            artist_info: ArtistMetadata,
            base_uri: felt252,
        ) -> u256 {
            let series_id: u256 = self._series_counter.read() + 1;
            let artists_id: u256 = self._artists_counter.read() + 1;
            let new_series = Series { name, description, base_uri };
            self._series_data.write(series_id, new_series);
            self._series_counter.write(series_id);

            self._artists_data.write(artists_id, artist_info);
            self._artists_counter.write(artists_id);
            series_id
        }
    }
}
