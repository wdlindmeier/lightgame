//
//  Photon.h
//  LightGame
//
//  Created by William Lindmeier on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Vec3f.h"

@class Triangle;

@interface Photon : Vec3f {
	float angle;
	Triangle *triangle;
}

@property (assign) float angle;
@property (nonatomic, retain) Triangle *triangle;

@end
