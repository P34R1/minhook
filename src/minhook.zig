const LPVOID = *anyopaque;
const MH_ALL_HOOKS: ?LPVOID = null;

extern fn MH_Initialize() callconv(.winapi) STATUS;
extern fn MH_Uninitialize() callconv(.winapi) STATUS;
extern fn MH_CreateHook(pTarget: LPVOID, pDetour: LPVOID, ppOriginal: ?*LPVOID) callconv(.winapi) STATUS;
extern fn MH_RemoveHook(pTarget: ?LPVOID) callconv(.winapi) STATUS;
extern fn MH_EnableHook(pTarget: ?LPVOID) callconv(.winapi) STATUS;
extern fn MH_DisableHook(pTarget: ?LPVOID) callconv(.winapi) STATUS;

/// MinHook Error Codes.
pub const Error = error{ AlreadyInitialized, NotInitialized, AlreadyCreated, NotCreated, Enabled, Disabled, NotExecutable, UnsupportedFunction, MemoryAlloc, MemoryProtect, ModuleNotFound, FunctionNotFound, MutexFailure };
const STATUS = enum(c_int) {
    OK = 0,
    ERROR_ALREADY_INITIALIZED,
    ERROR_NOT_INITIALIZED,
    ERROR_ALREADY_CREATED,
    ERROR_NOT_CREATED,
    ERROR_ENABLED,
    ERROR_DISABLED,
    ERROR_NOT_EXECUTABLE,
    ERROR_UNSUPPORTED_FUNCTION,
    ERROR_MEMORY_ALLOC,
    ERROR_MEMORY_PROTECT,
    ERROR_MODULE_NOT_FOUND,
    ERROR_FUNCTION_NOT_FOUND,
    ERROR_MUTEX_FAILURE,
    _,

    fn toError(self: @This()) Error!void {
        return switch (self) {
            .OK => {},
            .ERROR_ALREADY_INITIALIZED => Error.AlreadyInitialized,
            .ERROR_NOT_INITIALIZED => Error.NotInitialized,
            .ERROR_ALREADY_CREATED => Error.AlreadyCreated,
            .ERROR_NOT_CREATED => Error.NotCreated,
            .ERROR_ENABLED => Error.Enabled,
            .ERROR_DISABLED => Error.Disabled,
            .ERROR_NOT_EXECUTABLE => Error.NotExecutable,
            .ERROR_UNSUPPORTED_FUNCTION => Error.UnsupportedFunction,
            .ERROR_MEMORY_ALLOC => Error.MemoryAlloc,
            .ERROR_MEMORY_PROTECT => Error.MemoryProtect,
            .ERROR_MODULE_NOT_FOUND => Error.ModuleNotFound,
            .ERROR_FUNCTION_NOT_FOUND => Error.FunctionNotFound,
            .ERROR_MUTEX_FAILURE => Error.MutexFailure,
            _ => unreachable,
        };
    }
};

/// Initialize the MinHook library. You must call this function EXACTLY ONCE
/// at the beginning of your program.
pub fn init() Error!void {
    return MH_Initialize().toError();
}

/// Uninitialize the MinHook library. You must call this function EXACTLY
/// ONCE at the end of your program.
pub fn deinit() Error!void {
    return MH_Uninitialize().toError();
}

/// Creates a hook for the specified target function, in disabled state.
///
/// `target` is a pointer to the target function, which will be overridden by the detour function.
///
/// `detour` is the detour function, which will override the target function.
///
/// Returns a pointer to the trampoline function, which will be used to call the original target function.
pub fn create(target: *const anyopaque, detour: anytype) Error!*const @TypeOf(detour) {
    if (@typeInfo(@TypeOf(detour)) != .@"fn")
        @compileError("detour must be a function");

    var original: *const @TypeOf(detour) = undefined;
    try MH_CreateHook(@ptrCast(@constCast(target)), @ptrCast(@constCast(&detour)), @ptrCast(@constCast(&original))).toError();

    return original;
}

/// Removes all already created hooks.
pub fn removeAll() Error!void {
    return MH_RemoveHook(MH_ALL_HOOKS).toError();
}

/// Enables all already created hooks.
pub fn enableAll() Error!void {
    return MH_EnableHook(MH_ALL_HOOKS).toError();
}

/// Disables all already created hooks.
pub fn disableAll() Error!void {
    return MH_DisableHook(MH_ALL_HOOKS).toError();
}

test {
    @import("std").testing.refAllDecls(@This());
}
