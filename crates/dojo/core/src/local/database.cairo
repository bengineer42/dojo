use dojo::{
    database::DatabaseInterface, meta::Layout,
    storage::entity_model::{read_model_entity, write_model_entity},
    world::{IWorldDispatcher, IWorldDispatcherTrait}
};

#[derive(Drop, Copy)]
struct LocalDatabase {
    dispatcher: IWorldDispatcher
}


impl LocalDatabaseInterfaceImpl of DatabaseInterface<LocalDatabase> {
    fn read_entity(
        self: @LocalDatabase, table: felt252, id: felt252, layout: Layout
    ) -> Span<felt252> {
        read_model_entity(table, id, layout)
    }

    fn read_entities(
        self: @LocalDatabase, table: felt252, ids: Span<felt252>, layout: Layout
    ) -> Array<Span<felt252>> {
        let mut entities = ArrayTrait::<Span<felt252>>::new();
        for id in ids {
            entities.append(read_model_entity(table, *id, layout));
        };
        entities
    }

    fn write_entity(
        ref self: LocalDatabase, table: felt252, id: felt252, values: Span<felt252>, layout: Layout
    ) {
        write_model_entity(table, id, values, layout)
    }

    fn write_entities(
        ref self: LocalDatabase,
        table: felt252,
        mut ids: Span<felt252>,
        mut values: Array<Span<felt252>>,
        layout: Layout
    ) {
        loop {
            match (ids.pop_front(), values.pop_front()) {
                (
                    Option::Some(id), Option::Some(values)
                ) => { write_model_entity(table, *id, values, layout); },
                _ => { break; }
            }
        }
    }
}
