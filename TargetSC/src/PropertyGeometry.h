// Normalized property glyph and sector selection shared with CPU tests.
// Circle rim is emitted separately by the projection-aware ring path. Author: A.
#pragma once
#include <cstdint>
#include <array>
#include <algorithm>
#include <cmath>
namespace targetsc {
struct GlyphPoint {float x,y;};
struct GlyphLine {GlyphPoint a,b;};
constexpr int kGlyphLines=24;
inline int sector_index(int slice,int slices,int sectors) {
    return std::min(sectors-1,std::max(0,slice)*sectors/std::max(1,slices));
}
// Native 0.6.0 gradient discs. Sector k's pure color sits at the centre of
// the arc sector_index() would give it; between centres the rim blends with
// a smoothstep, wrapping cyclically. Works on packed ARGB channel by channel.
inline std::uint32_t lerp_argb(std::uint32_t a,std::uint32_t b,float t) {
    std::uint32_t out=0;
    for(int shift=0;shift<32;shift+=8) {
        const float ca=static_cast<float>((a>>shift)&0xFFu),cb=static_cast<float>((b>>shift)&0xFFu);
        const float v=ca+(cb-ca)*t+.5f;
        out|=(static_cast<std::uint32_t>(v<0.f?0.f:(v>255.f?255.f:v))&0xFFu)<<shift;
    }
    return out;
}
inline std::uint32_t gradient_color(std::uint32_t const* palette,int sectors,int slice,int slices) {
    sectors=std::max(1,std::min(4,sectors));
    if(sectors==1)return palette[0];
    const float p=(static_cast<float>(slice)+.5f)*sectors/std::max(1,slices)-.5f;
    const float wrapped=p<0.f?p+sectors:p;
    const int k=static_cast<int>(wrapped)%sectors;
    float t=wrapped-static_cast<float>(static_cast<int>(wrapped));
    t=t*t*(3.f-2.f*t);
    return lerp_argb(palette[k],palette[(k+1)%sectors],t);
}
inline std::uint32_t average_color(std::uint32_t const* palette,int sectors) {
    sectors=std::max(1,std::min(4,sectors));
    std::uint32_t out=0;
    for(int shift=0;shift<32;shift+=8) {
        unsigned sum=0;for(int k=0;k<sectors;++k)sum+=(palette[k]>>shift)&0xFFu;
        out|=((sum+sectors/2)/sectors&0xFFu)<<shift;
    }
    return out;
}
// Two opposite gaps split the ring into equal 32-segment open arcs.
// Points 0..32 describe the first arc; 33..65 describe the opposite arc.
inline float ring_angle(int point,int slices,float gap_degrees) {
    constexpr float pi=3.14159265359f;
    const float gap=gap_degrees*pi/180.f;
    const int points_per_arc=slices/2+1;
    const int arc=point/points_per_arc,at=point%points_per_arc;
    return gap*.5f+arc*pi+at*(pi-gap)/(slices/2);
}
inline std::array<GlyphLine,kGlyphLines> property_glyph() {
    std::array<GlyphLine,kGlyphLines> lines{};
    int count=0;
    auto polygon=[&](GlyphPoint const* p,int n) {
        for(int i=0;i<n;++i)lines[count++]={p[i],p[(i+1)%n]};
    };
    // Trace the union of the diagonal star and wider cross, retaining only
    // its exterior boundary. These are the exact approved Lua preview points.
    const float tip=.78f/std::sqrt(2.f);
    const float valley=.18f,half_width=.12f;
    const float edge=std::sqrt(1.f-half_width*half_width);
    const float join=valley+(tip-valley)*half_width/tip;
    const GlyphPoint quarter[5]={{half_width,edge},{half_width,join},
        {tip,tip},{join,half_width},{edge,half_width}};
    GlyphPoint silhouette[20]{};
    for(int turn=0;turn<4;++turn)for(int i=0;i<5;++i) {
        auto p=quarter[i];
        for(int j=0;j<turn;++j){const float x=p.x;p.x=p.y;p.y=-x;}
        silhouette[turn*5+i]=p;
    }
    polygon(silhouette,20);
    const GlyphPoint square[4]={{-.15f,-.15f},{.15f,-.15f},{.15f,.15f},{-.15f,.15f}};
    polygon(square,4);
    return lines;
}
}
