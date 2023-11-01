void(entity obj) GenerateSticksFromTetrahedrons;
void() Phys_ObjectThink;

vector(vector v1, vector v2) maxvec =
{
	local vector rv;
	rv_x = max(v1_x, v2_x);
	rv_y = max(v1_y, v2_y);
	rv_z = max(v1_z, v2_z);
	return rv;
}

vector(vector v1, vector v2) minvec =
{
	local vector rv;
	rv_x = min(v1_x, v2_x);
	rv_y = min(v1_y, v2_y);
	rv_z = min(v1_z, v2_z);
	return rv;
}

float(entity tetra, float local) GetTetraVolumeSextupled =
{
	vector a, b, c, d;
	entity p1, p2, p3, p4;

	p1 = tetra.physobj_p1;
	p2 = tetra.physobj_p2;
	p3 = tetra.physobj_p3;
	p4 = tetra.physobj_p4;

	if (local){
		a = p1.relative_org;
		b = p2.relative_org;
		c = p3.relative_org;
		d = p4.relative_org;
	}
	else {
		a = p1.origin;
		b = p2.origin;
		c = p3.origin;
		d = p4.origin;
	}

	vector d0 = b - a;
    vector d1 = c - a;
    vector d2 = d - a;

    return CrossProduct(d1, d2) * d0;
}

entity(entity a, entity b, entity c, entity d) Tetrahedron_Circumcenter =
{
	const float EPSILON = 0.0001;

	// Use coordinates relative to point 'a' of the tetrahedron.
	vector ba = b.relative_org - a.relative_org;
	vector ca = c.relative_org - a.relative_org;
	vector da = d.relative_org - a.relative_org;

	// Cross products of these edges.
	vector cross_bc = CrossProduct(ba, ca);
	float tripleproduct = (da) * (cross_bc);
	if (fabs(tripleproduct) < EPSILON){
		/*
		dprint("detected coplanar:\n");
		dprint(vtos(a.relative_org));
		dprint("\n");
		dprint(vtos(b.relative_org));
		dprint("\n");
		dprint(vtos(c.relative_org));
		dprint("\n");
		dprint(vtos(d.relative_org));
		dprint(" - end\n");
		*/
		return world;
	}
	vector cross_cd = CrossProduct(ca, da);
	vector cross_db = CrossProduct(da, ba);

	// Squares of lengths of the edges incident to 'a'.
	float len_ba = vlensqr(ba);
	float len_ca = vlensqr(ca);
	float len_da = vlensqr(da);

	// Calculate the denominator of the formula.
	float denominator = 0.5 / (ba * cross_cd);

	// Calculate offset (from 'a') of circumcenter.
	vector circ;
	circ_x = (len_ba * cross_cd.x + len_ca * cross_db.x + len_da * cross_bc.x) * denominator;
	circ_y = (len_ba * cross_cd.y + len_ca * cross_db.y + len_da * cross_bc.y) * denominator;
	circ_z = (len_ba * cross_cd.z + len_ca * cross_db.z + len_da * cross_bc.z) * denominator;
	
	entity tetra = spawn();
	tetra.classname = "tetra";
	tetra.physobj_p1 = a;
	tetra.physobj_p2 = b;
	tetra.physobj_p3 = c;
	tetra.physobj_p4 = d;
	tetra.phys_center = circ + a.relative_org;
	tetra.phys_radius = vlen(circ);
	tetra.phys_volume = GetTetraVolumeSextupled(tetra, TRUE);
	return tetra;
}

entity(entity obj) SuperTetra {
	vector vmin, vmax;

	vmin_x = vmin_y = vmin_z = 9999999999;
	vmax_x = vmax_y = vmax_z = -9999999999;

	entity e = obj.physobj_particlelist;
	while(e) {
		vmin = minvec(vmin, e.relative_org);
		vmax = maxvec(vmax, e.relative_org);
		e = e.physobj_next;
	}

	makevectors(obj.angles);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;

	vector d = vmax - vmin;
	vector mid = (vmax + vmin) * 0.5;
	float dmax = max(d.x, max(d.y, d.z));
	float scale = 50;
	vector p1 = [mid.x - dmax * scale, mid.y - dmax, mid.z - dmax];
	vector p2 = [mid.x + dmax * scale, mid.y - dmax, mid.z - dmax];
	vector p3 = [mid.x, mid.y + dmax * scale, mid.z - dmax];
	vector p4 = [mid.x, mid.y, mid.z + dmax * scale];

	entity support_p1 = spawn();
	support_p1.classname = "support_particle";
	support_p1.relative_org = p1;

	entity support_p2 = spawn();
	support_p2.classname = "support_particle";
	support_p2.relative_org = p2;

	entity support_p3 = spawn();
	support_p3.classname = "support_particle";
	support_p3.relative_org = p3;

	entity support_p4 = spawn();
	support_p4.classname = "support_particle";
	support_p4.relative_org = p4;
	
	return Tetrahedron_Circumcenter(support_p1, support_p2, support_p3, support_p4);
}

