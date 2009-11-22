//
//  GlobalFunctions.m
//  LightGame
//
//  Created by William Lindmeier on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GlobalFunctions.h"

CGPoint rotateXYDegrees(float x, float y, float d)
{
	float aX = x*cos(DEGREES_TO_RADIANS(d)) - y*sin(DEGREES_TO_RADIANS(d));
	float aY = x*sin(DEGREES_TO_RADIANS(d)) + y*cos(DEGREES_TO_RADIANS(d));
	return CGPointMake(aX, aY);
}