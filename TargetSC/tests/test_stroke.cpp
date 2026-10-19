#include "../src/StrokeGeometry.h"
#include <cassert>
#include <cmath>
#include <cstdio>
int main(){
    using targetsc::Vec2;
    assert(targetsc::visible_width(.001f,1.f)==1.f);
    assert(targetsc::visible_width(.1f,2.f)==2.f);
    assert(targetsc::visible_width(3.f,2.f)==3.f);
    for(float flat:{1.f,.1f,.01f,.001f})for(float radius:{2.f,20.f,1000.f})for(int i=0;i<64;++i){
        const float a=i*6.28318530718f/64,delta=6.28318530718f/64;
        Vec2 p{std::cos(a)*radius,std::sin(a)*radius*flat};
        Vec2 before{std::cos(a-delta)*radius,std::sin(a-delta)*radius*flat};
        Vec2 after{std::cos(a+delta)*radius,std::sin(a+delta)*radius*flat};
        for(float width:{1.f,2.f,8.f}){
            const auto d=targetsc::stroke_offset(before,p,after,width*.5f);
            assert(std::isfinite(d.x)&&std::isfinite(d.y));
            assert(std::hypot(d.x,d.y)<=width*1.001f);
            if(flat==1.f)assert(std::hypot(d.x,d.y)>=width*.5f);
        }
    }
    auto d=targetsc::stroke_offset({0,0},{0,0},{0,0},1);
    assert(d.x==0&&d.y==0);
    std::puts("PASS native stroke geometry: 2304 projected ellipse/width cases, one/two/eight-pixel floors, bounded miter, degenerate points");
}
