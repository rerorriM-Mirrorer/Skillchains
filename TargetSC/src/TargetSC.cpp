// TargetSC 0.2.0 — Author: A.
// Device discovery, projection and model following adapted from Broguypal's
// TargetRing (BSD-3-Clause); see licenses/ and THIRD_PARTY_NOTICES.md.
// SceneHook.h is deliberately byte-identical to both reference addons.
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <tlhelp32.h>
#include <d3d8.h>
#include "SceneHook/SceneHook.h"
#include "StrokeGeometry.h"
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <algorithm>
namespace {
using lua_State = struct lua_State;
using lua_CFunction = int(__cdecl*)(lua_State*);

using fn_createtable = void(__cdecl*)(lua_State*, int, int);
using fn_pushcclosure = void(__cdecl*)(lua_State*, lua_CFunction, int);
using fn_setfield = void(__cdecl*)(lua_State*, int, char const*);
using fn_pushvalue = void(__cdecl*)(lua_State*, int);
using fn_pushstring = void(__cdecl*)(lua_State*, char const*);
using fn_gettop = int(__cdecl*)(lua_State*);
using fn_tonumber = double(__cdecl*)(lua_State*, int);

constexpr int kGlobalsIndex = -10002;

struct LuaApi {
    fn_createtable createtable = nullptr;
    fn_pushcclosure pushcclosure = nullptr;
    fn_setfield setfield = nullptr;
    fn_pushvalue pushvalue = nullptr;
    fn_pushstring pushstring = nullptr;
    fn_gettop gettop = nullptr;
    fn_tonumber tonumber = nullptr;

