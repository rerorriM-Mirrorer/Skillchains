#!/usr/bin/env python3
"""Static guard for TargetRing 3.0.4 / SceneHook 2.1 safety ports.

This validates source invariants only. It does not execute native FFXI code.
"""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
native = (root / "src" / "TargetSC.cpp").read_text(encoding="utf-8")
hook = (root / "src" / "SceneHook" / "SceneHook.h").read_text(encoding="utf-8")

def require(source, snippet, name):
    assert snippet in source, f"missing {name}: {snippet!r}"

require(native, "bool code_at(void const* address)", "executable-address guard")
require(native, "VirtualQuery(address, &region, sizeof(region))", "memory query")
require(native, "region.State == MEM_COMMIT", "committed-memory check")
require(native, "page_executable(region.Protect)", "executable-page check")
require(native, "return code_at(fn) ? fn : nullptr;", "guarded COM slot")
require(native, "com_slot(object, 0) && com_slot(object, 1) && com_slot(object, 2)",
        "candidate COM shape")
require(native, "return vtable_in_d3d8_module(vtable, modules, count) && com_shaped(object);",
        "candidate validation")
require(native, "com_slot(reinterpret_cast<std::uintptr_t>(object), 2)",
        "guarded Release")
require(native, "void* fn = com_slot(object, 0);", "guarded QueryInterface")
require(native, "void* get_device = com_slot(object, 3);", "guarded GetDevice")
assert "void* fn = vtable_slot(object, 0);" not in native
assert "void* get_device = vtable_slot(object, 3);" not in native
require(native, "scenehook_unregister(g_bus,g_bus_slot,true);", "synchronous unregister")
require(native, 'g_lua.pushstring(L,"0.5.1")', "native version")

start = hook.index("inline void SCENEHOOK_ALIGN_STACK __fastcall owner_stub(")
end = hook.index("// Hand the frame", start)
stub = hook[start:end]
increment = stub.index("InterlockedIncrement(&bus->in_flight);")
trampoline = stub.index("original(renderer, unused);")
decrement = stub.index("InterlockedDecrement(&bus->in_flight);")
assert increment < trampoline < decrement, "in_flight must cover the trampoline"

start = hook.index("inline void scenehook_unregister(")
end = hook.index("inline void scenehook_set_enabled(", start)
unregister = hook[start:end]
require(unregister, "InterlockedExchange(&client.enabled, 0);", "client disable")
require(unregister, "scenehook_detail::reassign_owner(bus, slot);", "owner reassign")
require(unregister, "spin < 1000", "full-frame drain budget")

print("PASS static native COM and SceneHook safety checks (not an in-game test)")
