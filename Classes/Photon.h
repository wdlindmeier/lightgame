//
//  Photon.h
//  LightGame
//
//  Created by William Lindmeier on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//#import "Vec3f.h"

@interface Photon : NSObject {
	float x, y, z, velocity, direction;
}

@property (assign) float x;
@property (assign) float y;
@property (assign) float z;
@property (assign) float velocity;
@property (assign) float direction;

@end
