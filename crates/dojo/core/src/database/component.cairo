use dojo::database::DatabaseInterface;


#[starknet::component]
mod database {
    use dojo::database::IDatabase;

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {}

    impl IDatabaseImpl of IDatabase<ContractState> {
        fn read_entity(
            self: @ContractState, table: felt252, id: felt252, layout: Layout
        ) -> Span<felt252> {}

        fn read_entities(
            self: @ContractState, table: felt252, ids: Span<felt252>, layout: Layout
        ) -> Array<Span<felt252>> {}

        fn write_entity(
            ref self: ContractState,
            table: felt252,
            id: felt252,
            values: Span<felt252>,
            layout: Layout
        ) {}

        fn write_entities(
            ref self: ContractState,
            table: felt252,
            ids: Span<felt252>,
            values: Array<Span<felt252>>,
            layout: Layout
        ) {}
    }
}
