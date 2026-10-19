// Projection-aware screen stroke math, shared with the portable geometry test.
// Author: A. No platform, game or graphics-device dependency.
#pragma once
#include <algorithm>
#include <cmath>
namespace targetsc {
struct Vec2 {float x,y;};
inline Vec2 stroke_offset(Vec2 previous,Vec2 point,Vec2 next,float half_width) {
    float ax=point.x-previous.x,ay=point.y-previous.y;
    float bx=next.x-point.x,by=next.y-point.y;
    const float al=std::hypot(ax,ay),bl=std::hypot(bx,by);
    if(al<.0001f && bl<.0001f)return {0,0};
    if(al<.0001f){ax=bx;ay=by;} if(bl<.0001f){bx=ax;by=ay;}
    const float aa=std::hypot(ax,ay),bb=std::hypot(bx,by);
    ax/=aa;ay/=aa;bx/=bb;by/=bb;
    float nx=-ay-by,ny=ax+bx;
    const float nl=std::hypot(nx,ny);
    if(nl<.0001f)return {-by*half_width,bx*half_width};
    nx/=nl;ny/=nl;
    // Bound the miter for near-edge-on/cusped projections; never emit a spike.
    const float projection=std::max(.5f,std::fabs(nx*(-by)+ny*bx));
    const float scale=half_width/projection;
    return {nx*scale,ny*scale};
}
inline float visible_width(float projected_world_width,float pixels) {
    return std::max(std::max(0.f,projected_world_width),std::max(0.f,pixels));
}
}
