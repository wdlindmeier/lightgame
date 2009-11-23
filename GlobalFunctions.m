//
//  GlobalFunctions.m
//  LightGame
//
//  Created by William Lindmeier on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GlobalFunctions.h"

// http://www.gamedev.net/community/forums/topic.asp?topic_id=460026
CGPoint rotateXYDegrees(float x, float y, float d)
{
	float aX = x*cos(DEGREES_TO_RADIANS(d)) - y*sin(DEGREES_TO_RADIANS(d));
	float aY = x*sin(DEGREES_TO_RADIANS(d)) + y*cos(DEGREES_TO_RADIANS(d));
	return CGPointMake(aX, aY);
}

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