void(entity tetra, entity sup) UpdateSupportTriangles =
{
	entity tri0,tri1,tri2,tri3;
	tri0 = sup;
	tri1 = tri0.physobj_next;
	tri2 = tri1.physobj_next;
	tri3 = tri2.physobj_next;

	tri0.physobj_p1 = tetra.physobj_p1;
	tri0.physobj_p2 = tetra.physobj_p2;
	tri0.physobj_p3 = tetra.physobj_p3;

	tri1.physobj_p1 = tetra.physobj_p1;
	tri1.physobj_p2 = tetra.physobj_p3;
	tri1.physobj_p3 = tetra.physobj_p4;

	tri2.physobj_p1 = tetra.physobj_p1;
	tri2.physobj_p2 = tetra.physobj_p4;
	tri2.physobj_p3 = tetra.physobj_p2;

	tri3.physobj_p1 = tetra.physobj_p2;
	tri3.physobj_p2 = tetra.physobj_p4;
	tri3.physobj_p3 = tetra.physobj_p3;
}

float(entity tetra, entity tri) ContainsTriangle =
{
	float sharedVerts = 0;
	if(tetra.physobj_p1 == tri.physobj_p1 || tetra.physobj_p2 == tri.physobj_p1 || tetra.physobj_p3 == tri.physobj_p1 || tetra.physobj_p4 == tri.physobj_p1)
		sharedVerts++;
	if(tetra.physobj_p1 == tri.physobj_p2 || tetra.physobj_p2 == tri.physobj_p2 || tetra.physobj_p3 == tri.physobj_p2 || tetra.physobj_p4 == tri.physobj_p2)
		sharedVerts++;
	if(tetra.physobj_p1 == tri.physobj_p3 || tetra.physobj_p2 == tri.physobj_p3 || tetra.physobj_p3 == tri.physobj_p3 || tetra.physobj_p4 == tri.physobj_p3)
		sharedVerts++;
	return sharedVerts == 3;
}

float SharesVertex(entity tetra1, entity tetra2) {
	if(tetra1.physobj_p1 == tetra2.physobj_p1 || tetra1.physobj_p2 == tetra2.physobj_p1 || tetra1.physobj_p3 == tetra2.physobj_p1 || tetra1.physobj_p4 == tetra2.physobj_p1)
		return TRUE;
	if(tetra1.physobj_p1 == tetra2.physobj_p2 || tetra1.physobj_p2 == tetra2.physobj_p2 || tetra1.physobj_p3 == tetra2.physobj_p2 || tetra1.physobj_p4 == tetra2.physobj_p2)
		return TRUE;
	if(tetra1.physobj_p1 == tetra2.physobj_p3 || tetra1.physobj_p2 == tetra2.physobj_p3 || tetra1.physobj_p3 == tetra2.physobj_p3 || tetra1.physobj_p4 == tetra2.physobj_p3)
		return TRUE;
	if(tetra1.physobj_p1 == tetra2.physobj_p4 || tetra1.physobj_p2 == tetra2.physobj_p4 || tetra1.physobj_p3 == tetra2.physobj_p4 || tetra1.physobj_p4 == tetra2.physobj_p4)
		return TRUE;
	return FALSE;
}

entity(entity list_pointer, string name) AddEntityToSupportList =
{
	if (!list_pointer.physobj_next){
		entity l_next = spawn();
		l_next.classname = name;
		list_pointer.physobj_next = l_next;
	}
	return list_pointer.physobj_next;
}

