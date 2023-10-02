
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
	// Use coordinates relative to point 'a' of the tetrahedron.
	vector ba = b.relative_org - a.relative_org;
	vector ca = c.relative_org - a.relative_org;
	vector da = d.relative_org - a.relative_org;

	// Squares of lengths of the edges incident to 'a'.
	float len_ba = vlensqr(ba);
	float len_ca = vlensqr(ca);
	float len_da = vlensqr(da);

	// Cross products of these edges.
	vector cross_cd = CrossProduct(ca, da);
	vector cross_db = CrossProduct(da, ba);
	vector cross_bc = CrossProduct(ba, ca);

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

	makevectors(self.angles);
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
	support_p1.think = SUB_Remove;
	support_p1.nextthink = time;
	support_p1.relative_org = p1;

	entity support_p2 = spawn();
	support_p2.classname = "support_particle";
	support_p2.think = SUB_Remove;
	support_p2.nextthink = time;
	support_p2.relative_org = p2;

	entity support_p3 = spawn();
	support_p3.classname = "support_particle";
	support_p3.think = SUB_Remove;
	support_p3.nextthink = time;
	support_p3.relative_org = p3;

	entity support_p4 = spawn();
	support_p4.classname = "support_particle";
	support_p4.think = SUB_Remove;
	support_p4.nextthink = time;
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
		l_next.think = SUB_Remove;
		l_next.nextthink = time;
		list_pointer.physobj_next = l_next;
	}
	return list_pointer.physobj_next;
}

void(entity obj) GenerateTetrahedrons =
{
	entity tetra_list, super_tetra;
	entity bad_tetra_list, bad_tetra_pointer;
	entity volume_list, volume_pointer;
	entity t, temp, tetra;
	float i, j;

	// support entities which auto-remove themselves
	volume_list = spawn();
	volume_list.classname = "volume_triangle";
	volume_list.think = SUB_Remove;
	volume_list.nextthink = time;

	bad_tetra_list = spawn();
	bad_tetra_list.classname = "bad_tetra";
	bad_tetra_list.think = SUB_Remove;
	bad_tetra_list.nextthink = time;

	entity support_triangles = spawn();
	support_triangles.classname = "support_triangle";
	support_triangles.think = SUB_Remove;
	support_triangles.nextthink = time;
	support_triangles.physobj_next = spawn();
	support_triangles.physobj_next.classname = "support_triangle";
	support_triangles.physobj_next.think = SUB_Remove;
	support_triangles.physobj_next.nextthink = time;
	support_triangles.physobj_next.physobj_next = spawn();
	support_triangles.physobj_next.physobj_next.classname = "support_triangle";
	support_triangles.physobj_next.physobj_next.think = SUB_Remove;
	support_triangles.physobj_next.physobj_next.nextthink = time;
	support_triangles.physobj_next.physobj_next.physobj_next = spawn();
	support_triangles.physobj_next.physobj_next.physobj_next.classname = "support_triangle";
	support_triangles.physobj_next.physobj_next.physobj_next.think = SUB_Remove;
	support_triangles.physobj_next.physobj_next.physobj_next.nextthink = time;

	// start the tetras list with the supertetra
	tetra_list = super_tetra = SuperTetra(obj);
	super_tetra.classname = "supertetra";
	super_tetra.think = SUB_Remove;
	super_tetra.nextthink = time;

	const float EPSILON = 0.001;

	entity e = obj.physobj_particlelist;
	while(e) {
		float badtetras = 0;
		bad_tetra_pointer = bad_tetra_list;
		// find all tetras whose circumcenter overlap the new point we are adding
		tetra = tetra_list;
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
			if (tetra_list == bad)
				tetra_list = bad.physobj_next;
			else {
				tetra = tetra_list;
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

			tetra.physobj_next = tetra_list;
			tetra_list = tetra;
			volume_pointer = volume_pointer.physobj_next;
		}

		e = e.physobj_next;
	}

	// remove the outer tetrahedrons sharing verts with the supertetra, leaving only the convex hull of the object left
	tetra = tetra_list;
	while(tetra){
		temp = tetra.physobj_next;

		if(SharesVertex(super_tetra, tetra)){
			if (tetra_list == tetra)
				tetra_list = tetra.physobj_next;
			else {
				t = tetra_list;
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
		else{
			vector center = tetra.physobj_p1.relative_org + tetra.physobj_p2.relative_org + tetra.physobj_p3.relative_org + tetra.physobj_p4.relative_org;
			center /= 4;
			setorigin(tetra, obj.origin + center);
			setmodel(tetra, "progs/debug/point.spr");
		}
		*/
		tetra = temp;
	}
	obj.physobj_tetralist = tetra_list;
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

void(entity obj) GenerateSticksFromTetrahedrons =
{
	entity tetra = obj.physobj_tetralist;
	while (tetra){
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
		tetra = tetra.physobj_next;
	}
}