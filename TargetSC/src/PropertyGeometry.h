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
// position is measured in slices around the circle (vertex i sits at i).
inline std::uint32_t gradient_at(std::uint32_t const* palette,int sectors,float position,int slices) {
    sectors=std::max(1,std::min(4,sectors));
    if(sectors==1)return palette[0];
    const float p=position*sectors/std::max(1,slices)-.5f;
    const float wrapped=p<0.f?p+sectors:p;
    const int k=static_cast<int>(wrapped)%sectors;
    float t=wrapped-static_cast<float>(static_cast<int>(wrapped));
    t=t*t*(3.f-2.f*t);
    return lerp_argb(palette[k],palette[(k+1)%sectors],t);
}
inline std::uint32_t gradient_color(std::uint32_t const* palette,int sectors,int slice,int slices) {
    return gradient_at(palette,sectors,static_cast<float>(slice)+.5f,slices);
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
// Native 0.7.0 radial fills: multiply only the alpha byte (0..1), keeping RGB.
// Templated so DWORD (unsigned long on Win32) and uint32_t both work.
template<class C> inline C scale_alpha(C color,float k) {
    k=k<0.f?0.f:(k>1.f?1.f:k);
    const float a=static_cast<float>((static_cast<std::uint32_t>(color)>>24)&0xFFu)*k+.5f;
    const std::uint32_t alpha=static_cast<std::uint32_t>(a>255.f?255.f:a);
    return static_cast<C>((static_cast<std::uint32_t>(color)&0x00FFFFFFu)|(alpha<<24));
}
// Native 0.10.0 three-stop radial fill: the optional middle ring sits at
// `position` (0..1 of the radius). Its RGBA is the straight blend of the
// unscaled center and rim colors there, with alpha then multiplied by `mid`
// (center/rim keep their own inner/outer multipliers).
template<class C> inline C radial_mid(C center,C rim,float position,float mid) {
    position=position<0.f?0.f:(position>1.f?1.f:position);
    return scale_alpha(static_cast<C>(lerp_argb(static_cast<std::uint32_t>(center),
        static_cast<std::uint32_t>(rim),position)),mid);
}
// Native 0.8.0 opener arc fade. at = point index within one open arc
// (0..points-1, angle increasing). direction +1 keeps the high-angle end
// (the end facing a positive rotation) bright; -1 the other end. The fade
// covers the far `length` fraction of the arc, shaped by `curve` (1 even,
// >1 holds brightness longer, <1 drops early), reaching 1-fade at the tip.
// 0 at the bright end .. 1 at the tip, over the far `length`, shaped by curve.
inline float arc_shape(int at,int points,float length,float curve,int direction) {
    if(points<2)return 0.f;
    const float u=static_cast<float>(at)/static_cast<float>(points-1);
    const float d=direction<0?u:1.f-u; // distance from the bright end, 0..1
    length=length<.01f?.01f:(length>1.f?1.f:length);
    const float t=(d-(1.f-length))/length;
    if(t<=0.f)return 0.f;
    return std::pow(t>1.f?1.f:t,curve);
}
inline float arc_fade(int at,int points,float fade,float length,float curve,int direction) {
    if(fade<=0.f||points<2)return 1.f;
    const float k=1.f-(fade>1.f?1.f:fade)*arc_shape(at,points,length,curve,direction);
    return k<0.f?0.f:k;
}
// 0.9.0 section arcs: lead color at the bright end blending to the tail
// color along the same shaped path; alpha fades by `fade` along it too.
inline std::uint32_t arc_color(std::uint32_t lead,std::uint32_t tail,int at,int points,
    float fade,float length,float curve,int direction) {
    const float shaped=arc_shape(at,points,length,curve,direction);
    const std::uint32_t mixed=lerp_argb(lead,tail,shaped);
    return scale_alpha(mixed,1.f-(fade<0.f?0.f:(fade>1.f?1.f:fade))*shaped);
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
