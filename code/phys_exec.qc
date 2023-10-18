void(entity attacker, float damage) SUB_NullPain = {};
void(entity part, entity targ) SUB_NullImpact = {};
void(entity part) Particle_CheckOnGround;
void(entity part, float ftime) Particle_Friction;
void(entity part, entity object) Phys_ObjectRemoveParticle;


vector(vector c_maxs, vector c_mins, vector c_org) Clamp =
{
	local vector ret_vec;

	ret_vec_x = min(c_maxs_x, c_org_x);
	ret_vec_x = max(c_mins_x, ret_vec_x);
	ret_vec_y = min(c_maxs_y, c_org_y);
	ret_vec_y = max(c_mins_y, ret_vec_y);
	ret_vec_z = min(c_maxs_z, c_org_z);
	ret_vec_z = max(c_mins_z, ret_vec_z);
	return ret_vec;
};

void(entity targ, vector vel) setvelocity =
{
	targ.physobj_flags = targ.physobj_flags | PHFLAGS_FORCE;
	targ.velocity = vel;
};

void(entity targ, float in_mass, vector inforce, vector hitspot, vector normal) Phys_Force =
{
	local float dot;
	local float t_mass;
	local float closest_dist;
	local vector force;
	local entity part;

	if (!targ.physobj_mass || !in_mass)
		return;

	if (targ.classname == "hitmodel")
		targ = targ.realowner;

	t_mass = min(1, in_mass/targ.physobj_mass);
	targ.physobj_flags = targ.physobj_flags | PHFLAGS_FORCE;
	targ.physobj_flags -= (targ.physobj_flags & PHFLAGS_RESTING);
	targ.flags = targ.flags - (targ.flags & FL_ONGROUND);

	if (targ.physobj_particlelist)
	{
		closest_dist = 999999999;
		part = targ.physobj_particlelist;
		while (part)
		{
			part.force_calcdist = vlen(part.origin - hitspot);
			closest_dist = min(part.force_calcdist, closest_dist);
			part = part.physobj_next;
		}
		part = targ.physobj_particlelist;
		while (part)
		{
			part.force_calcscale = closest_dist/part.force_calcdist;
			part = part.physobj_next;
		}
		targ = targ.physobj_particlelist;
	}
	while(targ)
	{
		dot = normalize(inforce)*normal;
		force = normal*vlen(inforce)*dot*t_mass*targ.force_calcscale;
		setvelocity(targ, targ.velocity + force*0.8); // hack to soften things up a bit, before I figure out wtf is wrong
		//targ.physobj_flags = targ.physobj_flags - (targ.physobj_flags & PHFLAGS_RESTING);
		targ.flags = targ.flags - (targ.flags & FL_ONGROUND);
		targ = targ.physobj_next;
	}
};

// Fixes the worst cases of being stuck inside walls and objects
void(entity targ) Phys_CheckStatus =
{
	local float inverse_frametime, dot, success, best_dot, best_dist;
	local vector best_normal;
	local entity stick, part, oself, t_ent, hitmodel;
	local float f;

	oself = self;
	inverse_frametime = 1 / frametime;
	if (targ)
	{
		part = targ;
		self = targ.realowner;
	}
	else
		part = self.physobj_particlelist;
	// make our hitmodels non-collidey for a moment
	hitmodel = self.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.solid = SOLID_NOT;
		hitmodel = hitmodel.physobj_next;
	}
	while(part)
	{
		Particle_CheckOnGround(part);
		if (part.flags & FL_ONGROUND)
			f++;
		if (part.physobj_flags & PHFLAGS_FORCE)
		{
			self.physobj_flags = self.physobj_flags | PHFLAGS_FORCE;
			part.physobj_flags = part.physobj_flags - (part.physobj_flags & PHFLAGS_FORCE);
		}
		// Wake up in case we got pushed
		if (part.origin != part.pushorigin)
		{
			self.physobj_flags = self.physobj_flags - (self.physobj_flags & PHFLAGS_RESTING);
			//part.physobj_flags = part.physobj_flags - (part.physobj_flags & PHFLAGS_RESTING);
		}

		//tracebox(part.origin, part.mins, part.maxs, part.origin, TRUE, part);
		traceline(part.origin, part.origin, TRUE, part);
		if (trace_startsolid) // we got jammed by a hitmodel or are generally stuck
		{
			//part.solid = SOLID_NOT;
			//part.movetype = MOVETYPE_NONE;
			//part.flags = part.flags - (part.flags & FL_FLY);
			//part.physobj_movetype = MOVE_WORLDONLY;
			part.physobj_movetype = MOVE_NOMONSTERS;
			part.physobj_flags = part.physobj_flags | PHFLAGS_BLOCKED;
			self.physobj_flags = self.physobj_flags - (self.physobj_flags & PHFLAGS_RESTING);
			//part.physobj_flags = part.physobj_flags - (part.physobj_flags & PHFLAGS_RESTING);
			success = FALSE;
			best_dot = 0;
			best_normal = '0 0 0';
			best_dist = 0;
			t_ent = world;
			stick = self.physobj_sticklist;
			while (stick) // trace from any of the free 
			{
				if (stick.physobj_p1 == part)
				{
					if (stick.physobj_p2.relative_size >= stick.physobj_p1.relative_size)
						traceline(stick.physobj_p2.origin, stick.physobj_p1.origin, FALSE, stick.physobj_p2);
						//tracebox(stick.physobj_p2.origin, stick.physobj_p2.mins, stick.physobj_p2.maxs, stick.physobj_p1.origin, FALSE, stick.physobj_p2);
					if (trace_fraction < 1)
					{
						dot = normalize(stick.physobj_p1.origin-stick.physobj_p2.origin)*trace_plane_normal*-1;
						if (dot > best_dot)
						{
							t_ent = trace_ent;
							best_dot = dot;
							best_dist = vlen(trace_endpos - part.origin);
							best_normal = trace_plane_normal;
						}
					}
				}
				else if (stick.physobj_p2 == part)
				{
					if (stick.physobj_p1.relative_size >= stick.physobj_p2.relative_size)
						traceline(stick.physobj_p1.origin, stick.physobj_p2.origin, FALSE, stick.physobj_p1);
						//tracebox(stick.physobj_p1.origin, stick.physobj_p1.mins, stick.physobj_p1.maxs, stick.physobj_p2.origin, FALSE, stick.physobj_p1);
					if (trace_fraction < 1)
					{
						dot = normalize(stick.physobj_p2.origin-stick.physobj_p1.origin)*trace_plane_normal*-1;
						if (dot > best_dot)
						{
							t_ent = trace_ent;
							best_dot = dot;
							best_dist = vlen(trace_endpos - part.origin);
							best_normal = trace_plane_normal;
						}
					}
				}
				stick = stick.physobj_next;
			}
			if (best_dot)
			{
				part.velocity = best_normal*best_dist*best_dot*inverse_frametime;
				//Phys_Force(hitmodel, self.physobj_mass*part.part_mass, part.velocity*-0.01, part.origin+part.velocity*frametime, trace_plane_normal); // lolhax
			}
		}
		else
		{
			//part.solid = SOLID_TRIGGER;
			setorigin(part, part.origin);
			//part.movetype = MOVETYPE_STEP;
			//part.flags = part.flags | FL_FLY;
			part.physobj_flags = part.physobj_flags - (part.physobj_flags & PHFLAGS_BLOCKED);
			part.physobj_movetype = MOVE_NORMAL;
		}
		if (!targ)
			part = part.physobj_next;
		else
			part = world;
	}
	if (f < 3)
		self.physobj_flags -= (self.physobj_flags & PHFLAGS_RESTING);
	hitmodel = self.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.solid = SOLID_BSP;
		setorigin(hitmodel, hitmodel.origin);
		hitmodel = hitmodel.physobj_next;
	}
	self = oself;
};

