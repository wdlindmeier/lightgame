
@interface Vec3f:NSObject{
	float x, y, z;
}

-(id) initWithX: (float) aX y: (float) aY z: (float) aZ;
- (Vec3f*) addv: (Vec3f*) v;
- (Vec3f*) subv: (Vec3f*) v;
- (Vec3f*) multv: (Vec3f*) v;
- (Vec3f*) multf: (float) f;
- (Vec3f*) divv: (Vec3f*) v;
- (Vec3f*) divf: (float) f;
- (Vec3f*) cross: (Vec3f*) v;
- (Vec3f*) lerpv: (Vec3f*)v at:(float)t;

- (void) setx:(float) x y:(float)y z:(float)z;
- (void) setv: (Vec3f*) v;
- (void) addEqv: (Vec3f*) v;
- (void) subEqv: (Vec3f*) v;
- (void) multEqv: (Vec3f*) v;
- (void) multEqf: (float) f;
- (void) divEqv: (Vec3f*) v;
- (void) divEqf: (float) f;
- (void) lerpEqv: (Vec3f*)v at:(float)t;

- (float) length;

- (void) reset;
- (void) normalize;
- (Vec3f*) normalized;
- (void) invert;
- (Vec3f*) inverse;

@property float x;
@property float y;
@property float z;

@end

