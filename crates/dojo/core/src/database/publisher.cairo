use dojo::{
    meta::{Introspect, Layout}, utils::{serialize_inline, serialize_multiple},
    database::{entry::{entry_layout, entry_to_id_values, entries_to_ids_values}, Table}
};

pub trait PublisherInterface<P> {
    fn set_entity(ref self: P, table: felt252, id: felt252, values: Span<felt252>, layout: Layout);

    fn set_entities(
        ref self: P,
        table: felt252,
        ids: Span<felt252>,
        values: Array<Span<felt252>>,
        layout: Layout
    );
}


pub trait PublisherTrait<P> {
    fn set_table_value<V, +Serde<V>, +Introspect<V>>(
        ref self: P, table: felt252, id: felt252, value: @V
    );

    fn set_table_values<V, +Serde<V>, +Introspect<V>>(
        ref self: P, table: felt252, ids: Span<felt252>, values: Span<V>
    );

    fn set_table_entry<E, +Serde<E>, +Introspect<E>>(ref self: P, table: felt252, entry: @E);

    fn set_table_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: P, table: felt252, entries: Span<E>
    );

    fn to_table(self: @P, selector: felt252) -> Table<P>;
}

pub trait TablePublisherTrait<T> {
    fn set_value<V, +Serde<V>, +Introspect<V>>(ref self: T, table: felt252, id: felt252, value: @V);

    fn set_values<V, +Serde<V>, +Introspect<V>>(
        ref self: T, table: felt252, ids: Span<felt252>, values: Span<V>
    );

    fn set_entry<E, +Serde<E>, +Introspect<E>>(ref self: T, table: felt252, entry: @E);

    fn set_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: T, table: felt252, entries: Span<E>
    );
}

pub impl PublisherImpl<P, +PublisherInterface<P>, +Drop<P>, +Copy<P>> of PublisherTrait<P> {
    fn set_table_value<V, +Serde<V>, +Introspect<V>>(
        ref self: P, table: felt252, id: felt252, value: @V
    ) {
        self.set_entity(table, id, serialize_inline(value), Introspect::<V>::layout())
    }

    fn set_table_values<V, +Serde<V>, +Introspect<V>>(
        ref self: P, table: felt252, ids: Span<felt252>, values: Span<V>
    ) {
        self.set_entities(table, ids, serialize_multiple(values), Introspect::<V>::layout())
    }

    fn set_table_entry<E, +Serde<E>, +Introspect<E>>(ref self: P, table: felt252, entry: @E) {
        let (id, values) = entry_to_id_values(entry);
        self.set_entity(table, id, values, entry_layout(Introspect::<E>::layout()));
    }

    fn set_table_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: P, table: felt252, entries: Span<E>
    ) {
        let (ids, values) = entries_to_ids_values(entries);
        self.set_entities(table, ids, values, entry_layout(Introspect::<E>::layout()));
    }

    fn to_table(self: @P, selector: felt252) -> Table<P> {
        Table { database: *self, selector, }
    }
}

pub impl TablePublisherImpl<
    P, +PublisherInterface<P>, +Copy<P>, +Drop<P>
> of TablePublisherTrait<Table<P>> {
    fn set_value<V, +Serde<V>, +Introspect<V>>(
        ref self: Table<P>, table: felt252, id: felt252, value: @V
    ) {
        let mut database = self.database;
        database.set_entity(self.selector, id, serialize_inline(value), Introspect::<V>::layout())
    }

    fn set_values<V, +Serde<V>, +Introspect<V>>(
        ref self: Table<P>, table: felt252, ids: Span<felt252>, values: Span<V>
    ) {
        let mut database = self.database;
        database
            .set_entities(self.selector, ids, serialize_multiple(values), Introspect::<V>::layout())
    }

    fn set_entry<E, +Serde<E>, +Introspect<E>>(ref self: Table<P>, table: felt252, entry: @E) {
        let mut database = self.database;
        let (id, values) = entry_to_id_values(entry);
        database.set_entity(self.selector, id, values, entry_layout(Introspect::<E>::layout()));
    }

    fn set_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: Table<P>, table: felt252, entries: Span<E>
    ) {
        let mut database = self.database;
        let (ids, values) = entries_to_ids_values(entries);
        database.set_entities(self.selector, ids, values, entry_layout(Introspect::<E>::layout()));
    }
}
