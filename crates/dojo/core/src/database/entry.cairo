use dojo::{utils::deserialize_unwrap, meta::Layout};

pub fn entry_to_id_values<E, +Serde<E>>(entry: @E) -> (felt252, Span<felt252>) {
    let mut serialized = ArrayTrait::<felt252>::new();
    Serde::serialize(entry, ref serialized);
    (serialized.pop_front().unwrap(), serialized.span())
}

pub fn id_values_to_entry<E, +Serde<E>>(id: felt252, values: Span<felt252>) -> E {
    let mut serialized = array![id];
    serialized.append_span(values);
    deserialize_unwrap(serialized.span())
}


pub fn entry_layout(layout: Layout) -> Layout {
    let mut span = match layout {
        Layout::Struct(layout) => layout,
        _ => panic!("Unexpected layout type for an entity.")
    };
    Layout::Struct(span.slice(1, span.len() - 1))
}
