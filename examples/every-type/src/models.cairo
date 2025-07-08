use core::integer::u512;
use starknet::{ContractAddress, ClassHash, EthAddress};


#[derive(Serde, Drop, PartialEq)]
enum SimpleEnum {
    Variant1,
    Variant2,
    Variant3,
}

#[derive(Serde, Drop, PartialEq)]
enum SimpleEnumWithDefault {
    #[default]
    Variant1,
    Variant2,
    Variant3,
}


#[dojo::model]
#[derive(Serde, Drop)]
struct UnsignedInts {
    uint8: u8,
    uint16: u16,
    uint32: u32,
    uint64: u64,
    uint128: u128,
}

#[dojo::model]
#[derive(Serde, Drop)]
struct LargeUnsignedInts {
    uint256: u256,
    uint512: u512,
}

#[dojo::model]
#[derive(Serde, Drop)]
struct SignedInts {
    int8: i8,
    int16: i16,
    int32: i32,
    int64: i64,
    int128: i128,
}

#[dojo::model]
#[derive(Serde, Drop)]
struct AllCoreFixedTypes {
    felt: felt252,
    uint8: u8,
    uint16: u16,
    uint32: u32,
    uint64: u64,
    uint128: u128,
    uint256: u256,
    uint512: u512,
    int8: i8,
    int16: i16,
    int32: i32,
    int64: i64,
    int128: i128,
    boolean: bool,
    contract_address: ContractAddress,
    class_hash: ClassHash,
    eth_address: EthAddress,
}
