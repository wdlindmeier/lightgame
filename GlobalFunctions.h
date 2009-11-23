//
//  GlobalFunctions.h
//  LightGame
//
//  Created by William Lindmeier on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vec3f.h"

#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE) ((__ANGLE) * 180.0 / M_PI)

CGPoint rotateXYDegrees(float x, float y, float d);
Vec3f * areIntersecting(float v1x1, float v1y1, float v1x2, float v1y2,
						float v2x1, float v2y1, float v2x2, float v2y2);
