use dojo::{utils::deserialize_unwrap, meta::Layout};

pub fn entry_to_id_values<E, +Serde<E>>(entry: @E) -> (felt252, Span<felt252>) {
    let mut serialized = ArrayTrait::<felt252>::new();
    Serde::serialize(entry, ref serialized);
    (serialized.pop_front().unwrap(), serialized.span())
}

pub fn entries_to_ids_values<E, +Serde<E>, +Drop<E>>(
    mut entries: Span<E>
) -> (Span<felt252>, Array<Span<felt252>>) {
    let mut ids = ArrayTrait::<felt252>::new();
    let mut values = ArrayTrait::<Span<felt252>>::new();
    for entry in entries {
        let (id, value) = entry_to_id_values::<E>(entry);
        ids.append(id);
        values.append(value);
    };
    (ids.span(), values)
}

pub fn id_values_to_entry<E, +Serde<E>>(id: felt252, values: Span<felt252>) -> E {
    let mut serialized = array![id];
    serialized.append_span(values);
    deserialize_unwrap(serialized.span())
}

pub fn ids_values_to_entries<E, +Serde<E>, +Drop<E>>(
    ids: Span<felt252>, values: Array<Span<felt252>>
) -> Array<E> {
    let mut entries = ArrayTrait::<E>::new();
    for n in 0..ids.len() {
        entries.append(id_values_to_entry(*ids[n], *values[n]));
    };
    entries
}

pub fn entry_layout(layout: Layout) -> Layout {
    let mut span = match layout {
        Layout::Struct(layout) => layout,
        _ => panic!("Unexpected layout type for an entity.")
    };
    Layout::Struct(span.slice(1, span.len() - 1))
}
