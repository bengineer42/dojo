const $MODEL_NAME_SNAKE$_SELECTOR: felt252 = $model_selector$;

#[derive(Drop, Serde)]
pub struct $model_name$Entity {
    __id: felt252, // private field
    $members_values$
}

impl $model_name$SerializeKeyImpl of dojo::model::model::SerializeKeyTrait<$key_type$>{
    fn serialize_key(key: $key_type$) -> Array<felt252> {
        $expand_keys$
        let mut serialized = core::array::ArrayTrait::new();
        $serialized_param_keys$
        serialized
    }
}

#[generate_trait]
pub impl $model_name$FieldStoreImpl of $model_name$FieldStore{
    $field_accessors$
}



impl $model_name$ModelPropsImpl of dojo::model::model::ModelPropsTrait<$model_name$> {
    
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
    fn name_hash() -> felt252 {
        $model_name_hash$
    }

    #[inline(always)]
    fn namespace_hash() -> felt252 {
        $model_namespace_hash$
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
}

impl $model_name$EntityPropsImpl of dojo::model::model::EntityPropsTrait<$model_name$Entity> {
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

    #[inline(always)]
    fn selector() -> felt252 {
        $model_selector$
    }

    #[inline(always)]
    fn layout() -> dojo::model::Layout {
        dojo::model::introspect::Introspect::<$model_name$>::layout()
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


pub impl $model_name$ModelImpl = dojo::model::model::TModelImpl<$model_name$>;
pub impl $model_name$EntityImpl = dojo::model::model::TEntityImpl<$model_name$Entity>;
pub impl $model_name$Store = dojo::model::model::ModelStoreImpl<$model_name$, $model_name$Entity, $key_type$, $model_name$ModelImpl, $model_name$EntityImpl, $model_name$SerializeKeyImpl>;
