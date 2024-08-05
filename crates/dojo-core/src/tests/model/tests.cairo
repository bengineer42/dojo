use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::model::{Model, ModelEntity};
use dojo::utils::test::{spawn_test_world};

use dojo::tests::model::model::{
    Foo, FooStore, FooEntity, foo::TEST_CLASS_HASH as FOO_TEST_CLASS_HASH, FooFieldStore, Foo2,
    Foo2Store, Foo2Entity, foo_2::TEST_CLASS_HASH as FOO2_TEST_CLASS_HASH, Foo2FieldStore
};

// Utils
fn deploy_world() -> IWorldDispatcher {
    spawn_test_world("dojo", array![])
}

#[test]
fn test_id() {
    let mvalues = FooEntity { __id: 1, v1: 3, v2: 4 };
    assert!(mvalues.id() == 1);
}

#[test]
fn test_values() {
    let mvalues = FooEntity { __id: 1, v1: 3, v2: 4 };
    let expected_values = array![3, 4].span();

    let values = ModelEntity::<FooEntity>::values(@mvalues);
    assert!(expected_values == values);
}

#[test]
fn test_from_values() {
    let mut values = array![3, 4].span();

    let model_entity = ModelEntity::<FooEntity>::from_values(1, ref values);
    assert!(model_entity.__id == 1 && model_entity.v1 == 3 && model_entity.v2 == 4);
}

#[test]
#[should_panic(expected: "ModelEntity `FooEntity`: deserialization failed.")]
fn test_from_values_bad_data() {
    let mut values = array![3].span();
    let _ = ModelEntity::<FooEntity>::from_values(1, ref values);
}

#[test]
fn test_get_and_update_entity() {
    let world = deploy_world();
    world.register_model(FOO_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(foo);

    let entity_id = foo.entity_id();
    let mut entity: FooEntity = FooStore::get_entity(@world, foo.k);
    assert!(entity.__id == entity_id && entity.v1 == entity.v1 && entity.v2 == entity.v2);

    entity.v1 = 12;
    entity.v2 = 18;
    FooStore::update(world, entity);

    let read_values: FooEntity = FooStore::get_entity(@world, foo.k);
    assert!(read_values.v1 == entity.v1 && read_values.v2 == entity.v2);
}


#[test]
fn test_get_and_update_entity_from_id() {
    let world = deploy_world();
    world.register_model(FOO_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(foo);

    let entity_id = foo.entity_id();
    let mut entity: FooEntity = FooStore::get_entity_from_id(@world, entity_id);
    assert!(entity.__id == entity_id && entity.v1 == entity.v1 && entity.v2 == entity.v2);
    entity.v1 = 12;
    entity.v2 = 18;
    FooStore::update(world, entity);

    let read_values: FooEntity = FooStore::get_entity_from_id(@world, entity_id);
    assert!(read_values.v1 == entity.v1 && read_values.v2 == entity.v2);
}

#[test]
fn test_delete_entity() {
    let world = deploy_world();
    world.register_model(FOO_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(foo);

    let mut entity: FooEntity = FooStore::get_entity(@world, foo.k);

    FooStore::delete_entity(world, entity);

    let read_values: FooEntity = FooStore::get_entity(@world, foo.k);
    assert!(read_values.v1 == 0 && read_values.v2 == 0);
}

#[test]
fn test_get_and_set_field_name_from_id() {
    let world = deploy_world();
    world.register_model(FOO_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(foo);

    let v1 = world.get_foo_v1_from_id(foo.entity_id());
    assert!(foo.v1 == v1);

    world.update_foo_v1_from_id(foo.entity_id(), 42);

    let v1 = world.get_foo_v1_from_id(foo.entity_id());
    assert!(v1 == 42);
}

#[test]
fn test_get_and_set_from_model() {
    let world = deploy_world();
    world.register_model(FOO_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(foo);

    let read_entity: Foo = world.get(foo.k);

    assert!(foo.k == read_entity.k && foo.v1 == read_entity.v1 && foo.v2 == read_entity.v2);
}

#[test]
fn test_delete_from_model() {
    let world = deploy_world();
    world.register_model(FOO_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    world.set(foo);
    world.delete(foo);

    let read_entity: Foo = world.get(foo.k);
    assert!(read_entity.k == foo.k && read_entity.v1 == 0 && read_entity.v2 == 0);
}

#[test]
fn test_get_and_set_member_from_model() {
    let world = deploy_world();
    world.register_model(FOO_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo { k: 1, v1: 3, v2: 4 };
    let keys = array![foo.k.into()].span();
    world.set(foo);

    let v1_raw_value = Model::<Foo>::get_member(world, keys, selector!("v1"));

    assert!(v1_raw_value.len() == 1);
    assert!(*v1_raw_value.at(0) == 3);

    foo.set_member(world, selector!("v1"), array![42].span());
    let foo: Foo = world.get(foo.k);
    assert!(foo.v1 == 42);
}

#[test]
fn test_get_and_update_entity_tuple() {
    let world = deploy_world();
    world.register_model(FOO2_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    world.set(foo);

    let entity_id = foo.entity_id();
    let mut entity: Foo2Entity = Foo2Store::get_entity(@world, (foo.k1, foo.k2));
    assert!(entity.__id == entity_id && entity.v1 == entity.v1 && entity.v2 == entity.v2);

    entity.v1 = 12;
    entity.v2 = 18;
    Foo2Store::update(world, entity);

    let read_values: Foo2Entity = Foo2Store::get_entity(@world, (foo.k1, foo.k2));
    assert!(read_values.v1 == entity.v1 && read_values.v2 == entity.v2);
}


#[test]
fn test_delete_entity_tuple() {
    let world = deploy_world();
    world.register_model(FOO2_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    world.set(foo);

    let mut entity: Foo2Entity = Foo2Store::get_entity(@world, (foo.k1, foo.k2));

    Foo2Store::delete_entity(world, entity);

    let read_values: Foo2Entity = Foo2Store::get_entity(@world, (foo.k1, foo.k2));
    assert!(read_values.v1 == 0 && read_values.v2 == 0);
}

#[test]
fn test_get_and_set_from_model_tuple() {
    let world = deploy_world();
    world.register_model(FOO2_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    world.set(foo);

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
    world.register_model(FOO2_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    world.set(foo);
    world.delete(foo);

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
    world.register_model(FOO2_TEST_CLASS_HASH.try_into().unwrap());

    let foo = Foo2 { k1: 1, k2: 2, v1: 3, v2: 4 };
    let keys = array![foo.k1.into(), foo.k2.into()].span();
    world.set(foo);

    let v1_raw_value = Model::<Foo2>::get_member(world, keys, selector!("v1"));

    assert!(v1_raw_value.len() == 1);
    assert!(*v1_raw_value.at(0) == 3);

    foo.set_member(world, selector!("v1"), array![42].span());
    let foo: Foo2 = world.get((foo.k1, foo.k2));
    assert!(foo.v1 == 42);
}
