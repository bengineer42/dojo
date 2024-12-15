pub fn serialize_inline<T, +Serde<T>>(value: @T) -> Span<felt252> {
    let mut serialized = ArrayTrait::new();
    Serde::serialize(value, ref serialized);
    serialized.span()
}

pub fn deserialize_unwrap<T, +Serde<T>>(mut span: Span<felt252>) -> T {
    match Serde::deserialize(ref span) {
        Option::Some(value) => value,
        Option::None => core::panic_with_felt252('Could not deserialize')
    }
}

pub fn serialize_multiple<T, +Serde<T>>(values: Span<T>) -> Array<Span<felt252>> {
    let mut serialized_values = ArrayTrait::new();
    for value in values {
        serialized_values.append(serialize_inline(value));
    };
    serialized_values
}

pub fn deserialize_multiple<T, +Serde<T>, +Drop<T>>(values: Array<Span<felt252>>) -> Array<T> {
    let mut deserialized_values = ArrayTrait::new();
    for value in values {
        deserialized_values.append(deserialize_unwrap(value));
    };
    deserialized_values
}