    bool ready() const {
        return createtable && pushcclosure && setfield && pushvalue
            && pushstring && gettop && tonumber;
    }
};

LuaApi g_lua {};

struct Position {
    float east = 0.0f;
    float north = 0.0f;
    float height = 0.0f;
};

struct DrawVertex {
    float x;
    float y;
    float z;
    float rhw;
    DWORD color;
};

constexpr int kMaxRings=32;
constexpr int kMaxDiscs=8;
constexpr int ring_slices_=64;
constexpr DWORD kMaxIndex=0x900;
constexpr std::uintptr_t kDisplayHeading=0x048;
constexpr std::uintptr_t kEntityDisplayPos=0x004;
constexpr std::uintptr_t kEntityDisplayPtr=0x0A0;
constexpr std::uintptr_t kDisplayNameplateBase=0x678;
constexpr std::uintptr_t kDisplayPosition=0x034;
constexpr std::uintptr_t kEntityTargetType=0x0EE;
constexpr unsigned char kTargetTypeObject=3;
int g_object_mode=0;
struct Ring {float radius=0, offset=0, width=0; DWORD color=0; float pixels=0;};
struct Disc {float radius=0,offset=0,rotation=0;DWORD color=0;bool glyph=false;};
struct Frame {DWORD index=0, id=0, tick=0;int count=0,disc_count=0;
    Ring rings[kMaxRings]{};Disc discs[kMaxDiscs]{};};
SRWLOCK g_frame_lock=SRWLOCK_INIT;
Frame g_pending{}, g_frame{};
volatile LONG g_frames=0, g_draws=0, g_tracking_failures=0, g_state_failures=0;
float ring_cos_[ring_slices_+1]{}, ring_sin_[ring_slices_+1]{};
void build_tables() {
    for (int i=0;i<=ring_slices_;++i) {
        const float a=6.28318530718f*i/ring_slices_;
        ring_cos_[i]=std::cos(a); ring_sin_[i]=std::sin(a);
    }
}
SceneBus* g_bus = nullptr;
int g_bus_slot = -1;
std::uintptr_t g_renderer = 0;
std::uintptr_t g_device = 0;
std::uintptr_t g_last_renderer = 0;
constexpr std::size_t kRendererScanWindow = 0x8000;
constexpr std::size_t kDeviceVtableEntries = 90;
constexpr unsigned long kDeviceRetryFrames = 30;
constexpr unsigned long kMaxDeviceAttempts = 240;
unsigned long g_device_frames = 0;
unsigned long g_device_attempts = 0;
char g_status[192] = "idle";

bool page_readable(DWORD protect) {
    if (protect & (PAGE_GUARD | PAGE_NOACCESS)) {
        return false;
    }

    switch (protect & 0xFF) {
    case PAGE_READONLY:
    case PAGE_READWRITE:
    case PAGE_WRITECOPY:
    case PAGE_EXECUTE_READ:
    case PAGE_EXECUTE_READWRITE:
    case PAGE_EXECUTE_WRITECOPY:
        return true;
    default:
        return false;
    }
}

bool page_executable(DWORD protect) {
    if (protect & (PAGE_GUARD | PAGE_NOACCESS)) {
        return false;
    }

    switch (protect & 0xFF) {
    case PAGE_EXECUTE:
    case PAGE_EXECUTE_READ:
    case PAGE_EXECUTE_READWRITE:
    case PAGE_EXECUTE_WRITECOPY:
        return true;
    default:
        return false;
    }
}

bool span_readable(std::uintptr_t address, std::size_t size) {
    if (address == 0 || size == 0) {
        return false;
    }

    MEMORY_BASIC_INFORMATION region {};
    if (!VirtualQuery(reinterpret_cast<void const*>(address), &region, sizeof(region))) {
        return false;
    }

    if (region.State != MEM_COMMIT || !page_readable(region.Protect)) {
        return false;
    }

    std::uintptr_t const low = reinterpret_cast<std::uintptr_t>(region.BaseAddress);
    return address >= low && address + size <= low + region.RegionSize;
}

bool module_range_from_handle(HMODULE module, std::uintptr_t& base, std::size_t& size) {
    base = 0;
    size = 0;

    if (!module) {
        return false;
    }

    base = reinterpret_cast<std::uintptr_t>(module);
    if (!span_readable(base, sizeof(IMAGE_DOS_HEADER))) {
        return false;
    }

    auto const* dos = reinterpret_cast<IMAGE_DOS_HEADER const*>(base);
    if (dos->e_magic != IMAGE_DOS_SIGNATURE) {
        return false;
    }

    std::uintptr_t const nt_address = base + static_cast<std::uintptr_t>(dos->e_lfanew);
    if (!span_readable(nt_address, sizeof(IMAGE_NT_HEADERS32))) {
        return false;
    }

    auto const* nt = reinterpret_cast<IMAGE_NT_HEADERS32 const*>(nt_address);
    if (nt->Signature != IMAGE_NT_SIGNATURE) {
        return false;
    }

    size = nt->OptionalHeader.SizeOfImage;
    return size != 0;
}

bool module_range(char const* name, std::uintptr_t& base, std::size_t& size) {
    return module_range_from_handle(GetModuleHandleA(name), base, size);
}

std::uintptr_t scan_module(char const* name, unsigned char const* pattern,
    char const* mask, std::size_t length) {
    std::uintptr_t base = 0;
    std::size_t image = 0;
    if (!module_range(name, base, image)) {
        return 0;
    }

    auto const* dos = reinterpret_cast<IMAGE_DOS_HEADER const*>(base);
    auto const* nt = reinterpret_cast<IMAGE_NT_HEADERS32 const*>(
        base + static_cast<std::uintptr_t>(dos->e_lfanew));

    auto const* section = IMAGE_FIRST_SECTION(nt);
    for (unsigned i = 0; i < nt->FileHeader.NumberOfSections; ++i, ++section) {
        if ((section->Characteristics & IMAGE_SCN_MEM_EXECUTE) == 0) {
            continue;
        }

        std::uintptr_t const start = base + section->VirtualAddress;
        std::size_t const span = section->Misc.VirtualSize;
        if (span <= length || !span_readable(start, span)) {
            continue;
        }

        auto const* bytes = reinterpret_cast<unsigned char const*>(start);
        for (std::size_t offset = 0; offset + length <= span; ++offset) {
            bool hit = true;
            for (std::size_t j = 0; j < length; ++j) {
                if (mask[j] != '?' && bytes[offset + j] != pattern[j]) {
                    hit = false;
                    break;
                }
            }

            if (hit) {
                return start + offset;
            }
        }
    }

    return 0;
}

void* vtable_slot(std::uintptr_t object, int index) {
    if (!span_readable(object, sizeof(std::uintptr_t))) {
        return nullptr;
    }

    std::uintptr_t vtable = 0;
    std::memcpy(&vtable, reinterpret_cast<void const*>(object), sizeof(vtable));

    std::uintptr_t const entry = vtable + static_cast<std::uintptr_t>(index) * sizeof(std::uintptr_t);
    if (!span_readable(entry, sizeof(std::uintptr_t))) {
        return nullptr;
    }

    std::uintptr_t address = 0;
    std::memcpy(&address, reinterpret_cast<void const*>(entry), sizeof(address));
    return reinterpret_cast<void*>(address);
}

using fn_release = unsigned long(__stdcall*)(void*);
void* d3d_device_=nullptr;
std::uintptr_t g_entity_array = 0;
bool g_entity_array_resolved = false;

// mov edx,[esi+0xC] / mov eax,[edx+ebp] / mov eax,[eax*4+imm32] -- the trailing
// imm32 is the array base itself, not a pointer to it.
std::uintptr_t entity_array() {
    if (g_entity_array_resolved) {
        return g_entity_array;
    }

    g_entity_array_resolved = true;

    static unsigned char const pattern[] = {
        0x8B, 0x56, 0x0C, 0x8B, 0x04, 0x2A, 0x8B, 0x04, 0x85,
    };
    static char const mask[] = "xxxxxxxxx";

    std::uintptr_t const match = scan_module("FFXiMain.dll", pattern, mask, sizeof(pattern));
    if (match == 0) {
        return 0;
    }

    std::uint32_t base = 0;
    if (!span_readable(match + sizeof(pattern), sizeof(base))) {
        return 0;
    }

    std::memcpy(&base, reinterpret_cast<void const*>(match + sizeof(pattern)), sizeof(base));
    if (!span_readable(base, sizeof(std::uintptr_t) * kMaxIndex)) {
        return 0;
    }

    g_entity_array = base;
    return g_entity_array;
}

bool live_position(DWORD index, Position& out, float* heading_out) {
    std::uintptr_t const base = entity_array();
    if (base == 0 || index == 0 || index >= kMaxIndex) {
        return false;
    }

    std::uintptr_t const slot = base + static_cast<std::uintptr_t>(index) * sizeof(std::uintptr_t);
    if (!span_readable(slot, sizeof(std::uintptr_t))) {
        return false;
    }

    std::uintptr_t entity = 0;
    std::memcpy(&entity, reinterpret_cast<void const*>(slot), sizeof(entity));
    if (entity == 0) {
        return false;
    }

    float coords[3] {};
    bool have = false;

    unsigned char target_type = 0;
    if (span_readable(entity + kEntityTargetType, sizeof(target_type))) {
        std::memcpy(&target_type, reinterpret_cast<void const*>(entity + kEntityTargetType),
            sizeof(target_type));
    }

    const bool is_object = target_type == kTargetTypeObject;
    if (is_object && g_object_mode == 1) {
        return false;
    }

    const std::uintptr_t position_field = (is_object && g_object_mode == 0)
        ? kDisplayPosition : kDisplayNameplateBase;

    if (span_readable(entity + kEntityDisplayPtr, sizeof(std::uintptr_t))) {
        std::uintptr_t display = 0;
        std::memcpy(&display, reinterpret_cast<void const*>(entity + kEntityDisplayPtr), sizeof(display));
        if (display != 0 && span_readable(display + position_field, sizeof(float) * 3)) {
            std::memcpy(coords, reinterpret_cast<void const*>(display + position_field),
                sizeof(coords));
            have = true;

            if (heading_out && span_readable(display + kDisplayHeading, sizeof(float))) {
                float heading = 0.0f;
                std::memcpy(&heading, reinterpret_cast<void const*>(display + kDisplayHeading),
                    sizeof(heading));
                if (std::isfinite(heading)) {
                    *heading_out = heading;
                }
            }
        }
    }

    if (!have) {
        if (!span_readable(entity + kEntityDisplayPos, sizeof(float) * 3)) {
            return false;
        }

        std::memcpy(coords, reinterpret_cast<void const*>(entity + kEntityDisplayPos), sizeof(coords));
    }

    if (!std::isfinite(coords[0]) || !std::isfinite(coords[1]) || !std::isfinite(coords[2])
        || std::fabs(coords[0]) > 10000.0f || std::fabs(coords[1]) > 10000.0f
        || std::fabs(coords[2]) > 10000.0f) {
        return false;
    }

    out.east = coords[0];
    out.height = coords[1];
    out.north = coords[2];
    return true;
}

bool plausible_device_vtable(std::uintptr_t vtable) {
    if (!span_readable(vtable, sizeof(std::uintptr_t) * kDeviceVtableEntries)) {
        return false;
    }

    static int const probes[] = { 2, 35, 41, 72 };
    for (int slot : probes) {
        std::uintptr_t entry = 0;
        std::memcpy(&entry,
            reinterpret_cast<void const*>(vtable + static_cast<std::uintptr_t>(slot) * sizeof(std::uintptr_t)),
            sizeof(entry));
        if (entry == 0) {
            return false;
        }

        MEMORY_BASIC_INFORMATION region {};
        if (!VirtualQuery(reinterpret_cast<void const*>(entry), &region, sizeof(region))
            || region.State != MEM_COMMIT
            || !page_executable(region.Protect)) {
            return false;
        }
    }

    return true;
}

constexpr std::size_t kMaxD3DModules = 8;

struct D3DModuleRange {
    std::uintptr_t base;
    std::size_t size;
};

GUID const kIidDevice8 =
    { 0x7385E5DF, 0x8FE8, 0x41D5, { 0x86, 0xB6, 0xD7, 0xB4, 0x85, 0x47, 0xB6, 0xCF } };
GUID const kIidBaseTexture8 =
    { 0xB4211CFA, 0x51B9, 0x4A9F, { 0xAB, 0x78, 0xDB, 0x99, 0xB2, 0xBB, 0x67, 0x8E } };
GUID const kIidTexture8 =
    { 0xE4CDD575, 0x2866, 0x4F01, { 0xB1, 0x2E, 0x7E, 0xEC, 0xE1, 0xEC, 0x93, 0x58 } };
GUID const kIidSurface8 =
    { 0xB96EEBCA, 0xB326, 0x4EA5, { 0x88, 0x2F, 0x2F, 0xF5, 0xBA, 0xE0, 0x21, 0xDD } };
GUID const kIidVertexBuffer8 =
    { 0x8AEEEAC7, 0x05F9, 0x44D4, { 0xB5, 0x91, 0x00, 0x0B, 0x0D, 0xF1, 0xCB, 0x95 } };
GUID const kIidIndexBuffer8 =
    { 0x0E689C9A, 0x053D, 0x44A0, { 0x9D, 0x92, 0xDB, 0x0E, 0x3D, 0x75, 0x0F, 0x86 } };
GUID const kIidResource8 =
    { 0x1B36BB7B, 0x09B7, 0x410A, { 0xB4, 0x45, 0x7D, 0x14, 0x30, 0xD7, 0xB3, 0x3F } };

GUID const* const kResourceIids[] = {
    &kIidBaseTexture8, &kIidTexture8, &kIidSurface8,
    &kIidVertexBuffer8, &kIidIndexBuffer8, &kIidResource8,
};

#if defined(__GNUC__)
__attribute__((noinline, optimize("no-omit-frame-pointer")))
long call_com_2(void* fn, void* object, void* a) {
    long result = 0;
    __asm__ __volatile__(
        "movl %%esp, %%ebx\n\t"
        "pushl %2\n\t"
        "pushl %3\n\t"
        "call *%1\n\t"
        "movl %%ebx, %%esp\n\t"
        : "=a"(result)
        : "m"(fn), "m"(a), "m"(object)
        : "ebx", "ecx", "edx", "memory", "cc");
    return result;
}

__attribute__((noinline, optimize("no-omit-frame-pointer")))
long call_com_3(void* fn, void* object, void* a, void* b) {
    long result = 0;
    __asm__ __volatile__(
        "movl %%esp, %%ebx\n\t"
        "pushl %2\n\t"
        "pushl %3\n\t"
        "pushl %4\n\t"
        "call *%1\n\t"
        "movl %%ebx, %%esp\n\t"
        : "=a"(result)
        : "m"(fn), "m"(b), "m"(a), "m"(object)
        : "ebx", "ecx", "edx", "memory", "cc");
    return result;
}

#else
long call_com_2(void* fn, void* object, void* a) {
    return reinterpret_cast<long(__stdcall*)(void*,void*)>(fn)(object,a);
}
long call_com_3(void* fn, void* object, void* a, void* b) {
    return reinterpret_cast<long(__stdcall*)(void*,void*,void*)>(fn)(object,a,b);
}
#endif
void release_com(void* object) {
    if (!object) {
        return;
    }
    auto release = reinterpret_cast<fn_release>(
        vtable_slot(reinterpret_cast<std::uintptr_t>(object), 2));
    if (release) {
        release(object);
    }
}

bool query_interface(std::uintptr_t object, GUID const& iid, void*& out) {
    out = nullptr;

    void* fn = vtable_slot(object, 0);
    if (!fn) {
        return false;
    }

    long const hr = call_com_3(fn, reinterpret_cast<void*>(object),
        const_cast<GUID*>(&iid), &out);
    if (hr < 0 || out == nullptr) {
        out = nullptr;
        return false;
    }
    return true;
}

void owning_module_name(std::uintptr_t address, char* out, std::size_t size) {
    if (size == 0) {
        return;
    }
    out[0] = '\0';

    HMODULE module = nullptr;
    if (!GetModuleHandleExA(
            GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS
                | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
            reinterpret_cast<char const*>(address), &module)
        || !module) {
        return;
    }

    char path[MAX_PATH] {};
    if (GetModuleFileNameA(module, path, MAX_PATH) == 0) {
        return;
    }

    char const* leaf = std::strrchr(path, '\\');
    leaf = leaf ? leaf + 1 : path;
    std::snprintf(out, size, "%s", leaf);
}

std::size_t collect_d3d8_modules(D3DModuleRange* out, std::size_t capacity) {
    std::size_t count = 0;

    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, GetCurrentProcessId());
    if (snapshot == INVALID_HANDLE_VALUE) {
        return 0;
    }

