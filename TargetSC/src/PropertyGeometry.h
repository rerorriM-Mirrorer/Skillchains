// Normalized property glyph and sector selection shared with CPU tests.
// Circle rim is emitted separately by the projection-aware ring path. Author: A.
#pragma once
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
// An open ring has 65 points and 64 segments. Distribute the visible arc
// between exact gap endpoints; no segment crosses the opening.
inline float ring_angle(int point,int slices,float gap_degrees) {
    constexpr float tau=6.28318530718f;
    const float gap=gap_degrees*tau/360.f;
    return gap*.5f+point*(tau-gap)/slices;
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
