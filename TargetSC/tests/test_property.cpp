#include "../src/PropertyGeometry.h"
#include <cassert>
#include <cmath>
#include <cstdlib>
#include <cstdint>
#include <cstdio>
int main() {
    constexpr float tau=6.28318530718f;
    auto degrees=[](int i){return targetsc::ring_angle(i,64,12)*360/6.28318530718f;};
    assert(std::fabs(degrees(0)-6)<.0001f && std::fabs(degrees(32)-174)<.0001f);
    assert(std::fabs(degrees(33)-186)<.0001f && std::fabs(degrees(65)-354)<.0001f);
    assert(std::fabs(degrees(33)-degrees(32)-12)<.0001f);
    assert(std::fabs(360-degrees(65)+degrees(0)-12)<.0001f);
    for(int i=1;i<66;++i)assert(targetsc::ring_angle(i,64,12)>targetsc::ring_angle(i-1,64,12));
    for(int i=0;i<=32;++i)assert(std::fabs(targetsc::ring_angle(i+33,64,12)-targetsc::ring_angle(i,64,12)-tau/2)<.00001f);
    const auto lines=targetsc::property_glyph();
    // 0.13.0: four open arm paths (4 segments each, chained, starting and
    // ending on the circle) + the central square; no cap line along the rim.
    assert(lines.size()==20);
    int rim_endpoints=0,square_edges=0,star_tips=0;
    for(std::size_t i=0;i<lines.size();++i) {
        const auto line=lines[i];
        int on_rim=0;
        for(auto p:{line.a,line.b}) {
            assert(std::isfinite(p.x)&&std::isfinite(p.y));
            assert(std::hypot(p.x,p.y)<=1.00001f);
            if(std::hypot(p.x,p.y)>.999f){++rim_endpoints;++on_rim;}
        }
        assert(on_rim<2); // the removed cap lines were the only rim-to-rim segments
        if(i<16) {
            if(i%4!=3){const auto next=lines[i+1];assert(line.b.x==next.a.x && line.b.y==next.a.y);}
            if(i%4==0)assert(std::hypot(line.a.x,line.a.y)>.999f);
            if(i%4==3)assert(std::hypot(line.b.x,line.b.y)>.999f);
            assert(std::max(std::fabs(line.a.x),std::fabs(line.a.y))>.15f);
            if(std::hypot(line.a.x,line.a.y)>.77f &&
               std::hypot(line.a.x,line.a.y)<.79f) {
                assert(std::fabs(std::fabs(line.a.x)-std::fabs(line.a.y))<.00001f);
                ++star_tips;
            }
        } else {
            assert(std::fabs(std::fabs(line.a.x)-.15f)<.00001f);
            assert(std::fabs(std::fabs(line.a.y)-.15f)<.00001f);
            ++square_edges;
        }
    }
    assert(rim_endpoints==8 && square_edges==4 && star_tips==4);
    // 0.13.0 half-plane clip.
    {
        targetsc::GlyphPoint a{-1,0},b{1,0};
        assert(targetsc::half_clip(a,b,1,0)&&a.x==0.f&&b.x==1.f);      // cut at the line
        targetsc::GlyphPoint c{-1,.5f},d{-.2f,.5f};
        assert(!targetsc::half_clip(c,d,1,0));                         // wholly on the far side
        targetsc::GlyphPoint e{.1f,-1},f{.3f,1};
        assert(targetsc::half_clip(e,f,1,0)&&e.x==.1f&&f.x==.3f);      // wholly kept
        targetsc::GlyphPoint g{0,-1},h{0,1};
        assert(targetsc::half_clip(g,h,0,1)&&std::fabs(g.y)<1e-6f&&h.y==1.f); // north half
    }
    for(int sectors=1;sectors<=4;++sectors) {
        int counts[4]{};
        for(int slice=0;slice<64;++slice) {
            const int index=targetsc::sector_index(slice,64,sectors);
            assert(index>=0 && index<sectors);++counts[index];
        }
        for(int i=0;i<sectors;++i)assert(counts[i]>=64/sectors && counts[i]<=64/sectors+1);
    }
    assert(targetsc::sector_index(31,64,2)==0 && targetsc::sector_index(32,64,2)==1);
    // 0.9.0 section arcs: lead color at the bright end, tail color at the tip.
    {
        const int P=33;
        const std::uint32_t lead=0xFFFFFFFFu,tail=0xFFFF0000u;
        assert(targetsc::arc_color(lead,tail,P-1,P,0.f,1.f,1.f,1)==lead);           // bright lead end
        assert((targetsc::arc_color(lead,tail,0,P,0.f,1.f,1.f,1)&0x00FFFFFFu)==0x00FF0000u); // tip = tail rgb
        assert((targetsc::arc_color(lead,tail,0,P,1.f,1.f,1.f,1)>>24)==0u);         // fade 1: tip transparent
        assert((targetsc::arc_color(lead,tail,0,P,.5f,1.f,1.f,1)>>24)==0x80u);      // fade .5: half alpha
        assert(targetsc::arc_color(lead,tail,0,P,0.f,1.f,1.f,-1)==lead);            // trail mode flips ends
        assert(targetsc::arc_shape(P-1,P,1.f,1.f,1)==0.f && targetsc::arc_shape(0,P,1.f,1.f,1)==1.f);
        // length .4: the bright 60% keeps the pure lead color at full alpha.
        for(int at=0;at<P;++at){const float d=1.f-static_cast<float>(at)/(P-1);
            if(d<=.6f)assert(targetsc::arc_color(lead,tail,at,P,1.f,.4f,1.f,1)==lead);}
        assert(targetsc::arc_fade(5,P,.7f,.8f,1.5f,1)==1.f-.7f*targetsc::arc_shape(5,P,.8f,1.5f,1));
    }
    // 0.8.0 opener arc fade along each open arc.
    {
        const int P=33;
        assert(targetsc::arc_fade(0,P,0.f,1.f,1.f,1)==1.f);              // off
        assert(std::fabs(targetsc::arc_fade(P-1,P,.6f,1.f,1.f,1)-1.f)<1e-6f); // bright lead end
        assert(std::fabs(targetsc::arc_fade(0,P,.6f,1.f,1.f,1)-.4f)<1e-6f);  // tip = 1-fade
        assert(std::fabs(targetsc::arc_fade(0,P,.6f,1.f,1.f,-1)-1.f)<1e-6f); // trail mode flips
        assert(std::fabs(targetsc::arc_fade(P-1,P,.6f,1.f,1.f,-1)-.4f)<1e-6f);
        // length .4: the bright 60% stays full.
        for(int at=P-1;at>=0;--at) {
            const float d=1.f-static_cast<float>(at)/(P-1);
            const float k=targetsc::arc_fade(at,P,1.f,.4f,1.f,1);
            if(d<=.6f)assert(k==1.f);
            assert(k>=0.f&&k<=1.f);
        }
        // monotone from bright end to tip; curve >1 stays brighter midway.
        float prev=2.f;
        for(int at=P-1;at>=0;--at){const float k=targetsc::arc_fade(at,P,.8f,1.f,1.f,1);assert(k<=prev+1e-6f);prev=k;}
        assert(targetsc::arc_fade(16,P,.8f,1.f,2.f,1)>targetsc::arc_fade(16,P,.8f,1.f,1.f,1));
        assert(targetsc::arc_fade(16,P,.8f,1.f,.5f,1)<targetsc::arc_fade(16,P,.8f,1.f,1.f,1));
    }
    // 0.7.0 radial fills scale only alpha, clamped to 0..1.
    {
        assert(targetsc::scale_alpha(0x80FF00FFu,1.f)==0x80FF00FFu);
        assert(targetsc::scale_alpha(0x80FF00FFu,0.f)==0x00FF00FFu);
        assert(targetsc::scale_alpha(0xFF123456u,.5f)==0x80123456u);
        assert(targetsc::scale_alpha(0xFF123456u,2.f)==0xFF123456u);
        assert(targetsc::scale_alpha(0xFF123456u,-1.f)==0x00123456u);
        // 0.11.0 3D glyph: flat at rest; standing turns a segment vertical
        // about its midpoint at lift x half the longest; sinking takes it
        // fully below the plane; clipping keeps z >= 0; tilt stands it up.
        {
            const targetsc::GlyphLine line{{.2f,0.f},{.6f,0.f}};
            targetsc::Glyph3Params g;targetsc::Point3 a{},b{};
            targetsc::glyph3_segment(line,g,.8f,1.f,a,b);
            assert(std::fabs(a.z)<1e-6f&&std::fabs(b.z)<1e-6f&&std::fabs(a.x-.2f)<1e-6f&&std::fabs(b.x-.6f)<1e-6f);
            g.stand=1.f;targetsc::glyph3_segment(line,g,.8f,1.f,a,b);
            assert(std::fabs(a.x-.4f)<1e-5f&&std::fabs(b.x-.4f)<1e-5f);          // vertical at the midpoint
            assert(std::fabs((a.z+b.z)*.5f-.4f)<1e-5f&&std::fabs(b.z-a.z-.4f)<1e-5f); // centered at .4, length .4
            g.sink=1.f;targetsc::glyph3_segment(line,g,.8f,1.f,a,b);
            assert(a.z<0.f&&b.z<0.f);auto ca=a,cb=b;assert(!targetsc::glyph3_clip(ca,cb)); // fully swallowed
            g.sink=.5f;g.pull=1.f;targetsc::glyph3_segment(line,g,.8f,1.f,a,b);
            assert(a.x<.4f&&a.x>0.f);                                              // pulled toward the center
            auto pa=a,pb=b;if(targetsc::glyph3_clip(pa,pb))assert(pa.z>=0.f&&pb.z>=0.f);
            targetsc::Point3 u{0,0,-1},v{0,0,1};assert(targetsc::glyph3_clip(u,v)&&std::fabs(u.z)<1e-6f);
            targetsc::Glyph3Params t;t.tilt=1.57079632679f;
            targetsc::glyph3_segment({{0.f,.5f},{0.f,1.f}},t,.8f,1.f,a,b);
            assert(std::fabs(a.y)<1e-5f&&std::fabs(a.z-.5f)<1e-5f&&std::fabs(b.z-1.f)<1e-5f); // stood upright
            // Stagger: outer-first segments start before inner ones.
            assert(targetsc::glyph3_local(.5f,0.f,.5f)>targetsc::glyph3_local(.5f,1.f,.5f));
            assert(targetsc::glyph3_key({1.f,0.f},1.f,1)==0.f&&targetsc::glyph3_key({0.f,0.f},1.f,1)==1.f);
        }
        // 0.10.0 middle radial stop: straight blend of unscaled center/rim
        // at the stop position, then its own alpha multiplier.
        assert(targetsc::radial_mid(0xFFFFFFFFu,0x00FF0000u,0.f,1.f)==0xFFFFFFFFu);
        assert(targetsc::radial_mid(0xFFFFFFFFu,0x00FF0000u,1.f,1.f)==0x00FF0000u);
        assert(targetsc::radial_mid(0xFF00FF00u,0xFF0000FFu,.5f,1.f)==0xFF008080u);
        assert(targetsc::radial_mid(0xFF00FF00u,0xFF0000FFu,.5f,.5f)==0x80008080u);
        assert(targetsc::radial_mid(0xFF00FF00u,0xFF0000FFu,.5f,0.f)==0x00008080u);
        assert(targetsc::radial_mid(0xFF00FF00u,0xFF0000FFu,2.f,1.f)==0xFF0000FFu);
    }
    // 0.6.0 gradient discs: pure color at each sector centre, smooth and
    // continuous around the rim, hub = average, alpha preserved.
    {
        const std::uint32_t pal[]={0xFF0000FFu,0x80FF0000u,0xFF00FF00u,0xFFFFFFFFu};
        assert(targetsc::lerp_argb(pal[0],pal[1],0.f)==pal[0]);
        assert(targetsc::lerp_argb(pal[0],pal[1],1.f)==pal[1]);
        // Two sectors: centres are slices 16 and 48 of 64 (± half a slice).
        const auto a=targetsc::gradient_at(pal,2,16.f,64),b=targetsc::gradient_at(pal,2,48.f,64);
        auto channel=[](std::uint32_t c,int s){return static_cast<int>((c>>s)&0xFFu);};
        assert(channel(a,0)>=250 && channel(a,16)<=5);  // near pure blue
        assert(channel(b,16)>=250 && channel(b,0)<=5);  // near pure red
        assert(channel(b,24)<=0x82 && channel(a,24)>=0xFD); // alpha blends too
        for(int sectors=2;sectors<=4;++sectors)for(int i=0;i<64;++i) {
            const auto c0=targetsc::gradient_color(pal,sectors,i,64),c1=targetsc::gradient_color(pal,sectors,(i+1)%64,64);
            for(int sh=0;sh<32;sh+=8)assert(std::abs(channel(c0,sh)-channel(c1,sh))<=48); // no hard edge
        }
        const auto avg=targetsc::average_color(pal,2);
        assert(channel(avg,0)==128 && channel(avg,16)==128 && channel(avg,24)==0xC0);
        assert(targetsc::gradient_color(pal,1,7,64)==pal[0]);
    }
    {
        // 0.14.0 sliced center: opposite lit quarters {A,clear,B,clear}. Each
        // slice's center corner is its own gradient color: full A at the A
        // sector's middle, clear at the clear sectors' middles (no shared
        // averaged center), B opposite A.
        const std::uint32_t A=0xFFFF8000u,B=0xFF000000u,clear=0x00808080u;
        const std::uint32_t pal[4]={A,clear,B,clear};
        const int slices=64;
        auto alpha=[](std::uint32_t c){return c>>24;};
        // Sector k's pure color sits at slice position k*16+8 (vertex units).
        assert(targetsc::sliced_center(pal,4,8,slices)>>24>=0xF0u);
        assert(alpha(targetsc::sliced_center(pal,4,24,slices))<=0x10u);
        assert((targetsc::sliced_center(pal,4,40,slices)&0xFFFFFFu)<=0x0A0A0Au && alpha(targetsc::sliced_center(pal,4,40,slices))>=0xF0u);
        assert(alpha(targetsc::sliced_center(pal,4,56,slices))<=0x10u);
        // Unlike the averaged center (alpha ~ half everywhere).
        assert(alpha(targetsc::average_color(pal,4))>0x70u && alpha(targetsc::average_color(pal,4))<0x90u);
        // Matches the rim gradient halfway between the slice's two vertices.
        for(int i=0;i<slices;++i)assert(targetsc::sliced_center(pal,4,i,slices)==targetsc::gradient_at(pal,4,i+.5f,slices));
    }
    {
        // 0.15.0 glyph shimmer: cosine bell around the patch angle, wrapping;
        // count repeats it; the far side keeps alpha x rest; the patch goes
        // toward white and opaque by gain.
        const float pi=3.14159265f;
        assert(std::fabs(targetsc::shimmer_weight(1.f,1.f,.8f,1)-1.f)<1e-5f);
        assert(targetsc::shimmer_weight(1.f+.8f,1.f,.8f,1)<1e-5f);
        assert(std::fabs(targetsc::shimmer_weight(1.f+.4f,1.f,.8f,1)-.5f)<1e-4f);
        assert(std::fabs(targetsc::shimmer_weight(-pi+.05f,pi-.05f,.8f,1)-targetsc::shimmer_weight(.1f,0.f,.8f,1))<1e-4f); // wraps
        assert(targetsc::shimmer_weight(1.f+pi,1.f,.8f,1)<1e-5f && targetsc::shimmer_weight(1.f+pi,1.f,.8f,2)>.999f); // count 2
        assert(targetsc::shimmer_weight(0.f,0.f,0.f,1)==0.f);
        const std::uint32_t base=0x99FF8000u; // alpha .6
        const auto far_c=targetsc::shimmer_color(base,0.f,.25f,1.f);
        assert((far_c>>24)==static_cast<std::uint32_t>(.6f*.25f*255.f+.5f) && (far_c&0xFFFFFFu)==0xFF8000u);
        const auto hot=targetsc::shimmer_color(base,1.f,.25f,1.f);
        assert(hot==0xFFFFFFFFu);
        const auto plain=targetsc::shimmer_color(base,1.f,.25f,0.f);
        assert(plain==base);
        const auto half=targetsc::shimmer_color(base,.5f,1.f,.5f); // alpha .6 -> .6+.4*.25 = .7
        assert(((half>>24)>=0xB1u)&&((half>>24)<=0xB4u));
    }
    std::puts("PASS portable property geometry: traced wide cross, diagonal four-point star, central square, transparent line geometry, complete sector coverage");
}
