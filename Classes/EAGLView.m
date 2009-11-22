//
//  EAGLView.m
//  LightGame
//
//  Created by William Lindmeier on 11/15/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "EAGLView.h"
#import "Photon.h"
#import "Vec3f.h"
#import "Triangle.h"

#define USE_DEPTH_BUFFER 0

#pragma mark Collision detection

/* 
 * check_lines:
 * This is based off an explanation and expanded math presented by Paul Bourke:
 *
 * It takes two lines as inputs and returns 1 if they intersect, 0 if they do
 * not.  hitp returns the point where the two lines intersected.  
 *
 * This function expects integer value inputs and stores an integer value
 * in hitp if the two lines interesect.  The internal calculations are fixed 
 * point with a 14 bit fractional precision for processors without floating
 * point units.
 */
//int check_lines(line *line1, line *line2, point *hitp)
Vec3f * areIntersecting(float v1x1, float v1y1, float v1x2, float v1y2,
						float v2x1, float v2y1, float v2x2, float v2y2) 
{
    /* Introduction:
     * This code is based on the solution of these two input equations:
     *  Pa = P1 + ua (P2-P1)
     *  Pb = P3 + ub (P4-P3)
     *
     * Where line one is composed of points P1 and P2 and line two is composed
     *  of points P3 and P4.
     *
     * ua/b is the fractional value you can multiple the x and y legs of the
     *  triangle formed by each line to find a point on the line.
     *
     * The two equations can be expanded to their x/y components:
     *  Pa.x = p1.x + ua(p2.x - p1.x) 
     *  Pa.y = p1.y + ua(p2.y - p1.y) 
     *
     *  Pb.x = p3.x + ub(p4.x - p3.x)
     *  Pb.y = p3.y + ub(p4.y - p3.y)
     *
     * When Pa.x == Pb.x and Pa.y == Pb.y the lines intersect so you can come 
     *  up with two equations (one for x and one for y):
     *
     * p1.x + ua(p2.x - p1.x) = p3.x + ub(p4.x - p3.x)
     * p1.y + ua(p2.y - p1.y) = p3.y + ub(p4.y - p3.y)
     *
     * ua and ub can then be individually solved for.  This results in the
     *  equations used in the following code.
     */
	
    /* Denominator for ua and ub are the same so store this calculation */
    int d   =   (v2y2 - v2y1)*(v1x2-v1x1) - (v2x2 - v2x1)*(v1y2-v1y1);
	
    /* n_a and n_b are calculated as seperate values for readability */
    int n_a =   (v2x2 - v2x1)*(v1y1-v2y1) - (v2y2 - v2y1)*(v1x1-v2x1);
	
    int n_b =   (v1x2 - v1x1)*(v1y1 - v2y1) - (v1y2 - v1y1)*(v1x1 - v2x1);
	
    /* Make sure there is not a division by zero - this also indicates that
     * the lines are parallel.  
     *
     * If n_a and n_b were both equal to zero the lines would be on top of each 
     * other (coincidental).  This check is not done because it is not 
     * necessary for this implementation (the parallel check accounts for this).
     */
    if(d == 0)
        return nil;
	
    /* Calculate the intermediate fractional point that the lines potentially
     *  intersect.
     */
    int ua = (n_a << 14)/d;
    int ub = (n_b << 14)/d;
    
    /* The fractional point will be between 0 and 1 inclusive if the lines
     * intersect.  If the fractional calculation is larger than 1 or smaller
     * than 0 the lines would need to be longer to intersect.
     */
    if(ua >=0 && ua <= (1<<14) && ub >= 0 && ub <= (1<<14))
    {
		// if the distance between the starting point (x1, y1) and the intersection (ix, iy)
		// is small, return nil
		
		int ix = v1x1 + ((int)(ua * (v1x2 - v1x1))>>14);
		int iy = v1y1 + ((int)(ua * (v1y2 - v1y1))>>14);

//		int xDist = ix - v1x1;
//		int yDist = iy - v1y1;
//		int iDist = sqrt((xDist*xDist) + (yDist*yDist));
//		if(iDist > 1){		
			return [[[Vec3f alloc] initWithX:ix
										   y:iy
										   z:0.0] autorelease];
//		}else{
//			NSLog(@"ix: %i iy: %i iDist: %i", ix, iy, iDist);
//		}
    }
    return nil;
}


// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) beginGLDraw;
- (void) finishGLDraw;
- (void) calculatePathStartingWithPhoton:(Photon *)photon;

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
		
		self.multipleTouchEnabled = YES;
		
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
		[self setupScene];
				
    }
	
    return self;
}

