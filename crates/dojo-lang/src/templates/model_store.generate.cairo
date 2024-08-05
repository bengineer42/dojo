const $MODEL_NAME_SNAKE$_SELECTOR: felt252 = $model_selector$;

#[derive(Drop, Serde)]
pub struct $model_name$Entity {
    __id: felt252, // private field
    $members_values$
}

pub impl $model_name$Store of dojo::model::WorldStore<$model_name$, $model_name$Entity, $key_type$>{
    fn serialize_key(key: $key_type$) -> Array<felt252> {
        $expand_keys$
        let mut serialized = core::array::ArrayTrait::new();
        $serialized_param_keys$
        serialized
    }
    fn key_to_id(key: $key_type$) -> felt252 {
        core::poseidon::poseidon_hash_span(Self::serialize_key(key).span())
    }
    fn from_values(ref keys: Span<felt252>, ref values: Span<felt252>) -> $model_name${
        let mut serialized = core::array::ArrayTrait::new();
        serialized.append_span(keys);
        serialized.append_span(values);
        let mut serialized = core::array::ArrayTrait::span(@serialized);

        let entity = core::serde::Serde::<$model_name$>::deserialize(ref serialized);
        if core::option::OptionTrait::<$model_name$>::is_none(@entity) {
            panic!(
                "Model `$model_name$`: deserialization failed. Ensure the length of the keys tuple is matching the number of #[key] fields in the model struct."
            );
        }
        core::option::OptionTrait::<$model_name$>::unwrap(entity)
    }
    fn get(self: @dojo::world::IWorldDispatcher, key: $key_type$) -> $model_name$ {
        dojo::model::Model::<$model_name$>::get(*self, Self::serialize_key(key).span())
    }
    fn get_entity(self: @dojo::world::IWorldDispatcher, key: $key_type$) -> $model_name$Entity{
        $model_name$ModelEntityImpl::get(*self, Self::key_to_id(key))
    }
    fn get_entity_from_id(self: @dojo::world::IWorldDispatcher, id: felt252) -> $model_name$Entity{
        $model_name$ModelEntityImpl::get(*self, id)
    }
    fn set(self: dojo::world::IWorldDispatcher, model: $model_name$){
        $model_name$ModelImpl::set(@model, self);
    }
    fn update(self: dojo::world::IWorldDispatcher, entity: $model_name$Entity){
        $model_name$ModelEntityImpl::update(@entity, self);
    }
    fn delete(self: dojo::world::IWorldDispatcher, model: $model_name$){
        $model_name$ModelImpl::delete(@model, self);
    }
    fn delete_entity(self: dojo::world::IWorldDispatcher, entity: $model_name$Entity){
        $model_name$ModelEntityImpl::delete(@entity, self);
    }
}

#[generate_trait]
pub impl $model_name$FieldStoreImpl of $model_name$FieldStore{
    $field_accessors$
}

pub impl $model_name$ModelImpl of dojo::model::Model<$model_name$> {
    fn get(world: dojo::world::IWorldDispatcher, keys: Span<felt252>) -> $model_name$ {
        let mut values = dojo::world::IWorldDispatcherTrait::entity(
            world,
            Self::selector(),
            dojo::model::ModelIndex::Keys(keys),
            Self::layout()
        );
        let mut _keys = keys;

        $model_name$Store::from_values(ref _keys, ref values)
    }

   fn set(
        self: @$model_name$,
        world: dojo::world::IWorldDispatcher
    ) {
        dojo::world::IWorldDispatcherTrait::set_entity(
            world,
            Self::selector(),
            dojo::model::ModelIndex::Keys(Self::keys(self)),
            Self::values(self),
            Self::layout()
        );
    }

    fn delete(
        self: @$model_name$,
        world: dojo::world::IWorldDispatcher
    ) {
        dojo::world::IWorldDispatcherTrait::delete_entity(
            world,
            Self::selector(),
            dojo::model::ModelIndex::Keys(Self::keys(self)),
            Self::layout()
        );
    }

