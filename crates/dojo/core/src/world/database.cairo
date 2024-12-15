//! A simple storage abstraction for the world's storage.

use dojo::{
    meta::Layout, world::{IWorldDispatcher, IWorldDispatcherTrait}, database::DatabaseInterface,
    model::ModelIndex,
};

#[derive(Drop, Copy)]
pub struct WorldStorage {
    pub dispatcher: IWorldDispatcher,
    pub namespace_hash: felt252,
}

struct WorldDatabase {
    dispatcher: IWorldDispatcher
}

impl Felt252SpanIntoIndexes of Into<Span<felt252>, Span<ModelIndex>> {
    fn into(self: Span<felt252>) -> Span<ModelIndex> {
        let mut indexes: Array<ModelIndex> = array![];
        for id in self {
            indexes.append(ModelIndex::Id(*id));
        };
        indexes.span()
    }
}

impl WorldDatabaseImpl of DatabaseInterface<WorldDatabase> {
    fn read_entity(
        self: @WorldDatabase, table: felt252, id: felt252, layout: Layout
    ) -> Span<felt252> {
        IWorldDispatcherTrait::entity(*self.dispatcher, table, ModelIndex::Id(id), layout)
    }

    fn read_entities(
        self: @WorldDatabase, table: felt252, ids: Span<felt252>, layout: Layout
    ) -> Array<Span<felt252>> {
        IWorldDispatcherTrait::entities(*self.dispatcher, table, ids.into(), layout).into()
    }

    fn write_entity(
        ref self: WorldDatabase, table: felt252, id: felt252, values: Span<felt252>, layout: Layout
    ) {
        IWorldDispatcherTrait::set_entity(
            self.dispatcher, table, ModelIndex::Id(id), values, layout
        )
    }

    fn write_entities(
        ref self: WorldDatabase,
        table: felt252,
        ids: Span<felt252>,
        values: Array<Span<felt252>>,
        layout: Layout
    ) {
        IWorldDispatcherTrait::set_entities(
            self.dispatcher, table, ids.into(), values.span(), layout
        )
    }
}

