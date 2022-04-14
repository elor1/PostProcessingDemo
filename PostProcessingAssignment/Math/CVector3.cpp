//--------------------------------------------------------------------------------------
// Vector3 class (cut down version), to hold points and vectors
//--------------------------------------------------------------------------------------

#include "CVector3.h"


/*-----------------------------------------------------------------------------------------
    Operators
-----------------------------------------------------------------------------------------*/

// Addition of another vector to this one, e.g. Position += Velocity
CVector3& CVector3::operator+= (const CVector3& v)
{
    x += v.x;
    y += v.y;
    z += v.z;
    return *this;
}

// Subtraction of another vector from this one, e.g. Velocity -= Gravity
CVector3& CVector3::operator-= (const CVector3& v)
{
    x -= v.x;
    y -= v.y;
    z -= v.z;
    return *this;
}

// Negate this vector (e.g. Velocity = -Velocity)
CVector3& CVector3::operator- ()
{
    x = -x;
    y = -y;
    z = -z;
    return *this;
}

// Plus sign in front of vector - called unary positive and usually does nothing. Included for completeness (e.g. Velocity = +Velocity)
CVector3& CVector3::operator+ ()
{
    return *this;
}


// Multiply vector by scalar (scales vector);
CVector3& CVector3::operator*= (float s)
{
    x *= s;
    y *= s;
    z *= s;
    return *this;
}
// Divide vector by scalar (scales vector);
CVector3& CVector3::operator/= (float s)
{
    x /= s;
    y /= s;
    z /= s;
    return *this;
}


// Vector-vector addition
CVector3 operator+ (const CVector3& v, const CVector3& w)
{
    return { v.x + w.x, v.y + w.y, v.z + w.z };
}

// Vector-vector subtraction
CVector3 operator- (const CVector3& v, const CVector3& w)
{
    return { v.x - w.x, v.y - w.y, v.z - w.z };
}

// Vector-scalar multiplication
CVector3 operator* (const CVector3& v, float s)
{
    return { v.x * s, v.y * s, v.z * s };
}
CVector3 operator* (float s, const CVector3& v)
{
    return { v.x * s, v.y * s, v.z * s };
}

// Vector-scalar division
CVector3 operator/ (const CVector3& v, float s)
{
    return { v.x / s, v.y / s, v.z / s };
}


/*-----------------------------------------------------------------------------------------
    Non-member functions
-----------------------------------------------------------------------------------------*/

// Dot product of two given vectors (order not important) - non-member version
float Dot(const CVector3& v1, const CVector3& v2)
{
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

// Cross product of two given vectors (order is important) - non-member version
CVector3 Cross(const CVector3& v1, const CVector3& v2)
{
    return { v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z, v1.x * v2.y - v1.y * v2.x };
}

// Return unit length vector in the same direction as given one
CVector3 Normalise(const CVector3& v)
{
    float lengthSq = v.x*v.x + v.y*v.y + v.z*v.z;

    // Ensure vector is not zero length (use BaseMath.h float approx. fn with default epsilon)
    if (IsZero(lengthSq))
    {
        return { 0.0f, 0.0f, 0.0f };
    }
    else
    {
        float invLength = InvSqrt(lengthSq);
        return { v.x * invLength, v.y * invLength, v.z * invLength };
    }
}


// Returns length of a vector
float Length(const CVector3& v)
{
    return sqrt(Dot(v, v));
}

// Convert a HSL colour to an RGB colour
CVector3 HSLToRGB(CVector3 HSL)
{
	CVector3 RGB;

	float fS = (float)HSL.y / 100.0f;
	float fL = (float)HSL.z / 100.0f;
	float C = (1.0f - fabsf((2.0f * fL) - 1.0)) * fS;
	float fH = (float)HSL.x / 60.0f;
	float fR, fG, fB;
	float X = C * (1.0f - fabsf(fmodf(fH, 2.0f) - 1.0f));

	if (0.0f <= fH && fH < 1.0f) {
		fR = C;
		fG = X;
		fB = 0.0f;
	}
	else if (1.0f <= fH && fH < 2.0f) {
		fR = X;
		fG = C;
		fB = 0.0f;
	}
	else if (2.0f <= fH && fH < 3.0f) {
		fR = 0.0f;;
		fG = C;
		fB = X;
	}
	else if (3.0f <= fH && fH < 4.0f) {
		fR = 0.0f;
		fG = X;
		fB = C;
	}
	else if (4.0f <= fH && fH < 5.0f) {
		fR = X;
		fG = 0.0f;
		fB = C;
	}
	else if (5.0f <= fH && fH < 6.0f) {
		fR = C;
		fG = 0.0f;
		fB = X;
	}
	else {
		fR = 0.0f;
		fG = 0.0f;
		fB = 0.0f;
	}

	float m = fL - (0.5f * C);
	RGB.x = (fR + m) * 255;
	RGB.y = (fG + m) * 255;
	RGB.z = (fB + m) * 255;
	return RGB;
}

// Convert an RGB colour to a HSL colour
CVector3 RGBToHSL(CVector3 RGB)
{
	CVector3 HSL;

	float fR = RGB.x / 255.0f;
	float fG = RGB.y / 255.0f;
	float fB = RGB.z / 255.0f;

	float min = Min(fR, fG, fB);
	float max = Max(fR, fG, fB);

	HSL.z = 50.0f * (max + min);
	HSL.y = 0.0f;
	HSL.x = 0.0f;

	if (min == max) {
		return RGB;
	}
	else {
		if (HSL.z < 50.0f) {
			HSL.y = 100.0f * (max - min) / (max + min);
		}
		else if (HSL.z > 50.0f) {
			HSL.y = 100.0f * (max - min) / (2.0f - max - min);
		}

		if (max == fR) {
			HSL.x = 60.0f * (fG - fB) / (max - min);
		}
		else if (max == fG) {
			HSL.x = 60.0f * (fB - fR) / (max - min) + 120.0f;
		}
		else if (max == fB) {
			HSL.x = 60.0f * (fR - fG) / (max - min) + 240.0f;
		}

		if (HSL.x < 0) {
			HSL.x += 360.0f;
		}
	}
	return HSL;
}