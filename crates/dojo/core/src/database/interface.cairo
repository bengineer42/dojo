use dojo::meta::Layout;

#[starknet::interface]
pub trait IDatabase<T> {
    fn read_entity(self: @T, table: felt252, index: felt252, layout: Layout) -> Array<felt252>;
    fn read_entities(
        self: @T, table: felt252, indexes: Span<felt252>, layout: Layout
    ) -> Array<Array<felt252>>;
    fn write_entity(
        ref self: T, table: felt252, index: felt252, values: Span<felt252>, layout: Layout
    );
    fn write_entities(
        ref self: T,
        table: felt252,
        indexes: Span<felt252>,
        values: Array<Span<felt252>>,
        layout: Layout
    );
}

#[starknet::interface]
pub trait IPublisher<T> {
    fn set_entity(
        ref self: T, table: felt252, index: felt252, values: Span<felt252>, layout: Layout
    );
    fn set_entities(
        ref self: T,
        table: felt252,
        indexes: Span<felt252>,
        values: Array<Span<felt252>>,
        layout: Layout
    );
}