// Particle acceleration, such as gravity, buoyancy
void(float ftime, float sv_gravity) Phys_Acceleration =
{
	local entity part, hitmodel;

	const float ANTIROLL_MULT = 1.25;

	hitmodel = self.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.solid = SOLID_NOT;
		hitmodel = hitmodel.physobj_next;
	}

	part = self.physobj_particlelist;
	while(part)
	{
		Particle_CheckOnGround(part);
		traceline(part.origin, part.origin, FALSE, part);
		//tracebox(part.origin, part.mins, part.maxs, part.origin, FALSE, part);
		if (trace_inwater)
			part.velocity_z = part.velocity_z + sv_gravity*part.physobj_buoyancy*ftime; // Buoyancy
		else
			part.velocity_z = part.velocity_z - sv_gravity*ftime; // Gravity
		
		if (part.physobj_spring_length)
		{
			if (part.flags & FL_ONGROUND && part.physobj_flags & PHFLAGS_SPRING_TOUCH)
			{
				// EXPERIMENTS
				//float offsetDistance = part.physobj_spring_length;
				//float currentDistance = part.physobj_spring_length * part.physobj_floor_frac;
				//float sf = 0.4;
				//float f = (offsetDistance-currentDistance)*sf * part.physobj_spring_mult;
				//spring = springdir * max(0, (sf.y * p * ftime - damping * ftime));
				
				float p = 1-part.physobj_floor_frac;
				vector v = part.physobj_spring_force;
				float f = lerp(v_x, v_y, p*p) * part.physobj_spring_mult;

				//Debug_DrawLine(part.origin, part.origin + part.lmat_up * 50 * part.physobj_spring_mult, 0.02);

				float damping = part.physobj_spring_force_z;
				vector springdir = part.lmat_up;

				float dampingForce = (normalize(part.velocity) * springdir) * vlen(part.velocity) * damping;
				part.frags = sv_gravity * max(0, (f - dampingForce));
				vector spring = springdir * part.frags;

				part.velocity += spring*ftime;

				// basically the old damping
				//part.velocity -= part.lmat_up*vlen(part.velocity)*(normalize(part.velocity)*part.lmat_up)*damping*4*ftime;
			}
			else
			{
				part.frags = sv_gravity*part.physobj_spring_force_x;
			}
		}
		// Build future positions for particles
		part.destorigin = part.origin + part.velocity * ftime * 2;
		Particle_Friction(part, ftime);
		part = part.physobj_next;
	}

	hitmodel = self.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.solid = SOLID_BSP;
		setorigin(hitmodel, hitmodel.origin);
		hitmodel = hitmodel.physobj_next;
	}
};

const float STABILITY_MULTIPLIER = 1; // lower values make the object more soft, but less prone to randomly exploding

vector(entity p1, entity p2, entity p3) GetGradient =
{
	vector p2p1 = p2.origin - p1.origin;
	vector p3p1 = p3.origin - p1.origin;

	return CrossProduct(p2p1, p3p1);
}

// Run constraints on all tetras
void(float ftime) Phys_Constraints_Volume =
{
	float C, wTotal, lambda;
	float current_volume, rest_volume;
	entity p1, p2, p3, p4, tetra;
	vector grad1, grad2, grad3, grad4;
	float w1, w2, w3, w4;

	tetra = self.physobj_tetralist;
	while(tetra)
	{
		wTotal = 0.0;

		p1 = tetra.physobj_p1;
		p2 = tetra.physobj_p2;
		p3 = tetra.physobj_p3;
		p4 = tetra.physobj_p4;

		w1 = p1.physobj_inversemass;
		w2 = p2.physobj_inversemass;
		w3 = p3.physobj_inversemass;
		w4 = p4.physobj_inversemass;

		grad1 = GetGradient(p2, p4, p3);
		wTotal += w1 * vlensqr(grad1);

		grad2 = GetGradient(p1, p3, p4);
		wTotal += w2 * vlensqr(grad2);

		grad3 = GetGradient(p1, p4, p2);
		wTotal += w3 * vlensqr(grad3);

		grad4 = GetGradient(p1, p2, p3);
		wTotal += w4 * vlensqr(grad4);

		if (wTotal == 0)
			continue;

		current_volume = GetTetraVolumeSextupled(tetra, FALSE);
		rest_volume = tetra.phys_volume;
		C = current_volume - rest_volume;
		lambda = -C / wTotal;

		p1.destorigin += grad1 * lambda * w1;
		p2.destorigin += grad2 * lambda * w2;
		p3.destorigin += grad3 * lambda * w3;
		p4.destorigin += grad4 * lambda * w4;

		tetra = tetra.physobj_next;
	}
};

