
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

void() phys_object =
{
	if (cvar("developer") != 0){
		precache_model("progs/debug/org.mdl");
		precache_model("progs/debug/orgbig.mdl");
	}
	precache_model("progs/null.spr");
	precache_model("progs/debug/point.spr");

	self.think = StartPhysObject;
	self.nextthink = 0.2;
};
