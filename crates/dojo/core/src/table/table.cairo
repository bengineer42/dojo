#[derive(Drop, Serde)]
struct Table {
    namespace_selector: felt252,
    selector: felt252,
    layout: Layout,
}
