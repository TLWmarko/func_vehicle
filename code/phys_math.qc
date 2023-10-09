float(float f) sign =
{
	return (0 < f) - (f < 0);
}

float(float current, float target, float maxDelta) MoveTowards =
{
	if (fabs(target - current) <= maxDelta)
        return target;
    return current + sign(target - current) * maxDelta;
}

float(float current, float target, float maxDelta) MoveTowardsAngle =
{
	float deltaAngle = mod((target - current), 360);
	if (deltaAngle > 180)
		deltaAngle -= 360;
	if (-maxDelta < deltaAngle && deltaAngle < maxDelta)
		return target;
	target = current + deltaAngle;
	return MoveTowards(current, target, maxDelta);
}
