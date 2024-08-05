use starknet::SyscallResult;
use dojo::model::layout::compute_packed_size;
use dojo::model::Layout;
use dojo::model::introspect::{Ty, Introspect};
use dojo::world::IWorldDispatcher;

#[derive(Copy, Drop, Serde, Debug, PartialEq)]
pub enum ModelIndex {
    Keys: Span<felt252>,
    Id: felt252,
    // (entity_id, member_id)
    MemberId: (felt252, felt252)
}

/// Trait that is implemented at Cairo level for each struct that is a model.
pub trait ModelEntity<T> {
    fn id(self: @T) -> felt252;
    fn values(self: @T) -> Span<felt252>;
    fn from_values(entity_id: felt252, ref values: Span<felt252>) -> T;
    fn get_entity(world: IWorldDispatcher, entity_id: felt252) -> T;
    fn update_entity(self: @T, world: IWorldDispatcher);
    fn delete_entity(self: @T, world: IWorldDispatcher);
    fn get_member(
        world: IWorldDispatcher, entity_id: felt252, member_id: felt252,
    ) -> Span<felt252>;
    fn set_member(self: @T, world: IWorldDispatcher, member_id: felt252, values: Span<felt252>);
}

pub trait Model<T> {
    fn get_model(world: IWorldDispatcher, keys: Span<felt252>) -> T;
    // Note: `get` is implemented with a generated trait because it takes
    // the list of model keys as separated parameters.
    fn set_model(self: @T, world: IWorldDispatcher);
    fn delete_model(self: @T, world: IWorldDispatcher);
    fn from_values(ref keys: Span<felt252>, ref values: Span<felt252>) -> T;
    fn get_member(
        world: IWorldDispatcher, keys: Span<felt252>, member_id: felt252,
    ) -> Span<felt252>;

    fn set_member(self: @T, world: IWorldDispatcher, member_id: felt252, values: Span<felt252>,);

    /// Returns the name of the model as it was written in Cairo code.
    fn name() -> ByteArray;

    /// Returns the namespace of the model as it was written in the `dojo::model` attribute.
    fn namespace() -> ByteArray;

    // Returns the model tag which combines the namespace and the name.
    fn tag() -> ByteArray;

    fn version() -> u8;

    /// Returns the model selector built from its name and its namespace.
    /// model selector = hash(namespace_hash, model_hash)
    fn selector() -> felt252;
    fn instance_selector(self: @T) -> felt252;

    fn name_hash() -> felt252;
    fn namespace_hash() -> felt252;

    fn entity_id(self: @T) -> felt252;
    fn keys(self: @T) -> Span<felt252>;
    fn values(self: @T) -> Span<felt252>;
    fn layout() -> Layout;
    fn instance_layout(self: @T) -> Layout;
    fn packed_size() -> Option<usize>;
}

#[starknet::interface]
pub trait IModel<T> {
    fn name(self: @T) -> ByteArray;
    fn namespace(self: @T) -> ByteArray;
    fn tag(self: @T) -> ByteArray;
    fn version(self: @T) -> u8;

    fn selector(self: @T) -> felt252;
    fn name_hash(self: @T) -> felt252;
    fn namespace_hash(self: @T) -> felt252;
    fn unpacked_size(self: @T) -> Option<usize>;
    fn packed_size(self: @T) -> Option<usize>;
    fn layout(self: @T) -> Layout;
    fn schema(self: @T) -> Ty;
}

/// Deploys a model with the given [`ClassHash`] and retrieves it's name.
/// Currently, the model is expected to already be declared by `sozo`.
///
/// # Arguments
///
/// * `salt` - A salt used to uniquely deploy the model.
/// * `class_hash` - Class Hash of the model.
pub fn deploy_and_get_metadata(
    salt: felt252, class_hash: starknet::ClassHash
) -> SyscallResult<(starknet::ContractAddress, ByteArray, felt252, ByteArray, felt252)> {
    let (contract_address, _) = starknet::syscalls::deploy_syscall(
        class_hash, salt, array![].span(), false,
    )?;
    let model = IModelDispatcher { contract_address };
    let name = model.name();
    let selector = model.selector();
    let namespace = model.namespace();
    let namespace_hash = model.namespace_hash();
    Result::Ok((contract_address, name, selector, namespace, namespace_hash))
}

pub trait WorldStoreTrait<M, E, K> {
    fn serialize_key(key: K) -> Array<felt252>;
    fn key_to_id(key: K) -> felt252;
    fn get(self: @IWorldDispatcher, key: K) -> M;
    fn set(self: IWorldDispatcher, model: @M);
    fn delete(self: IWorldDispatcher, model: @M);
    fn update(self: IWorldDispatcher, entity: @E);
    fn get_entity(self: @IWorldDispatcher, key: K) -> E;
    fn get_entity_from_id(self: @IWorldDispatcher, id: felt252) -> E;
    fn delete_entity(self: IWorldDispatcher, entity: @E);
}

