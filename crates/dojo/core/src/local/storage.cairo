use dojo::storage::entity_model::{read_model_entity, write_model_entity};
use dojo::database::DatabaseTrait;

struct LocalDatabase{
    dispatcher: ILocalDispatcher
}

impl LocalDatabase of DatabaseTrait<LocalDatabase> {
    fn read_table_entry<S, +Serde<S>, +Introspect<S>>(self: @LocalDatabase, table: felt252, id: felt252) -> S {
        deserialize_unwrap(
            read_model_entity(table, id, Introspect::<S>::layout())
        )
    }

    fn read_table_entries<S, +Drop<S>, +Serde<S>, +Introspect<S>>(self: @LocalDatabase, table: felt252, ids: Span<felt252>) -> Array<S> {
        let mut values = array![];
        let layout = Introspect::<S>::layout();
        for id in ids {
            values.append(read_model_entity(table, id, layout));
        };
        values
    }

    fn write_table_entry<S, +Drop<S>, +Serde<S>, +Introspect<S>>(ref self: LocalDatabase, table: felt252, id: felt252, value: @S) {
        write_model_entity(table, id, serialize_inline(@value), Introspect::<S>::layout());
    }

    fn write_table_entries<S, +Drop<S>, +Serde<S>, +Introspect<S>>(ref self: LocalDatabase, table: felt252, entries: Span<(felt252, @S)>) {
        let layout = Introspect::<S>::layout();
        for (id, value) in values {
            write_model_entity(table, id, serialize_inline(@value), layout)
        };
        
    }

    fn to_table<T, +Table<T>>(self: @LocalDatabase, selector: felt252) -> T {
        Table::<T> { database: self, selector }
    }
}