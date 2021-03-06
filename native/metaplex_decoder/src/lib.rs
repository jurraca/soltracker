rustler::init!("Elixir.SolTracker.Transfers", [deserialize_metadata]);

use serde::Serialize;
use serde_json::json;
use solana_program::borsh::try_from_slice_unchecked;
use spl_token_metadata::state::Metadata;

#[derive(Debug, Serialize)]
pub struct JSONCreator {
    pub address: String,
    pub verified: bool,
    // In percentages, NOT basis points ;) Watch out!
    pub share: u8,
}

#[rustler::nif]
fn deserialize_metadata(base58_string: String) -> std::string::String {
    let decoded: Vec<u8> = bs58::decode(base58_string)
        .into_vec()
        .expect("Failed to decode base58 string");
    
    let metadata: Metadata = try_from_slice_unchecked(&decoded).unwrap();

    if let Some(ref _i) = metadata.data.creators
    {    	
    	let creators = metadata.data.creators
	        .unwrap()
	        .iter()
	        .map(|c| JSONCreator {
	            address: c.address.to_string(),
	            verified: c.verified,
	            share: c.share,
	        })
	        .collect::<Vec<JSONCreator>>();

        let nft_metadata = json!({
    	    "name": metadata.data.name.to_string().trim_matches(char::from(0)),
    	    "mint": metadata.mint.to_string().trim_matches(char::from(0)),
    	    "symbol": metadata.data.symbol.to_string().trim_matches(char::from(0)),
    	    "seller_fee_basis_points": metadata.data.seller_fee_basis_points,
    	    "uri": metadata.data.uri.to_string().trim_matches(char::from(0)),
    	    "creators": [creators],
    	});

    	nft_metadata.to_string()
    } else { 
    	let creators = "None";
        let nft_metadata = json!({
    	    "name": metadata.data.name.to_string().trim_matches(char::from(0)),
    	    "mint": metadata.mint.to_string().trim_matches(char::from(0)),
    	    "symbol": metadata.data.symbol.to_string().trim_matches(char::from(0)),
    	    "seller_fee_basis_points": metadata.data.seller_fee_basis_points,
    	    "uri": metadata.data.uri.to_string().trim_matches(char::from(0)),
    	    "creators": creators,
    	});

    	nft_metadata.to_string()

    }
}
