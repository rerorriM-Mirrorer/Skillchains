#include "../src/PropertyGeometry.h"
#include <cassert>
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
    assert(lines.size()==24);
    int rim_endpoints=0,square_edges=0,star_tips=0;
    for(std::size_t i=0;i<lines.size();++i) {
        const auto line=lines[i];
        for(auto p:{line.a,line.b}) {
            assert(std::isfinite(p.x)&&std::isfinite(p.y));
            assert(std::hypot(p.x,p.y)<=1.00001f);
            if(std::hypot(p.x,p.y)>.999f)++rim_endpoints;
        }
        if(i<20) {
            const auto next=lines[(i+1)%20];
            assert(line.b.x==next.a.x && line.b.y==next.a.y);
            assert(std::max(std::fabs(line.a.x),std::fabs(line.a.y))>.15f);
            if(std::hypot(line.a.x,line.a.y)>.77f &&
               std::hypot(line.a.x,line.a.y)<.79f) {
                assert(std::fabs(std::fabs(line.a.x)-std::fabs(line.a.y))<.00001f);
                ++star_tips;
            }
        }
        if(i>=20) {
            assert(std::fabs(std::fabs(line.a.x)-.15f)<.00001f);
            assert(std::fabs(std::fabs(line.a.y)-.15f)<.00001f);
            ++square_edges;
        }
    }
    assert(rim_endpoints==16 && square_edges==4 && star_tips==4);
    for(int sectors=1;sectors<=4;++sectors) {
        int counts[4]{};
        for(int slice=0;slice<64;++slice) {
            const int index=targetsc::sector_index(slice,64,sectors);
            assert(index>=0 && index<sectors);++counts[index];
        }
        for(int i=0;i<sectors;++i)assert(counts[i]>=64/sectors && counts[i]<=64/sectors+1);
    }
    assert(targetsc::sector_index(31,64,2)==0 && targetsc::sector_index(32,64,2)==1);
    std::puts("PASS portable property geometry: traced wide cross, diagonal four-point star, central square, transparent line geometry, complete sector coverage");
}
