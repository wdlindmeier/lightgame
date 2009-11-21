//
//  Triangle.m
//  LightGame
//
//  Created by William Lindmeier on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Triangle.h"
#import "Vec3f.h"

@implementation Triangle

@synthesize a, b, c, intersected, lastIntersection;

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
	return [NSArray arrayWithObjects:self.a, self.b, self.c, nil];
}

- (void)dealloc
{
	self.a = nil;
	self.b = nil;
	self.c = nil;
	[super dealloc];
}

@end
