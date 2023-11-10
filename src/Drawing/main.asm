
.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc

WinMain PROTO :DWORD

public hMenu

;======================== DATA ========================
.data

; �����Լ�������
className db "DrawingClass", 0
appName db "��ͼ", 0

; ����ȱ���
hInstance HINSTANCE ?
hMenu HMENU ?

;======================== CODE ========================
.code

start:
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	INVOKE WinMain, hInstance
	INVOKE ExitProcess, eax


WinMain PROC,
	hInst: HINSTANCE
	LOCAL wc: WNDCLASSEX
	LOCAL msg: MSG
	LOCAL hwnd: HWND

	INVOKE CreateMainMenu	; ��ʼ���˵�
	; ��� WNDCLASSEX ��
	mov wc.cbSize, SIZEOF WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc, OFFSET WndProc
	mov wc.cbClsExtra, NULL
	mov wc.cbWndExtra, NULL
	mov eax, hInst
	mov wc.hInstance, eax
	mov wc.hbrBackground, COLOR_WINDOWFRAME
	mov wc.lpszMenuName, NULL
	mov wc.lpszClassName, OFFSET className
	INVOKE LoadIcon, NULL, IDI_APPLICATION
	mov wc.hIcon, eax
	mov wc.hIconSm, eax
	INVOKE LoadCursor, NULL, IDC_ARROW
	mov wc.hCursor, eax
	; register window class
	INVOKE RegisterClassEx, ADDR wc
	; create window app		988 �� 600
	INVOKE CreateWindowEx, NULL, ADDR className, ADDR appName, \
		WS_OVERLAPPEDWINDOW AND (NOT WS_SIZEBOX) AND (NOT WS_MAXIMIZEBOX) AND (NOT WS_MINIMIZEBOX), CW_USEDEFAULT, \
		CW_USEDEFAULT, 988, 600, NULL, hMenu, \
		hInst, NULL
	mov hwnd, eax
	; Show and draw the window.
	INVOKE ShowWindow, hwnd, SW_SHOWNORMAL
	INVOKE UpdateWindow, hwnd
	; message-handling loop
	.WHILE TRUE
		INVOKE GetMessage, ADDR msg, NULL, 0, 0
		.BREAK .IF (!eax)
			INVOKE TranslateMessage, ADDR msg
		INVOKE DispatchMessage, ADDR msg
	.ENDW
	mov eax, msg.wParam
	ret
WinMain ENDP


; message handler
WndProc PROC USES ebx ecx edx,
	hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM

	.IF uMsg == WM_DESTROY		; ��������
		INVOKE PostQuitMessage, NULL

	.ELSEIF uMsg == WM_COMMAND	; �ؼ�����(��ť���˵�)
		INVOKE HandleCommand, hWnd, wParam, lParam

	.ELSEIF uMsg == WM_MOUSEMOVE	; ����ƶ�
		INVOKE HandleMouseMove, hWnd, wParam, lParam

	.ELSEIF uMsg == WM_LBUTTONDOWN	; ����������
		INVOKE HandleLButtonDown, hWnd, wParam, lParam

	.ELSEIF uMsg == WM_LBUTTONUP	; �������ͷ�
		INVOKE HandleLButtonUp, hWnd, wParam, lParam

	.ELSEIF uMsg == WM_PAINT	; �����ػ�
		INVOKE HandlePaint, hWnd, wParam, lParam

	.ELSE
		INVOKE DefWindowProc, hWnd, uMsg, wParam, lParam	; Ĭ����Ϣ������
		ret
	.ENDIF

	xor eax, eax
	ret
WndProc ENDP

end start