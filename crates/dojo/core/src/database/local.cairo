use dojo::{
    database::{DatabaseInterface, interface::IPublisher}, meta::Layout,
    storage::entity_model::{read_model_entity, write_model_entity},
    event::storage::{emit_entity_update_event, emit_entities_update_event}
};

#[derive(Drop, Copy)]
struct LocalDatabase<P> {
    publisher: P,
}

#[derive(Drop, Copy)]
struct LocalPublisher {}

impl LocalDatabaseInterfaceImpl<
    P, +Drop<P>, +Copy<P>, +IPublisher<P>
> of DatabaseInterface<LocalDatabase<P>> {
    fn read_entity(
        self: @LocalDatabase<P>, table: felt252, index: felt252, layout: Layout
    ) -> Span<felt252> {
        read_model_entity(table, index, layout)
    }

    fn read_entities(
        self: @LocalDatabase<P>, table: felt252, indexes: Span<felt252>, layout: Layout
    ) -> Array<Span<felt252>> {
        let mut entities = ArrayTrait::<Span<felt252>>::new();
        for index in indexes {
            entities.append(read_model_entity(table, *index, layout));
        };
        entities
    }

    fn write_entity(
        ref self: LocalDatabase<P>,
        table: felt252,
        index: felt252,
        values: Span<felt252>,
        layout: Layout
    ) {
        write_model_entity(table, index, values, layout);
        let mut publisher = self.publisher;
        publisher.set_entity(table, index, values, layout);
    }

    fn write_entities(
        ref self: LocalDatabase<P>,
        table: felt252,
        mut indexes: Span<felt252>,
        mut values: Array<Span<felt252>>,
        layout: Layout
    ) {
        loop {
            match (indexes.pop_front(), values.pop_front()) {
                (
                    Option::Some(id), Option::Some(values)
                ) => { write_model_entity(table, *id, values, layout); },
                _ => { break; }
            }
        };
        let mut publisher = self.publisher;
        publisher.set_entities(table, indexes, values, layout);
    }
}

impl LocalPublisherImpl of IPublisher<LocalPublisher> {
    fn set_entity(
        ref self: LocalPublisher,
        table: felt252,
        index: felt252,
        values: Span<felt252>,
        layout: Layout
    ) {
        emit_entity_update_event(table, index, values);
    }

    fn set_entities(
        ref self: LocalPublisher,
        table: felt252,
        indexes: Span<felt252>,
        values: Array<Span<felt252>>,
        layout: Layout
    ) {
        emit_entities_update_event(table, indexes, values);
    }
}