    MODULEENTRY32 entry {};
    entry.dwSize = sizeof(entry);
    if (Module32First(snapshot, &entry)) {
        do {
            if (count >= capacity) {
                break;
            }
            if (!entry.hModule || !GetProcAddress(entry.hModule, "Direct3DCreate8")) {
                continue;
            }

            std::uintptr_t base = 0;
            std::size_t size = 0;
            if (!module_range_from_handle(entry.hModule, base, size)) {
                continue;
            }

            out[count].base = base;
            out[count].size = size;
            ++count;
        } while (Module32Next(snapshot, &entry));
    }

    CloseHandle(snapshot);
    return count;
}

bool vtable_in_d3d8_module(
    std::uintptr_t vtable, D3DModuleRange const* modules, std::size_t count) {
    for (std::size_t index = 0; index < count; ++index) {
        if (vtable >= modules[index].base
            && vtable < modules[index].base + modules[index].size) {
            return true;
        }
    }
    return false;
}

bool candidate_at(
    std::uintptr_t slot, D3DModuleRange const* modules, std::size_t count,
    std::uintptr_t& object) {
    if (!span_readable(slot, sizeof(std::uintptr_t))) {
        return false;
    }

    object = 0;
    std::memcpy(&object, reinterpret_cast<void const*>(slot), sizeof(object));
    if (object == 0 || !span_readable(object, sizeof(std::uintptr_t))) {
        return false;
    }

    std::uintptr_t vtable = 0;
    std::memcpy(&vtable, reinterpret_cast<void const*>(object), sizeof(vtable));
    return vtable_in_d3d8_module(vtable, modules, count);
}

