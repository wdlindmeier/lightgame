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
	BOOL singing;
	float size;
	CGPoint origin;
	float rotation;
	// TODO: Maybe this should be abstracted
	float pitch;
	NSUInteger soundId;
	
}

@property (nonatomic, readonly) Vec3f *a;
@property (nonatomic, readonly) Vec3f *b;
@property (nonatomic, readonly) Vec3f *c;
@property (assign) float size;
@property (assign) float pitch;
@property (assign) BOOL intersected;
@property (assign) BOOL singing;
@property (assign) float rotation;
@property (assign) CGPoint origin;

- (NSArray *)points;

- (id)initWithOrigin:(CGPoint)anOrigin size:(float)aSize rotation:(float)aRotation;

- (void)setOffsetX:(float)xOffset y:(float)yOffset;

/*- (id)initWithA:(Vec3f *)aVec b:(Vec3f *)bVec c:(Vec3f *)cVec;
- (id)initWithAx:(float)aX aY:(float)aY aZ:(float)aZ 
			  bx:(float)bX bY:(float)bY bZ:(float)bZ 
			  cx:(float)cX cY:(float)cY cZ:(float)cZ;
*/
@end
