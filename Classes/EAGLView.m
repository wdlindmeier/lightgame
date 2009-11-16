//
//  EAGLView.m
//  LightGame
//
//  Created by William Lindmeier on 11/15/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "EAGLView.h"
#import "Photon.h"

#define USE_DEPTH_BUFFER 0
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (void)perspectiveFov:(float)fov aspect:(float)aspect zNear:(float)zNear zFar:(float)zFar;
- (void)gluLookAtEye:(Vec3f*)eye center:(Vec3f*)center up:(Vec3f*)up;
- (Vec3f*)crossProduct:(Vec3f*)v1 with:(Vec3f*)v2;
- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) beginGLDraw;
- (void) finishGLDraw;

@end

@implementation EAGLView

@synthesize animating;
@synthesize context;
@synthesize animationTimer;

@dynamic animationInterval;

// You must implement this method
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id) initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
	{
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }		
		
		animating = FALSE;
		displayLinkSupported = FALSE;
		animationInterval = 1;
		displayLink = nil;
		animationTimer = nil;
		
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
			displayLinkSupported = TRUE;
		
		[self setupView];
		
		photon = [[Photon alloc] initWithX:-159.0 y:-239.0 z:0.0];
		
    }
	
    return self;
}

#pragma mark Drawing

- (void)beginGLDraw
{
	[EAGLContext setCurrentContext:context];   	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);	
	glViewport(0, 0, backingWidth, backingHeight);	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);		
	glMatrixMode(GL_MODELVIEW);
}

- (void) drawView:(id)sender
{
	[self beginGLDraw];
	
	int numParticles = 1; // [particles count];

	GLfloat particles[3 * numParticles * 4]; // 4 for the particle color
	
	int particleIndex = 0;
	photon.x += 1;
	photon.y += 1;
	
	for(int i=0; i<numParticles; i++){
		// The particle's position in space
		particles[ particleIndex++ ] = photon.x;
		particles[ particleIndex++ ] = photon.y;
		particles[ particleIndex++ ] = photon.z;
		// The particle's color
		particles[ particleIndex++ ] = 1.0; // r
		particles[ particleIndex++ ] = 0.0; // g
		particles[ particleIndex++ ] = 0.0; // b
		particles[ particleIndex++ ] = 1.0; // a
	}
	
	GLfloat box[] = {
		-160.0, 240.0,	0.0, // top left
		-160.0, -240.0, 0.0, // bottom left
		160.0, -240.0,	0.0, // bottom right
		160.0, 240.0,	0.0 // top right
	};
	
	GLfloat boxColors[] = {
		0.0, 1.0, 0.0, 1.0, // top left
		0.0, 1.0, 1.0, 1.0, // bottom left
		0.0, 1.0, 0.0, 1.0, // bottom right
		0.0, 1.0, 1.0, 1.0, // top right
	};
		
	// 1 Obstruction: Just a simple triangle
	// All lines are in red. 
	// NOTE: Should the color of the lines be stripped out alltogether? 
/*	const GLfloat obstructions[] = {
		0.0, 1.0, 0.0,   1.0, 1.0, 0.0, 1.0,
		-1.0, 0.0, 0.0,  1.0, 1.0, 1.0, 1.0,
		1.0, 0.0, 0.0,   1.0, 0.0, 0.0, 1.0,
	};	*/
	
	// Draw the box
	glPushMatrix();
	{
		//glTranslatef(2.0, 0.0, -4.0);		
		glVertexPointer(3, GL_FLOAT, 0, box);
		glColorPointer(4, GL_FLOAT, 0, boxColors);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	}
	glPopMatrix();
	
	// Draw the particles
	glPushMatrix();	
	{		
		//glTranslatef(-2.0, 0.0, -4.0);
		glPointSize(8.0);		
		glEnable(GL_POINT_SMOOTH);
		glVertexPointer(3, GL_FLOAT, 28, particles);
		glColorPointer(4, GL_FLOAT, 28, &particles[3]);
		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);		
		glDrawArrays(GL_POINTS, 0, numParticles);		
	}
	glPopMatrix();

	// Draw the obstructions	
	/*glPushMatrix();
	{
		// glTranslatef(2.0, 0.0, -4.0);
		//glEnable(GL_LINE_SMOOTH);
		//glVertexPointer(3, GL_FLOAT, 28, obstructions);
		//glColorPointer(4, GL_FLOAT, 28, &obstructions[3]);
		//glDrawArrays(GL_LINE_LOOP, 0, 4);		
	}
	glPopMatrix();*/
	
	[self finishGLDraw];

}
		
