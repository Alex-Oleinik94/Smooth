// Глобальное объявление
#include "camera.h"
// Для того, что бы работала функция timeGetTime()
#pragma comment(lib, "winmm.lib")
Camera TheCamera(Camera::LANDOBJECT);

// Функция обработки нажатия клавиш  
bool EnterKey(float timeDelta)
{
	if(pDirect3DDevice)
	{
		if (GetAsyncKeyState('W') & 0x8000f)
			TheCamera.FirstBack(4.0f * timeDelta);

		if (GetAsyncKeyState('S') & 0x8000f)
			TheCamera.FirstBack(-4.0f * timeDelta);

		if (GetAsyncKeyState('A') & 0x8000f)
			TheCamera.LeftRight(-4.0f * timeDelta);

		if (GetAsyncKeyState('D') & 0x8000f)
			TheCamera.LeftRight(4.0f * timeDelta);

		if (GetAsyncKeyState('R') & 0x8000f)
			TheCamera.UpDown(4.0f * timeDelta);

		if (GetAsyncKeyState('F') & 0x8000f)
			TheCamera.UpDown(-4.0f * timeDelta);

		if (GetAsyncKeyState(VK_UP) & 0x8000f)
			TheCamera.RollRightVector(1.0f * timeDelta);

		if (GetAsyncKeyState(VK_DOWN) & 0x8000f)
			TheCamera.RollRightVector(-1.0f * timeDelta);

		if (GetAsyncKeyState(VK_LEFT) & 0x8000f)
			TheCamera.RollUpVector(-1.0f * timeDelta);
			
		if (GetAsyncKeyState(VK_RIGHT) & 0x8000f)
			TheCamera.RollUpVector(1.0f * timeDelta);

		if (GetAsyncKeyState('N') & 0x8000f)
			TheCamera.RollFirstVector(1.0f * timeDelta);

		if (GetAsyncKeyState('M') & 0x8000f)
			TheCamera.RollFirstVector(-1.0f * timeDelta);

		// Обновление матрицы вида согласно новому
        //местоположению и ориентации камеры
		D3DXMATRIX V;
		TheCamera.getViewMatrix(&V);
		pDirect3DDevice->SetTransform(D3DTS_VIEW, &V);
	}
	return true;
}

// Функция синхронизации перемещения камеры по прошедшему с прошлого кадра времени (timeDelta)
void EnterMsgLoop (bool (*ptr_display)(float timeDelta))
{
	MSG msg;
	ZeroMemory(&msg, sizeof(msg));

	static float lastTime = (float)timeGetTime(); 

	while(msg.message != WM_QUIT)
	{
		if(PeekMessage(&msg, 0, 0, 0, PM_REMOVE))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else
        {	
			float currTime  = (float)timeGetTime();
			float timeDelta = (currTime - lastTime)*0.001f;

			ptr_display(timeDelta);
			lastTime = currTime;

			RenderingDirect3D();
        }
    }
}
