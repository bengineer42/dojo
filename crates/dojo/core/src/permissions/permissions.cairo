use dojo::permissions::IPermissions;

/// Trait for reading permissions from storage
///
/// Generic parameter P represents the permission type that will be returned
trait Permission<P, R, S, T> {
    /// Retrieves permissions for a given resource and requester
    ///
    /// # Arguments
    /// * `resource` - The identifier of the resource
    /// * `requester` - The identifier requesting access
    ///
    /// # Returns
    /// * The permissions of type P for the given resource and requester
    fn get_permission(self: @P, resource: R, requester: S) -> T;
}

/// Trait for writing permissions to storage
///
/// Generic parameter P represents the permission type that will be stored
trait WritePermission<P, R, S, T> {
    /// Sets permissions for a given resource and requester
    ///
    /// # Arguments
    /// * `resource` - The identifier of the resource
    /// * `requester` - The identifier requesting access
    /// * `permissions` - The permissions to set
    fn set_permission(ref self: P, resource: R, requester: S, permission: T);
}

/// Implementation of the Permissions trait
///
/// Requires that R, S can be converted from a and T can be converted from felt252
impl IntoFelt252PermissionsImpl<
    P,
    R,
    S,
    T,
    +IPermissions<P>,
    +Into<R, felt252>,
    +Into<S, felt252>,
    +TryInto<felt252, T>,
    +Drop<S>
> of Permission<P, R, S, T> {
    fn get_permission(self: @P, resource: R, requester: S) -> T {
        self.read_permission(resource.into(), requester.into()).try_into().unwrap()
    }
}

/// Implementation of the WritePermission trait
///
/// Requires that R, S, and T can be converted to felt252
impl WritePermissionsImpl<
    P,
    R,
    S,
    T,
    +IPermissions<P>,
    +Into<R, felt252>,
    +Into<S, felt252>,
    +Into<T, felt252>,
    +Drop<P>,
    +Drop<R>,
    +Drop<S>,
    +Drop<T>
> of WritePermission<P, R, S, T> {
    fn set_permission(ref self: P, resource: R, requester: S, permission: T) {
        self.write_permission(resource.into(), requester.into(), permission.into());
    }
}

