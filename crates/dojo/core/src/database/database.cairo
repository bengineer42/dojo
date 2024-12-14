use dojo::{
    meta::{Introspect, Layout}, utils::{deserialize_unwrap, serialize_inline},
    database::entry::{entry_layout, id_values_to_entry, entry_to_id_values}
};

// TODO: define the right interface for member accesses.

pub trait DatabaseInterface<D> {
    fn read_entity(self: @D, table: felt252, id: felt252, layout: Layout) -> Span<felt252>;

    fn read_entities(
        self: @D, table: felt252, ids: Span<felt252>, layout: Layout
    ) -> Array<Span<felt252>>;

    fn write_entity(
        ref self: D, table: felt252, id: felt252, values: Span<felt252>, layout: Layout
    );

    fn write_entities(
        ref self: D,
        table: felt252,
        ids: Span<felt252>,
        values: Array<Span<felt252>>,
        layout: Layout
    );
}

pub trait DatabaseTrait<D> {
    fn read_table_value<V, +Serde<V>, +Introspect<V>>(self: @D, table: felt252, id: felt252) -> V;

    fn read_table_values<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        self: @D, table: felt252, ids: Span<felt252>
    ) -> Array<V>;

    fn read_table_entry<E, +Serde<E>, +Introspect<E>>(self: @D, table: felt252, id: felt252) -> E;

    fn read_table_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        self: @D, table: felt252, ids: Span<felt252>
    ) -> Array<E>;

    fn write_table_value<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        ref self: D, table: felt252, id: felt252, value: @V
    );

    fn write_table_values<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        ref self: D, table: felt252, ids: Span<felt252>, values: Span<V>
    );

    fn write_table_entry<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: D, table: felt252, entry: @E
    );

    fn write_table_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: D, table: felt252, entries: Span<E>
    );

    fn to_table<T, +TableTrait<T>>(self: @D, selector: felt252) -> T;
}


pub trait TableTrait<T> {
    fn new<D>(database: D, selector: felt252) -> T;

    fn read_value<V, +Serde<V>, +Introspect<V>>(self: @T, id: felt252) -> V;

    fn read_values<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        self: @T, ids: Span<felt252>
    ) -> Array<V>;

    fn read_entry<E, +Serde<E>, +Introspect<E>>(self: @T, id: felt252) -> E;

    fn read_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        self: @T, ids: Span<felt252>
    ) -> Array<E>;

    fn write_value<V, +Drop<V>, +Serde<V>, +Introspect<V>>(ref self: T, id: felt252, value: @V);

    fn write_values<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        ref self: T, ids: Span<felt252>, values: Span<V>
    );

    fn write_entry<E, +Drop<E>, +Serde<E>, +Introspect<E>>(ref self: T, entry: @E);

    fn write_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(ref self: T, entries: Span<E>);

    fn selector(self: @T) -> felt252;
}

pub struct Table<D> {
    pub database: D,
    pub selector: felt252,
}

pub impl DatabaseImpl<D, +DatabaseInterface<D>, +Drop<D>, +Copy<D>> of DatabaseTrait<D> {
    fn read_table_value<V, +Serde<V>, +Introspect<V>>(self: @D, table: felt252, id: felt252) -> V {
        deserialize_unwrap(self.read_entity(table, id, Introspect::<V>::layout()))
    }

    fn read_table_values<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        self: @D, table: felt252, ids: Span<felt252>
    ) -> Array<V> {
        let mut values = ArrayTrait::<V>::new();
        for v in self
            .read_entities(
                table, ids, Introspect::<V>::layout()
            ) {
                values.append(deserialize_unwrap(*v));
            };
        values
    }

    fn read_table_entry<E, +Serde<E>, +Introspect<E>>(self: @D, table: felt252, id: felt252) -> E {
        id_values_to_entry(id, self.read_entity(table, id, entry_layout(Introspect::<E>::layout())))
    }

    fn read_table_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        self: @D, table: felt252, ids: Span<felt252>
    ) -> Array<E> {
        let mut entries = ArrayTrait::<E>::new();
        let entities = self.read_entities(table, ids, entry_layout(Introspect::<E>::layout()));
        for n in 0..ids.len() {
            entries.append(id_values_to_entry(*ids[n], *entities[n]));
        };
        entries
    }

    fn write_table_value<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        ref self: D, table: felt252, id: felt252, value: @V
    ) {
        self.write_entity(table, id, serialize_inline(value), Introspect::<V>::layout())
    }

    fn write_table_values<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        ref self: D, table: felt252, ids: Span<felt252>, values: Span<V>
    ) {
        let mut serialized_values = ArrayTrait::<Span<felt252>>::new();
        for value in values {
            serialized_values.append(serialize_inline(value));
        };
        self.write_entities(table, ids, serialized_values, Introspect::<V>::layout())
    }

    fn write_table_entry<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: D, table: felt252, entry: @E
    ) {
        let (id, values) = entry_to_id_values(entry);
        self.write_entity(table, id, values, entry_layout(Introspect::<E>::layout()))
    }

    fn write_table_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: D, table: felt252, entries: Span<E>
    ) {
        let mut values = ArrayTrait::<Span<felt252>>::new();
        let mut ids = ArrayTrait::<felt252>::new();
        for entry in entries {
            let (id, value) = entry_to_id_values(entry);
            ids.append(id);
            values.append(value);
        };
        self.write_entities(table, ids.span(), values, entry_layout(Introspect::<E>::layout()))
    }

    fn to_table<T, +TableTrait<T>>(self: @D, selector: felt252) -> T {
        TableTrait::<T>::new(*self, selector)
    }
}


pub impl TableImpl<D, +DatabaseTrait<D>> of TableTrait<Table<D>> {
    fn new<D>(database: D, selector: felt252) -> Table<D> {
        Table { database, selector, }
    }

    fn read_value<V, +Serde<V>, +Introspect<V>>(self: @Table<D>, id: felt252) -> V {
        self.database.read_table_value(*self.selector, id)
    }

    fn read_values<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        self: @Table<D>, ids: Span<felt252>
    ) -> Array<V> {
        self.database.read_table_values(*self.selector, ids)
    }

    fn read_entry<E, +Serde<E>, +Introspect<E>>(self: @Table<D>, id: felt252) -> E {
        self.database.read_table_entry(*self.selector, id)
    }

    fn read_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        self: @Table<D>, ids: Span<felt252>
    ) -> Array<E> {
        self.database.read_table_entries(*self.selector, ids)
    }

    fn write_value<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        ref self: Table<D>, id: felt252, value: @V
    ) {
        self.database.write_table_value(self.selector, id, value)
    }

    fn write_values<V, +Drop<V>, +Serde<V>, +Introspect<V>>(
        ref self: Table<D>, ids: Span<felt252>, values: Span<V>
    ) {
        self.database.write_table_values(self.selector, ids, values)
    }

    fn write_entry<E, +Drop<E>, +Serde<E>, +Introspect<E>>(ref self: Table<D>, entry: @E) {
        self.database.write_table_entry(self.selector, entry)
    }

    fn write_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(ref self: Table<D>, entries: Span<E>) {
        self.database.write_table_entries(self.selector, entries)
    }

    fn selector(self: @Table<D>) -> felt252 {
        *self.selector
    }
}

