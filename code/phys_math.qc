float(float f) sign =
{
	return (0 < f) - (f < 0);
}

float(float current, float target, float maxDelta) MoveTowards =
{
	if (fabs(target - current) <= maxDelta)
        return target;
    return current + sign(target - current) * maxDelta;
}

float(float current, float target, float maxDelta) MoveTowardsAngle =
{
	float deltaAngle = mod((target - current), 360);
	if (deltaAngle > 180)
		deltaAngle -= 360;
	if (-maxDelta < deltaAngle && deltaAngle < maxDelta)
		return target;
	target = current + deltaAngle;
	return MoveTowards(current, target, maxDelta);
}

float invlerp( float a, float b, float v ){
	return (v-a)/(b-a);
}

float remap(float v, float ilow, float ihigh, float olow, float ohigh){
	float t = invlerp(ilow, ihigh, v);
	return lerp(olow, ohigh, t );
}

// courtesy of bmFbr
// high precision atan2
float(float y, float x) atan2_smooth = {
    float b = 0.596227;

    // Extract the sign bits
    float ux_s  =  x < 0 ? -1 : 1;
    float uy_s  =  y < 0 ? -1 : 1;

    // Determine the quadrant offset
    float q;
    if (ux_s > 0 && uy_s > 0) q = 0;
    else if (ux_s < 0 && uy_s > 0) q = 1;
    else if (ux_s < 0 && uy_s < 0) q = 2;
    else q = 3;

    // Calculate the arctangent in the first quadrant
    float bxy_a = fabs( b * x * y );
    float num = bxy_a + y * y;
    float atan_1q =  num / ( x * x + bxy_a + num );

    // Translate it to the proper quadrant
    float uatan_2q = ux_s < 0 ? 1 - atan_1q : atan_1q;
    if (q >= 2) uatan_2q = 1 - uatan_2q;
    return (q + uatan_2q) * 90;
}

// from maths.qc in Copper, thanks Lunaran
// fixed divide by 0
vector(float num) SinCos_Trick =
{
	local vector angle, vf, vu, vr, result;
	
	vf = v_forward;
	vu = v_up;
	vr = v_right;
	
	angle = '0 1 0' * num;
	makevectors(angle);

	result = [v_forward_y, v_forward_x, 0];
	
	v_forward = vf;
	v_up = vu;
	v_right = vr;
	
	return result;
}
