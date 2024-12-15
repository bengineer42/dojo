use dojo::meta::FieldLayout;

pub type Schema = Span<FieldLayout>;

pub trait SchemaTrait<T> {
    fn schema() -> Schema;
}
mod implement {
    use dojo::meta::{Introspect, Layout};
    use super::{SchemaTrait, Schema};
    pub impl SchemaImpl<T, +Introspect<T>> of SchemaTrait<T> {
        fn schema() -> Schema {
            match Introspect::<T>::layout() {
                Layout::Struct(fields) => { fields },
                _ => panic!("Unexpected model layout")
            }
        }
    }
}
