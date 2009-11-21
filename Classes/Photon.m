//
//  Photon.m
//  LightGame
//
//  Created by William Lindmeier on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Photon.h"
#import "Triangle.h"

@implementation Photon

@synthesize angle, triangle;

#pragma mark Memory 

- (void)dealloc
{
	self.triangle = nil;
	[super dealloc];
}

@end
