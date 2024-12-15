use dojo::{meta::{Layout, Introspect},};

#[derive(Drop, Copy)]
pub struct DatabaseTable<D> {
    pub database: D,
    pub selector: felt252,
}

pub trait Table<T> {
    const SELECTOR: felt252;
    fn selector(self: @T) -> felt252;
    fn schema(self: @T) -> Layout;
    fn database<D>(self: @T, database: D) -> DatabaseTable<D>;
}

pub impl TableImpl<T, const selector: felt252, +Introspect<T>> of Table<T> {
    const SELECTOR: felt252 = selector;
    fn selector(self: @T) -> felt252 {
        Self::SELECTOR
    }
    fn schema(self: @T) -> Layout {
        Introspect::<T>::layout()
    }
    fn database<D>(self: @T, database: D) -> DatabaseTable<D> {
        DatabaseTable { database, selector: Self::SELECTOR, }
    }
}
// #[derive(Drop, Serde, Introspect)]
// struct Foo {
//     a: Array<felt252>,
//     b: felt252,
// }

// #[derive(Drop, Serde, IntrospectPacked)]
// struct Bar {
//     some: u8,
//     thing: u16,
// }

// /// Example of a table implementation
// #[dojo::table(selector)] // Can either be inline or derive (default selector only)
// #[derive(Drop, Serde, Table)] // Table will implement this and Introspect
// struct Example {
//     value: felt252,
//     value_2: Foo,
//     value_3: Bar,
// }

// // /// Generated code would look like this but the Impl could be overwritten
// // /// if a another selector is needed.
// const SELECTOR: felt252 = selector!("Example");
// impl ExampleTable = TableImpl<Example, SELECTOR>;


