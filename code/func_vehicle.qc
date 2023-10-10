.entity frontright, frontleft, backright, backleft;
.entity gun, driver;

.float max_forward_speed;
.float max_reverse_speed;
.float max_roll_speed;

.float accelerate_forward;
.float accelerate_reverse;
.float accelerate_roll;

.float max_turn;
.float turn_speed;

float VEHICLE_NO_ROOF = 1;
float VEHICLE_PERMANENT_GUN = 2;

entity() hotrod;
entity() triton;

void() Spin_Tires;
float() crandom;
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(vector org, vector vel, float damage) SpawnBlood;

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

	traceline(tireparticle.origin, tireparticle.origin + tireparticle.lmat_up * -tire.frags, TRUE, tire);
	float tracelen = fabs(tireparticle.physobj_spring_length);
	tire.frags = min(tire.frags + frametime*30, tracelen*trace_fraction);
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

	self.nextthink = time;
};

void(float turn, float pitch) Gun_Turn =
{
	local float f;
	if (!self.driving)
		return;
	f = 125;
	entity car = self.driving;
	entity base = car.gun;
	if (!base.modelindex)
		return;
	entity swivel = base.gun;
	if (!swivel)
		return;
	entity body = swivel.gun;
	entity barrel = body.gun;
	float want_yaw = turn - swivel.base_pose_y;
	swivel.ideal_yaw = MoveTowardsAngle(swivel.ideal_yaw, want_yaw, f*frametime);
	makevectors(swivel.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle('0 0 1', swivel.ideal_yaw);
	swivel.relative_forward = matrix_forward;
	swivel.relative_left = matrix_left;
	swivel.relative_up = matrix_up;

	want_yaw = clamp(pitch, -25, 90) - body.base_pose_x;
	body.ideal_yaw = MoveTowardsAngle(body.ideal_yaw, want_yaw, f*frametime);
	Matrix_RotateByAxisAngle(matrix_left, body.ideal_yaw);
	body.relative_forward = matrix_forward;
	body.relative_left = matrix_left;
	body.relative_up = matrix_up;

	if (self.button0){
		barrel.yaw_speed = -1500*frametime;
		if (car.attack_finished <= time){
			car.attack_finished = time + 0.06;

			vector ang = body.angles;
			ang_x = -ang_x;
			makevectors(ang);

			sound (barrel, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

			vector src = body.origin + v_forward*10;

			vector spread = [0.01,0.01,0];

			vector direction = v_forward + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

			traceline (src, src + direction*4096, FALSE, self);
			if (trace_fraction != 1.0){
				vector vel = normalize(direction + v_up*crandom() + v_right*crandom());
				vel = vel + 2*trace_plane_normal;
				vel = vel * 200;

				vector org = trace_endpos - direction*4;

				if (trace_ent.takedamage)
				{
					SpawnBlood (org, vel*0.2, 10);
					T_Damage (trace_ent, self, self, 10);
				}
				else
				{
					WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
					WriteByte (MSG_BROADCAST, TE_GUNSHOT);
					WriteCoord (MSG_BROADCAST, org_x);
					WriteCoord (MSG_BROADCAST, org_y);
					WriteCoord (MSG_BROADCAST, org_z);
				}
			}

		}
	}
	else {
		barrel.yaw_speed = MoveTowards(barrel.yaw_speed, 0, 10 * frametime);
	}
	barrel.ideal_yaw += barrel.yaw_speed;
	Matrix_RotateByAxisAngle(matrix_forward, barrel.ideal_yaw);
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
	local float hasStabilizer;

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
	hasStabilizer = FALSE;
	if (car.frontright && car.frontleft){
		e = car.physobj_sticklist;
		while (e)
		{
			if (e.physobj_p1 == car.frontright || e.physobj_p2 == car.frontright){
				if (e.physobj_p1 == car.frontleft || e.physobj_p2 == car.frontleft){
					e.physobj_flags |= PHFLAGS_STABILIZERBAR;
					hasStabilizer = TRUE;
					break;
				}
			}
			e = e.physobj_next;
		}
		if (!hasStabilizer){ // we better make one then
			e = Phys_ObjectAddStick(car.frontright, car.frontleft, car);
			e.physobj_flags |= PHFLAGS_STABILIZERBAR;
		}
	}
	hasStabilizer = FALSE;
	if (car.backright && car.backleft){
		e = car.physobj_sticklist;
		while (e)
		{
			if (e.physobj_p1 == car.backright || e.physobj_p2 == car.backright){
				if (e.physobj_p1 == car.backleft || e.physobj_p2 == car.backleft){
					e.physobj_flags |= PHFLAGS_STABILIZERBAR;
					hasStabilizer = TRUE;
					break;
				}
			}
			e = e.physobj_next;
		}
		if (!hasStabilizer){ // we better make one then
			e = Phys_ObjectAddStick(car.backright, car.backleft, car);
			e.physobj_flags |= PHFLAGS_STABILIZERBAR;
		}
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
		else if (e.netname == "roof")
		{
			if (car.spawnflags & VEHICLE_NO_ROOF){ // hide
				e.modelindex = 0;
			}
		}
		else if (e.netname == "driver")
		{
			car.driver = e;
			e.mdl = e.model;
			e.modelindex = 0;
		}
		else if (e.netname == "turretbase")
		{
			car.gun = e;
			car.gun.gun = FindStaticOfName("turretswivel", car);
			car.gun.gun.gun = FindStaticOfName("turretbody", car);
			car.gun.gun.gun.gun = FindStaticOfName("turretbarrel", car);
			if (!(car.spawnflags & VEHICLE_PERMANENT_GUN)){ // hide
				car.gun.modelindex = 0;
				car.gun.gun.modelindex = 0;
				car.gun.gun.gun.modelindex = 0;
				car.gun.gun.gun.gun.modelindex = 0;
			}
		}
		e = e.physobj_next;
	}
	car.physobj_extra_think = Spin_Tires;
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
		car.driver.modelindex = 0;
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
		setmodel(car.driver, car.driver.mdl);
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

void(entity tire, float doMatrix) Spin_A_Tire =
{
	entity vistire = tire.enemy;
	if (tire.flags & FL_ONGROUND){
		vistire.yaw_speed = (tire.velocity * tire.lmat_forward) / (PI * tire.relative_size * 0.5);
	}
	else {
		vistire.yaw_speed = MoveTowards(vistire.yaw_speed, 0, 5 * frametime);
	}
	vistire.ideal_yaw = mod(vistire.ideal_yaw - vistire.yaw_speed, 360);
	if (doMatrix){
		makevectors(tire.base_pose);
		matrix_forward = v_forward;
		matrix_left = -v_right;
		matrix_up = v_up;
	}
	Matrix_RotateByAxisAngle(matrix_left, vistire.ideal_yaw);
	vistire.relative_forward = matrix_forward;
	vistire.relative_left = matrix_left;
	vistire.relative_up = matrix_up;
}

void(float turn) Car_Turn =
{
	local float f, want_yaw;
	local entity tright, tleft;

	if (!self.driving)
		return;
	
	entity car = self.driving;
	tleft = car.frontleft;
	tright = car.frontright;
	f = car.turn_speed;
	want_yaw = clamp(turn, -car.max_turn, car.max_turn) - tleft.base_pose_y;
	car.ideal_yaw = MoveTowardsAngle(car.ideal_yaw, want_yaw, f*frametime);

	// left tire
	makevectors(tleft.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle('0 0 1', car.ideal_yaw);
	tleft.relative_forward = matrix_forward;
	tleft.relative_left = matrix_left;
	tleft.relative_up = matrix_up;

	Spin_A_Tire(tleft, FALSE);

	// right tire
	makevectors(tright.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle('0 0 1', car.ideal_yaw);
	tright.relative_forward = matrix_forward;
	tright.relative_left = matrix_left;
	tright.relative_up = matrix_up;

	Spin_A_Tire(tright, FALSE);
};

void(entity tire, float frame_acc) Accelerate_A_Tire =
{
	entity vistire = tire.enemy;
	if (tire.flags & FL_ONGROUND){
		vistire.yaw_speed = (tire.velocity * tire.lmat_forward) / (PI * tire.relative_size * 0.5);
	}
	else {
		vistire.yaw_speed = MoveTowards(vistire.yaw_speed, 0, 10 * frametime);
	}
	if (frame_acc < 0)
		vistire.yaw_speed = min(vistire.yaw_speed, frame_acc * 0.25);
	else if (frame_acc > 0)
		vistire.yaw_speed = max(vistire.yaw_speed, frame_acc * 0.25);
	vistire.ideal_yaw = mod(vistire.ideal_yaw - vistire.yaw_speed, 360);
	makevectors(tire.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle(matrix_left, vistire.ideal_yaw);
	vistire.relative_forward = matrix_forward;
	vistire.relative_left = matrix_left;
	vistire.relative_up = matrix_up;
}

void(float accel, float maxspeed) Car_Accelerate =
{
	float frame_acc;
	local entity tright, tleft;

	if (!self.driving)
		return;
	entity car = self.driving;
	tleft = car.backleft;
	tright = car.backright;

	frame_acc = accel*frametime;
	if (accel != 0) {
		float allowAccelerateRight = tright.velocity * tright.lmat_forward < maxspeed;
		float allowAccelerateLeft = tleft.velocity * tleft.lmat_forward < maxspeed;
		if (allowAccelerateRight && tright.flags & FL_ONGROUND){
			tright.velocity = tright.velocity + tright.lmat_forward * frame_acc;
		}
		if (allowAccelerateLeft && tleft.flags & FL_ONGROUND){
			tleft.velocity = tleft.velocity + tleft.lmat_forward * frame_acc;
		}
	}

	Accelerate_A_Tire(tright, frame_acc);
	Accelerate_A_Tire(tleft, frame_acc);
};

void() Spin_Tires =
{
	if (self.driving)
		return;

	Spin_A_Tire(self.frontleft, TRUE);
	Spin_A_Tire(self.frontright, TRUE);
	Spin_A_Tire(self.backleft, TRUE);
	Spin_A_Tire(self.backright, TRUE);
};

void(float accel, float maxspeed) Car_Roll =
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
		f_right.velocity = f_right.velocity + f_right.lmat_up *accel*frametime;
		b_right.velocity = b_right.velocity + b_right.lmat_up *accel*frametime;
		f_left.velocity = f_left.velocity - f_left.lmat_up *accel*frametime;
		b_left.velocity = b_left.velocity - b_left.lmat_up *accel*frametime;
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
	self.attack_finished = time + 10; // don't allow shooting besides the gun on the car
	entity car = self.driving;
	car.physobj_flags -= (car.physobj_flags & PHFLAGS_RESTING);
	setorigin(self, Car_SpringyOrigin());
	makevectors(self.v_angle);
	float forw = v_forward * self.velocity;
	if (forw > 100){
		Car_Accelerate(car.max_forward_speed, car.accelerate_forward);
	}
	else if (forw < -100){
		Car_Accelerate(-car.max_reverse_speed, car.accelerate_reverse);
	}
	else {
		Car_Accelerate(0, 0);
	}
	makevectors(self.v_angle);
	float roll = v_right * self.velocity;
	if (roll > 100){
		Car_Roll(-car.max_roll_speed, car.accelerate_roll);
	}
	else if (roll < -100){
		Car_Roll(car.max_roll_speed, car.accelerate_roll);
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
	makevectors(car.angles);
	v_forward_z = 0;
	normalize(v_forward);
	float f = (car.velocity * v_forward > 0) * 2 - 1;

	float turn = (mod(self.driving.angles_y - self.v_angle_y + 180, 360) - 180) * f;

	if (f < 0){ // driving backwards, check if we are also aiming backwards, in which case don't flip car around
		if (turn > 100)
			turn -= 180;
		if (turn < -100)
			turn += 180;
	}
	Car_Turn(turn);
	Gun_Turn(self.driving.angles_y - self.v_angle_y, mod(self.driving.angles_x - self.v_angle_x + 180, 360) - 180);
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
	org = (org / 4) + car.lmat_up * car.lip;

	return org;
};

void(entity wheel, entity car) AddWheelStatic =
{
	local entity stat;

	stat = spawn();
	stat.classname = "phys_static";
	stat.netname = wheel.netname;
	setorigin(stat, wheel.origin);
	stat.model = wheel.model;
	wheel.model = 0;
	wheel.classname = "phys_particle";
	stat.base_pose = wheel.base_pose;
	stat.relative_org = wheel.relative_org;
	stat.relative_forward = wheel.relative_forward;
	stat.relative_left = wheel.relative_forward;
	stat.relative_up = wheel.relative_forward;

	stat.physobj_next = car.physobj_staticlist;
	car.physobj_staticlist = stat;
}

void() StartFuncVehicle =
{
	entity e;

	makevectors(self.angles);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	if (self.phys_particle_target) {
		e = find(world, targetname, self.phys_particle_target);
		while(e) {
			e.physobj_next = self.physobj_particlelist;
			self.physobj_particlelist = e;
			e.owner = self;
			e.relative_org = Matrix_MultiplyPoint(e.origin - self.origin);
			e.base_pose = e.angles - self.angles;
			makevectors(e.base_pose);
			e.relative_forward = v_forward;
			e.relative_left = -v_right;
			e.relative_up = v_up;
			if (e.classname == "func_vehicle_wheel" || e.classname == "phys_wheel")
				AddWheelStatic(e, self);
			e = find(e, targetname, self.phys_particle_target);
		}
	}
	if (self.phys_hitmodel_target) {
		e = find(world, targetname, self.phys_hitmodel_target);
		while(e) {
			e.physobj_next = self.physobj_hitmodel;
			self.physobj_hitmodel = e;
			e.owner = self;
			e.relative_org = Matrix_MultiplyPoint(e.origin - self.origin);
			e.base_pose = e.angles - self.angles;
			makevectors(e.base_pose);
			e.relative_forward = v_forward;
			e.relative_left = -v_right;
			e.relative_up = v_up;
			e = find(e, targetname, self.phys_hitmodel_target);
		}
	}
	if (self.phys_static_target){
		e = find(world, targetname, self.phys_static_target);
		while(e) {
			e.physobj_next = self.physobj_staticlist;
			self.physobj_staticlist = e;
			e.owner = self;
			e.relative_org = Matrix_MultiplyPoint(e.origin - self.origin);
			e.base_pose = e.angles - self.angles;
			makevectors(e.base_pose);
			e.relative_forward = v_forward;
			e.relative_left = -v_right;
			e.relative_up = v_up;
			e = find(e, targetname, self.phys_static_target);
		}
	}

	Phys_MakeIntoPhysicsObject(self, self.origin, matrix_forward, matrix_left, matrix_up, '0 0 1', 0);
	self.physobj_impactevent = PushAndDamageTarget;
	Car_InitVehicle(self);
}

// keeping the titular name for the memes, but this is a point entity
/*QUAKED func_vehicle (1 0 0) (-8 -8 -8) (8 8 8)
This is the entity which brings all the disjointed particles, statics and hitmodels together for a fully simulated vehicle

"targetname" must be defined, used by the physics object to find the particle
"model" must be defined, loads a .bsp model to use for pushing objects around
"phys_particle_target" must be defined, the targetname of all the particles and/or wheels in this object
"phys_static_target" the targetname of all the statics in this object
"phys_hitmodel_target" the targetname of all the hitmodels in this object
"physobj_mass" the mass of the entire object
"lip" the offset above the wheels where the player resides, good default 16
*/
void() func_vehicle =
{
	if (cvar("developer") != 0)
		Debug_Precache();
	
	precache_model("progs/null.spr");

	self.think = StartFuncVehicle;
	self.nextthink = time;
};
/*QUAKED phys_hitmodel (1 0 0) (-8 -8 -8) (8 8 8)
Hitmodels are brushes that move together with the physics-object and push entities around (for example monsters).

"targetname" must be defined, used by the physics object to find the particle
"model" must be defined, loads a .bsp model to use for pushing objects around
"angle" base-pose for the physics object
*/
void() phys_hitmodel =
{
	self.physobj_flags = self.physobj_flags | PHFLAGS_BSPMODEL; // this is always a bmodel
	setorigin (self, self.origin);
	if (!self.model)
		error("hitmodel with no model");
	precache_model(self.model);
	setmodel (self, self.model);
}
/*QUAKED func_vehicle_hitmodel (1 0 0) ?
Brush version of phys_hitmodel.

Hitmodels are brushes that move together with the physics-object and push entities around (for example monsters).

"targetname" must be defined, used by the physics object to find the particle
*/
void() func_vehicle_hitmodel =
{
	phys_hitmodel();
}
/*QUAKED phys_particle (1 0 0) (-8 -8 -8) (8 8 8)
Particles are what define the simulation-shape of a physics-object. These collide with the world and other entities.

"targetname" must be defined, used by the physics object to find the particle
"angle" base-pose angle for this particle in the physics object
"physobj_spring_length" length of spring for this particle, primarily meant for wheels (see phys_wheel instead)
"physobj_spring_force" x and y are spring forces based on distance to surface, z is unused, primarily meant for wheels (see phys_wheel instead)
"relative_size" extra-height for particles as an offset from the floor, good default 1
"physobj_stepup" quake-style step-up in stairs. relative_size already gives some step-up inherently, but if relative_size is 0 the quake default would be 18
"part_mass" mass multiplier of this particle, affects center of mass of entire object, mass of 0 makes particle stick in mid-air, good default 1
"physobj_stiction" half-assed attempt at making physics objects not slide infinitely on slopes, good default 10
"physobj_friction_ground" directional ground friction, good default '8 8 8'
"physobj_friction_water" directional water friction, good default '2 2 2'
"physobj_friction_air" directional air friction
"physobj_bounce" 1 means no bounce, 2 means perfect reflection-bounce, good default 1.025
"physobj_buoyancy" gravity multiplier when under-water, good default -0.75
*/
void() phys_particle =
{
	setorigin (self, self.origin);
	if (self.model){
		precache_model(self.model);
		setmodel (self, self.model);
	}
}
/*QUAKED phys_static (1 0 0) (-8 -8 -8) (8 8 8)
Statics are objects which follow the physics-object around but don't affect the physics themselves. Useful for models visually representing the physics-object, and for entrances/exits in a vehicle.

"targetname" must be defined, used by the physics-object to find the static
"model" the model to be loaded for visualization
"netname" in vehicle-contexts useful names are chassis, roof, driver, but also rightdoor, leftdoor, topexit, botexit, backexit, frontexit
"angle" base-pose angle for this static in the physics-object
*/
void() phys_static =
{
	setorigin (self, self.origin);
	if (self.model){
		precache_model(self.model);
		setmodel (self, self.model);
	}
}
/*QUAKED func_vehicle_static (1 0 0) ?
Brush version of phys_static.

Statics are objects which follow the physics-object around but don't affect the physics themselves. Useful for models visually representing the physics-object, and for entrances/exits in a vehicle.

"targetname" must be defined, used by the physics-object to find the static
"netname" in vehicle-contexts useful names are chassis, roof, driver, but also rightdoor, leftdoor, topexit, botexit, backexit, frontexit
*/
void() func_vehicle_static =
{
	self.physobj_flags = self.physobj_flags | PHFLAGS_BSPMODEL;
	phys_static();
}

/*QUAKED phys_wheel (1 0 0) (-8 -8 -8) (8 8 8)
Wheels are useful for vehicles! They're a combo of a particle and a static. Make four of these, with correct netnames and targetnames.

"targetname" must be defined, used by the physics object to find the wheel
"netname" useful names are frontleft, frontright, backleft, backright
"model" the model to be loaded for visualization
"angle" base-pose angle for this wheel in the physics object
"physobj_spring_length" length of spring for this wheel, good default 12
"physobj_spring_force" x and y are spring forces based on distance to surface, z is unused, good default '2 4 0'
"relative_size" radius of wheel, good default 14
"physobj_stepup" quake-style step-up in stairs. relative_size already gives some step-up inherently, but if relative_size is 0 the quake default would be 18
"part_mass" mass multiplier of this wheel, affects center of mass of entire object, mass of 0 makes wheel stick in mid-air, good default 1
"physobj_stiction" half-assed attempt at making physics objects not slide infinitely on slopes, good default 10
"physobj_friction_ground" directional ground friction, higher value on y than x is what allows steering of vehicles. z is used for damping the spring! good default '0.225 3.3 5'
"physobj_friction_water" directional water friction, good default '2 2 2'
"physobj_friction_air" directional air friction
"physobj_bounce" 1 means no bounce, 2 means perfect reflection-bounce, good default 1.025
"physobj_buoyancy" gravity multiplier when under-water, good default -0.75
*/
void() phys_wheel =
{
	setorigin (self, self.origin);
	if (self.model){
		precache_model(self.model);
	}
}
/*QUAKED func_vehicle_wheel (1 0 0) ?
Brush version of phys_wheel.

Wheels are useful for vehicles! They're a combo of a particle and a static. Make four of these, with correct netnames and targetnames.

"targetname" must be defined, used by the physics object to find the wheel
"netname" useful names are frontleft, frontright, backleft, backright
"physobj_spring_length" length of spring for this wheel, good default 12
"physobj_spring_force" x and y are spring forces based on distance to surface, z is unused, good default '2 4 0'
"relative_size" radius of wheel, good default 14
"physobj_stepup" quake-style step-up in stairs. relative_size already gives some step-up inherently, but if relative_size is 0 the quake default would be 18
"part_mass" mass multiplier of this wheel, affects center of mass of entire object, mass of 0 makes wheel stick in mid-air, good default 1
"physobj_stiction" half-assed attempt at making physics objects not slide infinitely on slopes, good default 10
"physobj_friction_ground" directional ground friction, higher value on y than x is what allows steering of vehicles. z is used for damping the spring! good default '0.225 3.3 5'
"physobj_friction_water" directional water friction, good default '2 2 2'
"physobj_friction_air" directional air friction
"physobj_bounce" 1 means no bounce, 2 means perfect reflection-bounce, good default 1.025
"physobj_buoyancy" gravity multiplier when under-water, good default -0.75
*/
void() func_vehicle_wheel =
{
	self.physobj_flags = self.physobj_flags | PHFLAGS_BSPMODEL;
	phys_wheel();
}

void() StartBuiltinVehicle =
{
	makevectors(self.angles);
	entity car = Phys_MakeIntoPhysicsObject(self, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
}

// legacy, hopefully can remove in next release
void() func_vehicle_builtins =
{
	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	if (cvar("developer") != 0)
		Debug_Precache();

	precache_model("progs/null.spr");

	entity car;
	if (self.netname == "triton"){
		precache_model("progs/test/whl.mdl");
		precache_model("progs/test/triton.mdl");
		car = triton();
	}
	else if (self.netname == "hotrod"){
		precache_model("progs/HotRod_body.mdl");
		precache_model("progs/HotRod_roof.mdl");
		precache_model("progs/HotRod_player_driver.mdl");
		precache_model("progs/HotRod_wheel_front_L.mdl");
		precache_model("progs/HotRod_wheel_rear_L.mdl");
		precache_model("progs/HotRod_wheel_front_R.mdl");
		precache_model("progs/HotRod_wheel_rear_R.mdl");
		precache_model("progs/HotRod_turret_base.mdl");
		precache_model("progs/HotRod_turret_swivel.mdl");
		precache_model("progs/HotRod_turret_body.mdl");
		precache_model("progs/HotRod_turret_barrel.mdl");
		car = hotrod();
	}
	
	car.angles = self.angles;
	car.think = StartBuiltinVehicle;
	car.nextthink = time;
	car.spawnflags = self.spawnflags | VEHICLE_PERMANENT_GUN;
};
// legacy, hopefully can remove in next release
void() func_vehicle_triton =
{
	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	if (cvar("developer") != 0)
		Debug_Precache();

	precache_model("progs/null.spr");

	precache_model("progs/test/whl.mdl");
	precache_model("progs/test/triton.mdl");
	entity car = triton();

	car.angles = self.angles;
	car.think = StartBuiltinVehicle;
	car.nextthink = time;
	car.spawnflags = self.spawnflags;
};
/*QUAKED vehicle_hotrod (1 0 0) (-8 -8 -8) (8 8 8) VEHICLE_NO_ROOF VEHICLE_PERMANENT_GUN
The built-in Mad Max styled hotrod. 

SPAWNFLAGS
"vehicle_no_roof" convertible style
"vehicle_permanent_gun" turret always active
*/
void() vehicle_hotrod =
{

	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	if (cvar("developer") != 0)
		Debug_Precache();

	precache_model("progs/null.spr");

	precache_model("progs/HotRod_body.mdl");
	precache_model("progs/HotRod_roof.mdl");
	precache_model("progs/HotRod_player_driver.mdl");
	precache_model("progs/HotRod_wheel_front_L.mdl");
	precache_model("progs/HotRod_wheel_rear_L.mdl");
	precache_model("progs/HotRod_wheel_front_R.mdl");
	precache_model("progs/HotRod_wheel_rear_R.mdl");
	precache_model("progs/HotRod_turret_base.mdl");
	precache_model("progs/HotRod_turret_swivel.mdl");
	precache_model("progs/HotRod_turret_body.mdl");
	precache_model("progs/HotRod_turret_barrel.mdl");
	entity car = hotrod();
	
	car.angles = self.angles;
	car.think = StartBuiltinVehicle;
	car.nextthink = time;
	car.spawnflags = self.spawnflags;
};
// legacy, hopefully can remove in next release
void() func_vehicle_hotrod =
{
	vehicle_hotrod();
};
