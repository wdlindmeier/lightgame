//
//  LightGameAppDelegate.m
//  LightGame
//
//  Created by William Lindmeier on 11/15/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "LightGameAppDelegate.h"
#import "EAGLView.h"
#import "OALAudioController.h"

@implementation LightGameAppDelegate

@synthesize window;
@synthesize glView;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
	// Loading up the audio controller so openAL is loaded
	[OALAudioController sharedAudioController];
	[glView startAnimation];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	[glView stopAnimation];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	[glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[glView stopAnimation];
}

- (void) dealloc
{
	[window release];
	[glView release];
	
	
	[super dealloc];
}

@end
