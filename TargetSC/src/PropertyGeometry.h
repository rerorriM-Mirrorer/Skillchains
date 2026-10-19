// Normalized property glyph and sector selection shared with CPU tests.
// Circle rim is emitted separately by the projection-aware ring path. Author: A.
#pragma once
#include <array>
#include <algorithm>
#include <cmath>
namespace targetsc {
struct GlyphPoint {float x,y;};
struct GlyphLine {GlyphPoint a,b;};
constexpr int kGlyphLines=28;
inline int sector_index(int slice,int slices,int sectors) {
    return std::min(sectors-1,std::max(0,slice)*sectors/std::max(1,slices));
}
inline std::array<GlyphLine,kGlyphLines> property_glyph() {
    std::array<GlyphLine,kGlyphLines> lines{};
    int count=0;
    auto polygon=[&](GlyphPoint const* p,int n) {
        for(int i=0;i<n;++i)lines[count++]={p[i],p[(i+1)%n]};
    };
    // The pointed star is NOT a substitute for the full border-reaching cross.
    GlyphPoint star[8]{};
    for(int i=0;i<8;++i) {
        const float a=i*6.28318530718f/8;
        const float r=(i&1)? .18f:.78f;
        star[i]={std::cos(a)*r,std::sin(a)*r};
    }
    polygon(star,8);
    const float edge=std::sqrt(1.f-.045f*.045f);
    for(int arm=0;arm<4;++arm) {
        GlyphPoint cross[4]={{.15f,-.045f},{edge,-.045f},{edge,.045f},{.15f,.045f}};
        for(auto& p:cross)for(int j=0;j<arm;++j){const float x=p.x;p.x=-p.y;p.y=x;}
        polygon(cross,4);
    }
    const GlyphPoint square[4]={{-.15f,-.15f},{.15f,-.15f},{.15f,.15f},{-.15f,.15f}};
    polygon(square,4);
    return lines;
}
}