- (void)setupScene
{	
	//float obstructionSize = 20.0;
//	int numObstructions = 60; //arc4random() % 50;
//	obstructions = [[NSMutableArray alloc] initWithCapacity:numObstructions];
	obstructions = [[NSMutableArray alloc] init];
/*
	for(int i=0;i<numObstructions;i++){
		int initX = (arc4random() % 320) - 160;
		int initY = (arc4random() % 480) - 240;
		Triangle *t = [[Triangle alloc] initWithAx:initX
												aY:initY
												aZ:0.0 
												bx:initX-(obstructionSize*0.5)
												bY:initY-obstructionSize
												bZ:0.0 
												cx:initX+(obstructionSize*0.5)
												cY:initY-obstructionSize
												cZ:0.0];
		[obstructions addObject:t];	
		[t release];
	}
*/	
	Photon *p = [[Photon alloc] initWithX:0.0
										y:0.0
										z:0.0];
	p.angle = (arc4random() % 360);
	
	[self calculatePathStartingWithPhoton:p];
	[p release];
}

- (void)calculatePathStartingWithPhoton:(Photon *)photon
{	
	[lightPoints release];
	lightPoints = [[NSMutableArray alloc] initWithCapacity:1];
	Photon *p1 = photon;
	float maxDistance = 500.0;  // A large number so it's always off screen		
	
	while(p1 != nil){
		[lightPoints addObject:p1];

		float x2 = p1.x + (maxDistance * cos(DEGREES_TO_RADIANS(p1.angle)));
		float y2 = p1.y + (maxDistance * sin(DEGREES_TO_RADIANS(p1.angle)));
		Photon *p2 = [[Vec3f alloc] initWithX:x2 y:y2 z:p1.z];
		
		// check if the line goes through every triangle
		// if it does, compare which one is closest
		// add that new point to the array
		// reset the photon to the new point or nil
		
		NSMutableArray *intersections = [[NSMutableArray alloc] init];
		
		for(Triangle *triangle in obstructions){			
			NSArray *points = [triangle points];
			int pointCount = [points count];

			for(int l=0;l<pointCount;l++){
				// Since we are assuming it's a polygon, we can circle back around and connect the first and the last point
				Vec3f *v3 = [points objectAtIndex:l%pointCount];
				Vec3f *v4 = [points objectAtIndex:(l+1)%pointCount];
				Vec3f *intersectPoint = areIntersecting(p1.x, p1.y, p2.x, p2.y, v3.x, v3.y, v4.x, v4.y);
				if(intersectPoint){

					float px = intersectPoint.x;
					float py = intersectPoint.y;
					
					float sideAngle = RADIANS_TO_DEGREES(atan2f(v4.y-v3.y, v4.x-v3.x));
										
					float angleDelta = sideAngle - p1.angle;
					float newAngle = sideAngle + angleDelta;

					// I... think ... this nudges the intersection point down the normal of the angle
					float x5 = v4.x - (v4.y - v3.y);
					float y5 = v4.y + (v4.x - v3.x);					
					float sideNormal = RADIANS_TO_DEGREES(atan2f(v4.y-y5, v4.x-x5));
					float nudgeX = 2.0 * cos(sideNormal);
					float nudgeY = 2.0 * sin(sideNormal);															
					px += nudgeX;
					py += nudgeY;
					 
					Photon *p = [[Photon alloc] initWithX:px y:py z:p1.z];
					p.angle = newAngle;
					p.triangle = triangle;
					[intersections addObject:p];
					[p release];
					// DONT break, so we can check all sides (and thus find the closest)
					// break; 
				}
			}
		}

		if([intersections count] > 0){
			// figure out the closest intersection and add that point
			float pointDistance = maxDistance;
			Photon *closestIntersection = nil;
			for(Photon *i in intersections){
				float xDist = (i.x - p1.x);
				float yDist = (i.y - p1.y);
				float dist = sqrtf((xDist*xDist) + (yDist*yDist));
				if(dist < pointDistance){
					// This intersection is closer than the other intersections tested
					closestIntersection = i;
					pointDistance = dist;
				}
			}	
						
			Triangle *iTriangle = closestIntersection.triangle;
			iTriangle.intersected = YES;
			p1 = [[Photon alloc] initWithX:closestIntersection.x y:closestIntersection.y z:closestIntersection.z];
			p1.angle = closestIntersection.angle;
			[p1 autorelease];

		}else{
			// Add the last point and bail.
			[lightPoints addObject:p2];
			p1 = nil;
		}
		
		// If there is too much reflection, just bail out
		if([lightPoints count] > 100){
			p1 = nil;
		}

		[intersections release];
	}
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
	
	// Slowly rotating the ray
	Photon *p = [lightPoints objectAtIndex:0];
	// p.angle += 0.5;	
	[p retain];
	[self calculatePathStartingWithPhoton:p];	
	[p release];

	[self beginGLDraw];
		
	int numPoints = [lightPoints count];
	GLfloat points[(3 * numPoints) + (4 * numPoints)];

	int pointIndex = 0;
	for(Vec3f *v in lightPoints){
		points[ pointIndex++ ] = v.x;
		points[ pointIndex++ ] = v.y;
		points[ pointIndex++ ] = v.z;	 
		
		points[ pointIndex++ ] = 1.0; // red particles
		points[ pointIndex++ ] = 0.0;
		points[ pointIndex++ ] = 0.0;
		points[ pointIndex++ ] = 1.0;
	}		
	
	pointIndex = 0;
	int numObstructions = [obstructions count];
	int pointsPerObstruction = 6;
	GLfloat obstructionPoints[((3 * pointsPerObstruction) + (4 * pointsPerObstruction)) * numObstructions];
	for(Triangle *triangle in obstructions){
		
		float triangleColor = 0.25 + (triangle.lastIntersection * 0.75);
		
		obstructionPoints[pointIndex++] = triangle.a.x;
		obstructionPoints[pointIndex++] = triangle.a.y;
		obstructionPoints[pointIndex++] = triangle.a.z;
		
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = 1.0;
		
		obstructionPoints[pointIndex++] = triangle.a.x;
		obstructionPoints[pointIndex++] = triangle.a.y;
		obstructionPoints[pointIndex++] = triangle.a.z;

		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = 1.0;
		
		obstructionPoints[pointIndex++] = triangle.b.x;
		obstructionPoints[pointIndex++] = triangle.b.y;
		obstructionPoints[pointIndex++] = triangle.b.z;

		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = 1.0;
		
		obstructionPoints[pointIndex++] = triangle.c.x;
		obstructionPoints[pointIndex++] = triangle.c.y;
		obstructionPoints[pointIndex++] = triangle.c.z;

		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = 1.0;
		
		obstructionPoints[pointIndex++] = triangle.a.x;
		obstructionPoints[pointIndex++] = triangle.a.y;
		obstructionPoints[pointIndex++] = triangle.a.z;		

		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = 1.0;
		
		obstructionPoints[pointIndex++] = triangle.a.x;
		obstructionPoints[pointIndex++] = triangle.a.y;
		obstructionPoints[pointIndex++] = triangle.a.z;		

		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = triangleColor;
		obstructionPoints[pointIndex++] = 1.0;
		
		triangle.intersected = NO;
	}
	
	glEnableClientState(GL_VERTEX_ARRAY);
	
	// Draw the obstructions	
	
	glPushMatrix();
	{		
		glEnableClientState(GL_COLOR_ARRAY);
		glEnable(GL_LINE_SMOOTH);
		glVertexPointer(3, GL_FLOAT, 28, obstructionPoints);
		glColorPointer(4, GL_FLOAT, 28, &obstructionPoints[3]);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, numObstructions * pointsPerObstruction);
		glDisableClientState(GL_COLOR_ARRAY);
	}
	glPopMatrix();

	// Draw the light
	
	glPushMatrix();	
	{				
		glVertexPointer(3, GL_FLOAT, 28, points);

		// Draw the lines
		glColor4f( 1.0, 0.0, 0.0, 1.0 );
		glEnable(GL_LINE_SMOOTH);
		glDrawArrays(GL_LINE_STRIP, 0, numPoints);
		
		// Draw the points
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glColor4f( 1.0, 1.0, 0.0, 0.5 );
		glPointSize(8.0);		
		glEnable(GL_POINT_SMOOTH);		
		glDrawArrays(GL_POINTS, 0, numPoints);				
		glDisable(GL_BLEND);
		
	}
	glPopMatrix();
	

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
	
	// This give us the size of the iPhone display
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
	
    glViewport(0, 0, rect.size.width, rect.size.height);	
	// NOTE: TODO: 277 is the magical distance into the z-axis to callibrate the coordinate system to the screen	
	glTranslatef(0.0, 0.0, -277.0);		
	// glMatrixMode(GL_MODELVIEW);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);		
}

#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch *touch in touches){
		// Add a triangle with a double tap
		if(touch.tapCount == 2){
			CGPoint touchPoint = [touch locationInView:self];
			CGPoint trianglePoint = CGPointMake(touchPoint.x - 160.0, -touchPoint.y + 240.0);
			Triangle *triangle = [[Triangle alloc] initWithOrigin:trianglePoint
															 size:20.0 
														 rotation:0.0];
			[obstructions addObject:triangle];			
			[triangle release];
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
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
	//[photon release];
	[lightPoints release];
	
    [super dealloc];
}

@end
