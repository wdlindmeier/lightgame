//
//  GlobalFunctions.h
//  LightGame
//
//  Created by William Lindmeier on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE) ((__ANGLE) * 180.0 / M_PI)

CGPoint rotateXYDegrees(float x, float y, float d);