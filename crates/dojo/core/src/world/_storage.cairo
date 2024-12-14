//! A simple storage abstraction for the world's storage.

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::meta::Introspect;
use dojo::utils::{serialize_inline,deserialize_unwrap};

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

impl WorldStorageTrait of DatabaseTrait<WorldDatabase> {
    fn read_table_entry<S, +Serde<S>, +Introspect<S>>(self: @WorldDatabase, table: felt252, id: felt252) -> S {
        deserialize_unwrap(
            IWorldDispatcherTrait::entity(
                self.dispatcher, table, ModelIndex::Id(id), Introspect::<S>::layout()
            )
        )
    }

    fn read_table_entries<S, +Drop<S>, +Serde<S>, +Introspect<S>>(self: @WorldDatabase, table: felt252, ids: Span<felt252>) -> Array<S> {
        let mut values = array![];
        for v in IWorldDispatcherTrait::entities(
            self.dispatcher, table, ids.into(), Introspect::<S>::layout()
        ) {
            values.append(deserialize_unwrap(*v));
        };
        values
    }

    fn write_table_entry<S, +Drop<S>, +Serde<S>, +Introspect<S>>(ref self: WorldDatabase, table: felt252, id: felt252, value: @S) {
        IWorldDispatcherTrait::set_entity(
            self.dispatcher, table, ModelIndex::Id(id), serialize_inline(@value), Introspect::<S>::layout()
        )
    }

    fn write_table_entries<S, +Drop<S>, +Serde<S>, +Introspect<S>>(ref self: WorldDatabase, table: felt252, ids: Span<felt252>, values: Span<S>) {
        let mut serialized_values = ArrayTrait::<Span<felt252>>::new();
        for value in values {
            serialized_values.append(serialize_inline(value));
        };
        IWorldDispatcherTrait::set_entities(
            self.dispatcher,
            table,
            ids.into(),
            serialized_values.span(),
            Introspect::<T>::layout()
        );
    }

    fn to_table<T, +Table<T>>(self: @WorldDatabase, selector: felt252) -> T {
        Table::<T> { database: self, selector }
    }
}

