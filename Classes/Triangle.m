//
//  Triangle.m
//  LightGame
//
//  Created by William Lindmeier on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Triangle.h"
#import "GlobalFunctions.h"
#import "Vec3f.h"

@implementation Triangle

@synthesize a, b, c, intersected, lastIntersection, size, origin, rotation;
/*
- (id)initWithAx:(float)aX aY:(float)aY aZ:(float)aZ 
			  bx:(float)bX bY:(float)bY bZ:(float)bZ 
			  cx:(float)cX cY:(float)cY cZ:(float)cZ
{
	Vec3f *aV = [[Vec3f alloc] initWithX:aX y:aY z:aZ];
	Vec3f *bV = [[Vec3f alloc] initWithX:bX y:bY z:bZ];
	Vec3f *cV = [[Vec3f alloc] initWithX:cX y:cY z:cZ];
	self = [self initWithA:aV b:bV c:cV];
	[aV release];
	[bV release];
	[cV release];
	return self;
}

- (id)initWithA:(Vec3f *)aVec b:(Vec3f *)bVec c:(Vec3f *)cVec
{
	if(self = [super init]){
		self.a = aVec;
		self.b = bVec;
		self.c = cVec;
	}
	return self;
}*/

- (id)initWithOrigin:(CGPoint)anOrigin size:(float)aSize rotation:(float)aRotation
{
	if(self = [super init]){
		self.origin = anOrigin;
		self.size = aSize;
		float halfSize = aSize * 0.5;
		a = [[Vec3f alloc] initWithX:anOrigin.x + halfSize y:anOrigin.y + halfSize z:0.0];
		b = [[Vec3f alloc] initWithX:anOrigin.x - halfSize y:anOrigin.y - halfSize z:0.0];
		c = [[Vec3f alloc] initWithX:anOrigin.x + halfSize y:anOrigin.y - halfSize z:0.0];
		self.rotation = aRotation;
	}
	return self;
}

- (void)setRotation:(float)aRotation
{
	if(rotation != aRotation){
		rotation = aRotation;
		
		float aX = self.a.x - self.origin.x;
		float aY = self.a.y - self.origin.y;
		float bX = self.b.x - self.origin.x;
		float bY = self.b.y - self.origin.y;
		float cX = self.c.x - self.origin.x;
		float cY = self.c.y - self.origin.y;
		
		CGPoint axy = rotateXYDegrees(aX, aY, rotation);
		CGPoint bxy = rotateXYDegrees(bX, bY, rotation);
		CGPoint cxy = rotateXYDegrees(cX, cY, rotation);

		self.a.x = self.origin.x + axy.x;
		self.a.y = self.origin.x + axy.y;
		self.b.x = self.origin.x + bxy.x;
		self.b.y = self.origin.x + bxy.y;
		self.c.x = self.origin.x + cxy.x;
		self.c.y = self.origin.x + cxy.y;
	}
}

- (void)setIntersected:(BOOL)isIntersected
{
	intersected = isIntersected;
	if(intersected){
		lastIntersection = 1.0;
	}else if(lastIntersection > 0){
		lastIntersection -= 0.01;
	}
}

- (NSArray *)points
{
	return [NSArray arrayWithObjects:a, b, c, nil];
}

- (void)dealloc
{
	[a release];
	[b release];
	[c release];
	[super dealloc];
}

@end
