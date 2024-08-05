use dojo::world::{IWorldDispatcher};
use dojo::model::model::{WorldStoreTrait, Model, ModelEntity};
use dojo::utils::test::{spawn_test_world};

use dojo::tests::model::model::{
    Foo, FooEntity, FooStore, foo::TEST_CLASS_HASH as FOO_TEST_CLASS_HASH, FooFieldStore, Foo2,
    Foo2Entity, foo_2::TEST_CLASS_HASH as FOO_2_TEST_CLASS_HASH, Foo2FieldStore
};

// Utils
fn deploy_world() -> IWorldDispatcher {
    spawn_test_world("dojo", array![])
}

#[test]
fn test_from_values() {
    let mut values = array![3, 4].span();
    let expected_values = array![12, 42].span();

    let mut model_entity = dojo::model::ModelEntity::<FooEntity>::from_values(1, ref values);
    assert!(model_entity.id() == 1 && model_entity.v1 == 3 && model_entity.v2 == 4);
    model_entity.v1 = 12;
    model_entity.v2 = 42;
    let values = dojo::model::ModelEntity::<FooEntity>::values(@model_entity);
    assert!(expected_values == values);
}

#[test]
#[should_panic(expected: "ModelEntity `FooEntity`: deserialization failed.")]
fn test_from_values_bad_data() {
    let mut values = array![3].span();
    let _ = dojo::model::ModelEntity::<FooEntity>::from_values(1, ref values);
}

#[test]
fn test_get_and_update_entity() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(@foo);

    let entity_id = dojo::model::Model::<Foo>::entity_id(@foo);
    let mut entity: FooEntity = world.get_entity(foo.k);
    assert!(entity.id() == entity_id && entity.v1 == entity.v1 && entity.v2 == entity.v2);

    let (v1, v2) = (12, 18);
    entity.v1 = v1;
    entity.v2 = v2;
    world.update(@entity);

    let read_values: FooEntity = world.get_entity(foo.k);
    assert!(read_values.v1 == v1 && read_values.v2 == v2);
}


#[test]
fn test_get_and_update_entity_from_id() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(@foo);

    let entity_id = dojo::model::Model::<Foo>::entity_id(@foo);
    let mut entity: FooEntity = world.get_entity_from_id(entity_id);
    assert!(entity.id() == entity_id && entity.v1 == entity.v1 && entity.v2 == entity.v2);

    let (v1, v2) = (12, 18);
    entity.v1 = v1;
    entity.v2 = v2;
    world.update(@entity);

    let read_values: FooEntity = world.get_entity_from_id(entity_id);
    assert!(read_values.v1 == v1 && read_values.v2 == v2);
}

#[test]
fn test_delete_entity() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(@foo);

    let mut entity: FooEntity = world.get_entity(foo.k);

    world.delete_entity(@entity);

    let read_values: FooEntity = world.get_entity(foo.k);
    assert!(read_values.v1 == 0 && read_values.v2 == 0);
}

#[test]
fn test_get_and_set_field_name_from_id() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(@foo);

    let v1 = world.get_foo_v1_from_id(foo.entity_id());
    assert!(foo.v1 == v1);

    world.update_foo_v1_from_id(foo.entity_id(), 42);

    let v1 = world.get_foo_v1_from_id(foo.entity_id());
    assert!(v1 == 42);
}

#[test]
fn test_get_and_set_from_model() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(@foo);

    let read_entity: Foo = world.get(foo.k);

    assert!(foo.k == read_entity.k && foo.v1 == read_entity.v1 && foo.v2 == read_entity.v2);
}

#[test]
fn test_delete_from_model() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(@foo);
    world.delete(@foo);

    let read_entity: Foo = world.get(foo.k);
    assert!(read_entity.k == foo.k && read_entity.v1 == 0 && read_entity.v2 == 0);
}

#[test]
fn test_get_and_set_member_from_model() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    let keys = array![foo.k.into()].span();
    world.set(@foo);

    let v1_raw_value = dojo::model::Model::<Foo>::get_member(world, keys, selector!("v1"));

    assert!(v1_raw_value.len() == 1);
    assert!(*v1_raw_value.at(0) == 3);

    foo.set_member(world, selector!("v1"), array![42].span());
    let foo: Foo = world.get(foo.k);
    assert!(foo.v1 == 42);
}

#[test]
fn test_get_and_update_entity_tuple() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_2_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    world.set(@foo);

    let entity_id = foo.entity_id();
    let mut entity: Foo2Entity = world.get_entity((foo.k1, foo.k2));
    assert!(entity.id() == entity_id && entity.v1 == entity.v1 && entity.v2 == entity.v2);

    let (v1, v2) = (12, 18);
    entity.v1 = v1;
    entity.v2 = v2;
    world.update(@entity);

    let read_values: Foo2Entity = world.get_entity((foo.k1, foo.k2));
    assert!(read_values.v1 == v1 && read_values.v2 == v2);
}


#[test]
fn test_delete_entity_tuple() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_2_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    world.set(@foo);

    let mut entity: Foo2Entity = world.get_entity((foo.k1, foo.k2));

    world.delete_entity(@entity);

    let read_values: Foo2Entity = world.get_entity((foo.k1, foo.k2));
    assert!(read_values.v1 == 0 && read_values.v2 == 0);
}

#[test]
fn test_get_and_set_from_model_tuple() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_2_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    world.set(@foo);

    let read_entity: Foo2 = world.get((foo.k1, foo.k2));

    assert!(
        foo.k1 == read_entity.k1
            && foo.k2 == read_entity.k2
            && foo.v1 == read_entity.v1
            && foo.v2 == read_entity.v2
    );
}

#[test]
fn test_delete_from_model_tuple() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_2_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    world.set(@foo);
    world.delete(@foo);

    let read_entity: Foo2 = world.get((foo.k1, foo.k2));
    assert!(
        read_entity.k1 == foo.k1
            && read_entity.k2 == foo.k2
            && read_entity.v1 == 0
            && read_entity.v2 == 0
    );
}

#[test]
fn test_get_and_set_member_from_model_tuple() {
    let world = deploy_world();
    dojo::world::IWorldDispatcherTrait::register_model(
        world, FOO_2_TEST_CLASS_HASH.try_into().unwrap()
    );

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    let keys = array![foo.k1.into(), foo.k2.into()].span();
    world.set(@foo);

    let v1_raw_value = Model::<Foo2>::get_member(world, keys, selector!("v1"));

    assert!(v1_raw_value.len() == 1);
    assert!(*v1_raw_value.at(0) == 3);

    foo.set_member(world, selector!("v1"), array![42].span());
    let foo: Foo2 = world.get((foo.k1, foo.k2));
    assert!(foo.v1 == 42);
}
