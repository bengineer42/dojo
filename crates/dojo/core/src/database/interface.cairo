#[starknet::interface]
trait IDatabase<T> {
    fn read_entity(self: @T, table: felt252, id: felt252, layout: Layout) -> Array<felt252>;
    fn read_entities(
        self: @T, table: felt252, ids: Span<felt252>, layout: Layout
    ) -> Array<Array<felt252>>;
    fn write_entity(self: @T, table: felt252, id: felt252, values: Span<felt252>, layout: Layout);
    fn write_entities(
        self: @T, table: felt252, ids: Span<felt252>, values: Array<Span<felt252>>, layout: Layout
    );
}

#[starknet::interface]
trait IPublisher<T> {
    fn set_entity(self: T, table: felt252, id: felt252, values: Span<felt252>, layout: Layout);
    fn set_entities(
        self: T, table: felt252, ids: Span<felt252>, values: Array<Span<felt252>>, layout: Layout
    );
}
