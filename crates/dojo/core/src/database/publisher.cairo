use dojo::{
    meta::{Introspect, Layout}, utils::{serialize_inline, serialize_multiple},
    database::{entry::{entry_layout, entry_to_id_values, entries_to_ids_values}, DatabaseTable}
};

/// Interface to publish entities without writing to the database.
pub trait PublisherInterface<P> {
    /// Set an entity with a layout.
    fn set_entity(ref self: P, table: felt252, id: felt252, values: Span<felt252>, layout: Layout);

    /// Set multiple entities with a layout.
    fn set_entities(
        ref self: P,
        table: felt252,
        ids: Span<felt252>,
        values: Array<Span<felt252>>,
        layout: Layout
    );
}

/// Publish with a schema without writing to the database.
pub trait PublisherTrait<P> {
    /// Set a value with a schema.
    fn set_table_value<V, +Serde<V>, +Introspect<V>>(
        ref self: P, table: felt252, id: felt252, value: @V
    );

    /// Set multiple values with a schema.
    fn set_table_values<V, +Serde<V>, +Introspect<V>>(
        ref self: P, table: felt252, ids: Span<felt252>, values: Span<V>
    );

    /// Set an entry with a schema.
    fn set_table_entry<E, +Serde<E>, +Introspect<E>>(ref self: P, table: felt252, entry: @E);

    /// Set multiple entries with a schema.
    fn set_table_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: P, table: felt252, entries: Span<E>
    );

    /// Convert to a table.
    fn to_table(self: @P, selector: felt252) -> DatabaseTable<P>;
}

/// Publish to a table without writing to the database.
pub trait TablePublisherTrait<T> {
    /// Set a value with a schema.
    fn set_value<V, +Serde<V>, +Introspect<V>>(ref self: T, table: felt252, id: felt252, value: @V);

    /// Set multiple values with a schema.
    fn set_values<V, +Serde<V>, +Introspect<V>>(
        ref self: T, table: felt252, ids: Span<felt252>, values: Span<V>
    );

    /// Set an entry with a schema.
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

    fn to_table(self: @P, selector: felt252) -> DatabaseTable<P> {
        DatabaseTable { database: *self, selector, }
    }
}

pub impl TablePublisherImpl<
    P, +PublisherInterface<P>, +Copy<P>, +Drop<P>
> of TablePublisherTrait<DatabaseTable<P>> {
    fn set_value<V, +Serde<V>, +Introspect<V>>(
        ref self: DatabaseTable<P>, table: felt252, id: felt252, value: @V
    ) {
        let mut database = self.database;
        database.set_entity(self.selector, id, serialize_inline(value), Introspect::<V>::layout())
    }

    fn set_values<V, +Serde<V>, +Introspect<V>>(
        ref self: DatabaseTable<P>, table: felt252, ids: Span<felt252>, values: Span<V>
    ) {
        let mut database = self.database;
        database
            .set_entities(self.selector, ids, serialize_multiple(values), Introspect::<V>::layout())
    }

    fn set_entry<E, +Serde<E>, +Introspect<E>>(
        ref self: DatabaseTable<P>, table: felt252, entry: @E
    ) {
        let mut database = self.database;
        let (id, values) = entry_to_id_values(entry);
        database.set_entity(self.selector, id, values, entry_layout(Introspect::<E>::layout()));
    }

    fn set_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: DatabaseTable<P>, table: felt252, entries: Span<E>
    ) {
        let mut database = self.database;
        let (ids, values) = entries_to_ids_values(entries);
        database.set_entities(self.selector, ids, values, entry_layout(Introspect::<E>::layout()));
    }
}
