#[starknet::interface]
pub trait IPermissions<P> {
    fn read_permission(self: @P, resource: felt252, requester: felt252) -> felt252;
    fn write_permission(ref self: P, resource: felt252, requester: felt252, permission: felt252);
}


pub trait INamespacedPermissions<P> {
    fn read_namespaced_permission(
        self: @P, resource_span: Span<felt252>, requester: felt252
    ) -> felt252;
    fn write_namespaced_permission(
        ref self: P, resource_span: Span<felt252>, requester: felt252, permission: felt252
    );
}
