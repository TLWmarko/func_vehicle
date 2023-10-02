void() Debug_Precache =
{
	precache_model("progs/debug/line.mdl");
	precache_model("progs/debug/point.spr");
	precache_model("progs/debug/org.mdl");
	precache_model("progs/debug/orgbig.mdl");
}

void(vector start, vector end, float lifetime) Debug_DrawLine =
{
	entity e;
	vector line = end - start;
	vector dir = normalize(line);
	float len = vlen(line);
	float f = len / 100;
	float count = ceil(f);
	float remainder = 1-fabs(f - count);
	f = 0;
	while(f < count)
	{
		e = spawn();
		setmodel(e, "progs/debug/line.mdl");
		e.frame = 99;
		setorigin(e, start + dir * 100 * f);
		e.angles = vectoangles(dir);
		e.think = SUB_Remove;
		e.nextthink = time + lifetime;
		f++;
	}
	e.frame = 100 * remainder;
}