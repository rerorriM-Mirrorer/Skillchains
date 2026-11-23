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
// 0.13.0: 16 outline segments + 4 square edges. The 4 short closing edges
// that ran along the circle at the cross-arm ends (the "cap lines") are gone.
constexpr int kGlyphLines=20;
// Largest segment-midpoint distance of the 0.12 glyph (its cap lines' midpoints
// on the circle). Kept so the 3D glyph's stagger keys (Umbra endings) do not move.
constexpr float kGlyph3KeyDistance=.99277f;
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
// Native 0.15.0 glyph shimmer: weight (0..1) of a glyph point at world angle
// `angle` for a bright patch centered on `center` with half-width `width`
// (radians), repeated `count` times around the circle: a cosine bell.
inline float shimmer_weight(float angle,float center,float width,int count) {
    constexpr float tau=6.28318530718f;
    count=count<1?1:(count>4?4:count);
    const float period=tau/static_cast<float>(count);
    float d=std::fmod(angle-center,period);
    if(d<0.f)d+=period;
    if(d>period*.5f)d=period-d;
    if(width<=0.f||d>=width)return 0.f;
    return .5f+.5f*std::cos(3.14159265359f*d/width);
}
// Shimmered stroke color: far side alpha x far; the patch whitens toward
// white by gain x w and raises alpha toward opaque by gain x w.
inline std::uint32_t shimmer_color(std::uint32_t base,float w,float rest,float gain) {
    const float a=static_cast<float>(base>>24)/255.f;
    const float k=gain*w;
    float alpha=a*(rest+(1.f-rest)*w);
    alpha=alpha+(1.f-alpha)*k;
    alpha=alpha<0.f?0.f:(alpha>1.f?1.f:alpha);
    const std::uint32_t rgb=lerp_argb(base|0xFF000000u,0xFFFFFFFFu,k)&0xFFFFFFu;
    return (static_cast<std::uint32_t>(alpha*255.f+.5f)<<24)|rgb;
}
// Native 0.16.0 ghost pass: a hidden part's color = alpha x k, same RGB.
inline std::uint32_t ghost_color(std::uint32_t c,float k) {
    k=k<0.f?0.f:(k>1.f?1.f:k);
    const std::uint32_t a=static_cast<std::uint32_t>(static_cast<float>(c>>24)*k+.5f);
    return (a<<24)|(c&0xFFFFFFu);
}
constexpr int kShimmerPieces=8; // each glyph line is cut into this many strokes

