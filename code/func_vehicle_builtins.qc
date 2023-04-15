entity() triton =
{
	local entity obj, part;

	obj = spawn();
	obj.netname = "triton";
	obj.physobj_mass = 1000;
	obj.physobj_impactevent = PushAndDamageTarget;
	
	// chassis
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "chassipart";
	part.relative_org = '0 0 25';
	part.relative_size = 10;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.5;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "chassis";
	part.mdl = "progs/test/triton.mdl";
	part.relative_org = '0 0 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// frontleft
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "frontleft";
	part.relative_org = '43.5 30 -24';
	part.physobj_spring_length = 15;
	part.physobj_spring_force = '1 2 0';
	part.relative_size = 13;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.2 4 5';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "frontleft";
	part.mdl = "progs/test/whl.mdl";
	part.relative_org = '43.5 30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// frontright
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "frontright";
	part.relative_org = '43.5 -30 -24';
	part.physobj_spring_length = 15;
	part.physobj_spring_force = '1 2 0';
	part.relative_size = 13;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.2 4 5';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "frontright";
	part.mdl = "progs/test/whl.mdl";
	part.relative_org = '43.5 -30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// backleft
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "backleft";
	part.relative_org = '-43.5 30 -24';
	part.physobj_spring_length = 15;
	part.physobj_spring_force = '1 2 0';
	part.relative_size = 13;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.2 4 5';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "backleft";
	part.mdl = "progs/test/whl.mdl";
	part.relative_org = '-43.5 30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// backright
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "backright";
	part.relative_org = '-43.5 -30 -24';
	part.physobj_spring_length = 15;
	part.physobj_spring_force = '1 2 0';
	part.relative_size = 13;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.2 4 5';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "backright";
	part.mdl = "progs/test/whl.mdl";
	part.relative_org = '-43.5 -30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	physobj_spawning = obj;
	Phys_SpawnSticks();
	return physobj_spawning;
}

entity() hotrod =
{
	local entity obj, part;

	obj = spawn();
	obj.netname = "hotrod";
	obj.physobj_mass = 1000;
	obj.physobj_impactevent = PushAndDamageTarget;
	
	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "chassis";
	part.mdl = "progs/HotRod_body.mdl";
	part.relative_org = '0 0 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "roof";
	part.mdl = "progs/HotRod_roof.mdl";
	part.relative_org = '0 0 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "driver";
	part.mdl = "progs/HotRod_player_driver.mdl";
	part.relative_org = '0 0 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "turretbase";
	part.mdl = "progs/HotRod_turret_base.mdl";
	part.relative_org = '-14.596 0 24.76';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "turretswivel";
	part.mdl = "progs/HotRod_turret_swivel.mdl";
	part.relative_org = '-14.596 0 24.76';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "turretbody";
	part.mdl = "progs/HotRod_turret_body.mdl";
	part.relative_org = '-14.596 0 36.18';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "turretbarrel";
	part.mdl = "progs/HotRod_turret_barrel.mdl";
	part.relative_org = '-14.596 0 36.18';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "leftdoor";
	part.relative_org = '-16 50 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "topexit";
	part.relative_org = '-16 0 50';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "rightdoor";
	part.relative_org = '-16 -50 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "botexit";
	part.relative_org = '-16 0 -50';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "frontexit";
	part.relative_org = '80 0 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "backexit";
	part.relative_org = '-80 0 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// frontleft
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "frontleft";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '47.5 23.3 -23.5';
	part.physobj_spring_length = 12;
	part.physobj_spring_force = '2 4 0';
	part.relative_size = 13;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 4.4 5';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "frontleft";
	part.mdl = "progs/HotRod_wheel_front_L.mdl";
	part.relative_org = '43.5 30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// frontright
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "frontright";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '47.5 -23.3 -23.5';
	part.physobj_spring_length = 12;
	part.physobj_spring_force = '2 4 0';
	part.relative_size = 13;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 4.4 5';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "frontright";
	part.mdl = "progs/HotRod_wheel_front_R.mdl";
	part.relative_org = '43.5 -30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// backleft
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "backleft";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '-49.84 27.08 -24';
	part.physobj_spring_length = 12;
	part.physobj_spring_force = '2 4 0';
	part.relative_size = 13;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 3.3 5';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "backleft";
	part.mdl = "progs/HotRod_wheel_rear_L.mdl";
	part.relative_org = '-43.5 30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// backright
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "backright";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '-49.84 -27.08 -24';
	part.physobj_spring_length = 12;
	part.physobj_spring_force = '2 4 0';
	part.relative_size = 13;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 3.3 5';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "backright";
	part.mdl = "progs/HotRod_wheel_rear_R.mdl";
	part.relative_org = '-43.5 -30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// all various points
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '56.9 0 -16.9';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.575;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '54.4 7.4 11.6';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.52;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '54.4 -7.4 11.6';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.52;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '15.9 0 10.35';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.52;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '5 18 -10';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.575;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '5 -18 -10';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.575;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '1.9 14.9 23.4';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.375;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '1.9 -14.9 23.4';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.375;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '-25 0 -15.5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.6;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '-30.3 16.7 23.9';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.375;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '-30.3 -16.7 23.9';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.375;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '-56.8 17.1 3.5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.52;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '-56.8 -17.1 3.5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.52;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	//part.mdl = "progs/debug/org.mdl";
	part.relative_org = '-65.1 0 -10.9';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.575;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	// hitmodels
	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round32.bsp";
	part.relative_org = '48 0 -3';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round32.bsp";
	part.relative_org = '28.4 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round32.bsp";
	part.relative_org = '8.8 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round32.bsp";
	part.relative_org = '-10.8 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round32.bsp";
	part.relative_org = '-30.4 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round32.bsp";
	part.relative_org = '-50 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;
	// roof hitmodels
	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '-2 6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '-2 -6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '-14 6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '-14 -6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '-30 6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '-30 -6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	//wheel hitmodels
	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '-49.84 -25 -14';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '-49.84 25 -14';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '47.5 -21 -13.5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.mdl = "maps/round16.bsp";
	part.relative_org = '47.5 21 -13.5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	physobj_spawning = obj;
	Phys_SpawnSticks();

	return physobj_spawning;
}

