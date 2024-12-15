use starknet::ContractAddress;
use dojo::{
    meta::Layout,
    database::{
        IDatabase, IDatabaseDispatcher, IDatabaseDispatcherTrait, IPublisher, IPublisherDispatcher,
        IPublisherDispatcherTrait
    },
    contract::Contract;
};

impl IDatabaseImpl of IDatabase<Contract> {
    fn read_entity(self: @Contract, table: felt252, id: felt252, layout: Layout) -> Array<felt252> {
        IDatabaseDispatcher { contract_address: *self.contract_address }
            .read_entity(table, id, layout)
    }

    fn read_entities(
        self: @Contract, table: felt252, ids: Span<felt252>, layout: Layout
    ) -> Array<Array<felt252>> {
        IDatabaseDispatcher { contract_address: *self.contract_address }
            .read_entities(table, ids, layout)
    }

    fn write_entity(
        ref self: Contract, table: felt252, id: felt252, values: Span<felt252>, layout: Layout
    ) {
        IDatabaseDispatcher { contract_address: self.contract_address }
            .write_entity(table, id, values, layout)
    }

    fn write_entities(
        ref self: Contract,
        table: felt252,
        ids: Span<felt252>,
        values: Array<Span<felt252>>,
        layout: Layout
    ) {
        IDatabaseDispatcher { contract_address: self.contract_address }
            .write_entities(table, ids, values, layout)
    }
}

impl IPublisherImpl of IPublisher<Contract> {
    fn set_entity(
        ref self: Contract, table: felt252, id: felt252, values: Span<felt252>, layout: Layout
    ) {
        IPublisherDispatcher { contract_address: self.contract_address }
            .set_entity(table, id, values, layout)
    }

    fn set_entities(
        ref self: Contract,
        table: felt252,
        ids: Span<felt252>,
        values: Array<Span<felt252>>,
        layout: Layout
    ) {
        IPublisherDispatcher { contract_address: self.contract_address }
            .set_entities(table, ids, values, layout)
    }
}
