use dojo::{
    meta::{Introspect, SchemaTrait, Schema},
    utils::{deserialize_unwrap, serialize_inline, serialize_multiple, deserialize_multiple},
    database::{
        DatabaseTable,
        entry::{
            index_value_to_entry, indexes_values_to_entries, entry_to_id_values,
            entries_to_ids_values
        },
        entry,
    },
};


pub trait DatabaseInterface<D> {
    /// Read an entity with a schema from a table in database.
    fn read_entity(self: @D, table: felt252, index: felt252, schema: Schema) -> Span<felt252>;

    /// Read multiple entities with a schema from a table in database.
    fn read_entities(
        self: @D, table: felt252, indexes: Span<felt252>, schema: Schema
    ) -> Array<Span<felt252>>;

    /// Write an entity with a schema to a table in database.
    fn write_entity(
        ref self: D, table: felt252, index: felt252, values: Span<felt252>, schema: Schema
    );

    /// Write multiple entities with a schema to a table in database.
    fn write_entities(
        ref self: D,
        table: felt252,
        indexes: Span<felt252>,
        values: Array<Span<felt252>>,
        schema: Schema
    );
}

/// Schema (S): field names an types are used as schemas to read the database.
/// Entity (E): Is the same as a Schema but the first value is the index.

pub trait DatabaseTrait<D> {
    /// Read a entry from a table in database using a schema.
    fn read_table_value<S, +Serde<S>, +SchemaTrait<S>>(
        self: @D, table: felt252, index: felt252
    ) -> S;

    /// Read multiple entries from a table in database using a schema.
    fn read_table_values<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        self: @D, table: felt252, indexes: Span<felt252>
    ) -> Array<S>;

    /// Read an entry from a table in database using an entity.
    fn read_table_entry<E, +Serde<E>, +SchemaTrait<E>>(
        self: @D, table: felt252, index: felt252
    ) -> E;

    /// Read multiple entries from a table in database using entities.
    fn read_table_entries<E, +Drop<E>, +Serde<E>, +SchemaTrait<E>>(
        self: @D, table: felt252, indexes: Span<felt252>
    ) -> Array<E>;

    /// Write an entry to a table in database using a schema.
    fn write_table_value<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        ref self: D, table: felt252, index: felt252, value: @S
    );

    /// Write multiple entries to a table in database using a schema.
    fn write_table_values<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        ref self: D, table: felt252, indexes: Span<felt252>, values: Span<S>
    );

    /// Write an entry to a table in database using an entity.
    fn write_table_entry<E, +Drop<E>, +Serde<E>, +SchemaTrait<E>>(
        ref self: D, table: felt252, entry: @E
    );

    /// Write multiple entries to a table in database using entities.
    fn write_table_entries<E, +Drop<E>, +Serde<E>, +SchemaTrait<E>>(
        ref self: D, table: felt252, entries: Span<E>
    );

    /// Convert a database to a table with selector being the selector for the table.
    fn to_table(self: @D, table: felt252) -> DatabaseTable<D>;
}


pub trait TableTrait<T> {
    /// Read a value from a table in database using a schema.
    fn read_value<S, +Serde<S>, +SchemaTrait<S>>(self: @T, index: felt252) -> S;

    /// Read multiple values from a table in database using a schema.
    fn read_values<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        self: @T, indexes: Span<felt252>
    ) -> Array<S>;

    /// Read an entry from a table in database using an entity.
    fn read_entry<E, +Serde<E>, +SchemaTrait<E>>(self: @T, index: felt252) -> E;

    /// Read multiple entries from a table in database using entities.
    fn read_entries<E, +Drop<E>, +Serde<E>, +SchemaTrait<E>>(
        self: @T, indexes: Span<felt252>
    ) -> Array<E>;

    /// Write a value to a table in database using a schema.
    fn write_value<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(ref self: T, index: felt252, value: @S);

    /// Write multiple values to a table in database using a schema.
    fn write_values<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        ref self: T, indexes: Span<felt252>, values: Span<S>
    );

    /// Write an entry to a table in database using an entity.
    fn write_entry<E, +Drop<E>, +Serde<E>, +SchemaTrait<E>>(ref self: T, entry: @E);


    fn write_entries<E, +Drop<E>, +Serde<E>, +SchemaTrait<E>>(ref self: T, entries: Span<E>);

    fn selector(self: @T) -> felt252;
}

pub impl DatabaseImpl<D, +DatabaseInterface<D>, +Drop<D>, +Copy<D>> of DatabaseTrait<D> {
    fn read_table_value<S, +Serde<S>, +SchemaTrait<S>>(
        self: @D, table: felt252, index: felt252
    ) -> S {
        deserialize_unwrap(self.read_entity(table, index, SchemaTrait::<S>::schema()))
    }

