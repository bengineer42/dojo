use dojo::{
    meta::{Layout, layout::compute_packed_size, Introspect}, utils::{find_model_field_layout},
    utils::{serialize_inline, deserialize_unwrap},
};


/// The `Schema` trait.
///
/// It provides a standardized way to interact with models.
pub trait Schema<S> {
    /// Returns the keys of the model.
    fn serialize(self: @S) -> Span<felt252>;
    /// Constructs a model from the given keys and values.
    fn deserialize(values: Span<felt252>) -> S;
    /// Returns the memory layout of the model.
    fn layout() -> Layout;
    /// Returns the layout of a field in the model.
    fn field_layout(field_selector: felt252) -> Option<Layout>;
    /// Returns the unpacked size of the model. Only applicable for fixed size models.
    fn unpacked_size() -> Option<usize>;
    /// Returns the packed size of the model. Only applicable for fixed size models.
    fn packed_size() -> Option<usize>;
    /// Returns the instance selector of the model.
    fn instance_layout(self: @S) -> Layout;
}

pub impl SchemaImpl<S, +Serde<S>, +Introspect<S>> of Schema<S> {
    fn serialize(self: @S) -> Span<felt252> {
        serialize_inline(self)
    }

    fn deserialize(values: Span<felt252>) -> S {
        deserialize_unwrap(values)
    }

    fn layout() -> Layout {
        Introspect::<S>::layout()
    }

    fn field_layout(field_selector: felt252) -> Option<Layout> {
        find_model_field_layout(Self::layout(), field_selector)
    }

    fn unpacked_size() -> Option<usize> {
        Introspect::<S>::size()
    }

    fn packed_size() -> Option<usize> {
        compute_packed_size(Introspect::<S>::layout())
    }

    fn instance_layout(self: @S) -> Layout {
        Introspect::<S>::layout()
    }
}

