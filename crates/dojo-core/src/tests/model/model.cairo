#[dojo::model]
#[derive(Copy, Drop, Serde, Debug)]
pub struct Foo {
    #[key]
    pub k: u8,
    pub v1: u128,
    pub v2: u32
}

// #[dojo::model]
#[derive(Copy, Drop, Serde, Debug)]
pub struct Foo2 {
    #[key]
    pub k1: u8,
    #[key]
    pub k2: felt252,
    pub v1: u128,
    pub v2: u32
}

#[dojo::model]
#[derive(Drop, Serde, Debug)]
pub struct Foo3 {
    #[key]
    pub k1: u8,
    #[key]
    pub k2: felt252,
    pub v1: ByteArray,
    pub v2: Array<felt252>,
}

impl Foo2Introspect<> of dojo::model::introspect::Introspect<Foo2<>> {
    #[inline(always)]
    fn size() -> Option<usize> {
        Option::Some(2)
    }

    fn layout() -> dojo::model::Layout {
        dojo::model::Layout::Struct(
            array![
                dojo::model::FieldLayout {
                    selector: 687013198911006804117413256380548377255056948723479227932116677690621743639,
                    layout: dojo::model::introspect::Introspect::<u128>::layout()
                },
                dojo::model::FieldLayout {
                    selector: 573200779692275582020388969134054872186051594998702457223229675092771367647,
                    layout: dojo::model::introspect::Introspect::<u32>::layout()
                }
            ]
                .span()
        )
    }

    #[inline(always)]
    fn ty() -> dojo::model::introspect::Ty {
        dojo::model::introspect::Ty::Struct(
            dojo::model::introspect::Struct {
                name: 'Foo2',
                attrs: array![].span(),
                children: array![
                    dojo::model::introspect::Member {
                        name: 'k1',
                        attrs: array!['key'].span(),
                        ty: dojo::model::introspect::Introspect::<u8>::ty()
                    },
                    dojo::model::introspect::Member {
                        name: 'k2',
                        attrs: array!['key'].span(),
                        ty: dojo::model::introspect::Introspect::<felt252>::ty()
                    },
                    dojo::model::introspect::Member {
                        name: 'v1',
                        attrs: array![].span(),
                        ty: dojo::model::introspect::Introspect::<u128>::ty()
                    },
                    dojo::model::introspect::Member {
                        name: 'v2',
                        attrs: array![].span(),
                        ty: dojo::model::introspect::Introspect::<u32>::ty()
                    }
                ]
                    .span()
            }
        )
    }
}
const FOO_2_SELECTOR: felt252 =
    3527203548031835670756371266703868182321936944000729738011496786085282379570;

#[derive(Drop, Serde)]
pub struct Foo2Entity {
    __id: felt252, // private field
    pub v1: u128,
    pub v2: u32,
}

impl Foo2SerializeKeyImpl of dojo::model::model::SerializeKeyTrait<(u8, felt252)> {
    fn serialize_key(key: (u8, felt252)) -> Array<felt252> {
        let (k1, k2) = key;
        let mut serialized = core::array::ArrayTrait::new();
        core::serde::Serde::serialize(@k1, ref serialized);
        core::array::ArrayTrait::append(ref serialized, k2);

        serialized
    }
}

#[generate_trait]
pub impl Foo2FieldStoreImpl of Foo2FieldStore {
    fn get_foo_2_v1(self: @dojo::world::IWorldDispatcher, key: (u8, felt252)) -> u128 {
        self.get_foo_2_v1_from_id(Foo2Store::key_to_id(key))
    }

    fn get_foo_2_v1_from_id(self: @dojo::world::IWorldDispatcher, entity_id: felt252) -> u128 {
        let mut values = dojo::model::model::ModelEntity::<
            Foo2Entity
        >::get_member(
            *self,
            entity_id,
            687013198911006804117413256380548377255056948723479227932116677690621743639
        );
        let field_value = core::serde::Serde::<u128>::deserialize(ref values);

        if core::option::OptionTrait::<u128>::is_none(@field_value) {
            panic!("Field `Foo2::v1`: deserialization failed.");
        }

        core::option::OptionTrait::<u128>::unwrap(field_value)
    }

