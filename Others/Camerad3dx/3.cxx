// Функция которая является входной точкой приложения
int WINAPI WinMain(HINSTANCE hInst,	HINSTANCE hprevinstance, LPSTR lpcmdline, int ncmdshow)
{
    WNDCLASSEX windowsclass;
    HWND hwnd;
    MSG msg;
    hInstance = hInst;

    windowsclass.cbSize = sizeof(WNDCLASSEX);
    windowsclass.style = CS_DBLCLKS|CS_OWNDC|CS_HREDRAW|CS_VREDRAW;
    windowsclass.lpfnWndProc = MainWinProc;
    windowsclass.cbClsExtra = 0;
    windowsclass.cbWndExtra = 0;
    windowsclass.hInstance = hInst;
    windowsclass.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    windowsclass.hCursor = LoadCursor(NULL, IDC_ARROW);
    windowsclass.hbrBackground = (HBRUSH)GetStockObject(GRAY_BRUSH);
    windowsclass.lpszMenuName = NULL;
    windowsclass.lpszClassName = "WINDOWSCLASS";
    windowsclass.hIconSm = LoadIcon(NULL, IDI_APPLICATION);

    if (!RegisterClassEx(&windowsclass))
        return 0;

    hwnd = CreateWindowEx(NULL, "WINDOWSCLASS", "Загрузка Х-файла с вращением", WS_OVERLAPPEDWINDOW|WS_VISIBLE,
        0, 0, 770, 500, NULL, NULL, hInst, NULL);
    if (!hwnd)
        return 0;

    if (SUCCEEDED(InitDirect3D(hwnd)))
    {
        if (SUCCEEDED(InitMesh()))
        {
            ShowWindow(hwnd, SW_SHOWDEFAULT);
            UpdateWindow(hwnd);

	EnterMsgLoop(EnterKey);
        }
    }
    return (int)msg.wParam;
}
