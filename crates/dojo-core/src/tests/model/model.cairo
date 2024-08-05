#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Foo {
    #[key]
    pub k: u8,
    pub v1: u128,
    pub v2: u32
}

#[dojo::model]
#[derive(Copy, Drop, Serde, Debug)]
pub struct Foo2 {
    #[key]
    pub k1: u8,
    #[key]
    pub k2: felt252,
    pub v1: u128,
    pub v2: u32
}

#[dojo::model]
#[derive(Drop, Serde, Debug)]
pub struct Foo3 {
    #[key]
    pub k1: u8,
    #[key]
    pub k2: felt252,
    pub v1: ByteArray,
    pub v2: Array<felt252>,
}

