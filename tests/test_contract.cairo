use starknet::{ContractAddress, contract_address_to_felt252, account::Call};
use snforge_std::{
    declare, start_prank, stop_prank, start_warp, stop_warp, ContractClassTrait, ContractClass,
    CheatTarget
};
use nicera_svg_poc::contract::SvgPoc;
use nicera_svg_poc::interfaces::erc721::{IERC721Dispatcher, IERC721DispatcherTrait};
use nicera_svg_poc::base::types::ArtistMetadata;
use nicera_svg_poc::base::types::Series;


fn __setup__() -> ContractAddress {
    let contract = declare("SvgPoc");
    let mut constructor_calldata = array!['TEST_NAME', 'TEST_SYMBOL'];
    let contract_address = contract.deploy(@constructor_calldata).unwrap();
    contract_address
}

#[test]
fn test_name() {
    let contract_address = __setup__();
    let dispatcher = IERC721Dispatcher { contract_address };

    let name = dispatcher.name();
    assert(name == 'nicera_svg_poc', 'invalid name');
}

#[test]
fn test_create_series() {
    let contract_address = __setup__();
    let dispatcher = IERC721Dispatcher { contract_address };
    let artist = ArtistMetadata {
        name: 'test_artist', bio: 'artist_bio', profile_link: 'artist_link'
    };
    let series_id = dispatcher
        .create_series('test_series', 'test_description', artist, 'test series uri');

    assert(dispatcher.get_series(series_id).name == 'test_series', 'Invalid series name');
    assert(dispatcher.get_artist(series_id).name == 'test_artist', 'Invalid artist name');
}
