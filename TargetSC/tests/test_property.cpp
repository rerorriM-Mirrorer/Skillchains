#include "../src/PropertyGeometry.h"
#include <cassert>
#include <cstdio>
int main() {
    const auto lines=targetsc::property_glyph();
    assert(lines.size()==28);
    int rim_endpoints=0,square_edges=0,star_tips=0;
    for(std::size_t i=0;i<lines.size();++i) {
        const auto line=lines[i];
        for(auto p:{line.a,line.b}) {
            assert(std::isfinite(p.x)&&std::isfinite(p.y));
            assert(std::hypot(p.x,p.y)<=1.00001f);
            if(std::hypot(p.x,p.y)>.999f)++rim_endpoints;
        }
        if(i<8 && std::hypot(line.a.x,line.a.y)>.77f)++star_tips;
        if(i>=24) {
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
    std::puts("PASS portable property geometry: border-reaching cross, four-point star, central square, transparent line geometry, complete sector coverage");
}