void(entity obj, entity e, entity bad_tetra_list, entity volume_list, entity support_triangles, entity super_tetra) GenerateTetrasForParticle = {
	entity bad_tetra_pointer;
	entity volume_pointer;
	entity tetra;
	float i, j;

	const float EPSILON = 0.001;

		float badtetras = 0;
		bad_tetra_pointer = bad_tetra_list;
		// find all tetras whose circumcenter overlap the new point we are adding
		tetra = obj.physobj_tetralist;
		while(tetra){
			float dist = vlen(e.relative_org - tetra.phys_center);
			if(dist < tetra.phys_radius-EPSILON) {
				bad_tetra_pointer.enemy = tetra;

				badtetras++;
				bad_tetra_pointer = AddEntityToSupportList(bad_tetra_pointer, "bad_tetra");
			}
			tetra = tetra.physobj_next;
		}

		// create a volume inside the hull of tetrahedrons
		float volume_size = 0;
		volume_pointer = volume_list;
		bad_tetra_pointer = bad_tetra_list;
		for (i = 0; i < badtetras; i++){
			UpdateSupportTriangles(bad_tetra_pointer.enemy, support_triangles);

			entity tri = support_triangles;
			while(tri){
				float rejectTriangle = FALSE;
				tetra = bad_tetra_list;
				for (j = 0; j < badtetras; j++){
					if (i != j)
					if (ContainsTriangle(tetra.enemy, tri)){
						rejectTriangle = TRUE;
						break;
					}
					tetra = tetra.physobj_next;
				}
				if (!rejectTriangle){
					volume_pointer.physobj_p1 = tri.physobj_p1;
					volume_pointer.physobj_p2 = tri.physobj_p2;
					volume_pointer.physobj_p3 = tri.physobj_p3;

					volume_size++;
					volume_pointer = AddEntityToSupportList(volume_pointer, "volume_triangle");
				}
				tri = tri.physobj_next;
			}
			bad_tetra_pointer = bad_tetra_pointer.physobj_next;
		}

		// remove all the tetras overlapping the new volume
		bad_tetra_pointer = bad_tetra_list;
		for (i = 0; i < badtetras; i++){
			entity bad = bad_tetra_pointer.enemy;
			if (obj.physobj_tetralist == bad)
				obj.physobj_tetralist = bad.physobj_next;
			else {
				tetra = obj.physobj_tetralist;
				while(tetra){
					if (tetra.physobj_next == bad){
						tetra.physobj_next = bad.physobj_next;
						break;
					}
					tetra = tetra.physobj_next;
				}
			}
			if (bad != super_tetra)
				remove(bad);

			bad_tetra_pointer = bad_tetra_pointer.physobj_next;
		}

		// create new tetras inside the volume
		volume_pointer = volume_list;
		for (i = 0; i < volume_size; i++){
			tetra = Tetrahedron_Circumcenter(e, volume_pointer.physobj_p1, volume_pointer.physobj_p2, volume_pointer.physobj_p3);
			if (tetra) {
				tetra.physobj_next = obj.physobj_tetralist;
				obj.physobj_tetralist = tetra;
			}
			volume_pointer = volume_pointer.physobj_next;
		}
}

void(entity obj) CleanUpOuterTetrasAndSupports =
{
	entity e, t, temp, tetra;
	// remove the outer tetrahedrons sharing verts with the supertetra, leaving only the convex hull of the object left
	tetra = obj.physobj_tetralist;
	while(tetra){
		temp = tetra.physobj_next;

		if(SharesVertex(obj.super_tetra_save, tetra)){
			if (obj.physobj_tetralist == tetra)
				obj.physobj_tetralist = tetra.physobj_next;
			else {
				t = obj.physobj_tetralist;
				while(t){
					if (t.physobj_next == tetra){
						t.physobj_next = tetra.physobj_next;
						break;
					}
					t = t.physobj_next;
				}
			}
			remove(tetra);
		}
		/*
		else if (cvar("developer") != 0) {
			vector center = tetra.physobj_p1.relative_org + tetra.physobj_p2.relative_org + tetra.physobj_p3.relative_org + tetra.physobj_p4.relative_org;
			center /= 4;
			setorigin(tetra, obj.origin + center);
			setmodel(tetra, "progs/debug/point.spr");
		}
		*/
		tetra = temp;
	}
	remove(obj.super_tetra_save.physobj_p1);
	remove(obj.super_tetra_save.physobj_p2);
	remove(obj.super_tetra_save.physobj_p3);
	remove(obj.super_tetra_save.physobj_p4);
	remove(obj.super_tetra_save);
	e = obj.bad_tetra_start;
	while(e){
		e.think = SUB_Remove;
		e.nextthink = time;
		e = e.physobj_next;
	}
	e = obj.volume_start;
	while(e){
		e.think = SUB_Remove;
		e.nextthink = time;
		e = e.physobj_next;
	}
	e = obj.support_tris_start;
	while(e){
		e.think = SUB_Remove;
		e.nextthink = time;
		e = e.physobj_next;
	}
}