// Run constraints on all sticks
void(float ftime) Phys_Constraints_Linear =
{
	local float offsetlength, diff, lendiff;
	local vector offset;
	local entity stick;
	local entity p1, p2;

	// Marko 2023: we are running a single iteration because the entire update loop runs multiple times instead, XPBD style
	stick = self.physobj_sticklist;
	while(stick)
	{
		p1 = stick.physobj_p1;
		p2 = stick.physobj_p2;

		if (stick.physobj_flags & PHFLAGS_STABILIZERBAR){
			float p1_mult = p2.physobj_floor_frac - p1.physobj_floor_frac;
			float p2_mult = p1.physobj_floor_frac - p2.physobj_floor_frac;
			
			if (p1_mult < 0)
				p1.physobj_spring_mult = remap(p1_mult + 1, 0, 1, -0.5, 1);
			else
				p1.physobj_spring_mult = 1;
			if (p2_mult < 0)
				p2.physobj_spring_mult = remap(p2_mult + 1, 0, 1, -0.5, 1);
			else
				p2.physobj_spring_mult = 1;
		}

		offset = p1.destorigin - p2.destorigin;
		offsetlength = vlen(offset);
		lendiff = offsetlength-stick.stick_preferredlength;
		if (resting_allowed)
		if (fabs(lendiff) > stick.stick_preferredlength * 0.05)
			resting_allowed = FALSE;
		diff = lendiff/(offsetlength*(p1.physobj_inversemass+p2.physobj_inversemass));
		p1.destorigin = p1.destorigin - p1.physobj_inversemass*offset*diff*STABILITY_MULTIPLIER;
		p2.destorigin = p2.destorigin + p2.physobj_inversemass*offset*diff*STABILITY_MULTIPLIER;
		stick = stick.physobj_next;
	}
};

void(entity part) Particle_CheckOnGround =
{
	local vector spring;

	if (part.physobj_spring_length) // check for springs
	{
		spring = -part.lmat_up * part.physobj_spring_length;
		traceline(part.origin, part.origin + spring, FALSE, part);
		if (trace_fraction < 1)
			part.physobj_flags = part.physobj_flags | PHFLAGS_SPRING_TOUCH;
		else
			part.physobj_flags = part.physobj_flags - (part.physobj_flags & PHFLAGS_SPRING_TOUCH);
	}
	else
	{
		traceline(part.origin, part.origin + '0 0 -1', FALSE, part);
	}
	// We're touching the ground
	if (trace_fraction < 1)
	{
		part.flags = part.flags | FL_ONGROUND;
		part.physobj_floor_plane_normal = trace_plane_normal;
		part.physobj_floor_frac = trace_fraction;
	}
	else{
		part.flags = part.flags - (part.flags & FL_ONGROUND);
		part.physobj_floor_frac = 1;
	}
}

void(entity part, float ftime) Particle_Friction =
{
	local float speed, st, dot;
	vector dir, veldir;

	if (part.flags & FL_ONGROUND)
	{
		speed = vlen(part.velocity);
		// Stiction
		if (part.physobj_stiction > 0)
		{
			if (speed <= part.physobj_stiction) // stiction occurs when moving slow enough
			{
				st = speed/part.physobj_stiction;
				//part.velocity *= st*scaledftime;
				part.velocity *= st;//*ftime;
			}
		}
		// Directional ground friction
		vector normal = part.physobj_floor_plane_normal;

		veldir = normalize(part.velocity);
		if (part.physobj_friction_ground_x){
			vector forwardVel = part.lmat_forward * (part.velocity * part.lmat_forward);
			dir = normalize(forwardVel);
			dot = 1-fabs(dir * normal);
			part.velocity -= part.lmat_forward*speed*(veldir*part.lmat_forward)*part.physobj_friction_ground_x*4*ftime*dot;
		}
		if (part.physobj_friction_ground_y){
			vector sideVel = part.lmat_left * (part.velocity * part.lmat_left);
			dir = normalize(sideVel);
			dot = 1-fabs(dir * normal);
			part.velocity -= part.lmat_left*speed*(veldir*part.lmat_left)*part.physobj_friction_ground_y*4*ftime*dot;
		}
		if (part.physobj_friction_ground_z){
			vector upVel = part.lmat_up * (part.velocity * part.lmat_up);
			dir = normalize(upVel);
			dot = 1-fabs(dir * normal);
			part.velocity -= part.lmat_up*speed*(veldir*part.lmat_up)*part.physobj_friction_ground_z*4*ftime*dot;
		}
		
		/*
		vector normal = part.physobj_floor_plane_normal;
		vector forwardVel = part.lmat_forward * (part.velocity * part.lmat_forward);
		vector sideVel = part.lmat_left * (part.velocity * part.lmat_left);
		vector upVel = part.lmat_up * (part.velocity * part.lmat_up);
		
		//vector tangent = normalize(forwardVel - (forwardVel * normal) * normal);
		float scaledftime = ftime * 275;

		// forward friction
		speed = vlen(forwardVel);
		dir = normalize(forwardVel);
		dot = 1-fabs(dir * normal);
		speed = max(0, speed - part.physobj_friction_ground_x * 5 * scaledftime * dot);
		forwardVel = dir * speed;
		
		// sideways friction
		speed = vlen(sideVel);
		dir = normalize(sideVel);
		dot = 1-fabs(dir * normal);

		// increase sideways friction based on side speed

		// EXPERIMENT
		//float dot2 = dir * tangent;
		//float det = normal * CrossProduct(dir, tangent);
		//float ang = atan2(det, dot2);
		//dprint(ftos(ang));
		//dprint("\n");
		//float sidedot = 1;//remap(ang, );
		//float fricc = part.physobj_friction_ground_y * 4 * sidedot;

		//EXPERIMENT 2
		float fricc = part.physobj_friction_ground_y * 2 + speed * 0.045;
		speed = max(0, speed - fricc * scaledftime * dot);
		sideVel = dir * speed;

		// up friction
		speed = vlen(upVel);
		dir = normalize(upVel);
		dot = 1-fabs(dir * normal);
		speed = max(0, speed - part.physobj_friction_ground_z * 5 * scaledftime * dot);
		upVel = dir * speed;
		
		part.velocity = forwardVel + sideVel + upVel;
		*/
	}
	traceline(part.origin, part.origin, TRUE, part);
	//tracebox(part.origin, part.mins, part.maxs, part.origin, TRUE, part);
	// Water friction
	//if (trace_inwater)
	if (pointcontents(part.origin) < CONTENT_SOLID)
	{
		if (part.physobj_friction_water_x)
			part.velocity = part.velocity - part.lmat_forward*vlen(part.velocity)*normalize(part.velocity)*part.lmat_forward*part.physobj_friction_water_x*ftime;
		if (part.physobj_friction_water_y)
			part.velocity = part.velocity - part.lmat_left*vlen(part.velocity)*normalize(part.velocity)*part.lmat_left*part.physobj_friction_water_y*ftime;
		if (part.physobj_friction_water_z)
			part.velocity = part.velocity - part.lmat_up*vlen(part.velocity)*normalize(part.velocity)*part.lmat_up*part.physobj_friction_water_z*ftime;
	}
	/*
	// Marko 2023: disabled air friction because it's a bunch of calcs for probably unused feature, remove the comments if you need it
	// Air friction
	else if (!trace_startsolid)
	{
		if (part.physobj_friction_air_x)
			part.velocity = part.velocity - part.lmat_forward*vlen(part.velocity)*normalize(part.velocity)*part.lmat_forward*part.physobj_friction_air_x*ftime;
		if (part.physobj_friction_air_y)
			part.velocity = part.velocity - part.lmat_left*vlen(part.velocity)*normalize(part.velocity)*part.lmat_left*part.physobj_friction_air_y*ftime;
		if (part.physobj_friction_air_z)
			part.velocity = part.velocity - part.lmat_up*vlen(part.velocity)*normalize(part.velocity)*part.lmat_up*part.physobj_friction_air_z*ftime;
	}
	*/
}


