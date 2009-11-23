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

@synthesize a, b, c, intersected, size, origin, rotation;

- (id)initWithOrigin:(CGPoint)anOrigin size:(float)aSize rotation:(float)aRotation
{
	if(self = [super init]){
		self.origin = anOrigin;
		self.size = aSize;
		float halfSize = aSize * 0.5;		
		float height = sqrtf((aSize * aSize) - (halfSize*halfSize));
		a = [[Vec3f alloc] initWithX:anOrigin.x y:anOrigin.y + (height*0.66) z:0.0];
		b = [[Vec3f alloc] initWithX:anOrigin.x - halfSize y:anOrigin.y - (height*0.33) z:0.0];
		c = [[Vec3f alloc] initWithX:anOrigin.x + halfSize y:anOrigin.y - (height*0.33) z:0.0];
		self.rotation = aRotation;
	}
	return self;
}

- (void)setRotation:(float)aRotation
{
	if(rotation != aRotation){
		float rotationDelta = aRotation - rotation;
		rotation = aRotation;
		
		float aX = self.a.x - self.origin.x;
		float aY = self.a.y - self.origin.y;

		float bX = self.b.x - self.origin.x;
		float bY = self.b.y - self.origin.y;

		float cX = self.c.x - self.origin.x;
		float cY = self.c.y - self.origin.y;
		
		CGPoint axy = rotateXYDegrees(aX, aY, rotationDelta);
		CGPoint bxy = rotateXYDegrees(bX, bY, rotationDelta);
		CGPoint cxy = rotateXYDegrees(cX, cY, rotationDelta);

		a.x = self.origin.x + axy.x;
		a.y = self.origin.y + axy.y;
		
		b.x = self.origin.x + bxy.x;
		b.y = self.origin.y + bxy.y;
	
		c.x = self.origin.x + cxy.x;
		c.y = self.origin.y + cxy.y;
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
