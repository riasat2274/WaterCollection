using UnityEditor.SceneManagement;
using UnityEngine;

[ExecuteAlways]
public class URPPlanarReflection : MonoBehaviour
{
    public Camera mainCamera;
    public Camera reflectionCamera;
    public Transform waterPlane;
    public RenderTexture renderTexture;

    void LateUpdate()
    {
        if (!mainCamera || !reflectionCamera || !waterPlane)
            return;

        // Copy camera settings (FOV, aspect, etc.)
        //reflectionCamera.CopyFrom(mainCamera);
        reflectionCamera.fieldOfView = mainCamera.fieldOfView;
        reflectionCamera.aspect = mainCamera.aspect;
        reflectionCamera.nearClipPlane = mainCamera.nearClipPlane;
        reflectionCamera.farClipPlane = mainCamera.farClipPlane;

        reflectionCamera.targetTexture = renderTexture;

        Vector3 normal = waterPlane.up;
        Vector3 pos = waterPlane.position;

        // Create reflection plane
        float d = -Vector3.Dot(normal, pos);
        Vector4 reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);

        // Create reflection matrix
        Matrix4x4 reflectionMatrix = Matrix4x4.zero;
        CalculateReflectionMatrix(ref reflectionMatrix, reflectionPlane);

        // Reflect camera position
        Vector3 oldPos = mainCamera.transform.position;
        Vector3 newPos = reflectionMatrix.MultiplyPoint(oldPos);

        reflectionCamera.worldToCameraMatrix =
            mainCamera.worldToCameraMatrix * reflectionMatrix;

        reflectionCamera.transform.position = newPos;

        // Fix upside down rendering
        GL.invertCulling = true;
        reflectionCamera.Render();
        GL.invertCulling = false;
    }

    static void CalculateReflectionMatrix(ref Matrix4x4 m, Vector4 p)
    {
        m.m00 = 1F - 2F * p[0] * p[0];
        m.m01 = -2F * p[0] * p[1];
        m.m02 = -2F * p[0] * p[2];
        m.m03 = -2F * p[3] * p[0];

        m.m10 = -2F * p[1] * p[0];
        m.m11 = 1F - 2F * p[1] * p[1];
        m.m12 = -2F * p[1] * p[2];
        m.m13 = -2F * p[3] * p[1];

        m.m20 = -2F * p[2] * p[0];
        m.m21 = -2F * p[2] * p[1];
        m.m22 = 1F - 2F * p[2] * p[2];
        m.m23 = -2F * p[3] * p[2];

        m.m30 = 0F;
        m.m31 = 0F;
        m.m32 = 0F;
        m.m33 = 1F;
    }
}

//public class URPPlanarReflection : MonoBehaviour
//{
//    public Camera mainCamera;
//    public Camera reflectionCamera;
//    public Transform waterPlane;

//    void LateUpdate()
//    {
//        if (!mainCamera || !reflectionCamera) return;

//        Vector3 pos = mainCamera.transform.position;
//        Vector3 normal = waterPlane.up;
//        Vector3 planePos = waterPlane.position;

//        float distance = Vector3.Dot(normal, pos - planePos);
//        Vector3 reflectedPos = pos - 2f * distance * normal;

//        reflectionCamera.transform.position = reflectedPos;

//        Vector3 forward = mainCamera.transform.forward;
//        forward = Vector3.Reflect(forward, normal);

//        reflectionCamera.transform.forward = forward;
//    }
//}