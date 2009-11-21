//
//  Triangle.h
//  LightGame
//
//  Created by William Lindmeier on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Vec3f;

@interface Triangle : NSObject {
	
	Vec3f *a;
	Vec3f *b;
	Vec3f *c;
	BOOL intersected;
	float lastIntersection;

}

@property (nonatomic, retain) Vec3f *a;
@property (nonatomic, retain) Vec3f *b;
@property (nonatomic, retain) Vec3f *c;
@property (assign) BOOL intersected;
@property (assign) float lastIntersection;

- (NSArray *)points;

- (id)initWithA:(Vec3f *)aVec b:(Vec3f *)bVec c:(Vec3f *)cVec;
- (id)initWithAx:(float)aX aY:(float)aY aZ:(float)aZ 
			  bx:(float)bX bY:(float)bY bZ:(float)bZ 
			  cx:(float)cX cY:(float)cY cZ:(float)cZ;

@end