    fn read_table_values<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        self: @D, table: felt252, indexes: Span<felt252>
    ) -> Array<S> {
        deserialize_multiple(self.read_entities(table, indexes, SchemaTrait::<S>::schema()))
    }

    fn read_table_entry<E, +Serde<E>, +Introspect<E>>(
        self: @D, table: felt252, index: felt252
    ) -> E {
        index_value_to_entry(
            index, self.read_entity(table, index, entry::EntitySchemaImpl::<E>::schema())
        )
    }

    fn read_table_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        self: @D, table: felt252, indexes: Span<felt252>
    ) -> Array<E> {
        indexes_values_to_entries(
            indexes, self.read_entities(table, indexes, entry::EntitySchemaImpl::<E>::schema())
        )
    }

    fn write_table_value<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        ref self: D, table: felt252, index: felt252, value: @S
    ) {
        self.write_entity(table, index, serialize_inline(value), SchemaTrait::<S>::schema())
    }

    fn write_table_values<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        ref self: D, table: felt252, indexes: Span<felt252>, values: Span<S>
    ) {
        self.write_entities(table, indexes, serialize_multiple(values), SchemaTrait::<S>::schema())
    }

    fn write_table_entry<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: D, table: felt252, entry: @E
    ) {
        let (index, values) = entry_to_id_values(entry);
        self.write_entity(table, index, values, entry::EntitySchemaImpl::<E>::schema())
    }

    fn write_table_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: D, table: felt252, entries: Span<E>
    ) {
        let (indexes, values) = entries_to_ids_values(entries);
        self.write_entities(table, indexes, values, entry::EntitySchemaImpl::<E>::schema())
    }

    fn to_table(self: @D, table: felt252) -> DatabaseTable<D> {
        DatabaseTable { database: *self, selector: table, }
    }
}


pub impl TableImpl<D, +DatabaseInterface<D>, +Drop<D>, +Copy<D>> of TableTrait<DatabaseTable<D>> {
    fn read_value<S, +Serde<S>, +SchemaTrait<S>>(self: @DatabaseTable<D>, index: felt252) -> S {
        deserialize_unwrap(
            self.database.read_entity(*self.selector, index, SchemaTrait::<S>::schema())
        )
    }

    fn read_values<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        self: @DatabaseTable<D>, indexes: Span<felt252>
    ) -> Array<S> {
        deserialize_multiple(
            self.database.read_entities(*self.selector, indexes, SchemaTrait::<S>::schema())
        )
    }

    fn read_entry<E, +Serde<E>, +Introspect<E>>(self: @DatabaseTable<D>, index: felt252) -> E {
        index_value_to_entry(
            index,
            self.database.read_entity(*self.selector, index, entry::EntitySchemaImpl::<E>::schema())
        )
    }

    fn read_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        self: @DatabaseTable<D>, indexes: Span<felt252>
    ) -> Array<E> {
        indexes_values_to_entries(
            indexes,
            self
                .database
                .read_entities(*self.selector, indexes, entry::EntitySchemaImpl::<E>::schema())
        )
    }

    fn write_value<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        ref self: DatabaseTable<D>, index: felt252, value: @S
    ) {
        let mut database = self.database;
        database
            .write_entity(self.selector, index, serialize_inline(value), SchemaTrait::<S>::schema())
    }

    fn write_values<S, +Drop<S>, +Serde<S>, +SchemaTrait<S>>(
        ref self: DatabaseTable<D>, indexes: Span<felt252>, values: Span<S>
    ) {
        let mut database = self.database;
        database
            .write_entities(
                self.selector, indexes, serialize_multiple(values), SchemaTrait::<S>::schema()
            )
    }

    fn write_entry<E, +Drop<E>, +Serde<E>, +Introspect<E>>(ref self: DatabaseTable<D>, entry: @E) {
        let (index, values) = entry_to_id_values(entry);
        let mut database = self.database;
        database.write_entity(self.selector, index, values, entry::EntitySchemaImpl::<E>::schema())
    }

    fn write_entries<E, +Drop<E>, +Serde<E>, +Introspect<E>>(
        ref self: DatabaseTable<D>, entries: Span<E>
    ) {
        let (indexes, values) = entries_to_ids_values(entries);
        let mut database = self.database;
        database
            .write_entities(self.selector, indexes, values, entry::EntitySchemaImpl::<E>::schema())
    }

    fn selector(self: @DatabaseTable<D>) -> felt252 {
        *self.selector
    }
}

