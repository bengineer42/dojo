    fn get_$model_name_snake$_$field_name$(self: @dojo::world::IWorldDispatcher, key: $key_type$) -> $field_type$ {
        self.get_$model_name_snake$_$field_name$_from_id($model_name$Store::key_to_id(key))
    }

    fn get_$model_name_snake$_$field_name$_from_id(self: @dojo::world::IWorldDispatcher, entity_id: felt252) -> $field_type$ 
            {
        let mut values = dojo::model::model::ModelEntity::<$model_name$Entity>::get_member(
            *self,
            entity_id,
            $field_selector$
        );
        let field_value = core::serde::Serde::<$field_type$>::deserialize(ref values);

        if core::option::OptionTrait::<$field_type$>::is_none(@field_value) {
            panic!(
                "Field `$model_name$::$field_name$`: deserialization failed."
            );
        }

        core::option::OptionTrait::<$field_type$>::unwrap(field_value)
    }

    fn update_$model_name_snake$_$field_name$(self: dojo::world::IWorldDispatcher, key: $key_type$, value: $field_type$) {
        self.update_$model_name_snake$_$field_name$_from_id($model_name$Store::key_to_id(key), value)
    }

    fn update_$model_name_snake$_$field_name$_from_id(self: dojo::world::IWorldDispatcher, entity_id: felt252, value: $field_type$) {
        let mut serialized = core::array::ArrayTrait::new();
        core::serde::Serde::serialize(@value, ref serialized);
        match dojo::utils::find_model_field_layout($model_name$ModelImpl::layout(), $field_selector$) {
            Option::Some(field_layout) => {
                dojo::world::IWorldDispatcherTrait::set_entity(
                    self,
                    $MODEL_NAME_SNAKE$_SELECTOR,
                    dojo::model::ModelIndex::MemberId((entity_id, $field_selector$)),
                    serialized.span(),
                    field_layout
                )
            },
            Option::None => core::panic_with_felt252('bad member id')
        }
    }