// Velocity Verlet physics, meant to be used for all moving entities in the game
void(float ftime) Phys_Move =
{
	local float bump, it;
	local float t, f, inverse_frametime;
	local float stuck;
	local vector test_org;
	local entity part, killme, hitmodel;

	local vector save_endpos;
	local vector save_normal;
	local vector save_velocity;
	local float save_fraction;
	local entity save_ent;

	hitmodel = self.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.solid = SOLID_NOT;
		hitmodel = hitmodel.physobj_next;
	}

	inverse_frametime = 1 / ftime;

	part = self.physobj_particlelist;
	if (!part)
		part = self;
	while(part)
	{
		// Convert back from future positions set by constraints to velocities again
		part.velocity = (part.destorigin - part.origin) * inverse_frametime;

		part.oldorigin = part.origin;
		bump = 0;
		it = 0;
		stuck = FALSE;
		t = ftime;
		test_org = part.origin;
		while (bump < 24)
		{
			// let's test if we're stuck first
			it = 0;
			bump = bump + 1;
			if (!stuck && !(part.physobj_flags & PHFLAGS_BLOCKED))
			{
				traceline(part.origin, part.origin, TRUE, part);
				//tracebox(part.origin, part.mins, part.maxs, part.origin, TRUE, part);
				if (trace_startsolid)
					stuck = TRUE;
			}
			while (stuck && it < 16)
			{
				it = it + 1;
				test_org = part.origin + randomvec()*0.125; // let's nudge the origin a bit
				traceline(test_org, test_org, TRUE, part);
				//tracebox(test_org, part.mins + '-0.05 -0.05 -0.05', part.maxs + '0.05 0.05 0.05', test_org, TRUE, part);
				if (!trace_startsolid)
				{
					stuck = FALSE;
					break;
				}
				else
					test_org = part.origin;
			}
			traceline(test_org, test_org + part.velocity*t, part.physobj_movetype, part);
			//tracebox(test_org, part.mins, part.maxs, test_org + part.velocity*t, part.physobj_movetype, part);
			save_fraction = trace_fraction;
			save_normal = trace_plane_normal;
			save_endpos = trace_endpos;
			// check if the move was valid
			if (!(part.physobj_flags & PHFLAGS_BLOCKED))
			{
				traceline(trace_endpos, trace_endpos, TRUE, part);
				//tracebox(trace_endpos, part.mins, part.maxs, trace_endpos, TRUE, part);
				if (trace_startsolid)
				{
					stuck = TRUE;
					continue; // nope, start over
				}
			}
			trace_endpos = save_endpos;
			trace_plane_normal = save_normal;
			trace_fraction = save_fraction;
			t = t*(1-trace_fraction);
			if (trace_fraction < 1)
			{
				// Check for stair steps
				if (part.physobj_stepup > 0 && trace_plane_normal_z <= 0)
				{
					save_fraction = trace_fraction;
					save_normal = trace_plane_normal;
					save_endpos = trace_endpos;
					save_ent = trace_ent;
					traceline(trace_endpos + '0 0 1'*part.physobj_stepup, trace_endpos + '0 0 1'*part.physobj_stepup + part.velocity * t, part.physobj_movetype, part);
					//tracebox(trace_endpos + '0 0 1'*part.physobj_stepup, part.mins, part.maxs, trace_endpos + '0 0 1'*part.physobj_stepup + part.velocity * t, part.physobj_movetype, part);
					if (!trace_startsolid && trace_fraction > 0.0001)
					{
						t = t * (1 - trace_fraction);
						save_ent = trace_ent;
						save_normal = trace_plane_normal;
						traceline(trace_endpos, trace_endpos + '0 0 -1'*part.physobj_stepup, part.physobj_movetype, part);
						//tracebox(trace_endpos, part.mins, part.maxs, trace_endpos + '0 0 -1'*part.physobj_stepup, part.physobj_movetype, part);
						trace_fraction = save_fraction;
						trace_ent = save_ent;
					}
					else
					{
						trace_endpos = save_endpos;
						trace_plane_normal = save_normal;
						trace_fraction = save_fraction;
						trace_ent = save_ent;
					}
				}
				// Let's push stuff we hit
				Phys_Force(trace_ent, part.physobj_mass*part.part_mass, part.velocity, trace_endpos, save_normal);
				// Impact event
				self.physobj_impactevent(part, trace_ent);
				save_velocity = part.velocity;
				// Bounce
				part.velocity = part.velocity - part.physobj_bounce*(trace_plane_normal * (trace_plane_normal * part.velocity));
			}
			else {
				// let's push monsters and players
				save_fraction = trace_fraction;
				save_endpos = trace_endpos;

				vector end_org = test_org + part.velocity*ftime*5;// + normalize(part.velocity)*part.relative_size;
				traceline(test_org, end_org, part.physobj_movetype, part);
				if (trace_fraction < 1)
					self.physobj_impactevent(part, trace_ent);

				trace_fraction = save_fraction;
				trace_endpos = save_endpos;
			}
			if (trace_fraction >= 0.0001)
			{
				setorigin(part, trace_endpos);
				force_retouch = 2;
				test_org = part.origin;
			}
			if (trace_fraction == 1)
				break;
		}
		part.pushorigin = part.origin;

		if(resting_allowed)
		{
			if(!(part.physobj_flags & PHFLAGS_BLOCKED))
			{
				if (vlen(part.origin - part.oldorigin) > ftime*5)
					resting_allowed = FALSE;
				else if (part.flags & FL_ONGROUND)
					f++;
			}
		}

		if (part.physobj_flags & PHFLAGS_KILLME)
		{
			killme = part;
			part = part.physobj_next;
			Phys_ObjectRemoveParticle(killme, self);
		}
		else
			part = part.physobj_next;
	}
	hitmodel = self.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.solid = SOLID_BSP;
		setorigin(hitmodel, hitmodel.origin);
		hitmodel = hitmodel.physobj_next;
	}
	if (f < 3)
		resting_allowed = FALSE;
};