pub trait SerializeKeyTrait<T> {
    fn serialize_key(key: T) -> Array<felt252>;
}

pub impl ModelStoreImpl<
    M,
    E,
    K,
    impl ModelImpl: Model<M>,
    impl EntityImpl: ModelEntity<E>,
    impl SerializeKey: SerializeKeyTrait<K>,
    +Drop<M>,
    +Drop<E>,
> of WorldStoreTrait<M, E, K> {
    fn serialize_key(key: K) -> Array<felt252> {
        SerializeKey::serialize_key(key)
    }
    fn key_to_id(key: K) -> felt252 {
        core::poseidon::poseidon_hash_span(Self::serialize_key(key).span())
    }
    fn get(self: @IWorldDispatcher, key: K) -> M {
        ModelImpl::get_model(*self, Self::serialize_key(key).span())
    }
    fn set(self: IWorldDispatcher, model: @M) {
        ModelImpl::set_model(model, self);
    }
    fn delete(self: IWorldDispatcher, model: @M) {
        ModelImpl::delete_model(model, self);
    }
    fn get_entity(self: @IWorldDispatcher, key: K) -> E {
        EntityImpl::get_entity(*self, Self::key_to_id(key))
    }
    fn get_entity_from_id(self: @IWorldDispatcher, id: felt252) -> E {
        EntityImpl::get_entity(*self, id)
    }
    fn update(self: IWorldDispatcher, entity: @E) {
        EntityImpl::update_entity(entity, self);
    }
    fn delete_entity(self: IWorldDispatcher, entity: @E) {
        EntityImpl::delete_entity(entity, self);
    }
}

pub trait ModelPropsTrait<T> {
    /// Returns the name of the model as it was written in Cairo code.
    fn name() -> ByteArray;
    /// Returns the namespace of the model as it was written in the `dojo::model` attribute.
    fn namespace() -> ByteArray;

    // Returns the model tag which combines the namespace and the name.
    fn tag() -> ByteArray;

    fn version() -> u8;

    /// Returns the model selector built from its name and its namespace.
    /// model selector = hash(namespace_hash, model_hash)
    fn selector() -> felt252;

    fn name_hash() -> felt252;
    fn namespace_hash() -> felt252;

    fn keys(self: @T) -> Span<felt252>;
    fn values(self: @T) -> Span<felt252>;
}

pub trait EntityPropsTrait<T> {
    fn id(self: @T) -> felt252;
    fn values(self: @T) -> Span<felt252>;
    fn from_values(entity_id: felt252, ref values: Span<felt252>) -> T;
    fn selector() -> felt252;
    fn layout() -> Layout;
}

pub impl TModelImpl<T, +ModelPropsTrait<T>, +Introspect<T>, +Serde<T>, +Drop<T>> of Model<T> {
    fn get_model(world: dojo::world::IWorldDispatcher, keys: Span<felt252>) -> T {
        let mut values = dojo::world::IWorldDispatcherTrait::entity(
            world, Self::selector(), ModelIndex::Keys(keys), Self::layout()
        );
        let mut _keys = keys;

        Self::from_values(ref _keys, ref values)
    }

    fn set_model(self: @T, world: dojo::world::IWorldDispatcher) {
        dojo::world::IWorldDispatcherTrait::set_entity(
            world,
            Self::selector(),
            ModelIndex::Keys(Self::keys(self)),
            Self::values(self),
            Self::layout()
        );
    }

