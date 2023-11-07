;事件处理

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc

;PUBLIC lMouseFlag

.data

;lMouseFlag	DWORD	0		;鼠标左键状态：down(1)、up(0)，只有down的时候才会绘制
drawingArea	RECT <0,0,800,600>	;绘制区域，就是窗口的 client area
drawingText LPCTSTR "draw"
color		DWORD	0


.code

; 处理 VM_COMMAND
HandleCommand PROC USES ebx ecx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	
	;extern mode:DWORD	; 绘制模式，定义在 paint.asm
	;更改画笔类型
	.IF wParam == IDM_MENU_BRUSH_BASIC
		mov mode, IDM_MODE_FREEHAND
	.ELSEIF wParam == IDM_MENU_BRUSH_DASH
		mov pen_style, PS_DASH
		mov pen_width, 1
	;选择工具
	.ELSEIF wParam == IDM_MENU_TOOL_ERASER
		mov mode, IDM_MODE_ERASE
	.ELSEIF wParam == IDM_MENU_TOOL_TEXT
		mov mode, IDM_MODE_TEXT
	.ELSEIF wParam == IDM_MENU_TOOL_COLPIC
		mov mode, IDM_MODE_COLPIC
	;选择形状
	.ELSEIF wParam == IDM_MENU_SHAPE_LINE
		mov mode, IDM_MODE_SHAPE_LINE
	.ELSEIF wParam == IDM_MENU_SHAPE_CIRCLE
		mov mode, IDM_MODE_SHAPE_CIRCLE
	.ELSEIF wParam == IDM_MENU_SHAPE_RECT
		mov mode, IDM_MODE_SHAPE_RECT
	;更改笔触大小
	.ELSEIF wParam == IDM_MENU_SIZE_ONE
		mov pen_width, 1 
	.ELSEIF wParam == IDM_MENU_SIZE_THREE
		mov pen_width, 3 
	.ELSEIF wParam == IDM_MENU_SIZE_FIVE
		mov pen_width, 5 
	.ELSEIF wParam == IDM_MENU_SIZE_SEVEN
		mov pen_width, 7 
	;更改颜色
	.ELSEIF wParam == IDM_MENU_COLOR_BLACK
		mov pen_color, 0h
	.ELSEIF wParam == IDM_MENU_COLOR_RED
		mov pen_color, 0FFh
	.ELSEIF wParam == IDM_MENU_COLOR_ORANGE
		mov pen_color, 0A5FFh
	.ELSEIF wParam == IDM_MENU_COLOR_GREEN
		mov pen_color, 0FF00h
	.ELSEIF wParam == IDM_MENU_COLOR_YELLOW
		mov pen_color, 0FFFFh
	.ELSEIF wParam == IDM_MENU_COLOR_PURPLE
		mov pen_color, 0FF00FFh
	.ELSEIF wParam == IDM_MENU_COLOR_CYAN
		mov pen_color, 0FFFF00h
	.ELSEIF wParam == IDM_MENU_COLOR_BLUE
		mov pen_color, 0FF0000h
	.ELSEIF wParam == IDM_MENU_COLOR_CELESTE
		mov pen_color, 0FF7F00h
	.ELSEIF wParam == IDM_MENU_COLOR_WHITE
		mov pen_color, 0FFFFFFh

	.ENDIF

	ret
HandleCommand ENDP


HandleMouseMove PROC USES ebx ecx edx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	
	;变量定义在 paint.asm
	;extern mode:DWORD
	extern lastX:DWORD
	extern lastY:DWORD
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

	.IF mode == IDM_MODE_SHAPE_LINE || mode == IDM_MODE_SHAPE_CIRCLE || mode == IDM_MODE_SHAPE_RECT
		.IF lMouseFlag == 1
			.IF	endX == 0	; 鼠标第一次进入 client area, last坐标需要置cur
				mov beginX, ecx
				mov lastX, ecx
			.ELSE
				mov eax, endX
				mov lastX, eax
			.ENDIF
			
			.IF endY == 0
				mov beginY, ebx
				mov lastY, ebx
			.ELSE
				mov eax, endY
				mov lastY, eax
			.ENDIF
			;把end更新为cur
			mov endX, ecx	;curX
			mov endY, ebx	;curY
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号VM_PAINT
		.ENDIF
	.ENDIF

	ret
HandleMouseMove ENDP

; 鼠标左键按下
HandleLButtonDown PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM


	mov lMouseFlag, 1
	.IF mode == IDM_MODE_TEXT
		INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号VM_PAINT
	.ENDIF

	ret
HandleLButtonDown ENDP

; 鼠标左键松开
HandleLButtonUp	PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	extern lastX:DWORD
	extern lastY:DWORD
	extern beginX:DWORD
	extern beginY:DWORD
	extern endX:DWORD
	extern endY:DWORD

	mov lastX, 0
	mov lastY, 0
	mov beginX, 0
	mov endX, 0
	mov beginY, 0
	mov endY, 0
	mov	lMouseFlag, 0

	ret
HandleLButtonUp	ENDP

; 重绘
HandlePaint PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM

	LOCAL ps:PAINTSTRUCT
	LOCAL hPen:HPEN
	LOCAL hPenInverse:HPEN

	INVOKE BeginPaint, hWnd, ADDR ps

	;自定义画笔
	INVOKE CreatePen, pen_style, pen_width, pen_color
	mov hPen, eax
	;实时消除用画笔
	INVOKE CreatePen, pen_style, 10, 0FFFFFFh
	mov hPenInverse, eax


	.IF mode == IDM_MODE_FREEHAND	; 自由绘制
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Freehand, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_ERASE	; 橡皮擦
		INVOKE Erase, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_TEXT	;文本
		INVOKE Draw_Text, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_LINE	;直线
		;擦除前图
		INVOKE SelectObject, ps.hdc, hPenInverse
		INVOKE Draw_Line_Inverse, ps.hdc
		;绘画新图
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Draw_Line, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_CIRCLE	;圆
		;擦除前图
		INVOKE SelectObject, ps.hdc, hPenInverse
		INVOKE Draw_Circle_Inverse, ps.hdc
		;绘画新图
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Draw_Circle, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_RECT	;矩形
		;擦除前图
		INVOKE SelectObject, ps.hdc, hPenInverse
		INVOKE Draw_Rect_Inverse, ps.hdc
		;绘画新图
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Draw_Rect, ps.hdc
	.ENDIF
	INVOKE EndPaint, hWnd, ADDR ps

	ret
HandlePaint ENDP

END