// Native 0.14.0 sliced center: the center corner of fan slice i (between rim
// vertices i and i+1) takes that slice's own gradient color, so a clear
// sector stays clear all the way in and lit sectors fade center -> rim.
inline std::uint32_t sliced_center(std::uint32_t const* palette,int sectors,int slice,int slices) {
    return gradient_at(palette,sectors,static_cast<float>(slice)+.5f,slices);
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
// Native 0.11.0 3D glyph (Umbra endings). Points are in glyph units (1 =
// the radius), z up from the glyph's plane. `tilt` stands the whole glyph up
// about its local x axis (gyroscope); per segment, `stand` (0..1) turns it up
// to vertical about its own midpoint (axis level and perpendicular to it),
// with every midpoint raised to lift x half the longest segment; `sink`
// (0..1, eased in) lowers it fully below the plane and `pull` moves its
// midpoint toward the center. `stagger` spreads each segment's start by its
// order key (0 together, 1 outer first, 2 inner first).
struct Point3 {float x,y,z;};
struct Glyph3Params {float tilt=0,stand=0,lift=1,sink=0,pull=0,stagger=0;int order=0;};
inline float glyph3_local(float progress,float key,float stagger) {
    stagger=stagger<0.f?0.f:(stagger>.95f?.95f:stagger);
    float t=(progress-key*stagger)/(1.f-stagger);
    return t<0.f?0.f:(t>1.f?1.f:t);
}
inline float glyph3_key(GlyphPoint mid,float max_distance,int order) {
    if(order==0||max_distance<=0.f)return 0.f;
    const float d=std::sqrt(mid.x*mid.x+mid.y*mid.y)/max_distance;
    return order==1?1.f-d:d;
}
inline Point3 glyph3_tilt(Point3 p,float tilt) {
    const float c=std::cos(tilt),s=std::sin(tilt);
    return {p.x,p.y*c-p.z*s,p.y*s+p.z*c};
}
// One segment's 3D ends. max_length / max_distance describe the whole glyph.
inline void glyph3_segment(GlyphLine line,Glyph3Params const& g,float max_length,float max_distance,Point3& a,Point3& b) {
    const GlyphPoint mid{(line.a.x+line.b.x)*.5f,(line.a.y+line.b.y)*.5f};
    const float hx=(line.b.x-line.a.x)*.5f,hy=(line.b.y-line.a.y)*.5f;
    const float half=std::sqrt(hx*hx+hy*hy);
    const float key=glyph3_key(mid,max_distance,g.order);
    const float s=glyph3_local(g.stand,key,g.stagger);
    float q=glyph3_local(g.sink,key,g.stagger);q*=q; // pulled: accelerates
    const float angle=s*1.57079632679f;
    const float raise=s*g.lift*max_length*.5f;
    const float depth=g.lift*max_length*.5f+half+.02f;
    const float pull=1.f-g.pull*q;
    const Point3 m{mid.x*pull,mid.y*pull,raise-q*depth};
    const float c=std::cos(angle),up=std::sin(angle)*half;
    a=glyph3_tilt({m.x-hx*c,m.y-hy*c,m.z-up},g.tilt);
    b=glyph3_tilt({m.x+hx*c,m.y+hy*c,m.z+up},g.tilt);
}
// Keep only the part of a-b with z >= 0; false if none remains.
inline bool glyph3_clip(Point3& a,Point3& b) {
    if(a.z<0.f&&b.z<0.f)return false;
    if(a.z>=0.f&&b.z>=0.f)return true;
    const float t=a.z/(a.z-b.z);
    const Point3 cut{a.x+(b.x-a.x)*t,a.y+(b.y-a.y)*t,0.f};
    if(a.z<0.f)a=cut;else b=cut;
    return true;
}
// 0.13.0 half-plane clip (SC kill halves): keep the part of a-b where
// p.x*nx+p.y*ny >= 0 (points already rotated into the disc's frame); false if
// none remains.
inline bool half_clip(GlyphPoint& a,GlyphPoint& b,float nx,float ny) {
    const float da=a.x*nx+a.y*ny,db=b.x*nx+b.y*ny;
    if(da<0.f&&db<0.f)return false;
    if(da>=0.f&&db>=0.f)return true;
    const float t=da/(da-db);
    const GlyphPoint cut{a.x+(b.x-a.x)*t,a.y+(b.y-a.y)*t};
    if(da<0.f)a=cut;else b=cut;
    return true;
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
    // Each arm's outline as an open path: no closing edge along the circle.
    auto arm=[&](GlyphPoint const* p,int n) {
        for(int i=0;i+1<n;++i)lines[count++]={p[i],p[i+1]};
    };
    // Trace the union of the diagonal star and wider cross, retaining only
    // its exterior boundary. These are the exact approved Lua preview points.
    const float tip=.78f/std::sqrt(2.f);
    const float valley=.18f,half_width=.12f;
    const float edge=std::sqrt(1.f-half_width*half_width);
    const float join=valley+(tip-valley)*half_width/tip;
    const GlyphPoint quarter[5]={{half_width,edge},{half_width,join},
        {tip,tip},{join,half_width},{edge,half_width}};
    // Quarter k runs from one arm's side edge (on the circle) to the next
    // arm's side edge. The 0.12 glyph also joined quarter k's last point to
    // quarter k+1's first: a short chord along the circle at each arm end.
    // 0.13.0 draws each quarter as an open path, so those chords are gone.
    for(int turn=0;turn<4;++turn) {
        GlyphPoint q[5]{};
        for(int i=0;i<5;++i) {
            auto p=quarter[i];
            for(int j=0;j<turn;++j){const float x=p.x;p.x=p.y;p.y=-x;}
            q[i]=p;
        }
        arm(q,5);
    }
    const GlyphPoint square[4]={{-.15f,-.15f},{.15f,-.15f},{.15f,.15f},{-.15f,.15f}};
    polygon(square,4);
    return lines;
}
}
