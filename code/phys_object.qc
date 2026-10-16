void StartFuncVehicle();
void PrecacheNull();
void PushAndDamageTarget(entity instigator, entity targ);
void Car_InitVehicle(entity car);

float PHYS_TEMPLATE = 8;

void(entity obj, vector org, vector rot, float keep_velocity) TeleportPhysObject =
{
	local entity e;
	local vector v, forward, left, up;

	makevectors(rot);
	forward = v_forward;
	left = -v_right;
	up = v_up;

	obj.physobj_flags -= (obj.physobj_flags & PHFLAGS_RESTING);

	e = obj.physobj_particlelist;
	while(e)
	{
		v = org + up*e.relative_org_z + left*e.relative_org_y + forward*e.relative_org_x;
		e.physobj_flags -= (e.physobj_flags & PHFLAGS_RESTING);

		setorigin(e, v);
		e.destorigin = e.pushorigin = e.oldorigin = e.origin;
		//if (!keep_velocity) // FIXME: need to figure out how to make this relative to orientation
			setvelocity(e, 0);

		e = e.physobj_next;
	}
}

// teleport testing stuff
/*
void() lethink =
{
	entity car = find(world, classname, "physics_object");
	TeleportPhysObject(car, self.origin, self.angles, TRUE);
}

void() physobj_teleporter =
{
	self.think = lethink;
	self.nextthink = time + 5;
}
*/
void(entity instigator, entity targ) DoNothing ={}

void() StartPhysObject =
{
	local vector com;
	entity e;
	local float particleCount;

	self.think = Phys_ObjectThink;
	self.nextthink = time + 0.2; // needs more leeway than a normal think tick otherwise there be errors for some reason when spawning from map entity
	self.solid = SOLID_TRIGGER;

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

			Phys_InitParticle(e.origin, e, self);
			setvelocity(e, randomvec()*1000);
			particleCount++;
			com += e.relative_org * e.part_mass;

			e = find(e, targetname, self.phys_particle_target);
		}
	}
	GenerateTetrahedrons(self);
	GenerateSticksFromTetrahedrons(self);
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

			Phys_InitHitmodel(e.origin, e, self);

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

			Phys_InitStatic(e.origin, e, self);

			e = find(e, targetname, self.phys_static_target);
		}
	}

	if (cvar("developer") != 0) {
		com /= particleCount;
		e = Phys_SpawnStatic(self.origin + matrix_up*com_z + matrix_left*com_y + matrix_forward*com_x, world, self);
		setmodel(e, "progs/debug/orgbig.mdl");
	}

	self.physobj_impactevent = DoNothing;
	Phys_InitPhysicsObject(self, self.origin, matrix_forward, matrix_left, matrix_up);
}

void(entity e) Phys_HideTemplateParts =
{
	while (e)
	{
		e.modelindex = 0;
		e = e.physobj_next;
	}
};

void(entity tmpl) Phys_MakeTemplate =
{
	Phys_HideTemplateParts(tmpl.physobj_particlelist);
	Phys_HideTemplateParts(tmpl.physobj_hitmodel);
	Phys_HideTemplateParts(tmpl.physobj_staticlist);
	tmpl.solid = SOLID_NOT;
	tmpl.physobj_flags |= PHFLAGS_TEMPLATE;
};

void(entity from, entity to) Phys_CopyPart =
{
	to.classname = from.classname;
	to.netname = from.netname;
	to.model = from.model;
	to.skin = from.skin;
	to.frame = from.frame;
	to.effects = from.effects;
	to.solid = from.solid;
	to.th_pain = from.th_pain;
	to.relative_org = from.relative_org;
	to.base_pose = from.base_pose;
	to.relative_forward = from.relative_forward;
	to.relative_left = from.relative_left;
	to.relative_up = from.relative_up;
	to.relative_size = from.relative_size;
	to.physobj_flags = from.physobj_flags;
	to.part_mass = from.part_mass;
	to.physobj_stepup = from.physobj_stepup;
	to.physobj_spring_length = from.physobj_spring_length;
	to.physobj_spring_force = from.physobj_spring_force;
	to.physobj_friction_ground = from.physobj_friction_ground;
	to.physobj_friction_water = from.physobj_friction_water;
	to.physobj_friction_air = from.physobj_friction_air;
	to.physobj_bounce = from.physobj_bounce;
	to.physobj_buoyancy = from.physobj_buoyancy;
};

entity(entity e, entity obj) Phys_CloneParts =
{
	local entity part, first, last;
	while (e)
	{
		part = spawn();
		Phys_CopyPart(e, part);
		part.owner = obj;
		if (last)
			last.physobj_next = part;
		else
			first = part;
		last = part;
		e = e.physobj_next;
	}
	return first;
};

entity(entity tmpl, vector org, vector ang) Phys_SpawnFromTemplate =
{
	local entity obj;

	obj = spawn();
	obj.classname = tmpl.classname;
	obj.netname = tmpl.netname;
	obj.spawnflags = tmpl.spawnflags - (tmpl.spawnflags & PHYS_TEMPLATE);
	obj.physobj_flags = tmpl.physobj_flags - (tmpl.physobj_flags & PHFLAGS_TEMPLATE);
	obj.physobj_mass = tmpl.physobj_mass;
	obj.lip = tmpl.lip;
	obj.max_forward_speed = tmpl.max_forward_speed;
	obj.max_reverse_speed = tmpl.max_reverse_speed;
	obj.max_roll_speed = tmpl.max_roll_speed;
	obj.accelerate_forward = tmpl.accelerate_forward;
	obj.accelerate_reverse = tmpl.accelerate_reverse;
	obj.accelerate_roll = tmpl.accelerate_roll;
	obj.max_turn = tmpl.max_turn;
	obj.turn_speed = tmpl.turn_speed;
	obj.autolevel_force = tmpl.autolevel_force;
	obj.autolevel_maxangle = tmpl.autolevel_maxangle;
	obj.chase_settings = tmpl.chase_settings;
	obj.physobj_friction_logic_mult = tmpl.physobj_friction_logic_mult;
	obj.physobj_friction_braking_mult = tmpl.physobj_friction_braking_mult;

	obj.physobj_particlelist = Phys_CloneParts(tmpl.physobj_particlelist, obj);
	obj.physobj_hitmodel = Phys_CloneParts(tmpl.physobj_hitmodel, obj);
	obj.physobj_staticlist = Phys_CloneParts(tmpl.physobj_staticlist, obj);

	obj.angles = ang;
	setorigin(obj, org);
	makevectors(ang);
	Phys_MakeIntoPhysicsObject(obj, org, v_forward, -v_right, v_up, '0 0 1', 0);
	if (obj.physobj_flags & PHFLAGS_VEHICLE){
		obj.physobj_impactevent = PushAndDamageTarget;
		Car_InitVehicle(obj);
	}
	else {
		obj.physobj_impactevent = DoNothing;
	}
	return obj;
};

void() phys_object =
{
	if (cvar("developer") != 0)
		Debug_Precache();
	
	PrecacheNull();

	self.think = StartFuncVehicle;
	self.nextthink = time;
};