    fn delete_model(self: @T, world: dojo::world::IWorldDispatcher) {
        dojo::world::IWorldDispatcherTrait::delete_entity(
            world, Self::selector(), ModelIndex::Keys(Self::keys(self)), Self::layout()
        );
    }
    fn from_values(ref keys: Span<felt252>, ref values: Span<felt252>) -> T {
        let mut serialized = core::array::ArrayTrait::new();
        serialized.append_span(keys);
        serialized.append_span(values);
        let mut serialized = core::array::ArrayTrait::span(@serialized);

        let entity = core::serde::Serde::<T>::deserialize(ref serialized);
        if core::option::OptionTrait::<T>::is_none(@entity) {
            panic!(
                "Model: deserialization failed. Ensure the length of the keys tuple is matching the number of #[key] fields in the model struct."
            );
        }
        core::option::OptionTrait::<T>::unwrap(entity)
    }
    fn get_member(
        world: dojo::world::IWorldDispatcher, keys: Span<felt252>, member_id: felt252
    ) -> Span<felt252> {
        match dojo::utils::find_model_field_layout(Self::layout(), member_id) {
            Option::Some(field_layout) => {
                let entity_id = dojo::utils::entity_id_from_keys(keys);
                dojo::world::IWorldDispatcherTrait::entity(
                    world,
                    Self::selector(),
                    ModelIndex::MemberId((entity_id, member_id)),
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }

    fn set_member(
        self: @T, world: dojo::world::IWorldDispatcher, member_id: felt252, values: Span<felt252>
    ) {
        match dojo::utils::find_model_field_layout(Self::layout(), member_id) {
            Option::Some(field_layout) => {
                dojo::world::IWorldDispatcherTrait::set_entity(
                    world,
                    Self::selector(),
                    ModelIndex::MemberId((self.entity_id(), member_id)),
                    values,
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }

    #[inline(always)]
    fn name() -> ByteArray {
        ModelPropsTrait::<T>::name()
    }

    #[inline(always)]
    fn namespace() -> ByteArray {
        ModelPropsTrait::<T>::namespace()
    }

    #[inline(always)]
    fn tag() -> ByteArray {
        ModelPropsTrait::<T>::tag()
    }

    #[inline(always)]
    fn version() -> u8 {
        ModelPropsTrait::<T>::version()
    }

    #[inline(always)]
    fn selector() -> felt252 {
        ModelPropsTrait::<T>::selector()
    }

    #[inline(always)]
    fn instance_selector(self: @T) -> felt252 {
        Self::selector()
    }

    #[inline(always)]
    fn name_hash() -> felt252 {
        ModelPropsTrait::<T>::name_hash()
    }

    #[inline(always)]
    fn namespace_hash() -> felt252 {
        ModelPropsTrait::<T>::namespace_hash()
    }

    #[inline(always)]
    fn entity_id(self: @T) -> felt252 {
        core::poseidon::poseidon_hash_span(ModelPropsTrait::<T>::keys(self))
    }

    #[inline(always)]
    fn keys(self: @T) -> Span<felt252> {
        ModelPropsTrait::<T>::keys(self)
    }

    #[inline(always)]
    fn values(self: @T) -> Span<felt252> {
        ModelPropsTrait::<T>::values(self)
    }

    #[inline(always)]
    fn layout() -> Layout {
        Introspect::<T>::layout()
    }

    #[inline(always)]
    fn instance_layout(self: @T) -> Layout {
        Self::layout()
    }

    #[inline(always)]
    fn packed_size() -> Option<usize> {
        compute_packed_size(Self::layout())
    }
}


pub impl TEntityImpl<T, +Serde<T>, +EntityPropsTrait<T>, +Drop<T>> of ModelEntity<T> {
    fn id(self: @T) -> felt252 {
        EntityPropsTrait::<T>::id(self)
    }

    fn values(self: @T) -> Span<felt252> {
        EntityPropsTrait::<T>::values(self)
    }

    fn from_values(entity_id: felt252, ref values: Span<felt252>) -> T {
        let mut serialized = array![entity_id];
        serialized.append_span(values);
        let mut serialized = core::array::ArrayTrait::span(@serialized);

        let entity_values = core::serde::Serde::<T>::deserialize(ref serialized);
        if core::option::OptionTrait::<T>::is_none(@entity_values) {
            panic!("ModelEntity `T`: deserialization failed.");
        }
        core::option::OptionTrait::<T>::unwrap(entity_values)
    }

    fn get_entity(world: dojo::world::IWorldDispatcher, entity_id: felt252) -> T {
        let mut values = dojo::world::IWorldDispatcherTrait::entity(
            world,
            EntityPropsTrait::<T>::selector(),
            ModelIndex::Id(entity_id),
            EntityPropsTrait::<T>::layout()
        );
        Self::from_values(entity_id, ref values)
    }

    fn update_entity(self: @T, world: dojo::world::IWorldDispatcher) {
        dojo::world::IWorldDispatcherTrait::set_entity(
            world,
            EntityPropsTrait::<T>::selector(),
            ModelIndex::Id(EntityPropsTrait::<T>::id(self)),
            EntityPropsTrait::<T>::values(self),
            EntityPropsTrait::<T>::layout()
        );
    }

    fn delete_entity(self: @T, world: dojo::world::IWorldDispatcher) {
        dojo::world::IWorldDispatcherTrait::delete_entity(
            world,
            EntityPropsTrait::<T>::selector(),
            ModelIndex::Id(EntityPropsTrait::<T>::id(self)),
            EntityPropsTrait::<T>::layout()
        );
    }

    fn get_member(
        world: dojo::world::IWorldDispatcher, entity_id: felt252, member_id: felt252,
    ) -> Span<felt252> {
        match dojo::utils::find_model_field_layout(EntityPropsTrait::<T>::layout(), member_id) {
            Option::Some(field_layout) => {
                dojo::world::IWorldDispatcherTrait::entity(
                    world,
                    EntityPropsTrait::<T>::selector(),
                    ModelIndex::MemberId((entity_id, member_id)),
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }

    fn set_member(
        self: @T, world: dojo::world::IWorldDispatcher, member_id: felt252, values: Span<felt252>,
    ) {
        match dojo::utils::find_model_field_layout(EntityPropsTrait::<T>::layout(), member_id) {
            Option::Some(field_layout) => {
                dojo::world::IWorldDispatcherTrait::set_entity(
                    world,
                    EntityPropsTrait::<T>::selector(),
                    ModelIndex::MemberId((EntityPropsTrait::<T>::id(self), member_id)),
                    values,
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }
}
