//--------------------------------------------------------------------------------------
// Class encapsulating a camera
//--------------------------------------------------------------------------------------
// Holds position, rotation, near/far clip and field of view. These to a view and projection matrices as required

#include "CVector2.h"
#include "CVector3.h"
#include "CMatrix4x4.h"
#include "MathHelpers.h"
#include "Input.h"

#ifndef _CAMERA_H_INCLUDED_
#define _CAMERA_H_INCLUDED_


class Camera
{
public:
	//-------------------------------------
	// Construction and Usage
	//-------------------------------------

	// Constructor - initialise all settings, sensible defaults provided for everything.
	Camera(CVector3 position = {0,0,0}, CVector3 rotation = {0,0,0}, 
           float fov = PI/3, float aspectRatio = 4.0f / 3.0f, float nearClip = 0.1f, float farClip = 10000.0f)
        : mPosition(position), mRotation(rotation), mFOVx(fov), mAspectRatio(aspectRatio), mNearClip(nearClip), mFarClip(farClip)
    {
    }


	// Control the camera's position and rotation using keys provided
	void Control( float frameTime, KeyCode turnUp, KeyCode turnDown, KeyCode turnLeft, KeyCode turnRight,  
	              KeyCode moveForward, KeyCode moveBackward, KeyCode moveLeft, KeyCode moveRight);


	//-------------------------------------
	// Data access
	//-------------------------------------

	// Getters / setters
	CVector3 Position()  { return mPosition; }
	CVector3 Rotation()  { return mRotation;	}
	void SetPosition(CVector3 position)  { mPosition = position; }
	void SetRotation(CVector3 rotation)  { mRotation = rotation; }

	float FOV()       { return mFOVx;     }
	float NearClip()  { return mNearClip; }
	float FarClip()   { return mFarClip;  }

	void SetFOV     (float fov     )  { mFOVx     = fov;      }
	void SetNearClip(float nearClip)  { mNearClip = nearClip; }
	void SetFarClip (float farClip )  { mFarClip  = farClip;  }

	// Read only access to camera matrices, updated on request from position, rotation and camera settings
	CMatrix4x4 WorldMatrix()           { UpdateMatrices(); return mWorldMatrix; }
	CMatrix4x4 ViewMatrix()            { UpdateMatrices(); return mViewMatrix;           }
	CMatrix4x4 ProjectionMatrix()      { UpdateMatrices(); return mProjectionMatrix;     }
	CMatrix4x4 ViewProjectionMatrix()  { UpdateMatrices(); return mViewProjectionMatrix; }


	//-------------------------------------
	// Camera Picking
	//-------------------------------------
	// Convert 2D pixel positions to and from 3D world positions

	// Return pixel coordinates corresponding to given world point when viewing from this
	// camera. Pass the viewport width and height. The returned CVector3 contains the pixel
	// coordinates in x and y and the Z distance to the world point in Z. If the Z distance
	// is less than the camera near clip (use NearClip() member function), then the world
	// point is behind the camera and the 2D x and y coordinates are to be ignored.
	CVector3 PixelFromWorldPt(CVector3 worldPoint, unsigned int viewportWidth, unsigned int viewportHeight);
	
	// Return the size of a pixel in world space at the given Z distance. Allows us to convert the 2D size of areas on the screen to actualy sizes in the world
	// Pass the viewport width and height
	CVector2 PixelSizeInWorldSpace(float Z, unsigned int viewportWidth, unsigned int viewportHeight);


//-------------------------------------
// Private members
//-------------------------------------
private:
	// Update the matrices used for the camera in the rendering pipeline
	void UpdateMatrices();

	// Postition and rotations for the camera (rarely scale cameras)
	CVector3 mPosition;
	CVector3 mRotation;

	// Camera settings: field of view, aspect ratio, near and far clip plane distances.
	// Note that the FOVx angle is measured in radians (radians = degrees * PI/180) from left to right of screen
	float mFOVx;
    float mAspectRatio;
	float mNearClip;
	float mFarClip;

	// Current view, projection and combined view-projection matrices (DirectX matrix type)
	CMatrix4x4 mWorldMatrix; // Easiest to treat the camera like a model and give it a "world" matrix...
	CMatrix4x4 mViewMatrix;  // ...then the view matrix used in the shaders is the inverse of its world matrix

	CMatrix4x4 mProjectionMatrix;     // Projection matrix holds the field of view and near/far clip distances
	CMatrix4x4 mViewProjectionMatrix; // Combine (multiply) the view and projection matrices together, which
	                                  // can sometimes save a matrix multiply in the shader (optional)
};


#endif //_CAMERA_H_INCLUDED_
