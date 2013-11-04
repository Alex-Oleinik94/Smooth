#ifndef _CAMERA_H_
#define _CAMERA_H_

class Camera
{
public:
     // ���������
     // LANDOBJECT ��������� ������������ �� ��������������� ���.
     // AIRCRAFT ��������� �������� ������������ � ������������ � ������������� ����� �������� �������.
     enum CameraType {LANDOBJECT, AIRCRAFT};

     Camera();                      // ����������� ������ ��� ����������
     Camera(CameraType cameraType); // ����������� � ����������
     ~Camera();                     // ���������� ������

     void LeftRight(float units); // �����/������
     void UpDown(float units);    // �����/����
     void FirstBack(float units); // ������/�����

     void RollRightVector(float angle); // �������� ������������ ������� �������
     void RollUpVector(float angle);    // �������� ������������ �������� �������
     void RollFirstVector(float angle); // �������� ������������ ������� �������

     // ���������� ������� ����, �� ��������� �������� �������� ������
     void getViewMatrix(D3DXMATRIX* V);
     // ��������� ���� ������
     void setCameraType(CameraType cameraType);
     // ��������� ��������� ������� ���������� ������
     void getPosition(D3DXVECTOR3* pos);
     // ��������� ������ � ��������� ����� � �� ��������� ������
     void setPosition(D3DXVECTOR3* pos);
     // ��������� ��������� ������� �������
     void getRight(D3DXVECTOR3* right);
     // ��������� ��������� �������� �������
     void getUp(D3DXVECTOR3* up);
     // ��������� ��������� ������� �������
     void getLook(D3DXVECTOR3* look);

private:
     CameraType  _cameraType; // ��� ������ ������
     D3DXVECTOR3 _right;      // ������ ������ ������
     D3DXVECTOR3 _up;         // ������� ������ ������
     D3DXVECTOR3 _look;       // �������� ������ ������
     D3DXVECTOR3 _pos;        // ������ �������������� ������
};
// ����������� ������ ��� ����������
Camera::Camera()
{
	_cameraType = AIRCRAFT;

	_pos   = D3DXVECTOR3(0.0f, 0.0f, 0.0f);
	_right = D3DXVECTOR3(1.0f, 0.0f, 0.0f);
	_up    = D3DXVECTOR3(0.0f, 1.0f, 0.0f);
	_look  = D3DXVECTOR3(0.0f, 0.0f, 1.0f);
}

// ����������� ������ ��� ���������� � �����������
Camera::Camera(CameraType cameraType)
{
	_cameraType = cameraType;

	_pos   = D3DXVECTOR3(0.0f, 0.0f, 0.0f);
	_right = D3DXVECTOR3(1.0f, 0.0f, 0.0f);
	_up    = D3DXVECTOR3(0.0f, 1.0f, 0.0f);
	_look  = D3DXVECTOR3(0.0f, 0.0f, 1.0f);
}

// ���������� ������
Camera::~Camera()
{

}

// �����/������
void Camera::LeftRight(float units)
{
     // ��� �������� �������� ����������� ������ � ��������� xz
     if(_cameraType == LANDOBJECT)
          _pos += D3DXVECTOR3(_right.x, 0.0f, _right.z) * units;

     if(_cameraType == AIRCRAFT)
          _pos += _right * units;
}

// �����/����
void Camera::UpDown(float units)
{
     if(_cameraType == AIRCRAFT)
          _pos += _up * units;
}

// ������/�����
void Camera::FirstBack(float units)
{
     // ��� �������� �������� ����������� ������ � ��������� xz
     if(_cameraType == LANDOBJECT)
          _pos += D3DXVECTOR3(_look.x, 0.0f, _look.z) * units;

     if(_cameraType == AIRCRAFT)
          _pos += _look * units;
}

// �������� ������������ ������� �������
void Camera::RollRightVector(float angle)
{
     D3DXMATRIX T;
     D3DXMatrixRotationAxis(&T, &_right, angle);

     // ������� �������� _up � _look ������������ ������� _right
     D3DXVec3TransformCoord(&_up,&_up, &T);
     D3DXVec3TransformCoord(&_look,&_look, &T);
}

// �������� ������������ �������� �������
void Camera::RollUpVector(float angle)
{
     D3DXMATRIX T;

     // ��� �������� �������� ��������� ��������
     // ������ ������� ��� Y (0, 1, 0)
     if(_cameraType == LANDOBJECT)
          D3DXMatrixRotationY(&T, angle);

     // ��� �������� �������� ��������� ��������
     // ������������ �������� �������
     if(_cameraType == AIRCRAFT)
          D3DXMatrixRotationAxis(&T, &_up, angle);

     // ������� �������� _right � _look ������������
     // ������� _up ��� ��� Y
     D3DXVec3TransformCoord(&_right, &_right, &T);
     D3DXVec3TransformCoord(&_look, &_look, &T);
}

// �������� ������������ ������� �������
void Camera::RollFirstVector(float angle)
{
     // �������� ������ ��� �������� ��������
     if(_cameraType == AIRCRAFT)
     {
          D3DXMATRIX T;
          D3DXMatrixRotationAxis(&T, &_look, angle);

          // ������� �������� _up � _right ������������
          // ������� _look
          D3DXVec3TransformCoord(&_right, &_right, &T);
          D3DXVec3TransformCoord(&_up, &_up, &T);
     }
}

// ���������� ������� ����, �� ��������� �������� �������� ������
void Camera::getViewMatrix(D3DXMATRIX* V)
{
     // ������ ��� ������ ��������������
     D3DXVec3Normalize(&_look, &_look);

     D3DXVec3Cross(&_up, &_look, &_right);
     D3DXVec3Normalize(&_up, &_up);

     D3DXVec3Cross(&_right, &_up, &_look);
     D3DXVec3Normalize(&_right, &_right);

     // ������ ������� ����:
     float x = -D3DXVec3Dot(&_right, &_pos);
     float y = -D3DXVec3Dot(&_up, &_pos);
     float z = -D3DXVec3Dot(&_look, &_pos);

     (*V)(0, 0) = _right.x;
     (*V)(0, 1) = _up.x;
     (*V)(0, 2) = _look.x;
     (*V)(0, 3) = 0.0f;

     (*V)(1, 0) = _right.y;
     (*V)(1, 1) = _up.y;
     (*V)(1, 2) = _look.y;
     (*V)(1, 3) = 0.0f;

     (*V)(2, 0) = _right.z;
     (*V)(2, 1) = _up.z;
     (*V)(2, 2) = _look.z;
     (*V)(2, 3) = 0.0f;

     (*V)(3, 0) = x;
     (*V)(3, 1) = y;
     (*V)(3, 2) = z;
     (*V)(3, 3) = 1.0f;
}

// ��������� ���� ������
void Camera::setCameraType(CameraType cameraType)
{
	_cameraType = cameraType;
}

// ��������� ��������� ������� ���������� ������
void Camera::getPosition(D3DXVECTOR3* pos)
{
	*pos = _pos;
}

// ��������� ������ � ��������� ����� � �� ��������� ������
void Camera::setPosition(D3DXVECTOR3* pos)
{
	_pos = *pos;
}

// ��������� ��������� ������� �������
void Camera::getRight(D3DXVECTOR3* right)
{
	*right = _right;
}

// ��������� ��������� �������� �������
void Camera::getUp(D3DXVECTOR3* up)
{
	*up = _up;
}

// ��������� ��������� ������� �������
void Camera::getLook(D3DXVECTOR3* look)
{
	*look = _look;
}

#endif