- (void)finishGLDraw
{
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	[self checkGLError:NO];		
}

- (void) layoutSubviews
{
	[EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];	
    [self drawView:nil];
}

#pragma mark Animation 

- (NSInteger) animationInterval
{
	return animationInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if (frameInterval >= 1)
	{
		animationInterval = frameInterval;
		
		if (animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void) startAnimation
{
	if (!animating)
	{
		if (displayLinkSupported)
		{
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.

			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
			[displayLink setFrameInterval:animationInterval];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
		
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}
		
		animating = FALSE;
	}
}

#pragma mark Setup / Teardown of OpenGL scene 

- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)setupView {
	
	if (USE_DEPTH_BUFFER) {
		glEnable(GL_DEPTH_TEST);
	}
	

    const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
    GLfloat size;
	
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	NSLog(@"size: %f", size);
	
	// This give us the size of the iPhone display
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
	
    glViewport(0, 0, rect.size.width, rect.size.height);	
	// NOTE: TODO: 277 is the magical distance into the z-axis to callibrate the coordinate system to the screen	
	glTranslatef(0.0, 0.0, -277.0);		
	// glMatrixMode(GL_MODELVIEW);
    glClearColor(1.0f, 0.0f, 1.0f, 1.0f);		
}

#pragma mark GL Logistics
/*
- (void) perspectiveFov: (float)fov aspect:(float)aspect zNear:(float)zNear zFar:(float)zFar
{
	float xmin, xmax, ymin, ymax;
	
	ymax = zNear * tan(fov * M_PI/360.0);
	ymin = -ymax;
	xmin = ymin * aspect;
	xmax = ymax * aspect;
	
	glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
}

- (void) gluLookAtEye:(Vec3f*)eye 
			   center:(Vec3f*)center 
				   up:(Vec3f*)up
{ 
	Vec3f* f = [[Vec3f alloc] init];
	f = [center subv:eye];
	
	if( eye != center ){
		[f normalize];
	}
	
	Vec3f* s = [[Vec3f alloc] init];
	Vec3f* u = [[Vec3f alloc] init];
	
	s = [self crossProduct:f with:up];
	u = [self crossProduct:s with:f];
	
	float M[]= 
	{ 
		s.x, s.y, s.z, 0.0,
		u.x, u.y, u.z, 0.0,
		-f.x,-f.y,-f.z, 0.0,
		0.0, 0.0, 0.0, 1.0
	};
	
	glMultMatrixf(M); 
	glTranslatef(-eye.x, -eye.y, -eye.z);
}

- (Vec3f*) crossProduct: (Vec3f*)v1
				   with: (Vec3f*)v2
{
	Vec3f* v = [[Vec3f alloc] init];
	v.x = v1.y * v2.z - v2.y * v1.z;
	v.y = v2.x * v1.z - v1.x * v2.z;
	v.z = v1.x * v2.y - v2.x * v1.y;
	
	return (v);
}
*/
#pragma mark Error checking

- (void)checkGLError:(BOOL)visibleCheck {
    GLenum error = glGetError();
    
    switch (error) {
        case GL_INVALID_ENUM:
            NSLog(@"GL Error: Enum argument is out of range");
            break;
        case GL_INVALID_VALUE:
            NSLog(@"GL Error: Numeric value is out of range");
            break;
        case GL_INVALID_OPERATION:
            NSLog(@"GL Error: Operation illegal in current state");
            break;
        case GL_STACK_OVERFLOW:
            NSLog(@"GL Error: Command would cause a stack overflow");
            break;
        case GL_STACK_UNDERFLOW:
            NSLog(@"GL Error: Command would cause a stack underflow");
            break;
        case GL_OUT_OF_MEMORY:
            NSLog(@"GL Error: Not enough memory to execute command");
            break;
        case GL_NO_ERROR:
            if (visibleCheck) {
                NSLog(@"No GL Error");
            }
            break;
        default:
            NSLog(@"Unknown GL Error");
            break;
    }
}


- (void) dealloc
{
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
	[photon release];
	
    [super dealloc];
}

@end
