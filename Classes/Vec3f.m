//
//  Vec3f.m
//  Particles
//
//  Created by Robert Hodgin on 1/12/09.
//  Copyright 2009 Gentleman's Cupboard. All rights reserved.
//

#import "Vec3f.h"

@implementation Vec3f

@synthesize x;
@synthesize y;
@synthesize z;


-(id) init {
	if( self = [super init] ) {
		x = y = z = 0.0;
	}
	return (self);
}

-(id) initWithX: (float) aX y: (float) aY z: (float) aZ {
	if( self = [self init] ){		
		x = aX;
		y = aY;
		z = aZ;
	}
	return (self);
}


- (Vec3f *) addv: (Vec3f *) v {
	Vec3f * newVec = [[Vec3f alloc] initWithX:(x + v.x) y:(y + v.y) z:(z + v.z)];
	return ([newVec autorelease]);
}

- (Vec3f *) subv: (Vec3f *) v {
	Vec3f * newVec = [[Vec3f alloc] initWithX:(x - v.x) y:(y - v.y) z:(z - v.z)];
	return ([newVec autorelease]);
}

- (Vec3f *) multv: (Vec3f *) v {
	Vec3f * newVec = [[Vec3f alloc] initWithX:(x * v.x) y:(y * v.y) z:(z * v.z)];
	return ([newVec autorelease]);
}

- (Vec3f *) multf: (float) f {
	Vec3f * newVec = [[Vec3f alloc] initWithX:(x * f) y:(y * f) z:(z * f)];
	return ([newVec autorelease]);
}

- (Vec3f *) divv: (Vec3f *) v {
	Vec3f * newVec = [[Vec3f alloc] initWithX:(x / v.x) y:(y / v.y) z:(z / v.z)];
	return ([newVec autorelease]);
}

- (Vec3f *) divf: (float) f {
	Vec3f * newVec = [[Vec3f alloc] initWithX:(x / f) y:(y / f) z:(z / f)];
	return ([newVec autorelease]);
}

- (Vec3f *) cross: (Vec3f *) v{
	Vec3f * newVec = [[Vec3f alloc] initWithX:(y * v.z - v.y * z) y:(z * v.x - v.z * x) z:(x * v.y - v.x * y)];
	return ([newVec autorelease]);
}

- (Vec3f *) lerpv: (Vec3f *)v at:(float)t {
	Vec3f * newVec = [[Vec3f alloc] initWithX:(x + ( v.x - x ) * t) y:(y + ( v.y - y ) * t) z:(z + ( v.z - z ) * t)];
	return ([newVec autorelease]);	
}


- (void) setx:(float)xo y:(float)yo z:(float)zo
{
	x = xo;
	y = yo;
	z = zo;
}

- (void) setv: (Vec3f*) v {
	x = v.x;
	y = v.y;
	z = v.z;
}


- (void) addEqv: (Vec3f*) v {
	x += v.x;
	y += v.y;
	z += v.z;
}

- (void) subEqv: (Vec3f*) v {
	x -= v.x;
	y -= v.y;
	z -= v.z;
}

- (void) multEqv: (Vec3f*) v {
	x *= v.x;
	y *= v.y;
	z *= v.z;
}

- (void) multEqf: (float) f {
	x *= f;
	y *= f;
	z *= f;
}

- (void) divEqv: (Vec3f*) v {
	x /= v.x;
	y /= v.y;
	z /= v.z;
}

- (void) divEqf: (float) f {
	x /= f;
	y /= f;
	z /= f;
}

- (void) lerpEqv: (Vec3f *)v at:(float)t {
	x = x + ( v.x - x ) * t;
	y = y + ( v.y - y ) * t;
	z = z + ( v.z - z ) * t;
}

- (float) length {
	return sqrt( x*x + y*y + z*z );
}

- (float) lengthSquared {
	return ( x*x + y*y + z*z );
}

- (void) normalize {
	float invS = 1.0 / [self length];
	x *= invS;
	y *= invS;
	z *= invS;
}

- (void) invert {
	x *= -1.0f;
	y *= -1.0f;
	z *= -1.0f;
}

- (void) reset {
	x = 0.0;
	y = 0.0;
	z = 0.0;
}

- (Vec3f*) normalized {
	float invS = 1.0 / [self length];
	
	Vec3f* newVec = [[Vec3f alloc] initWithX:x*invS y:y*invS z:z*invS ];
	return ([newVec autorelease]);
}

- (Vec3f*) inverse {
	Vec3f* newVec = [[Vec3f alloc] initWithX:x*-1.0f y:y*-1.0f z:z*-1.0f ];
	return ([newVec autorelease]);
}


@end
