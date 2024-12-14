use dojo::{model::{ModelPtr, model_value::ModelValueKey}, meta::Introspect};

// TODO: define the right interface for member accesses.

pub trait DatabaseTrait<N> {

    fn read_table_entry<S, +Serde<S>, +Introspect<S>>(self: @S, table: felt252, id: felt252) -> S;

    fn read_table_entries<S, +Drop<S>, +Serde<S>, +Introspect<S>>(self: @S, table: felt252, ids: Span<felt252>) -> Array<S>;

    fn write_table_entry<S, +Drop<S>, +Serde<S>, +Introspect<S>>(ref self: S, table: felt252, id:felt252,  value: @S);

    fn write_table_entries<S, +Drop<S>, +Serde<S>, +Introspect<S>>(ref self: S, table: felt252, ids: Span<felt252>,  values: Span<S>);

    fn to_table<T, +Table<T>>(self: @S, selector: felt252) -> T;
}


pub trait TableTrait<T> {
    fn read_entry<S, +Serde<S>, +Introspect<S>>(self: @T, id: felt252) -> S;

    fn read_entries<S, +Drop<S>, +Serde<S>, +Introspect<S>>(self: @T, ids: Span<felt252>) -> Array<S>;

    fn write_entry<S, +Drop<S>, +Serde<S>, +Introspect<S>>(ref self: T, id:felt252,  table: @S);

    fn write_entries<S, +Drop<S>, +Serde<S>, +Introspect<S>>(ref self: NT ids: Span<felt252>,  table: Span<S>);

    fn selector(self: @T) -> felt252;

    fn database<D, +Database<D>>(self: @T) -> D;
}

struct Table<D>{
    database: D,
    selector: felt252,
}

impl WorldTableImpl of TableTrait<Table<D>> {
    fn read_entry<S, +Serde<S>, +Introspect<S>>(self: @WorldTable<D>, id: felt252) -> S {
        self.database.read_table_entry(self.selector, id)
    }

    fn read_entries<S, +Drop<S>, +Serde<S>, +Introspect<S>>(self: @WorldTable<D>, ids: Span<felt252>) -> Array<S> {
        self.database.read_table_entries(self.selector, ids)
    }

    fn write_entry<S, +Drop<S>, +Serde<S>, +Introspect<S>>(ref self: WorldTable<D>, id:felt252,  table: @S) {
        self.database.write_table_entry(self.selector, id, table)
    }

    fn write_entries<S, +Drop<S>, +WorldDatabaseSerde<S>, +Introspect<S>>(ref self: WorldTable<D>, ids: Span<felt252>,  table: Span<S>) {
        self.database.write_table_entries(self.selector, ids, table)
    }

    fn selector(self: @WorldTable<D>) -> felt252 {
        self.selector
    }

    fn database<D, +Database<D>>(self: @WorldTable<D>) -> D {
        self.database
    }
}