    fn update_foo_2_v1(self: dojo::world::IWorldDispatcher, key: (u8, felt252), value: u128) {
        self.update_foo_2_v1_from_id(Foo2Store::key_to_id(key), value)
    }

    fn update_foo_2_v1_from_id(
        self: dojo::world::IWorldDispatcher, entity_id: felt252, value: u128
    ) {
        let mut serialized = core::array::ArrayTrait::new();
        core::serde::Serde::serialize(@value, ref serialized);
        match dojo::utils::find_model_field_layout(
            Foo2ModelImpl::layout(),
            687013198911006804117413256380548377255056948723479227932116677690621743639
        ) {
            Option::Some(field_layout) => {
                dojo::world::IWorldDispatcherTrait::set_entity(
                    self,
                    FOO_2_SELECTOR,
                    dojo::model::ModelIndex::MemberId(
                        (
                            entity_id,
                            687013198911006804117413256380548377255056948723479227932116677690621743639
                        )
                    ),
                    serialized.span(),
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }

    fn get_foo_2_v2(self: @dojo::world::IWorldDispatcher, key: (u8, felt252)) -> u32 {
        self.get_foo_2_v2_from_id(Foo2Store::key_to_id(key))
    }

    fn get_foo_2_v2_from_id(self: @dojo::world::IWorldDispatcher, entity_id: felt252) -> u32 {
        let mut values = dojo::model::model::ModelEntity::<
            Foo2Entity
        >::get_member(
            *self,
            entity_id,
            573200779692275582020388969134054872186051594998702457223229675092771367647
        );
        let field_value = core::serde::Serde::<u32>::deserialize(ref values);

        if core::option::OptionTrait::<u32>::is_none(@field_value) {
            panic!("Field `Foo2::v2`: deserialization failed.");
        }

        core::option::OptionTrait::<u32>::unwrap(field_value)
    }

    fn update_foo_2_v2(self: dojo::world::IWorldDispatcher, key: (u8, felt252), value: u32) {
        self.update_foo_2_v2_from_id(Foo2Store::key_to_id(key), value)
    }

    fn update_foo_2_v2_from_id(
        self: dojo::world::IWorldDispatcher, entity_id: felt252, value: u32
    ) {
        let mut serialized = core::array::ArrayTrait::new();
        core::serde::Serde::serialize(@value, ref serialized);
        match dojo::utils::find_model_field_layout(
            Foo2ModelImpl::layout(),
            573200779692275582020388969134054872186051594998702457223229675092771367647
        ) {
            Option::Some(field_layout) => {
                dojo::world::IWorldDispatcherTrait::set_entity(
                    self,
                    FOO_2_SELECTOR,
                    dojo::model::ModelIndex::MemberId(
                        (
                            entity_id,
                            573200779692275582020388969134054872186051594998702457223229675092771367647
                        )
                    ),
                    serialized.span(),
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }
}


impl Foo2ModelPropsImpl of dojo::model::model::ModelPropsTrait<Foo2> {
    #[inline(always)]
    fn name() -> ByteArray {
        "Foo2"
    }

    #[inline(always)]
    fn namespace() -> ByteArray {
        "dojo"
    }

    #[inline(always)]
    fn tag() -> ByteArray {
        "dojo-Foo2"
    }

    #[inline(always)]
    fn version() -> u8 {
        1
    }

    #[inline(always)]
    fn selector() -> felt252 {
        3527203548031835670756371266703868182321936944000729738011496786085282379570
    }

    #[inline(always)]
    fn name_hash() -> felt252 {
        699767059693891773803817697209309317904761015144055008561697029389559953280
    }

    #[inline(always)]
    fn namespace_hash() -> felt252 {
        1374390215641666319136539165206515249533397964515542652183446950829433832442
    }

    #[inline(always)]
    fn keys(self: @Foo2) -> Span<felt252> {
        let mut serialized = core::array::ArrayTrait::new();
        core::serde::Serde::serialize(self.k1, ref serialized);
        core::array::ArrayTrait::append(ref serialized, *self.k2);

        core::array::ArrayTrait::span(@serialized)
    }

    #[inline(always)]
    fn values(self: @Foo2) -> Span<felt252> {
        let mut serialized = core::array::ArrayTrait::new();
        core::serde::Serde::serialize(self.v1, ref serialized);
        core::serde::Serde::serialize(self.v2, ref serialized);

        core::array::ArrayTrait::span(@serialized)
    }
}

impl Foo2EntityPropsImpl of dojo::model::model::EntityPropsTrait<Foo2Entity> {
    fn id(self: @Foo2Entity) -> felt252 {
        *self.__id
    }

    fn values(self: @Foo2Entity) -> Span<felt252> {
        let mut serialized = core::array::ArrayTrait::new();
        core::serde::Serde::serialize(self.v1, ref serialized);
        core::serde::Serde::serialize(self.v2, ref serialized);

        core::array::ArrayTrait::span(@serialized)
    }

    fn from_values(entity_id: felt252, ref values: Span<felt252>) -> Foo2Entity {
        let mut serialized = array![entity_id];
        serialized.append_span(values);
        let mut serialized = core::array::ArrayTrait::span(@serialized);

        let entity_values = core::serde::Serde::<Foo2Entity>::deserialize(ref serialized);
        if core::option::OptionTrait::<Foo2Entity>::is_none(@entity_values) {
            panic!("ModelEntity `Foo2Entity`: deserialization failed.");
        }
        core::option::OptionTrait::<Foo2Entity>::unwrap(entity_values)
    }

    #[inline(always)]
    fn selector() -> felt252 {
        3527203548031835670756371266703868182321936944000729738011496786085282379570
    }

    #[inline(always)]
    fn layout() -> dojo::model::Layout {
        dojo::model::introspect::Introspect::<Foo2>::layout()
    }
}

#[starknet::interface]
pub trait IFoo2<T> {
    fn ensure_abi(self: @T, model: Foo2);
}

#[starknet::contract]
pub mod foo_2 {
    use super::{IFoo2, Foo2, FOO_2_SELECTOR};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl DojoModelImpl of dojo::model::IModel<ContractState> {
        fn name(self: @ContractState) -> ByteArray {
            dojo::model::Model::<Foo2>::name()
        }

        fn namespace(self: @ContractState) -> ByteArray {
            dojo::model::Model::<Foo2>::namespace()
        }

        fn tag(self: @ContractState) -> ByteArray {
            dojo::model::Model::<Foo2>::tag()
        }

        fn version(self: @ContractState) -> u8 {
            dojo::model::Model::<Foo2>::version()
        }

        fn selector(self: @ContractState) -> felt252 {
            dojo::model::Model::<Foo2>::selector()
        }

        fn name_hash(self: @ContractState) -> felt252 {
            dojo::model::Model::<Foo2>::name_hash()
        }

        fn namespace_hash(self: @ContractState) -> felt252 {
            dojo::model::Model::<Foo2>::namespace_hash()
        }

        fn unpacked_size(self: @ContractState) -> Option<usize> {
            dojo::model::introspect::Introspect::<Foo2>::size()
        }

        fn packed_size(self: @ContractState) -> Option<usize> {
            dojo::model::Model::<Foo2>::packed_size()
        }

        fn layout(self: @ContractState) -> dojo::model::Layout {
            dojo::model::Model::<Foo2>::layout()
        }

        fn schema(self: @ContractState) -> dojo::model::introspect::Ty {
            dojo::model::introspect::Introspect::<Foo2>::ty()
        }
    }

    #[abi(embed_v0)]
    impl IFoo2Impl of IFoo2<ContractState> {
        fn ensure_abi(self: @ContractState, model: Foo2) {}
    }
}


pub impl Foo2ModelImpl = dojo::model::model::TModelImpl<Foo2>;
pub impl Foo2EntityImpl = dojo::model::model::TEntityImpl<Foo2Entity>;
pub impl Foo2Store =
    dojo::model::model::ModelStoreImpl<
        Foo2, Foo2Entity, (u8, felt252), Foo2ModelImpl, Foo2EntityImpl, Foo2SerializeKeyImpl
    >;

