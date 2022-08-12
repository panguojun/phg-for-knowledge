// *************************************************************
// This is gauge physics for interpretation of centripetal force
// *************************************************************
// Gauge Physics - I try to divide physics into three parts:
// P(physics) = C(gauge) * [A(formula/geometry/particle system) * D(dimension)]

// ------------------------------------------
// Coordinate system is a simplified version of gauge
// 
// A coordinate system in three-dimensional space 
// consists of an origin plus three orientation axes 
// and three scaling components. 
// Corresponding to the three transformations of displacement, 
// rotation, and scaling, respectively.
// ------------------------------------------
struct coord
{
    vec3 o;        // define the origin position
    vec3 ux,uy,uz; // three axial unit vectors
    vec3 scale;    // scale transformation
};
// Multiplication operation
// C1*C2*C3* ... *Cloc * Vloc （transfrom)
vec3 mul(coord c, vec3 v)
{
    return c.ux * v.x + c.uy * v.y + c.uz * v.z + c.o;
}
coord mul (coord c1, coord c2)
{
    coord rc;
    rc.ux = c1.ux * c2.ux.x + c1.uy * c2.ux.y + c1.uz * c2.ux.z;
    rc.uy = c1.ux * c1.uy.x + c1.uy * c2.uy.y + c1.uz * c1.uy.z;
    rc.ux = c1.ux * c2.uz.x + c1.uy * c2.uz.y + c1.uz * c2.uz.z;
    rc.o = c1.o + c1.ux * c2.o.x + c1.uy * c2.o.y + c1.uz * c2.o.z;
    return rc;
}
// Division operation
// Vworld/C1/C2/C3/ ... /Cloc（projection)
vec3 div(vec3 v, coord c)
{
	vec3 dv = v - c.o;
	return vec3(dot(dv,c.ux), dot(dv,c.uy), dot(dv,c.uz));
}
coord div(coord c1,coord c2)
{
	coord rc;
	rc.ux = vec3(dot(c1.ux,c2.ux), dot(c1.ux,c2.uy), dot(c1.ux,c2.uz));
	rc.uy = vec3(dot(c1.uy,c2.ux), dot(c1.uy,c2.uy), dot(c1.uy,c2.uz));
	rc.uz = vec3(dot(c1.uz,c2.ux), dot(c1.uz,c2.uy), dot(c1.uz,c2.uz));
	rc.o = c1.o - c2.o;
	return rc;
}
// Polar Jacobian Transform
void polecoord(out coord c1, float x, float y)
{
	c1.o.x = x;
	c1.o.y = y;
	c1.ux = vec3(cos(c1.o.y), sin(c1.o.y), 0);
	c1.uy = vec3(-c1.o.x * sin(c1.o.y), c1.o.x * cos(c1.o.y), 0);
}

// ------------------------------------------
// Dimension or Const
// ------------------------------------------
#define PI 3.1415926535
#define m 10.0

// ------------------------------------------
// Formula Coefficient
// ------------------------------------------
// Kinematics settings
#define w    2.0     // angular velocity
#define dt   0.001   // deta time
#define dth  dt * w  // deta theta

// ------------------------------------------
// Phase View
// ------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord.xy/iResolution.yy-vec2(0.5);
	float r = length(uv) * m;
	float ang = atan(-uv.y,uv.x) + r*iTime * 0.1;
    
    //Observe a coordinate system C1 at point (r, ang) in global coordinates
    //float r = 2., ang = 180.;
    coord c1;
    polecoord(c1, r, ang * PI / 180.);
    //Observe a coordinate system C2 at a point after dt next to C1
    coord c2;
    polecoord(c2, r, dth + ang * PI / 180.);
    
    //Velocity vector in polar coordinates (circular motion)
    vec3 v = vec3(0.0, uv.y,0.0);
    vec3 dv = (mul(c2,v) - mul(c1,v)) ; // Instead, observe the velocity vector in the global coordinate system and differentiate the velocity
    vec3 a = dv / dt; // the time derivative of the vector, the acceleration

    // Output to screen
    fragColor = vec4(a,1.0);
}
