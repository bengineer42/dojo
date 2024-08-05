use dojo::model::Model;
use dojo::utils::{bytearray_hash, selector_from_names};

#[derive(Drop, Copy, Serde)]
#[dojo::model(namespace: "my_namespace")]
struct MyModel {
    #[key]
    x: u8,
    y: u8
}
