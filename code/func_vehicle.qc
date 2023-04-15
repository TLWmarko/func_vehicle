.entity frontright, frontleft, backright, backleft;
.entity gun;

void PushAndDamageThink(){
	entity e = self.p_damage_next;
	while(e){
		T_Damage (e, self, self, e.p_damage_val);
		e.p_damage_val = 0;
		entity temp = e.p_damage_next;
		e.p_damage_next = world;
		e = temp;
	}
	self.p_damage_next = world;

	self.nextthink = time + 0.2;
}

// FIXME: need to take attacker mass into account
void PushAndDamageTarget(entity instigator, entity targ){
	vector vel = instigator.velocity;
	if (!p_damage_thinker){
		p_damage_thinker = spawn();
		p_damage_thinker.think = PushAndDamageThink;
		p_damage_thinker.nextthink = time + 0.2;
	}

	if (targ.flags & FL_MONSTER || targ.flags & FL_CLIENT){
		float len = vlen(vel);
		if (len > 100) {
			targ.flags -= (other.flags & FL_ONGROUND);
			targ.velocity += vel * 0.035;
			targ.velocity += [0, 0, len * 0.02];

			float contains = FALSE;
			entity e = p_damage_thinker.p_damage_next;
			while(e){
				if(e == targ){
					contains = TRUE;
					break;
				}
				e = e.p_damage_next;
			}

			if (!contains){
				targ.p_damage_next = p_damage_thinker.p_damage_next;
				p_damage_thinker.p_damage_next = targ;
			}
			targ.p_damage_val += len * 0.01;
		}
	}
}

void() PhysCrush =
{
	PushAndDamageTarget(other, self);
};

void Car_TirePlace(entity tire){
	entity tireparticle = tire.enemy;
	tire.angles = vectoangles2(tireparticle.lmat_forward, tireparticle.lmat_up);

	traceline(tireparticle.origin, tireparticle.origin + tireparticle.lmat_up * -tire.frags, TRUE, tire);
	float tracelen = fabs(tireparticle.physobj_spring_length);
#if defined(SMOOTH)
	float f = 0.1;
#else
	float f = frametime;
#endif
	tire.frags = min(tire.frags + f*30, tracelen*trace_fraction);
	tire.oldorigin = tire.origin;
	setorigin(tire, trace_endpos + tireparticle.lmat_up * tireparticle.relative_size);
}

void() Car_ChassiThink =
{
	entity car = self.realowner;

	entity tbleft = car.backleft.enemy;
	entity tbright = car.backright.enemy;
	entity tfleft = car.frontleft.enemy;
	entity tfright = car.frontright.enemy;

	entity hitmodel = self.realowner.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.solid = SOLID_TRIGGER;
		setorigin(hitmodel, hitmodel.origin);
		hitmodel = hitmodel.physobj_next;
	}

	Car_TirePlace(tbleft);
	Car_TirePlace(tbright);
	Car_TirePlace(tfleft);
	Car_TirePlace(tfright);

	hitmodel = self.realowner.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.solid = SOLID_BSP;
		setorigin(hitmodel, hitmodel.origin);
		hitmodel = hitmodel.physobj_next;
	}

#if defined(SMOOTH)
	car.frags = time + 0.1;
	self.angles = vectoangles2(self.lmat_forward, self.lmat_up);
	setorigin(self, self.view_ofs);
	self.nextthink = time + 0.1;
#else
	self.nextthink = time;
#endif
};

#if defined(SMOOTH)
void() DriverThink =
{
	self.angles = vectoangles2(self.lmat_forward, self.lmat_up);
	setorigin(self, self.view_ofs);

	self.nextthink = time + 0.1;
};
#endif

