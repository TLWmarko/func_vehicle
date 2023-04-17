//#define SMOOTH

float MOVE_NORMAL = 0; // same as FALSE
float MOVE_NOMONSTERS = 1; // same as TRUE
float MOVE_MISSILE = 2; // save as movement with .movetype == MOVETYPE_FLYMISSILE

.entity realowner;
.entity driving;

nosave float check_camera_state;

entity physobj_spawning; // the current object in spawning
.entity physobj_next; // next part in list
.entity physobj_p1; // particle 1 of this stick (start)
.entity physobj_p2; // particle 2 of this stick (end)
.entity physobj_p3; // particle 3 of this stick (rotation)

entity p_damage_thinker;
.entity p_damage_next;
.float p_damage_val;

.vector relative_forward, relative_left, relative_up; // modify to rotate particles & statics
.vector relative_spring;
.vector base_pose;
.vector lmat_forward, lmat_left, lmat_up; // current pose, do not modify, read for logic
.vector relative_org;
.float relative_size;

.string phys_particle_target;
.string phys_hitmodel_target;
.string phys_static_target;

.entity physobj_particlelist; // first entity in particle list of this object
.entity physobj_sticklist; // first entity in stick list of this object
.entity physobj_hitmodel; // the object's hitmodel
.entity physobj_staticlist; // first entity in static list of this object

.float physobj_flags, physobj_movetype;
.float physobj_mass, physobj_inversemass;
.float physobj_bounce;
.float physobj_stepup;
.float physobj_spring_length;
.float physobj_spring_mult;
.vector physobj_spring_force;
.vector physobj_floor_plane_normal;
.float physobj_floor_frac;
.vector physobj_friction_ground, physobj_friction_water, physobj_friction_air;
.float physobj_stiction;
.float physobj_buoyancy;
.void(entity part, entity targ) physobj_impactevent;
.float stick_preferredlength;
.float part_mass;

float PHFLAGS_BLOCKED = 1;
float PHFLAGS_BSPMODEL = 2;
float PHFLAGS_RESTING = 4;
float PHFLAGS_ATTACHED = 8;
float PHFLAGS_FILEBASED = 16;
float PHFLAGS_SPRING_TOUCH = 32;
float PHFLAGS_FORCE = 64;
float PHFLAGS_KILLME = 128;
float PHFLAGS_STABILIZERBAR = 256;

.float force_calcdist, force_calcscale;

.vector destorigin;
.vector oldorigin;
.vector pushorigin;

// resulting matrix vectors from Matrix_ functions
vector matrix_forward, matrix_left, matrix_up;