// The think function for our physics objects in the game
void() Phys_ObjectThink =
{
	local float f, ftime, steps;//, iterations, coldot;
	//local float best_vel, best_len, vel_limit, vel;
	local entity part, hitmodel, stat;

	// Run every frame
	self.nextthink = time;

	local float sv_gravity = cvar("sv_gravity");

	Phys_CheckStatus(world); // Check in case we got pushed, got stuck, or the ground beneath us disappeared

	if (!(self.physobj_flags & PHFLAGS_RESTING))
	{
		steps = 2; // should be a cvar, higher means more stable but costs more perf
		ftime = 1/steps;
		ftime = ftime*frametime;

		resting_allowed = TRUE;
		// Let's run some physics
		while(steps)
		{
			steps--;
			Phys_Acceleration(ftime*0.5, sv_gravity);
			Phys_Constraints_Volume(ftime);
			Phys_Constraints_Linear(ftime);
			Phys_Move(ftime);
			Phys_Acceleration(ftime*0.5, sv_gravity);
		}
		self.physobj_flags = self.physobj_flags - (self.physobj_flags & PHFLAGS_FORCE);

		if (resting_allowed) // resting still allowed after various checks
			self.physobj_flags |= PHFLAGS_RESTING;

		// calculate an object matrix from the first three particles, used for orientation (magic)
		Matrix_CalculateObjectMatrix(self);
		self.lmat_forward = matrix_forward;
		self.lmat_left = matrix_left;
		self.lmat_up = matrix_up;

		// Update particle orientations
		part = self.physobj_particlelist;
		while(part)
		{
			/*
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
			WriteEntity (MSG_BROADCAST, part);
			WriteCoord (MSG_BROADCAST, part.origin_x);
			WriteCoord (MSG_BROADCAST, part.origin_y);
			WriteCoord (MSG_BROADCAST, part.origin_z);
			WriteCoord (MSG_BROADCAST, part.origin_x);
			WriteCoord (MSG_BROADCAST, part.origin_y);
			WriteCoord (MSG_BROADCAST, part.origin_z + 10);
			*/
			Matrix_Multiply(part.relative_forward, part.relative_left, part.relative_up, self.lmat_forward, self.lmat_left, self.lmat_up);
			part.lmat_forward = matrix_forward;
			part.lmat_left = matrix_left;
			part.lmat_up = matrix_up;
			// Update euler angles for viewing ingame
			part.angles = vectoangles2(matrix_forward, matrix_up);
			if (part.physobj_flags & PHFLAGS_BSPMODEL)
				part.angles_x = part.angles_x*-1;
			part = part.physobj_next;
		}
		// Update static object orientations and origins
		stat = self.physobj_staticlist;
		while (stat)
		{
			Matrix_Multiply(stat.relative_forward, stat.relative_left, stat.relative_up, self.lmat_forward, self.lmat_left, self.lmat_up);
			stat.lmat_forward = matrix_forward;
			stat.lmat_left = matrix_left;
			stat.lmat_up = matrix_up;
			// Update euler angles for viewing ingame
			// Static objects aren't affected by physics
			stat.angles = vectoangles2(matrix_forward, matrix_up);
			if (stat.physobj_flags & PHFLAGS_BSPMODEL)
				stat.angles_x = stat.angles_x*-1;
			stat.oldorigin = stat.origin;
			setorigin (stat, self.physobj_p1.origin + self.lmat_forward*stat.relative_org_x + self.lmat_left*stat.relative_org_y + self.lmat_up*stat.relative_org_z);
			stat = stat.physobj_next;
		}
		// Pushing is broken somehow :(
		// Either causes sign errors, or just acts plain weird and crazy
		// So we have to rely on pushing stuff out of solids
		/*
		hitmodel = self.physobj_hitmodel;
		while (hitmodel)
		{
			Matrix_Multiply(hitmodel.relative_forward, hitmodel.relative_left, hitmodel.relative_up, self.lmat_forward, self.lmat_left, self.lmat_up);
			hitmodel.lmat_forward = matrix_forward;
			hitmodel.lmat_left = matrix_left;
			hitmodel.lmat_up = matrix_up;
			hitmodel.angles = vectoangles2(matrix_forward, matrix_up);
			if (hitmodel.physobj_flags & PHFLAGS_BSPMODEL)
				hitmodel.angles_x = hitmodel.angles_x*-1;
			setorigin (hitmodel, self.physobj_p1.origin + self.lmat_forward*hitmodel.relative_org_x + self.lmat_left*hitmodel.relative_org_y + self.lmat_up*hitmodel.relative_org_z);
			hitmodel = hitmodel.physobj_next;
		}
		*/
		setorigin (self, self.physobj_p1.origin + self.lmat_forward*self.relative_org_x + self.lmat_left*self.relative_org_y + self.lmat_up*self.relative_org_z);
		self.angles = vectoangles2(self.lmat_forward, self.lmat_up);
		self.angles_x = -self.angles_x;
		self.velocity = self.physobj_p1.velocity; // FIXME: count average velocity
		if (self.physobj_extra_think)
			self.physobj_extra_think();
	}
	// Update BSP collision model rotation and velocity
	hitmodel = self.physobj_hitmodel;
	while (hitmodel)
	{
		Matrix_Multiply(hitmodel.relative_forward, hitmodel.relative_left, hitmodel.relative_up, self.lmat_forward, self.lmat_left, self.lmat_up);
		f = 1 / frametime;
		vector offset = self.physobj_p1.origin + self.lmat_forward*hitmodel.relative_org_x + self.lmat_left*hitmodel.relative_org_y + self.lmat_up*hitmodel.relative_org_z;
		hitmodel.velocity = (offset - hitmodel.origin)*f;
		/*vector ang = vectoangles2(matrix_forward, matrix_up);
		if (hitmodel.physobj_flags & PHFLAGS_BSPMODEL)
			ang_x = ang_x*-1;
		vector anglediff = ang - hitmodel.angles;
		anglediff_x = anglediff_x - 360*floor((anglediff_x + 180) / 360);
		anglediff_y = anglediff_y - 360*floor((anglediff_y + 180) / 360);
		anglediff_z = anglediff_z - 360*floor((anglediff_z + 180) / 360);
		hitmodel.avelocity = anglediff*f;*/
		hitmodel.nextthink = 1000000000; // ultimahax
		hitmodel = hitmodel.physobj_next;
	}
	force_retouch = 2;
};