bool adopt_device(
    void* device, char const* how, D3DModuleRange const* modules, std::size_t count) {
    std::uintptr_t const address = reinterpret_cast<std::uintptr_t>(device);
    if (!span_readable(address, sizeof(std::uintptr_t))) {
        return false;
    }

    std::uintptr_t device_vtable = 0;
    std::memcpy(&device_vtable, device, sizeof(device_vtable));
    if (!vtable_in_d3d8_module(device_vtable, modules, count)
        && !plausible_device_vtable(device_vtable)) {
        return false;
    }

    g_device = address;
    d3d_device_ = device;

    char owner[64] {};
    owning_module_name(device_vtable, owner, sizeof(owner));
    std::snprintf(g_status, sizeof(g_status), "running (%s, device in %s)",
        how, owner[0] ? owner : "unknown module");
    return true;
}

void acquire_device(std::uintptr_t renderer) {
    if (renderer == 0) {
        return;
    }

    if (renderer != g_last_renderer) {
        g_last_renderer = renderer;
        d3d_device_ = nullptr;
        g_device = 0;
        g_device_attempts = 0;
        g_device_frames = 0;
    }

    if (d3d_device_ || g_device_attempts >= kMaxDeviceAttempts) {
        return;
    }

    ++g_device_frames;
    if (g_device_attempts != 0 && (g_device_frames % kDeviceRetryFrames) != 0) {
        return;
    }

    ++g_device_attempts;

    D3DModuleRange modules[kMaxD3DModules] {};
    std::size_t const module_count = collect_d3d8_modules(modules, kMaxD3DModules);
    if (module_count == 0) {
        std::snprintf(g_status, sizeof(g_status), "no d3d8 implementation found");
        return;
    }

    // An unreadable slot is skipped rather than ending the scan; the renderer
    // has gaps and the device resource can sit past them.
    for (std::size_t offset = 0; offset + 4 <= kRendererScanWindow; offset += 4) {
        std::uintptr_t object = 0;
        if (!candidate_at(renderer + offset, modules, module_count, object)) {
            continue;
        }

        void* device = nullptr;
        if (!query_interface(object, kIidDevice8, device)) {
            continue;
        }

        bool const adopted = adopt_device(device, "direct", modules, module_count);
        release_com(device);
        if (adopted) {
            return;
        }
    }

    for (std::size_t offset = 0; offset + 4 <= kRendererScanWindow; offset += 4) {
        std::uintptr_t object = 0;
        if (!candidate_at(renderer + offset, modules, module_count, object)) {
            continue;
        }

        bool confirmed = false;
        for (GUID const* iid : kResourceIids) {
            void* resource = nullptr;
            if (query_interface(object, *iid, resource)) {
                release_com(resource);
                confirmed = true;
                break;
            }
        }
        if (!confirmed) {
            continue;
        }

        void* get_device = vtable_slot(object, 3);
        if (!get_device) {
            continue;
        }

        void* device = nullptr;
        long const hr = call_com_2(get_device, reinterpret_cast<void*>(object), &device);
        if (hr < 0 || !device) {
            continue;
        }

        bool const adopted = adopt_device(device, "resource", modules, module_count);
        release_com(device);
        if (adopted) {
            return;
        }
    }

    std::snprintf(g_status, sizeof(g_status), "device not found in renderer (try %lu)",
        g_device_attempts);
}


