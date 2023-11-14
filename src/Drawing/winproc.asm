;事件处理

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc

;PUBLIC lMouseFlag

.data

;lMouseFlag	DWORD	0		;鼠标左键状态：down(1)、up(0)，只有down的时候才会绘制
;drawingArea	RECT <0,0,988,600>	;绘制区域，就是窗口的 client area
;修改颜色
acrCustClr		COLORREF	16 DUP(0)


.code

; 选择颜色
ChangeColor PROC, hWnd:HWND
		LOCAL cc:CHOOSECOLOR 

		mov cc.lStructSize, SIZEOF cc
		mov eax, hWnd
		mov cc.hwndOwner, eax
		mov cc.lpCustColors, OFFSET acrCustClr
		mov eax, pen_color
		mov cc.rgbResult, eax
		mov eax, CC_FULLOPEN
		or eax, CC_RGBINIT
		mov cc.Flags, eax

		INVOKE ChooseColor, ADDR cc
		test eax, eax
		jz error
		mov eax, cc.rgbResult
		mov pen_color, eax
		
	error:
		ret
ChangeColor ENDP


; 处理 VM_COMMAND
HandleCommand PROC USES ebx ecx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM

	LOCAL cursor:LPCTSTR
	LOCAL hCursor:HCURSOR

	;光标形状改回
	.IF wParam != IDM_MENU_TOOL_TEXT
		.IF wParam != IDM_MENU_TOOL_COLPIC
			mov cursor, IDC_ARROW  
			INVOKE LoadCursor, NULL, cursor
			mov hCursor, eax
			INVOKE SetClassLong, hWnd, GCL_HCURSOR, hCursor
			INVOKE ShowCursor, TRUE
		.ENDIF
	.ENDIF

	;更改画笔类型
	.IF wParam == IDM_MENU_BRUSH_BASIC
		mov mode, IDM_MODE_FREEHAND
		mov pen_style, PS_SOLID
	.ELSEIF wParam == IDM_MENU_BRUSH_DASH
		mov pen_style, PS_DASH
		mov pen_width, 1
	;选择工具
	.ELSEIF wParam == IDM_MENU_TOOL_ERASER
		mov mode, IDM_MODE_ERASE
	.ELSEIF wParam == IDM_MENU_TOOL_TEXT
		mov mode, IDM_MODE_TEXT
		; 修改光标形状
		mov cursor, IDC_IBEAM 
		INVOKE LoadCursor, NULL, cursor
		mov hCursor, eax
		INVOKE SetClassLong, hWnd, GCL_HCURSOR, hCursor
		INVOKE ShowCursor, TRUE
	.ELSEIF wParam == IDM_MENU_TOOL_COLPIC
		mov mode, IDM_MODE_COLPIC
		; 修改光标形状
		mov cursor, IDC_CROSS  
		INVOKE LoadCursor, NULL, cursor
		mov hCursor, eax
		INVOKE SetClassLong, hWnd, GCL_HCURSOR, hCursor
		INVOKE ShowCursor, TRUE
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
	.ELSEIF wParam == IDM_MENU_COLOR_CHANGE
		INVOKE ChangeColor, hWnd

	; 选择文件
	.ELSEIF wParam == IDM_MENU_FILE_OPEN
		INVOKE Openfile, hWnd
	.ELSEIF wParam == IDM_MENU_FILE_SAVE
		INVOKE Savefile, hWnd

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
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号WM_PAINT
		.ENDIF
	.ENDIF

	.IF mode == IDM_MODE_ERASE
		.IF lMouseFlag == 1
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号WM_PAINT
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
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号WM_PAINT
		.ENDIF
	.ENDIF

	ret
HandleMouseMove ENDP

; 鼠标左键按下
HandleLButtonDown PROC USES ebx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	extern fixedX:DWORD
	extern fixedY:DWORD
	extern cnt:DWORD

	;清空文本计数
	mov cnt,0

	mov lMouseFlag, 1

	.IF mode == IDM_MODE_COLPIC
		INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号WM_PAINT
	.ENDIF

	.IF mode == IDM_MODE_TEXT
		mov ebx, curX
		mov fixedX, ebx
		mov ebx, curY
		mov fixedY, ebx
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

;键盘按下
HandleKeyboard PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	extern char:WPARAM
	extern cnt:DWORD

	.IF mode == IDM_MODE_TEXT
		push wParam
		pop char
		INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号WM_PAINT
	.ENDIF

	ret
HandleKeyboard ENDP

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
		; 设置文字颜色		
		INVOKE SetTextColor, ps.hdc, pen_color
		INVOKE Draw_Text, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_COLPIC	;取色器
		INVOKE GetPixel, ps.hdc, curX, curY
		mov pen_color, eax
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