void(entity wheel, entity car) AddWheelStatic =
{
	local entity stat;

	stat = spawn();
	stat.classname = "phys_static";
	stat.netname = wheel.netname;
	setorigin(stat, wheel.origin);
	if (wheel.mdl){
		stat.mdl = wheel.mdl;
	}
	else if (wheel.model){
		setmodel (stat, wheel.model);
	}
	wheel.model = 0;
	wheel.mdl = 0;
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

	Phys_MakeIntoPhysicsObject(self, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	self.physobj_impactevent = PushAndDamageTarget;
	Car_InitVehicle(self);
}

// keeping the titular name for the memes, but this is a point entity
void() func_vehicle =
{
	if (cvar("developer") != 0){
		precache_model("progs/debug/org.mdl");
		precache_model("progs/debug/orgbig.mdl");
	}
	precache_model("progs/null.spr");

	self.think = StartFuncVehicle;
	self.nextthink = 0.2;
};

void() phys_hitmodel =
{
	setorigin (self, self.origin);
	if (!self.model)
		error("hitmodel with no model");
	precache_model(self.model);
	setmodel (self, self.model);
}
// bmodel version of above entity
void() func_vehicle_hitmodel =
{
	phys_hitmodel();
}

void() phys_particle =
{
	setorigin (self, self.origin);
	if (self.mdl)
		precache_model(self.mdl);
	else if (self.model)
		setmodel (self, self.model);

	self.physobj_spring_length = 12;
	self.physobj_spring_force = '2 4 0';
	self.relative_size = 13;
	self.physobj_stepup = 18;
	self.part_mass = 1;
	self.physobj_stiction = 10;
	self.physobj_friction_ground = '0.225 3.3 5';
	self.physobj_friction_water = '2 2 2';
	self.physobj_bounce = 1.025;
	self.physobj_buoyancy = -0.75;
}
// bmodel version of above entity
void() func_vehicle_particle =
{
	phys_particle();
}

void() phys_static =
{
	setorigin (self, self.origin);
	if (self.mdl)
		precache_model(self.mdl);
	else if (self.model)
		setmodel (self, self.model);
}
// bmodel version of above entity
void() func_vehicle_static =
{
	phys_static();
}

void() phys_wheel =
{
	setorigin (self, self.origin);
	if (self.mdl){
		precache_model(self.mdl);
	}
	self.physobj_spring_length = 12;
	self.physobj_spring_force = '2 4 0';
	self.relative_size = 13;
	self.physobj_stepup = 18;
	self.part_mass = 1;
	self.physobj_stiction = 10;
	self.physobj_friction_ground = '0.225 3.3 5';
	self.physobj_friction_water = '2 2 2';
	self.physobj_bounce = 1.025;
	self.physobj_buoyancy = -0.75;
}
// bmodel version of above entity
void() func_vehicle_wheel =
{
	phys_wheel();
}

// legacy, hopefully can remove in next release
void() func_vehicle_builtins =
{
	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	if (cvar("developer") != 0){
		precache_model("progs/debug/org.mdl");
		precache_model("progs/debug/orgbig.mdl");
	}
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
	//car.netname = self.netname;
	
	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
};
// legacy, hopefully can remove in next release
void() func_vehicle_triton =
{
	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	if (cvar("developer") != 0){
		precache_model("progs/debug/org.mdl");
		precache_model("progs/debug/orgbig.mdl");
	}
	precache_model("progs/null.spr");

	precache_model("progs/test/whl.mdl");
	precache_model("progs/test/triton.mdl");
	entity car = triton();

	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
};

void() vehicle_hotrod =
{
	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	if (cvar("developer") != 0){
		precache_model("progs/debug/org.mdl");
		precache_model("progs/debug/orgbig.mdl");
	}
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
	
	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
};
// legacy, hopefully can remove in next release
void() func_vehicle_hotrod =
{
	vehicle_hotrod();
};