D3DMATRIX g_vp{};
bool project(Position const& p,D3DVIEWPORT8 const& v, DrawVertex& out,DWORD color) {
    const float x=p.east,y=p.height,z=p.north;
    const float w=x*g_vp.m[0][3]+y*g_vp.m[1][3]+z*g_vp.m[2][3]+g_vp.m[3][3];
    if (!std::isfinite(w)||w<=0.001f) return false;
    const float cx=x*g_vp.m[0][0]+y*g_vp.m[1][0]+z*g_vp.m[2][0]+g_vp.m[3][0];
    const float cy=x*g_vp.m[0][1]+y*g_vp.m[1][1]+z*g_vp.m[2][1]+g_vp.m[3][1];
    const float cz=x*g_vp.m[0][2]+y*g_vp.m[1][2]+z*g_vp.m[2][2]+g_vp.m[3][2];
    if (!std::isfinite(cx)||!std::isfinite(cy)||!std::isfinite(cz)||cz<0||cz>w) return false;
    out={v.X+(cx/w+1)*v.Width*.5f,v.Y+(1-cy/w)*v.Height*.5f,
         v.MinZ+(cz/w)*(v.MaxZ-v.MinZ),1/w,color};
    return true;
}
// Bounded storage reused by the render thread: no per-frame allocations.
constexpr int kMaxVertices=(kMaxRings+kMaxDiscs)*ring_slices_*6+kMaxDiscs*(ring_slices_*3+24);
DrawVertex g_vertices[kMaxVertices]{};
unsigned g_vertex_count=0;
void triangle(DrawVertex a,DrawVertex b,DrawVertex c) {
    if(g_vertex_count+3>kMaxVertices)return;
    g_vertices[g_vertex_count++]=a;g_vertices[g_vertex_count++]=b;g_vertices[g_vertex_count++]=c;
}
void emit_ring(Position const& base,Ring const& ring,D3DVIEWPORT8 const& viewport) {
    DrawVertex points[ring_slices_]{};bool valid[ring_slices_]{};
    float widths[ring_slices_]{};
    for(int i=0;i<ring_slices_;++i) {
        const float x=ring_cos_[i],y=ring_sin_[i];
        Position p{base.east+ring.radius*x,base.north+ring.radius*y,base.height-ring.offset};
        valid[i]=project(p,viewport,points[i],ring.color);
        DrawVertex inner{},outer{};
        Position a{base.east+(ring.radius-ring.width*.5f)*x,base.north+(ring.radius-ring.width*.5f)*y,p.height};
        Position b{base.east+(ring.radius+ring.width*.5f)*x,base.north+(ring.radius+ring.width*.5f)*y,p.height};
        const float natural=(project(a,viewport,inner,ring.color)&&project(b,viewport,outer,ring.color))
            ? std::hypot(outer.x-inner.x,outer.y-inner.y):0.f;
        widths[i]=targetsc::visible_width(natural,ring.pixels);
    }
    DrawVertex inside[ring_slices_]{},outside[ring_slices_]{};
    for(int i=0;i<ring_slices_;++i) {
        if(!valid[i])continue;
        int prev=(i+ring_slices_-1)%ring_slices_,next=(i+1)%ring_slices_;
        auto const& p=points[i];
        auto const& a=valid[prev]?points[prev]:p;
        auto const& b=valid[next]?points[next]:p;
        const auto d=targetsc::stroke_offset({a.x,a.y},{p.x,p.y},{b.x,b.y},widths[i]*.5f);
        // Keep centerline projected depth/rhw on both sides of the thin stroke.
        // Screen-space widening must never put a vertex on the near plane.
        inside[i]=p;outside[i]=p;inside[i].x-=d.x;inside[i].y-=d.y;
        outside[i].x+=d.x;outside[i].y+=d.y;
    }
    for(int i=0;i<ring_slices_;++i) {
        const int n=(i+1)%ring_slices_;
        if(!valid[i]||!valid[n])continue;
        triangle(inside[i],outside[i],inside[n]);triangle(inside[n],outside[i],outside[n]);
    }
}
void emit_disc(Position const& base,Disc const& disc,D3DVIEWPORT8 const& viewport) {
    const Position center{base.east,base.north,base.height-disc.offset};
    DrawVertex hub{};if(!project(center,viewport,hub,disc.color))return;
    // Translucent colored fill is deliberate ground glyph geometry, not a
    // filled backdrop beneath the rings. No texture/D3DX dependency is added.
    DrawVertex edge[ring_slices_]{};bool valid[ring_slices_]{};
    for(int i=0;i<ring_slices_;++i) {
        Position p{center.east+disc.radius*ring_cos_[i],center.north+disc.radius*ring_sin_[i],center.height};
        valid[i]=project(p,viewport,edge[i],disc.color);
    }
    for(int i=0;i<ring_slices_;++i){int n=(i+1)%ring_slices_;if(valid[i]&&valid[n])triangle(hub,edge[i],edge[n]);}
    if(!disc.glyph)return;
    const DWORD alpha=(disc.color>>24)&255;
    const DWORD white=(std::min<DWORD>(255,alpha*3)<<24)|0x00ffffff;
    Ring rim{disc.radius,disc.offset,0,white,1.f};emit_ring(base,rim,viewport);
    // Four-pointed star/cross, rotated in the actual horizontal world plane.
    DrawVertex star[8]{};bool stars_ok=true;DrawVertex sh=hub;sh.color=white;
    for(int i=0;i<8;++i) {
        const float angle=disc.rotation+i*6.28318530718f/8;
        const float r=disc.radius*((i&1)? .16f:.84f);
        Position p{center.east+std::cos(angle)*r,center.north+std::sin(angle)*r,center.height};
        if(!project(p,viewport,star[i],white))stars_ok=false;
    }
    if(stars_ok)for(int i=0;i<8;++i)triangle(sh,star[i],star[(i+1)%8]);
}
void draw_all_rings() {
    Frame f{};
    AcquireSRWLockShared(&g_frame_lock); f=g_frame; ReleaseSRWLockShared(&g_frame_lock);
    // A stopped/erroring Lua state cannot leave a permanent frozen resonance.
    if ((!f.count && !f.disc_count) || GetTickCount()-f.tick>250 || !d3d_device_) return;
    Position base{};
    if (!live_position(f.index,base,nullptr)) {InterlockedIncrement(&g_tracking_failures); return;}
    auto* dev=static_cast<IDirect3DDevice8*>(d3d_device_);
    D3DMATRIX view{},projection{}; D3DVIEWPORT8 viewport{};
    if (FAILED(dev->GetTransform(D3DTS_VIEW,&view)) || FAILED(dev->GetTransform(D3DTS_PROJECTION,&projection))
        || FAILED(dev->GetViewport(&viewport)) || !viewport.Width || !viewport.Height) return;
    for(int r=0;r<4;++r) for(int c=0;c<4;++c) {
        g_vp.m[r][c]=0; for(int k=0;k<4;++k) g_vp.m[r][c]+=view.m[r][k]*projection.m[k][c];
    }
    // D3D8 state blocks include shaders, textures, stage states AND stream 0
    // (DrawPrimitiveUP clears stream 0). A fresh token avoids reset-lifetime
    // resource issues. Never draw if capturing the complete state fails.
    DWORD token=0;
    if(FAILED(dev->CreateStateBlock(D3DSBT_ALL,&token))) {InterlockedIncrement(&g_state_failures);return;}
    bool ok=true;
    auto rs=[&](D3DRENDERSTATETYPE k,DWORD v){if(FAILED(dev->SetRenderState(k,v)))ok=false;};
    auto ts=[&](DWORD stage,D3DTEXTURESTAGESTATETYPE k,DWORD v){if(FAILED(dev->SetTextureStageState(stage,k,v)))ok=false;};
    if(FAILED(dev->SetTexture(0,nullptr))||FAILED(dev->SetPixelShader(0))
        ||FAILED(dev->SetVertexShader(D3DFVF_XYZRHW|D3DFVF_DIFFUSE)))ok=false;
    rs(D3DRS_ALPHABLENDENABLE,TRUE);rs(D3DRS_SRCBLEND,D3DBLEND_SRCALPHA);
    // Standard alpha permits translucent black-purple strands to be visible.
    rs(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA);rs(D3DRS_BLENDOP,D3DBLENDOP_ADD);
    rs(D3DRS_ZENABLE,TRUE);rs(D3DRS_ZFUNC,D3DCMP_LESSEQUAL);rs(D3DRS_ZWRITEENABLE,FALSE);
    rs(D3DRS_LIGHTING,FALSE);rs(D3DRS_CULLMODE,D3DCULL_NONE);rs(D3DRS_FOGENABLE,FALSE);
    rs(D3DRS_ALPHATESTENABLE,FALSE);rs(D3DRS_STENCILENABLE,FALSE);
    rs(D3DRS_FILLMODE,D3DFILL_SOLID);rs(D3DRS_CLIPPLANEENABLE,0);
    rs(D3DRS_COLORWRITEENABLE, D3DCOLORWRITEENABLE_RED|D3DCOLORWRITEENABLE_GREEN|D3DCOLORWRITEENABLE_BLUE|D3DCOLORWRITEENABLE_ALPHA);
    ts(0,D3DTSS_COLOROP,D3DTOP_SELECTARG1);ts(0,D3DTSS_COLORARG1,D3DTA_DIFFUSE);
    ts(0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG1);ts(0,D3DTSS_ALPHAARG1,D3DTA_DIFFUSE);
    ts(1,D3DTSS_COLOROP,D3DTOP_DISABLE);ts(1,D3DTSS_ALPHAOP,D3DTOP_DISABLE);
    if(ok) {
        g_vertex_count=0;
        // Draw larger/lower glyphs first (Lua orders them), then ring glows and
        // cores. One bounded native submission per visible frame.
        for(int i=0;i<f.disc_count;++i)emit_disc(base,f.discs[i],viewport);
        for(int i=0;i<f.count;++i)emit_ring(base,f.rings[i],viewport);
        if(g_vertex_count && SUCCEEDED(dev->DrawPrimitiveUP(D3DPT_TRIANGLELIST,g_vertex_count/3,g_vertices,sizeof(DrawVertex))))
            InterlockedIncrement(&g_draws);
    } else InterlockedIncrement(&g_state_failures);
    if(FAILED(dev->ApplyStateBlock(token)))InterlockedIncrement(&g_state_failures);
    dev->DeleteStateBlock(token);
}
void SCENEHOOK_ALIGN_STACK __cdecl scene_draw(void*,void* renderer,void*) {
    InterlockedIncrement(&g_frames);
    g_renderer=reinterpret_cast<std::uintptr_t>(renderer);
    acquire_device(g_renderer);draw_all_rings();
}
bool install_hook() {
    if (!g_bus) {
        g_bus = scenehook_attach();
    }

    if (!g_bus) {
        std::snprintf(g_status, sizeof(g_status),
            "scene hook unavailable (another addon may be built against a different ABI)");
        return false;
    }

    if (!scenehook_ensure_hook(g_bus)) {
        std::snprintf(g_status, sizeof(g_status), "%s", g_bus->status);
        return false;
    }

    if (g_bus_slot < 0) {
        g_bus_slot = scenehook_register(g_bus, &scene_draw, nullptr);
        if (g_bus_slot < 0) {
            std::snprintf(g_status, sizeof(g_status), "scene hook is full");
            return false;
        }
    }

    scenehook_set_enabled(g_bus, g_bus_slot, true);
    std::snprintf(g_status, sizeof(g_status), "running");
    return true;
}