void() ThinkGenerateTetras =
{
	entity e = self.physobj_next;
	if (e){
		GenerateTetrasForParticle(self, e, self.bad_tetra_start, self.volume_start, self.support_tris_start, self.super_tetra_save);
		self.physobj_next = e.physobj_next;
		self.nextthink = time;
		return;
	}
	CleanUpOuterTetrasAndSupports(self);
	GenerateSticksFromTetrahedrons(self);
}

void(entity obj) GenerateTetrahedrons =
{
	// support entities
	obj.bad_tetra_start = spawn();
	obj.bad_tetra_start.classname = "bad_tetra";

	obj.volume_start = spawn();
	obj.volume_start.classname = "volume_triangle";

	obj.support_tris_start = spawn();
	obj.support_tris_start.classname = "support_triangle";
	obj.support_tris_start.physobj_next = spawn();
	obj.support_tris_start.physobj_next.classname = "support_triangle";
	obj.support_tris_start.physobj_next.physobj_next = spawn();
	obj.support_tris_start.physobj_next.physobj_next.classname = "support_triangle";
	obj.support_tris_start.physobj_next.physobj_next.physobj_next = spawn();
	obj.support_tris_start.physobj_next.physobj_next.physobj_next.classname = "support_triangle";

	// start the tetras list with the supertetra
	obj.physobj_tetralist = obj.super_tetra_save = SuperTetra(obj);
	obj.super_tetra_save.classname = "supertetra";


#ifdef QUICKSPAWN
	entity e = obj.physobj_particlelist;
	while (e) {
		GenerateTetrasForParticle(obj, e, obj.bad_tetra_start, obj.volume_start, obj.support_tris_start, obj.super_tetra_save);
		e = e.physobj_next;
	}
	CleanUpOuterTetrasAndSupports(obj);
	GenerateSticksFromTetrahedrons(obj);
	obj.think = Phys_ObjectThink;
	obj.nextthink = time + 0.2;
#else
	obj.think = ThinkGenerateTetras;
	obj.nextthink = time + random();
	obj.physobj_next = obj.physobj_particlelist;
#endif
}

float(entity p1, entity p2, entity sticklist) CheckIfStickExists =
{
	entity e = sticklist;
	while(e){
		if (e.physobj_p1 == p1 && e.physobj_p2 == p2)
			return TRUE;
		if (e.physobj_p2 == p1 && e.physobj_p1 == p2)
			return TRUE;
		e = e.physobj_next;
	}
	return FALSE;
}

entity(entity p1, entity p2, entity obj) AddStick =
{
	local entity e;
	
	e = spawn();
	e.classname = "stick";
	e.owner = obj;

	e.physobj_next = obj.physobj_sticklist;
	obj.physobj_sticklist = e;

	e.physobj_p1 = p1;
	e.physobj_p2 = p2;
	e.stick_preferredlength = vlen(p2.relative_org - p1.relative_org);
	return e;
};

void(entity tetra, entity obj) GenerateSticksForTetra =
{
	entity p1 = tetra.physobj_p1;
	entity p2 = tetra.physobj_p2;
	entity p3 = tetra.physobj_p3;
	entity p4 = tetra.physobj_p4;
	if (!CheckIfStickExists(p1, p2, obj.physobj_sticklist))
		AddStick(p1, p2, obj);
	if (!CheckIfStickExists(p2, p3, obj.physobj_sticklist))
		AddStick(p2, p3, obj);
	if (!CheckIfStickExists(p3, p1, obj.physobj_sticklist))
		AddStick(p3, p1, obj);
	if (!CheckIfStickExists(p4, p1, obj.physobj_sticklist))
		AddStick(p4, p1, obj);
	if (!CheckIfStickExists(p4, p2, obj.physobj_sticklist))
		AddStick(p4, p2, obj);
	if (!CheckIfStickExists(p4, p3, obj.physobj_sticklist))
		AddStick(p4, p3, obj);
}

void() ThinkGenerateSticks =
{
	entity e = self.physobj_next;
	if (e){
		GenerateSticksForTetra(e, self);
		self.physobj_next = e.physobj_next;
		self.nextthink = time;
		return;
	}
	self.think = Phys_ObjectThink;
	self.nextthink = time;
}

void(entity obj) GenerateSticksFromTetrahedrons =
{
#ifdef QUICKSPAWN
	entity e = obj.physobj_tetralist;
	while (e){
		GenerateSticksForTetra(e, obj);
		e = e.physobj_next;
	}
#else
	obj.think = ThinkGenerateSticks;
	obj.nextthink = time;
	obj.physobj_next = obj.physobj_tetralist;
#endif
}