void(float turn, float pitch) Gun_Turn =
{
	local float f;
	if (!self.driving)
		return;
	f = 125;
	entity car = self.driving;
	entity swivel = car.gun;
	if (!swivel)
		return;
	entity body = swivel.gun;
	entity barrel = body.gun;
	float want_yaw = turn;
	//float want_yaw = clamp(turn, -35, 35);
	if (want_yaw < 0)
		swivel.ideal_yaw = max(want_yaw, swivel.ideal_yaw - f*frametime);
	else if (want_yaw > 0)
		swivel.ideal_yaw = min(want_yaw, swivel.ideal_yaw + f*frametime);
	else{
		if (swivel.ideal_yaw > 0)
			swivel.ideal_yaw = max(0, swivel.ideal_yaw - f*2*frametime);
		else
			swivel.ideal_yaw = min(0, swivel.ideal_yaw + f*2*frametime);
	}
	makevectors(swivel.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle('0 0 1', swivel.ideal_yaw);
	swivel.relative_forward = matrix_forward;
	swivel.relative_left = matrix_left;
	swivel.relative_up = matrix_up;

	want_yaw = clamp(pitch, -25, 90);
	if (want_yaw < 0)
		body.ideal_yaw = max(want_yaw, body.ideal_yaw - f*frametime);
	else if (want_yaw > 0)
		body.ideal_yaw = min(want_yaw, body.ideal_yaw + f*frametime);
	else{
		if (body.ideal_yaw > 0)
			body.ideal_yaw = max(0, body.ideal_yaw - f*2*frametime);
		else
			body.ideal_yaw = min(0, body.ideal_yaw + f*2*frametime);
	}
	makevectors(swivel.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle('0 1 0', body.ideal_yaw);
	Matrix_RotateByAxisAngle('0 0 1', swivel.ideal_yaw);
	body.relative_forward = matrix_forward;
	body.relative_left = matrix_left;
	body.relative_up = matrix_up;
	barrel.relative_forward = matrix_forward;
	barrel.relative_left = matrix_left;
	barrel.relative_up = matrix_up;
};

vector() Car_SpringyOrigin;

entity FindStaticOfName(string name, entity obj){
	entity e = obj.physobj_staticlist;
	while(e){
		if (e.netname == name)
			return e;
		e = e.physobj_next;
	}
	return world;
}

void(entity car) Car_InitVehicle =
{
	local entity e;

	e = car.physobj_particlelist;
	while (e)
	{
		if (e.netname == "frontright")
			car.frontright = e;
		else if (e.netname == "frontleft")
			car.frontleft = e;
		else if (e.netname == "backright")
			car.backright = e;
		else if (e.netname == "backleft")
			car.backleft = e;
		e = e.physobj_next;
	}
	e = car.physobj_staticlist;
	while (e)
	{
		if (e.netname == "frontright")
		{
			car.frontright.enemy = e;
			e.enemy = car.frontright;
		}
		else if (e.netname == "frontleft")
		{
			car.frontleft.enemy = e;
			e.enemy = car.frontleft;
		}
		else if (e.netname == "backright")
		{
			car.backright.enemy = e;
			e.enemy = car.backright;
		}
		else if (e.netname == "backleft")
		{
			car.backleft.enemy = e;
			e.enemy = car.backleft;
		}
		else if (e.netname == "chassis")
		{
			e.think = Car_ChassiThink;
			e.nextthink = time;
		}
#if defined(SMOOTH)
		else if (e.netname == "driver")
		{
			e.think = DriverThink;
			e.nextthink = time;
		}
#endif
		else if (e.netname == "turretswivel")
		{
			car.gun = e;
			car.gun.gun = FindStaticOfName("turretbody", car);
			car.gun.gun.gun = FindStaticOfName("turretbarrel", car);
		}
		e = e.physobj_next;
	}
};

float TryPlacePlayer(entity exit){
	setorigin(self, exit.origin);
	if (!droptofloor(0,0))
		return FALSE;
	setorigin(self, exit.origin);
	self.flags -= (self.flags & FL_ONGROUND);
	vector vel = (exit.origin - exit.oldorigin) / frametime;
	vel += normalize(exit.owner.origin - exit.origin) * vlen(vel) * 0.3;
	vel += [0, 0, vlen(vel) * 0.3];
	self.velocity = vel;
	return TRUE;
}

float modelindex_null;

void(entity ply, entity car) Car_AttachToVehicle =
{
	entity oself;
	if (ply.driving){ // already sitting in car
		ply.driving = world;
		ply.solid = SOLID_SLIDEBOX;
		ply.movetype = MOVETYPE_WALK;
		ply.modelindex = modelindex_player;
		stuffcmd(ply, "chase_active 0\n");
		stuffcmd(ply, "crosshair 1\n");
		oself = self;
		self = ply;
		if (!TryPlacePlayer(FindStaticOfName("rightdoor", car)))
			if (!TryPlacePlayer(FindStaticOfName("leftdoor", car)))
				if (!TryPlacePlayer(FindStaticOfName("topexit", car)))
					if (!TryPlacePlayer(FindStaticOfName("botexit", car)))
						if (!TryPlacePlayer(FindStaticOfName("backexit", car)))
							TryPlacePlayer(FindStaticOfName("frontexit", car));
		self = oself;
		car.driving = world;
	}
	else {
		//ply.view_ofs = '0 0 16';
		ply.driving = car;
		ply.solid = SOLID_NOT;
		ply.movetype = MOVETYPE_NOCLIP;
		//ply.flags |= FL_FLY;
		ply.modelindex = modelindex_null;
		stuffcmd(ply, "chase_active 1\n");
		stuffcmd(ply, "crosshair 0\n");
		setorigin(ply, car.origin);
		car.driving = ply;
	}
};

void Car_CheckAttach(){
	if (self.driving){
		Car_AttachToVehicle(self, self.driving);
		return;
	}
	entity e = findradius(self.origin + self.view_ofs, 100);
	while(e){
		if (e.classname == "physics_object"){
			if (!e.driving){
				Car_AttachToVehicle(self, e);
				break;
			}
		}
		e = e.chain;
	}
}

void(entity attacker, float damage) Car_Pain = {
	if (!self.realowner.driving)
		return;
	T_Damage(self.realowner.driving, attacker, attacker, damage * 0.5); // driving provides protection
};

void(float turn) Car_Turn =
{
	local float f;
	local entity tright, tleft;

	if (!self.driving)
		return;
	entity car = self.driving;
	tleft = car.frontleft;
	tright = car.frontright;
	tright.physobj_flags = tright.physobj_flags - (tright.physobj_flags & PHFLAGS_RESTING);
	tleft.physobj_flags = tleft.physobj_flags - (tleft.physobj_flags & PHFLAGS_RESTING);
	f = 125;
	float want_yaw = clamp(turn, -35, 35);
	if (want_yaw < 0)
		car.ideal_yaw = max(want_yaw, car.ideal_yaw - f*frametime);
	else if (want_yaw > 0)
		car.ideal_yaw = min(want_yaw, car.ideal_yaw + f*frametime);
	else{
		if (car.ideal_yaw > 0)
			car.ideal_yaw = max(0, car.ideal_yaw - f*2*frametime);
		else
			car.ideal_yaw = min(0, car.ideal_yaw + f*2*frametime);
	}
	// left tire
	makevectors(tleft.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle('0 0 1', car.ideal_yaw);
	tleft.relative_forward = matrix_forward;
	tleft.relative_left = matrix_left;
	tleft.relative_up = matrix_up;
	// right tire
	makevectors(tright.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle('0 0 1', car.ideal_yaw);
	tright.relative_forward = matrix_forward;
	tright.relative_left = matrix_left;
	tright.relative_up = matrix_up;
};

void(float speed, float maxspeed) Car_Accelerate =
{
	local entity tright, tleft;

	if (!self.driving)
		return;
	tleft = self.driving.backleft;
	tright = self.driving.backright;
	float allowAccelerateRight = tright.velocity * tright.lmat_forward < maxspeed;
	float allowAccelerateLeft = tleft.velocity * tleft.lmat_forward < maxspeed;
	if (allowAccelerateRight && tright.flags & FL_ONGROUND){
		tright.physobj_flags = tright.physobj_flags - (tright.physobj_flags & PHFLAGS_RESTING);
		tright.velocity = tright.velocity + tright.lmat_forward *speed*frametime;
	}
	if (allowAccelerateLeft && tleft.flags & FL_ONGROUND){
		tleft.physobj_flags = tleft.physobj_flags - (tleft.physobj_flags & PHFLAGS_RESTING);
		tleft.velocity = tleft.velocity + tleft.lmat_forward *speed*frametime;
	}
};

void(float speed, float maxspeed) Car_Roll =
{
	local entity f_right, f_left;
	local entity b_right, b_left;

	if (!self.driving)
		return;

	f_left = self.driving.frontleft;
	f_right = self.driving.frontright;
	b_left = self.driving.backleft;
	b_right = self.driving.backright;

	if (f_right.flags & FL_ONGROUND && f_left.flags & FL_ONGROUND && b_right.flags & FL_ONGROUND && b_left.flags & FL_ONGROUND) // all tires touching ground, no rolling allowed
		return;

	float fright_lzvel = f_right.velocity * f_right.lmat_up;
	float fleft_lzvel = f_left.velocity * f_left.lmat_up;
	float bright_lzvel = b_right.velocity * b_right.lmat_up;
	float bleft_lzvel = b_left.velocity * b_left.lmat_up;

	float rel_bzvel = fabs(bright_lzvel - bleft_lzvel);
	float rel_fzvel = fabs(fright_lzvel - fleft_lzvel);

	float allowRollFront = (rel_fzvel) < maxspeed;
	float allowRollBack = (rel_bzvel) < maxspeed;
	if (allowRollFront && allowRollBack){

		f_right.physobj_flags = f_right.physobj_flags - (f_right.physobj_flags & PHFLAGS_RESTING);
		f_left.physobj_flags = f_left.physobj_flags - (f_left.physobj_flags & PHFLAGS_RESTING);
		b_right.physobj_flags = b_right.physobj_flags - (b_right.physobj_flags & PHFLAGS_RESTING);
		b_left.physobj_flags = b_left.physobj_flags - (b_left.physobj_flags & PHFLAGS_RESTING);

		f_right.velocity = f_right.velocity + f_right.lmat_up *speed*frametime;
		b_right.velocity = b_right.velocity + b_right.lmat_up *speed*frametime;
		f_left.velocity = f_left.velocity - f_left.lmat_up *speed*frametime;	
		b_left.velocity = b_left.velocity - b_left.lmat_up *speed*frametime;	
	}
}

void TryUpdateVehicle(){
	if (!check_camera_state){
		check_camera_state = TRUE;
		if (self.driving){
			stuffcmd(self, "chase_active 1\n");
			stuffcmd(self, "crosshair 0\n");
		}
		else {
			stuffcmd(self, "chase_active 0\n");
			stuffcmd(self, "crosshair 1\n");
		}
	}
	if (!self.driving)
		return;
	setorigin(self, Car_SpringyOrigin());
	makevectors(self.v_angle);
	float forw = v_forward * self.velocity;
	if (forw > 100){
		Car_Accelerate(3000, 950);
	}
	else if (forw < -100){
		Car_Accelerate(-2500, 800);
	}
	float roll = v_right * self.velocity;
	if (roll > 100){
		Car_Roll(-2000, 350);
	}
	else if (roll < -100){
		Car_Roll(2000, 350);
	}
	float car_angs = self.driving.angles_y;
	if (car_angs > 180)
		car_angs -= 360;
	float move = car_angs - self.v_angle_y;
	if (car_angs > self.v_angle_y)
	{
		if (move > 180)
			move = move - 360;
	}
	else
	{
		if (move < -180)
			move = move + 360;
	}
	Car_Turn(move);
	car_angs = self.driving.angles_x;
	if (car_angs > 180)
		car_angs -= 360;
	float pitch = car_angs - self.v_angle_x;
	if (car_angs > self.v_angle_x)
	{
		if (pitch > 180)
			pitch = pitch - 360;
	}
	else
	{
		if (pitch < -180)
			pitch = pitch + 360;
	}
	Gun_Turn(move, pitch);
	self.velocity = '0 0 0';
	self.modelindex = modelindex_null;
	self.frame = 0;
}

vector() Car_SpringyOrigin =
{
	entity car = self.driving;
	entity tbleft = car.backleft.enemy;
	entity tbright = car.backright.enemy;
	entity tfleft = car.frontleft.enemy;
	entity tfright = car.frontright.enemy;

	vector org = tbleft.origin + tbright.origin + tfleft.origin + tfright.origin;
	org = (org / 4) + car.lmat_up * 16;
#if defined(SMOOTH)
	vector oldorg = tbleft.oldorigin + tbright.oldorigin + tfleft.oldorigin + tfright.oldorigin;
	oldorg = (oldorg / 4) + car.lmat_up * 16;
	vector pos = lerpVector(oldorg, org, 1-(car.frags - time)*10);
#else
	vector pos = org;
#endif
	return pos;
};

/*
void() automake_triton =
{
	entity car = triton();
	
	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin + '0 0 16', v_forward, v_right * -1, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
	Car_AttachToVehicle(self, car);
};
*/