//
//  EAGLView.h
//  LightGame
//
//  Created by William Lindmeier on 11/15/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "GlobalFunctions.h"

//@class OALAudioController;

@interface EAGLView : UIView
{    
@private
	
	BOOL animating;
	BOOL displayLinkSupported;
	NSInteger animationInterval;
	// Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	// CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	// The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
	// isn't available.
	id displayLink;
    NSTimer *animationTimer;
	
    GLint backingWidth;
    GLint backingHeight;
	//GLuint textures[4];    
    EAGLContext *context;    
    GLuint viewRenderbuffer, viewFramebuffer, depthRenderbuffer;

	NSMutableArray	*lightPoints;
	NSMutableArray	*obstructions;
	
	NSMutableDictionary *touchedObstructions;
	
	//OALAudioController *audioController;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;
- (void)setupView;
- (void)setupScene;
- (void)checkGLError:(BOOL)visibleCheck;

@end