void clear_frame() {
    AcquireSRWLockExclusive(&g_frame_lock);Frame empty{};g_frame=empty;ReleaseSRWLockExclusive(&g_frame_lock);
    Frame empty_pending{};g_pending=empty_pending;
}
int __cdecl lua_start(lua_State* L) {install_hook();g_lua.pushstring(L,g_status);return 1;}
int __cdecl lua_stop(lua_State* L) {
    clear_frame();scenehook_unregister(g_bus,g_bus_slot,true);g_bus_slot=-1;
    d3d_device_=nullptr;g_device=0;g_last_renderer=0;g_device_attempts=0;g_device_frames=0;
    std::snprintf(g_status,sizeof(g_status),"stopped");g_lua.pushstring(L,g_status);return 1;
}
int __cdecl lua_clear(lua_State*) {clear_frame();return 0;}
int __cdecl lua_begin(lua_State* L) {
    Frame empty_pending{};g_pending=empty_pending;
    const double index=g_lua.tonumber(L,1),id=g_lua.tonumber(L,2);
    if(std::isfinite(index)&&index>0&&index<kMaxIndex&&std::isfinite(id)&&id>0&&id<=4294967295.0) {
        g_pending.index=static_cast<DWORD>(index);g_pending.id=static_cast<DWORD>(id);
    }
    return 0;
}
int __cdecl lua_ring(lua_State* L) {
    if(g_pending.count>=kMaxRings || !g_pending.index || g_lua.gettop(L)<4)return 0;
    const double r=g_lua.tonumber(L,1),h=g_lua.tonumber(L,2),w=g_lua.tonumber(L,3),c=g_lua.tonumber(L,4);
    if(!std::isfinite(r)||!std::isfinite(h)||!std::isfinite(w)||!std::isfinite(c)
        ||r<.01||r>100||std::fabs(h)>1000||w<0||w>5||c<0||c>4294967295.0)return 0;
    const double pixels=g_lua.gettop(L)>=5?g_lua.tonumber(L,5):0;
    if(!std::isfinite(pixels)||pixels<0||pixels>64)return 0;
    g_pending.rings[g_pending.count++]={static_cast<float>(r),static_cast<float>(h),static_cast<float>(w),static_cast<DWORD>(c),static_cast<float>(pixels)};
    return 0;
}
int __cdecl lua_disc(lua_State* L) {
    if(!g_pending.index||g_pending.disc_count>=kMaxDiscs||g_lua.gettop(L)<5)return 0;
    const double r=g_lua.tonumber(L,1),h=g_lua.tonumber(L,2),a=g_lua.tonumber(L,3),c=g_lua.tonumber(L,4),g=g_lua.tonumber(L,5);
    if(!std::isfinite(r)||!std::isfinite(h)||!std::isfinite(a)||!std::isfinite(c)||!std::isfinite(g)
        ||r<.01||r>100||std::fabs(h)>1000||std::fabs(a)>1000000||c<0||c>4294967295.0)return 0;
    g_pending.discs[g_pending.disc_count++]={static_cast<float>(r),static_cast<float>(h),static_cast<float>(a),static_cast<DWORD>(c),g!=0};
    return 0;
}
int __cdecl lua_commit(lua_State*) {
    g_pending.tick=GetTickCount();
    AcquireSRWLockExclusive(&g_frame_lock);g_frame=g_pending;ReleaseSRWLockExclusive(&g_frame_lock);return 0;
}
int __cdecl lua_version(lua_State* L){g_lua.pushstring(L,"0.2.0");return 1;}
int __cdecl lua_status(lua_State* L) {
    char bus[224]{},report[768]{};scenehook_describe(g_bus,g_bus_slot,bus,sizeof(bus));
    Frame f{};AcquireSRWLockShared(&g_frame_lock);f=g_frame;ReleaseSRWLockShared(&g_frame_lock);
    std::snprintf(report,sizeof(report),"TargetSC 0.2.0 %s; frames=%ld draws=%ld device=%s entity_array=%s tracking_failures=%ld state_failures=%ld rings=%d discs=%d entity=%lu/index=%lu | %s",
        g_status,g_frames,g_draws,d3d_device_?"ready":"pending",g_entity_array?"ready":"pending",
        g_tracking_failures,g_state_failures,f.count,f.disc_count,static_cast<unsigned long>(f.id),static_cast<unsigned long>(f.index),bus);
    g_lua.pushstring(L,report);return 1;
}
bool bind_lua() {
    if (g_lua.ready()) {
        return true;
    }

    static char const* const hosts[] = {"LuaCore.dll", "lua51.dll", "lua5.1.dll"};
    for (char const* host : hosts) {
        HMODULE module = GetModuleHandleA(host);
        if (!module) {
            continue;
        }

        g_lua.createtable = reinterpret_cast<fn_createtable>(
            reinterpret_cast<void*>(GetProcAddress(module, "lua_createtable")));
        g_lua.pushcclosure = reinterpret_cast<fn_pushcclosure>(
            reinterpret_cast<void*>(GetProcAddress(module, "lua_pushcclosure")));
        g_lua.setfield = reinterpret_cast<fn_setfield>(
            reinterpret_cast<void*>(GetProcAddress(module, "lua_setfield")));
        g_lua.pushvalue = reinterpret_cast<fn_pushvalue>(
            reinterpret_cast<void*>(GetProcAddress(module, "lua_pushvalue")));
        g_lua.pushstring = reinterpret_cast<fn_pushstring>(
            reinterpret_cast<void*>(GetProcAddress(module, "lua_pushstring")));
        g_lua.gettop = reinterpret_cast<fn_gettop>(
            reinterpret_cast<void*>(GetProcAddress(module, "lua_gettop")));
        g_lua.tonumber = reinterpret_cast<fn_tonumber>(
            reinterpret_cast<void*>(GetProcAddress(module, "lua_tonumber")));

        if (g_lua.ready()) {
            return true;
        }
    }

    return false;
}

} // namespace
extern "C" __declspec(dllexport) int __cdecl luaopen__TargetSC(lua_State* L) {
    if(!bind_lua())return 0;
    build_tables();clear_frame();g_lua.createtable(L,0,9);
    struct Entry {char const* name;lua_CFunction fn;};
    const Entry entries[]={{"start",lua_start},{"stop",lua_stop},{"clear",lua_clear},{"begin",lua_begin},
        {"ring",lua_ring},{"disc",lua_disc},{"commit",lua_commit},{"status",lua_status},{"version",lua_version}};
    for(auto const& e:entries){g_lua.pushcclosure(L,e.fn,0);g_lua.setfield(L,-2,e.name);}
    return 1;
}
BOOL WINAPI DllMain(HINSTANCE module,DWORD reason,LPVOID) {
    if(reason==DLL_PROCESS_ATTACH)DisableThreadLibraryCalls(module);
    if(reason==DLL_PROCESS_DETACH){
        // Must run even after a Lua failure. No waiting under loader lock.
        scenehook_unregister(g_bus,g_bus_slot,false);g_bus_slot=-1;
    }
    return TRUE;
}