entity(vector org, entity e, entity obj) Phys_InitStatic =
{
	local vector v;

	if (e.model)
		setmodel(e, e.model);

	e.th_die = SUB_Null;
	e.th_pain = SUB_NullPain;
	//e.contentstransition = SUB_Null;

	setorigin(e, org);
	v_x = e.relative_size;
	v_y = v_x;
	v_z = v_x;
	setsize(e, v*-1, v);
	return e;
}

entity(vector org, entity basepart, entity obj) Phys_SpawnStatic =
{
	//local float f;
	//local vector v;
	//local string s;
	local entity e;

	e = spawn();
	e.classname = "static";
	e.owner = obj;
	if (e.owner)
	{
		e.physobj_next = e.owner.physobj_staticlist;
		e.owner.physobj_staticlist = e;
	}
	if (basepart)
	{
		e.netname = basepart.netname;
		e.base_pose = basepart.base_pose;
		e.relative_forward = basepart.relative_forward;
		e.relative_left = basepart.relative_left;
		e.relative_up = basepart.relative_up;
		e.relative_org = basepart.relative_org;
		e.relative_size = basepart.relative_size;
		e.model = basepart.model;
	}
	else
	{
		e.netname = "static";
		e.base_pose = '0 0 0';
		e.relative_forward = '1 0 0';
		e.relative_left = '0 1 0';
		e.relative_up = '0 0 1';
		e.relative_org = org;
		e.relative_size = 0;
	}
	return Phys_InitStatic(org, e, obj);
};

// MOVETYPE_STEP/FL_FLY/SOLID_TRIGGER combo is used to make the particles pushable by MOVETYPE_PUSH objects, while still be able to hang in the air and be essentially non-solid
entity(vector org, entity e, entity obj) Phys_InitParticle =
{
	local vector v;

	if (e.model)
		setmodel(e, e.model);

	if (e.owner)
		e.physobj_mass = e.owner.physobj_mass; // used as a shortcut in force calculations
	e.physobj_inversemass = 1 / e.part_mass;
	//e.effects = EF_NOMODELFLAGS;
	e.takedamage = DAMAGE_YES;
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	//e.solid = SOLID_TRIGGER;
	//e.movetype = MOVETYPE_STEP;
	//e.flags = FL_FLY;
	e.physobj_spring_mult = 1;

	e.th_die = SUB_Null;
	e.th_pain = SUB_NullPain;
	//e.contentstransition = SUB_Null;
	if (cvar("developer") == 2){
		setmodel(e, "progs/debug/org.mdl");
#ifdef QSSDEP
		e.scale = e.part_mass;
#endif
	}

	setorigin(e, org);
	e.pushorigin = e.oldorigin = e.origin;
	v_x = e.relative_size;
	v_y = v_x;
	v_z = v_x;
	setsize(e, v*-1, v);
	return e;
}

// Spawns particles for both the editor and ingame
entity(vector org, entity basepart, entity obj) Phys_SpawnParticle =
{
	//local float f;
	//local vector v;
	local entity e;
	//local string s;

	e = spawn();
	e.classname = "particle";
	e.owner = obj;
	if (e.owner)
	{
		e.physobj_next = e.owner.physobj_particlelist;
		e.owner.physobj_particlelist = e;
	}
	if (basepart)
	{
		e.netname = basepart.netname;
		e.part_mass = basepart.part_mass;
		e.physobj_bounce = basepart.physobj_bounce;
		e.physobj_spring_length = basepart.physobj_spring_length;
		e.physobj_spring_force = basepart.physobj_spring_force;
		e.physobj_friction_ground = basepart.physobj_friction_ground;
		e.physobj_friction_water = basepart.physobj_friction_water;
		e.physobj_friction_air = basepart.physobj_friction_air;
		e.physobj_buoyancy = basepart.physobj_buoyancy;
		e.physobj_stiction = basepart.physobj_stiction;
		e.physobj_stepup = basepart.physobj_stepup;
		e.physobj_p1 = basepart.physobj_p1;
		e.physobj_p2 = basepart.physobj_p2;
		e.base_pose = basepart.base_pose;
		e.relative_forward = basepart.relative_forward;
		e.relative_left = basepart.relative_left;
		e.relative_up = basepart.relative_up;
		e.relative_org = basepart.relative_org;
		e.relative_size = basepart.relative_size;
		e.model = basepart.model;
	}
	else
	{
		e.part_mass = 1;
		e.physobj_stiction = 50;
		e.physobj_friction_ground = '7.5 7.5 7.5';
		e.physobj_friction_water = '1 1 1';
		e.physobj_friction_air = '0 0 0';
		e.physobj_bounce = 1.2;
		e.physobj_stepup = 0;
		e.physobj_buoyancy = 0.2;
		e.base_pose = '0 0 0';
		e.relative_forward = '1 0 0';
		e.relative_left = '0 1 0';
		e.relative_up = '0 0 1';
		e.relative_org = org;
		e.relative_size = 0;
	}
	return Phys_InitParticle(org, e, obj);
};

entity(vector org, entity e, entity obj) Phys_InitHitmodel =
{
	if (e.model)
		setmodel(e, e.model);
	e.physobj_flags = e.physobj_flags | PHFLAGS_BSPMODEL; // always assume bmodel for hitmodels

	if (e.owner)
		e.physobj_mass = obj.physobj_mass;
	e.takedamage = DAMAGE_AIM;
	e.solid = SOLID_BSP;
	e.movetype = MOVETYPE_PUSH;
	e.health = 99999999;
	//e.effects = EF_NOMODELFLAGS;
	e.model = ""; // better way to nosend than EF_NODRAW

	e.th_die = SUB_Null;
	//e.contentstransition = SUB_Null;

	setorigin(e, org);
	return e;
}

// Spawns hitmodels for both the editor and ingame
entity(vector org, entity basepart, entity obj) Phys_SpawnHitmodel =
{
	//local float f;
	//local vector v;
	local entity e;
	//local string s;

	e = spawn();
	e.classname = "hitmodel";
	e.owner = obj;
	if (e.owner)
	{
		e.physobj_next = e.owner.physobj_hitmodel;
		e.owner.physobj_hitmodel = e;
	}
	if (basepart)
	{
		e.netname = basepart.netname;
		e.relative_org = basepart.relative_org;
		e.base_pose = basepart.base_pose;
		e.relative_forward = basepart.relative_forward;
		e.relative_left = basepart.relative_left;
		e.relative_up = basepart.relative_up;
		e.blocked = basepart.blocked;
		e.touch = basepart.touch;
		e.th_pain = basepart.th_pain;
		e.model = basepart.model;
	}
	else
	{
		e.netname = "hitmodel";
		e.base_pose = '0 0 0';
		e.relative_forward = '1 0 0';
		e.relative_left = '0 1 0';
		e.relative_up = '0 0 1';
		e.relative_org = org;
		e.th_pain = SUB_NullPain;
	}
	return Phys_InitHitmodel(org, e, obj);
};

