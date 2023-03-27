vector(vector a, vector b) crossproduct =
{
	local vector v;
	v_x = a_y * b_z - a_z * b_y;
	v_y = a_z * b_x - a_x * b_z;
	v_z = a_x * b_y - a_y * b_x;
	return v;
};

// Rodriguez vector aka Axis angle rotation, thanks LordHavoc
void(vector axis, float angle) Matrix_RotateByAxisAngle =
{
	local vector forward;
	local vector left;
	local vector up;
	local float c, s, mc;
	local vector rforward;
	local vector rleft;
	local vector rup;

	forward = matrix_forward;
	left = matrix_left;
	up = matrix_up;
#ifdef QSSDEP
	angle = angle * DEG2RAD;
#endif

	axis = normalize(axis);
	c = cos(angle);mc = 1 - c;
	s = sin(angle);

	rforward_x = axis_x * axis_x + c * (1 - axis_x * axis_x);
	rforward_y = axis_x * axis_y * mc - axis_z * s;
	rforward_z = axis_z * axis_x * mc + axis_y * s;
	rleft_x = axis_x * axis_y * mc + axis_z * s;
	rleft_y = axis_y * axis_y + c * (1 - axis_y * axis_y);
	rleft_z = axis_y * axis_z * mc - axis_x * s;
	rup_x = axis_z * axis_x * mc - axis_y * s;
	rup_y = axis_y * axis_z * mc + axis_x * s;
	rup_z = axis_z * axis_z + c * (1 - axis_z * axis_z);

	matrix_forward_x = rforward_x * forward_x + rleft_x * forward_y + rup_x * forward_z;
	matrix_forward_y = rforward_y * forward_x + rleft_y * forward_y + rup_y * forward_z;
	matrix_forward_z = rforward_z * forward_x + rleft_z * forward_y + rup_z * forward_z;
	matrix_left_x = rforward_x * left_x + rleft_x * left_y + rup_x * left_z;
	matrix_left_y = rforward_y * left_x + rleft_y * left_y + rup_y * left_z;
	matrix_left_z = rforward_z * left_x + rleft_z * left_y + rup_z * left_z;
	matrix_up_x = rforward_x * up_x + rleft_x * up_y + rup_x * up_z;
	matrix_up_y = rforward_y * up_x + rleft_y * up_y + rup_y * up_z;
	matrix_up_z = rforward_z * up_x + rleft_z * up_y + rup_z * up_z;

	/*
	// swapped multiply order
	matrix_forward_x = forward_x * rforward_x + left_x * rforward_y + up_x * rforward_z;
	matrix_forward_y = forward_y * rforward_x + left_y * rforward_y + up_y * rforward_z;
	matrix_forward_z = forward_z * rforward_x + left_z * rforward_y + up_z * rforward_z;
	matrix_left_x = forward_x * rleft_x + left_x * rleft_y + up_x * rleft_z;
	matrix_left_y = forward_y * rleft_x + left_y * rleft_y + up_y * rleft_z;
	matrix_left_z = forward_z * rleft_x + left_z * rleft_y + up_z * rleft_z;
	matrix_up_x = forward_x * rup_x + left_x * rup_y + up_x * rup_z;
	matrix_up_y = forward_y * rup_x + left_y * rup_y + up_y * rup_z;
	matrix_up_z = forward_z * rup_x + left_z * rup_y + up_z * rup_z;
	*/
};

void(entity head) Matrix_TransposeMatrix =
{
	local vector oldforward, oldleft, oldup;
	local vector newforward, newleft, newup;
	oldforward = matrix_forward;
	oldleft = matrix_left;
	oldup = matrix_up;
	newforward_x = oldforward_x;
	newforward_y = oldleft_x;
	newforward_z = oldup_x;
	newleft_x = oldforward_y;
	newleft_y = oldleft_y;
	newleft_z = oldup_y;
	newup_x = oldforward_z;
	newup_y = oldleft_z;
	newup_z = oldup_z;
	matrix_forward = newforward;
	matrix_left = newleft;
	matrix_up = newup;
};

void(vector m1forward, vector m1left, vector m1up, vector m2forward, vector m2left, vector m2up) Matrix_Multiply =
{
	matrix_forward = m1forward_x * m2forward + m1forward_y * m2left + m1forward_z * m2up;
	matrix_left    = m1left_x    * m2forward + m1left_y    * m2left + m1left_z    * m2up;
	matrix_up      = m1up_x      * m2forward + m1up_y      * m2left + m1up_z      * m2up;
};

void(entity obj) Matrix_CalculateObjectMatrix =
{
	local vector org1, org2, org3;
	local vector tpart_forward, tpart_left, tpart_up;

	org1 = obj.physobj_p1.origin;
	org2 = obj.physobj_p2.origin;
	org3 = obj.physobj_p3.origin;
	tpart_forward = normalize(org2-org1);
	tpart_left = org3-org1;
	tpart_up = normalize(crossproduct(tpart_forward, tpart_left));
	tpart_left = normalize(crossproduct(tpart_forward, tpart_up));

	// LordHavoc:
	// transform the current particle matrix by transposed basepose particle
	// matrix, which undoes any strangeness in the particle matrix, which
	// makes it face straight forward (as it did when it was loaded)
	// this makes the object face the same as in the editor
	matrix_forward = obj.objbase_forward_x * tpart_forward + obj.objbase_left_x * tpart_left + obj.objbase_up_x * tpart_up;
	matrix_left    = obj.objbase_forward_y * tpart_forward + obj.objbase_left_y * tpart_left + obj.objbase_up_y * tpart_up;
	matrix_up      = obj.objbase_forward_z * tpart_forward + obj.objbase_left_z * tpart_left + obj.objbase_up_z * tpart_up;
};
#ifndef QSSDEP
vector randomvec(){
	vector v;
	do {
		v_x = random()*2-1;
		v_y = random()*2-1;
		v_z = random()*2-1;
	}
	while(vlen(v) > 1);
	return v;
}

float DotProduct2(vector x, vector y){
	return x.x*y.x+x.y*y.y;
}

vector vectoangles2 (vector forward, vector up) {
	vector result;
	if (forward.x == 0 && forward.y == 0) {	//either vertically up or down
		if (forward.z > 0) {
			result.x = -90;
			result.y = atan2(-up.y, -up.x);
		}
		else {
			result.x = 90;
			result.y = atan2(up.y, up.x);
		}
		result.z = 0;
	}
	else {
		result.x = -atan2(forward.z, sqrt(DotProduct2(forward, forward)));
		result.y = atan2(forward.y, forward.x);

		float cp = cos(result.x), sp = sin(result.x);
		float cy = cos(result.y), sy = sin(result.y);
		vector tleft, tup;
		tleft.x = -sy;
		tleft.y = cy;
		tleft.z = 0;
		tup.x = sp*cy;
		tup.y = sp*sy;
		tup.z = cp;
		result.z = -atan2(up * tleft, up * tup);
	}
	result.x = -result.x;
	return result;
}
#endif