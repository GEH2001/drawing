;事件处理

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc

;PUBLIC lMouseFlag

.data

;lMouseFlag	DWORD	0		;鼠标左键状态：down(1)、up(0)，只有down的时候才会绘制
drawingArea	RECT <0,0,800,600>	;绘制区域，就是窗口的 client area

.code

; 处理 VM_COMMAND
HandleCommand PROC USES ebx ecx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	
	;extern mode:DWORD	; 绘制模式，定义在 paint.asm

	.IF wParam == IDM_MENU_BRUSH_BASIC
		mov mode, IDM_MODE_FREEHAND
	.ELSEIF wParam == IDM_MENU_TOOL_ERASER
		mov mode, IDM_MODE_ERASE
	.ENDIF

	ret
HandleCommand ENDP


HandleMouseMove PROC USES ebx ecx edx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	
	;变量定义在 paint.asm
	;extern mode:DWORD
	extern curX:DWORD
	extern curY:DWORD
	extern beginX:DWORD
	extern beginY:DWORD
	extern endX:DWORD
	extern endY:DWORD


	;获取鼠标当前位置：lParam 低16位是x坐标，高16位是y坐标
	mov ebx, lParam
	mov ecx, 0
	mov cx, bx	; x
	shr ebx, 16	; y
	mov curX, ecx
	mov curY, ebx
	
	;更新 begin(x,y) end(x,y)
	.IF mode == IDM_MODE_FREEHAND	;画图模式
		.IF lMouseFlag == 1
			.IF	endX == 0	; 鼠标第一次进入 client area, begin和end设置为相等，绘制线条的距离为0（也就是不绘制）
				mov beginX, ecx
			.ELSE
				mov eax, endX	;把begin更新为上次的end
				mov beginX, eax
			.ENDIF
			
			.IF endY == 0
				mov beginY, ebx
			.ELSE
				mov eax, endY
				mov beginY, eax
			.ENDIF
			;把end更新为cur
			mov endX, ecx	;curX
			mov endY, ebx	;curY
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号VM_PAINT
		.ENDIF
	.ENDIF

	.IF mode == IDM_MODE_ERASE
		.IF lMouseFlag == 1
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号VM_PAINT
		.ENDIF
	.ENDIF

	ret
HandleMouseMove ENDP

; 鼠标左键按下
HandleLButtonDown PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	mov lMouseFlag, 1

	ret
HandleLButtonDown ENDP

; 鼠标左键松开
HandleLButtonUp	PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	
	extern beginX:DWORD
	extern beginY:DWORD
	extern endX:DWORD
	extern endY:DWORD

	mov	lMouseFlag, 0
	mov beginX, 0
	mov endX, 0
	mov beginY, 0
	mov endY, 0

	ret
HandleLButtonUp	ENDP

; 重绘
HandlePaint PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM

	LOCAL ps:PAINTSTRUCT
	LOCAL hPen:HPEN

	INVOKE BeginPaint, hWnd, ADDR ps

	;自定义画笔
	INVOKE CreatePen, pen_style, pen_width, pen_color
	mov hPen, eax
	INVOKE SelectObject, ps.hdc, hPen

	.IF mode == IDM_MODE_FREEHAND	; 自由绘制
		INVOKE Freehand, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_ERASE	; 橡皮擦
		INVOKE Erase, ps.hdc
	.ENDIF

	INVOKE EndPaint, hWnd, ADDR ps

	ret
HandlePaint ENDP

END