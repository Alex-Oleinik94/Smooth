#ifndef _CAMERA_H_
#define _CAMERA_H_

class Camera
{
public:
     // Множестао
     // LANDOBJECT позволяет перемещаться по соответствующей оси.
     // AIRCRAFT позволяет свободно перемещаться в пространстве и предоставляет шесть степеней свободы.
     enum CameraType {LANDOBJECT, AIRCRAFT};

     Camera();                      // Конструктор класса без параметров
     Camera(CameraType cameraType); // Конструктор с параметром
     ~Camera();                     // Диструктор класса

     void LeftRight(float units); // влево/вправо
     void UpDown(float units);    // вверх/вниз
     void FirstBack(float units); // вперед/назад

     void RollRightVector(float angle); // вращение относительно правого вектора
     void RollUpVector(float angle);    // вращение относительно верхнего вектора
     void RollFirstVector(float angle); // вращение относительно вектора взгляда

     // Вычисление матрицы вида, на основании заданных векторов камеры
     void getViewMatrix(D3DXMATRIX* V);
     // Установка типа камеры
     void setCameraType(CameraType cameraType);
     // Получение координат вектора нахождения камеры
     void getPosition(D3DXVECTOR3* pos);
     // Установка камеры в требуемом месте и на требуемой высоте
     void setPosition(D3DXVECTOR3* pos);
     // Получение координат правого вектора
     void getRight(D3DXVECTOR3* right);
     // Получение координат верхнего вектора
     void getUp(D3DXVECTOR3* up);
     // Получение координат вектора взгляда
     void getLook(D3DXVECTOR3* look);

private:
     CameraType  _cameraType; // Тип работы камеры
     D3DXVECTOR3 _right;      // Правый вектор камеры
     D3DXVECTOR3 _up;         // Верхний вектор камеры
     D3DXVECTOR3 _look;       // Передний вектор камеры
     D3DXVECTOR3 _pos;        // Вектор местоположения камеры
};
// Конструктор класса без параметров
Camera::Camera()
{
	_cameraType = AIRCRAFT;

	_pos   = D3DXVECTOR3(0.0f, 0.0f, 0.0f);
	_right = D3DXVECTOR3(1.0f, 0.0f, 0.0f);
	_up    = D3DXVECTOR3(0.0f, 1.0f, 0.0f);
	_look  = D3DXVECTOR3(0.0f, 0.0f, 1.0f);
}

// Конструктор класса без параметров с параметрами
Camera::Camera(CameraType cameraType)
{
	_cameraType = cameraType;

	_pos   = D3DXVECTOR3(0.0f, 0.0f, 0.0f);
	_right = D3DXVECTOR3(1.0f, 0.0f, 0.0f);
	_up    = D3DXVECTOR3(0.0f, 1.0f, 0.0f);
	_look  = D3DXVECTOR3(0.0f, 0.0f, 1.0f);
}

// Диструктор класса
Camera::~Camera()
{

}

// влево/вправо
void Camera::LeftRight(float units)
{
     // Для наземных объектов перемещение только в плоскости xz
     if(_cameraType == LANDOBJECT)
          _pos += D3DXVECTOR3(_right.x, 0.0f, _right.z) * units;

     if(_cameraType == AIRCRAFT)
          _pos += _right * units;
}

// вверх/вниз
void Camera::UpDown(float units)
{
     if(_cameraType == AIRCRAFT)
          _pos += _up * units;
}

// вперед/назад
void Camera::FirstBack(float units)
{
     // Для наземных объектов перемещение только в плоскости xz
     if(_cameraType == LANDOBJECT)
          _pos += D3DXVECTOR3(_look.x, 0.0f, _look.z) * units;

     if(_cameraType == AIRCRAFT)
          _pos += _look * units;
}

// вращение относительно правого вектора
void Camera::RollRightVector(float angle)
{
     D3DXMATRIX T;
     D3DXMatrixRotationAxis(&T, &_right, angle);

     // Поворот векторов _up и _look относительно вектора _right
     D3DXVec3TransformCoord(&_up,&_up, &T);
     D3DXVec3TransformCoord(&_look,&_look, &T);
}

// вращение относительно верхнего вектора
void Camera::RollUpVector(float angle)
{
     D3DXMATRIX T;

     // Для наземных объектов выполняем вращение
     // вокруг мировой оси Y (0, 1, 0)
     if(_cameraType == LANDOBJECT)
          D3DXMatrixRotationY(&T, angle);

     // Для летающих объектов выполняем вращение
     // относительно верхнего вектора
     if(_cameraType == AIRCRAFT)
          D3DXMatrixRotationAxis(&T, &_up, angle);

     // Поворот векторов _right и _look относительно
     // вектора _up или оси Y
     D3DXVec3TransformCoord(&_right, &_right, &T);
     D3DXVec3TransformCoord(&_look, &_look, &T);
}

// вращение относительно вектора взгляда
void Camera::RollFirstVector(float angle)
{
     // Вращение только для летающих объектов
     if(_cameraType == AIRCRAFT)
     {
          D3DXMATRIX T;
          D3DXMatrixRotationAxis(&T, &_look, angle);

          // Поворот векторов _up и _right относительно
          // вектора _look
          D3DXVec3TransformCoord(&_right, &_right, &T);
          D3DXVec3TransformCoord(&_up, &_up, &T);
     }
}

// Вычисление матрицы вида, на основании заданных векторов камеры
void Camera::getViewMatrix(D3DXMATRIX* V)
{
     // Делаем оси камеры ортогональными
     D3DXVec3Normalize(&_look, &_look);

     D3DXVec3Cross(&_up, &_look, &_right);
     D3DXVec3Normalize(&_up, &_up);

     D3DXVec3Cross(&_right, &_up, &_look);
     D3DXVec3Normalize(&_right, &_right);

     // Строим матрицу вида:
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

// Установка типа камеры
void Camera::setCameraType(CameraType cameraType)
{
	_cameraType = cameraType;
}

// Получение координат вектора нахождения камеры
void Camera::getPosition(D3DXVECTOR3* pos)
{
	*pos = _pos;
}

// Установка камеры в требуемом месте и на требуемой высоте
void Camera::setPosition(D3DXVECTOR3* pos)
{
	_pos = *pos;
}

// Получение координат правого вектора
void Camera::getRight(D3DXVECTOR3* right)
{
	*right = _right;
}

// Получение координат верхнего вектора
void Camera::getUp(D3DXVECTOR3* up)
{
	*up = _up;
}

// Получение координат вектора взгляда
void Camera::getLook(D3DXVECTOR3* look)
{
	*look = _look;
}

#endif