entity(entity basepart, entity obj) Phys_SpawnTetra =
{
	local entity e;

	e = spawn();
	e.classname = "tetra";
	e.owner = obj;
	if (e.owner)
	{
		e.physobj_next = obj.physobj_tetralist;
		obj.physobj_tetralist = e;
	}
	if (basepart)
	{
		e.netname = basepart.netname;
		e.phys_volume = basepart.phys_volume;
		e.phys_radius = basepart.phys_radius;
		e.phys_center = basepart.phys_center;
		e.physobj_p1 = basepart.physobj_p1.enemy;
		e.physobj_p2 = basepart.physobj_p2.enemy;
		e.physobj_p3 = basepart.physobj_p3.enemy;
		e.physobj_p4 = basepart.physobj_p4.enemy;
		e.physobj_flags = basepart.physobj_flags;
	}
	return e;
};

entity(entity basepart, entity obj) Phys_SpawnStick =
{
	local entity e;

	e = spawn();
	e.classname = "stick";
	e.owner = obj;
	if (e.owner)
	{
		e.physobj_next = obj.physobj_sticklist;
		obj.physobj_sticklist = e;
	}
	if (basepart)
	{
		e.netname = basepart.netname;
		e.physobj_p1 = basepart.physobj_p1.enemy;
		e.physobj_p2 = basepart.physobj_p2.enemy;
		e.physobj_flags = basepart.physobj_flags;
		e.stick_preferredlength = basepart.stick_preferredlength;
	}
	return e;
};

entity(entity basepart) Phys_ObjectSpawn =
{
	local entity e;
	e = spawn();
	e.classname = "physics_object";
	e.netname = basepart.netname;
	e.physobj_mass = basepart.physobj_mass;
	e.physobj_impactevent = basepart.physobj_impactevent;
	setorigin(e, basepart.origin);
	e.think = Phys_ObjectThink;
	e.nextthink = time + 0.2; // needs more leeway than a normal think tick otherwise there be errors for some reason when spawning from map entity
	//e.contentstransition = SUB_Null;
	e.solid = SOLID_TRIGGER;
	return e;
};

void(entity obj) Phys_ObjectRemove =
{
	local entity e, next;
	if (!obj)
		return;
	e = obj.physobj_particlelist;
	while (e)
	{
		next = e.physobj_next;
		remove(e);
		e = next;
	}
	e = obj.physobj_sticklist;
	while (e)
	{
		next = e.physobj_next;
		remove(e);
		e = next;
	}
	e = obj.physobj_hitmodel;
	while (e)
	{
		next = e.physobj_next;
		remove(e);
		e = next;
	}
	e = obj.physobj_staticlist;
	while (e)
	{
		next = e.physobj_next;
		remove(e);
		e = next;
	}
	remove(obj);
};

void(entity stick, entity object) Phys_ObjectRemoveStick =
{
	local entity e;

	e = object.physobj_sticklist;
	if (e == stick)
		object.physobj_sticklist = stick.physobj_next;
	else
	{
		while (e)
		{
			if (e.physobj_next == stick)
			{
				e.physobj_next = stick.physobj_next;
				break;
			}
			e = e.physobj_next;
		}
	}
	remove(stick);
};

void(entity part, entity object) Phys_ObjectRemoveParticle =
{
	local entity e;

	e = object.physobj_sticklist;
	while (e)
	{
		if (e.physobj_p1 == part || e.physobj_p2 == part)
			Phys_ObjectRemoveStick(e, object);
		e = e.physobj_next;
	}
	e = object.physobj_particlelist;
	if (e == part)
		object.physobj_particlelist = part.physobj_next;
	else
	{
		while (e)
		{
			if (e.physobj_next == part)
			{
				e.physobj_next = part.physobj_next;
				break;
			}
			e = e.physobj_next;
		}
	}
	remove(part);
};

entity(entity p1, entity p2, entity obj) Phys_ObjectAddStick =
{
	local entity e;
	
	e = spawn();
	e.classname = "stick";
	e.owner = obj;
	if (e.owner)
	{
		e.physobj_next = e.owner.physobj_sticklist;
		e.owner.physobj_sticklist = e;
	}
	e.physobj_p1 = p1;
	e.physobj_p2 = p2;
	e.stick_preferredlength = vlen(p2.relative_org - p1.relative_org);
	return e;
};

entity(vector org, entity object) Phys_AddParticleToObject =
{
	local vector save_rel;
	local entity e, stick, part, end;

	part = object.physobj_particlelist;
	while(part)
	{
		end = part;
		part = part.physobj_next;
	}

	e = Phys_SpawnParticle(org, world, world);
	//e.owner = object.physobj_hitmodel;
	end.physobj_next = e;

	stick = object.physobj_sticklist;
	while(stick)
	{
		end = stick;
		stick = stick.physobj_next;
	}
	part = object.physobj_particlelist;
	while (part && part != e)
	{
		save_rel = part.relative_org;
		part.relative_org = part.origin;
		stick = Phys_ObjectAddStick(e, part, world);
		part.relative_org = save_rel;
		stick.owner = object;
		end.physobj_next = stick;
		end = stick;
		part = part.physobj_next;
	}
	return e;
};
/*
// obsolete
void() Phys_SpawnSticks =
{
	local float f, total_particles, total_sticks;
	local entity part1, part2;

	total_particles = 0;
	part1 = physobj_spawning.physobj_particlelist;
	while (part1)
	{
		total_particles = total_particles + 1;
		part1 = part1.physobj_next;
	}
	part1 = physobj_spawning.physobj_particlelist;
	while (part1)
	{
		part2 = part1;
		total_particles = total_particles - 1;
		f = 0;
		while (f < total_particles)
		{
			part2 = part2.physobj_next;
			if (Phys_ObjectAddStick(part1, part2, physobj_spawning))
				total_sticks++;
			f = f + 1;
		}
		part1 = part1.physobj_next;
	}
	dprint(ftos(total_sticks));
	dprint("\n");
}
*/