    fn get_member(
        world: dojo::world::IWorldDispatcher,
        keys: Span<felt252>,
        member_id: felt252
    ) -> Span<felt252> {
        match dojo::utils::find_model_field_layout(Self::layout(), member_id) {
            Option::Some(field_layout) => {
                let entity_id = dojo::utils::entity_id_from_keys(keys);
                dojo::world::IWorldDispatcherTrait::entity(
                    world,
                    Self::selector(),
                    dojo::model::ModelIndex::MemberId((entity_id, member_id)),
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }

    fn set_member(
        self: @$model_name$,
        world: dojo::world::IWorldDispatcher,
        member_id: felt252,
        values: Span<felt252>
    ) {
        match dojo::utils::find_model_field_layout(Self::layout(), member_id) {
            Option::Some(field_layout) => {
                dojo::world::IWorldDispatcherTrait::set_entity(
                    world,
                    Self::selector(),
                    dojo::model::ModelIndex::MemberId((self.entity_id(), member_id)),
                    values,
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }

    #[inline(always)]
    fn name() -> ByteArray {
        "$model_name$"
    }

    #[inline(always)]
    fn namespace() -> ByteArray {
        "$model_namespace$"
    }

    #[inline(always)]
    fn tag() -> ByteArray {
        "$model_tag$"
    }

    #[inline(always)]
    fn version() -> u8 {
        $model_version$
    }

    #[inline(always)]
    fn selector() -> felt252 {
        $model_selector$
    }

    #[inline(always)]
    fn instance_selector(self: @$model_name$) -> felt252 {
        Self::selector()
    }

    #[inline(always)]
    fn name_hash() -> felt252 {
        $model_name_hash$
    }

    #[inline(always)]
    fn namespace_hash() -> felt252 {
        $model_namespace_hash$
    }

    #[inline(always)]
    fn entity_id(self: @$model_name$) -> felt252 {
        core::poseidon::poseidon_hash_span(self.keys())
    }

    #[inline(always)]
    fn keys(self: @$model_name$) -> Span<felt252> {
        let mut serialized = core::array::ArrayTrait::new();
        $serialized_keys$
        core::array::ArrayTrait::span(@serialized)
    }

    #[inline(always)]
    fn values(self: @$model_name$) -> Span<felt252> {
        let mut serialized = core::array::ArrayTrait::new();
        $serialized_values$
        core::array::ArrayTrait::span(@serialized)
    }

    #[inline(always)]
    fn layout() -> dojo::model::Layout {
        dojo::model::introspect::Introspect::<$model_name$>::layout()
    }

    #[inline(always)]
    fn instance_layout(self: @$model_name$) -> dojo::model::Layout {
        Self::layout()
    }

    #[inline(always)]
    fn packed_size() -> Option<usize> {
        dojo::model::layout::compute_packed_size(Self::layout())
    }
}

pub impl $model_name$ModelEntityImpl of dojo::model::ModelEntity<$model_name$Entity> {
    fn id(self: @$model_name$Entity) -> felt252 {
        *self.__id
    }

    fn values(self: @$model_name$Entity) -> Span<felt252> {
        let mut serialized = core::array::ArrayTrait::new();
        $serialized_values$
        core::array::ArrayTrait::span(@serialized)
    }

    fn from_values(entity_id: felt252, ref values: Span<felt252>) -> $model_name$Entity {
        let mut serialized = array![entity_id];
        serialized.append_span(values);
        let mut serialized = core::array::ArrayTrait::span(@serialized);

        let entity_values = core::serde::Serde::<$model_name$Entity>::deserialize(ref serialized);
        if core::option::OptionTrait::<$model_name$Entity>::is_none(@entity_values) {
            panic!(
                "ModelEntity `$model_name$Entity`: deserialization failed."
            );
        }
        core::option::OptionTrait::<$model_name$Entity>::unwrap(entity_values)
    }

    fn get(world: dojo::world::IWorldDispatcher, entity_id: felt252) -> $model_name$Entity {
        let mut values = dojo::world::IWorldDispatcherTrait::entity(
            world,
            dojo::model::Model::<$model_name$>::selector(),
            dojo::model::ModelIndex::Id(entity_id),
            dojo::model::Model::<$model_name$>::layout()
        );
        Self::from_values(entity_id, ref values)
    }

    fn update(self: @$model_name$Entity, world: dojo::world::IWorldDispatcher) {
        dojo::world::IWorldDispatcherTrait::set_entity(
            world,
            dojo::model::Model::<$model_name$>::selector(),
            dojo::model::ModelIndex::Id(self.id()),
            self.values(),
            dojo::model::Model::<$model_name$>::layout()
        );
    }

    fn delete(self: @$model_name$Entity, world: dojo::world::IWorldDispatcher) {
        dojo::world::IWorldDispatcherTrait::delete_entity(
            world,
            dojo::model::Model::<$model_name$>::selector(),
            dojo::model::ModelIndex::Id(self.id()),
            dojo::model::Model::<$model_name$>::layout()
        );
    }

    fn get_member(
        world: dojo::world::IWorldDispatcher,
        entity_id: felt252,
        member_id: felt252,
    ) -> Span<felt252> {
        match dojo::utils::find_model_field_layout(dojo::model::Model::<$model_name$>::layout(), 
             member_id) {
            Option::Some(field_layout) => {
                dojo::world::IWorldDispatcherTrait::entity(
                    world,
                    dojo::model::Model::<$model_name$>::selector(),
                    dojo::model::ModelIndex::MemberId((entity_id, member_id)),
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }

    fn set_member(
        self: @$model_name$Entity,
        world: dojo::world::IWorldDispatcher,
        member_id: felt252,
        values: Span<felt252>,
    ) {
        match dojo::utils::find_model_field_layout(dojo::model::Model::<$model_name$>::layout(), 
             member_id) {
            Option::Some(field_layout) => {
                dojo::world::IWorldDispatcherTrait::set_entity(
                    world,
                    dojo::model::Model::<$model_name$>::selector(),
                    dojo::model::ModelIndex::MemberId((self.id(), member_id)),
                    values,
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }
}

#[starknet::interface]
pub trait I$model_name$<T> {
    fn ensure_abi(self: @T, model: $model_name$);
}

#[starknet::contract]
pub mod $model_name_snake$ {
    use super::{I$model_name$, $model_name$, $MODEL_NAME_SNAKE$_SELECTOR};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl DojoModelImpl of dojo::model::IModel<ContractState>{
        fn name(self: @ContractState) -> ByteArray {
           dojo::model::Model::<$model_name$>::name()
        }

        fn namespace(self: @ContractState) -> ByteArray {
           dojo::model::Model::<$model_name$>::namespace()
        }

        fn tag(self: @ContractState) -> ByteArray {
            dojo::model::Model::<$model_name$>::tag()
        }

        fn version(self: @ContractState) -> u8 {
           dojo::model::Model::<$model_name$>::version()
        }

        fn selector(self: @ContractState) -> felt252 {
           dojo::model::Model::<$model_name$>::selector()
        }

        fn name_hash(self: @ContractState) -> felt252 {
            dojo::model::Model::<$model_name$>::name_hash()
        }

        fn namespace_hash(self: @ContractState) -> felt252 {
            dojo::model::Model::<$model_name$>::namespace_hash()
        }

        fn unpacked_size(self: @ContractState) -> Option<usize> {
            dojo::model::introspect::Introspect::<$model_name$>::size()
        }

        fn packed_size(self: @ContractState) -> Option<usize> {
            dojo::model::Model::<$model_name$>::packed_size()
        }

        fn layout(self: @ContractState) -> dojo::model::Layout {
            dojo::model::Model::<$model_name$>::layout()
        }

        fn schema(self: @ContractState) -> dojo::model::introspect::Ty {
            dojo::model::introspect::Introspect::<$model_name$>::ty()
        }
    }

    #[abi(embed_v0)]
    impl I$model_name$Impl of I$model_name$<ContractState>{
        fn ensure_abi(self: @ContractState, model: $model_name$) {
        }
    }
}