// find some particles far apart from eachother, nice for orientation of visible meshes
void(entity obj) Phys_AssignFirstThreeParticles =
{
	entity e;
	vector v = '10000 10000 10000';
	vector sv;
	e = obj.physobj_particlelist;
	while(e)
	{
		if (e.relative_org.x <= v.x && e.relative_org.y <= v.y && e.relative_org.z <= v.z){
			obj.physobj_p1 = e;
			v = e.relative_org;
		}
		e = e.physobj_next;
	}
	sv = v;
	e = obj.physobj_particlelist;
	while(e)
	{
		if (e.relative_org.x > sv.x){
			obj.physobj_p2 = e;
			sv = e.relative_org;
		}
		e = e.physobj_next;
	}
	e = obj.physobj_particlelist;
	while(e)
	{
		if (e.relative_org.y > v.y){
			obj.physobj_p3 = e;
			v = e.relative_org;
		}
		e = e.physobj_next;
	}
	if (obj.physobj_p3)
		return;
	e = obj.physobj_particlelist;
	while(e)
	{
		if (e.relative_org.y < v.y){
			obj.physobj_p3 = e;
			v = e.relative_org;
		}
		e = e.physobj_next;
	}
}

entity(entity obj, vector org, vector forward, vector left, vector up) Phys_InitPhysicsObject =
{
	local float f;
	local entity e;
	local vector org1, org2, org3, v;

	// Assign the first three particles, used for origin and orientation of the object ingame
	Phys_AssignFirstThreeParticles(obj);

	// Recalculate relative_org for use ingame
	e = obj.physobj_hitmodel;
	while (e)
	{
		e.realowner = e.owner;
		v = e.origin - obj.physobj_p1.origin;
		e.relative_org_z = up*v;
		e.relative_org_y = left*v;
		e.relative_org_x = forward*v;
		e = e.physobj_next;
	}
	e = obj.physobj_staticlist;
	while (e)
	{
		e.realowner = e.owner;
		//e.owner = obj.physobj_hitmodel;
		v = e.origin - obj.physobj_p1.origin;
		e.relative_org_z = up*v;
		e.relative_org_y = left*v;
		e.relative_org_x = forward*v;
		e = e.physobj_next;
	}
	e = obj.physobj_particlelist;
	while(e)
	{
		e.realowner = e.owner;
		//e.owner = obj.physobj_hitmodel;
		e = e.physobj_next;
	}
	// let's save the center of mass for this object
	v = '0 0 0';
	e = obj.physobj_particlelist;
	while(e)
	{
		f = f + e.part_mass;
		v = v + e.origin*e.part_mass;
		e = e.physobj_next;
	}
	v = v*(1/f);
	v = v-obj.physobj_p1.origin;
	obj.relative_org_z = up*v;
	obj.relative_org_y = left*v;
	obj.relative_org_x = forward*v;

	// LadyHavoc: Calculate the matrix of the first three particles
	// this matrix is what the 3 particles produced in the editor, and we need
	// to exactly undo this matrix when generating the ingame orientations
	org1 = obj.physobj_p1.relative_org;
	org2 = obj.physobj_p2.relative_org;
	org3 = obj.physobj_p3.relative_org;

	obj.relative_forward = normalize(org2-org1);
	obj.relative_left = normalize(org3-org1);
	obj.relative_up = normalize(crossproduct(obj.relative_forward, obj.relative_left));
	obj.relative_left = normalize(crossproduct(obj.relative_forward, obj.relative_up));

	return obj;
}

entity(entity obj, vector org, vector forward, vector left, vector up, vector toss, float randvel) Phys_MakeIntoPhysicsObject =
{
	local entity e;
	local vector com, v;
	local float particleCount;

	physobj_spawning = obj;
	obj.classname = "physics_object";
	obj.solid = SOLID_TRIGGER;

	e = obj.physobj_particlelist;
	while(e)
	{
		v = org + up*e.relative_org_z + left*e.relative_org_y + forward*e.relative_org_x;
		Phys_InitParticle(v, e, physobj_spawning);
		setvelocity(e, toss + randomvec()*randvel);
		com += e.relative_org * e.part_mass;
		e = e.physobj_next;
		particleCount++;
	}
	GenerateTetrahedrons(obj);
	e = obj.physobj_hitmodel;
	while(e)
	{
		v = org + up*e.relative_org_z + left*e.relative_org_y + forward*e.relative_org_x;
		Phys_InitHitmodel(v, e, physobj_spawning);
		e = e.physobj_next;
	}
	e = obj.physobj_staticlist;
	while(e)
	{
		v = org + up*e.relative_org_z + left*e.relative_org_y + forward*e.relative_org_x;
		Phys_InitStatic(v, e, physobj_spawning);
		e = e.physobj_next;
	}
	if (cvar("developer") != 0) {
		com /= particleCount;
		e = Phys_SpawnStatic(org + up*com_z + left*com_y + forward*com_x, world, physobj_spawning);
		setmodel(e, "progs/debug/orgbig.mdl");
	}
	
	return Phys_InitPhysicsObject(physobj_spawning, org, forward, left, up);
};

/*
// obsolete
entity(entity obj, vector org, vector forward, vector left, vector up, vector toss, float randvel) Phys_ObjectCreate =
{
	local entity e, part;
	local vector com;
	local float particleCount;

	physobj_spawning = Phys_ObjectSpawn(obj);

	e = obj.physobj_particlelist;
	while(e)
	{
		part = Phys_SpawnParticle(org + up*e.relative_org_z + left*e.relative_org_y + forward*e.relative_org_x, e, physobj_spawning);
		setvelocity(part, toss + randomvec()*randvel);
		//part.velocity = toss + randomvec()*randvel;
		e.enemy = part; // used for easier stick spawning
		com += e.relative_org * e.part_mass;
		e = e.physobj_next;
		particleCount++;
	}
	e = obj.physobj_tetralist;
	while (e)
	{
		Phys_SpawnTetra(e, physobj_spawning);
		e = e.physobj_next;
	}
	e = obj.physobj_sticklist;
	while (e)
	{
		Phys_SpawnStick(e, physobj_spawning);
		e = e.physobj_next;
	}
	e = obj.physobj_hitmodel;
	while(e)
	{
		Phys_SpawnHitmodel(org + up*e.relative_org_z + left*e.relative_org_y + forward*e.relative_org_x, e, physobj_spawning);
		e = e.physobj_next;
	}
	e = obj.physobj_staticlist;
	while(e)
	{
		Phys_SpawnStatic(org + up*e.relative_org_z + left*e.relative_org_y + forward*e.relative_org_x, e, physobj_spawning);
		e = e.physobj_next;
	}
	if (cvar("developer") != 0) {
		com /= particleCount;
		e = Phys_SpawnStatic(org + up*com_z + left*com_y + forward*com_x, world, physobj_spawning);
		setmodel(e, "progs/debug/orgbig.mdl");
	}
	return Phys_InitPhysicsObject(physobj_spawning, org, forward, left, up);
};
*/
