;事件处理

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc
INCLUDE gdiplus.inc

;PUBLIC lMouseFlag

.data
;修改颜色
acrCustClr		COLORREF	16 DUP(0)
; 内存缓存
memDC		HDC			?
memBitmap	HBITMAP		?
isDrawing	DWORD		0

.code

; 选择线条颜色
ChangeColorLine PROC, hWnd:HWND
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
		mov border, 1
		
	error:
		ret
ChangeColorLine ENDP


; 选择填充颜色
ChangeColorFill PROC, hWnd:HWND
		LOCAL cc:CHOOSECOLOR 

		mov cc.lStructSize, SIZEOF cc
		mov eax, hWnd
		mov cc.hwndOwner, eax
		mov cc.lpCustColors, OFFSET acrCustClr
		mov eax, fill_color
		mov cc.rgbResult, eax
		mov eax, CC_FULLOPEN
		or eax, CC_RGBINIT
		mov cc.Flags, eax

		INVOKE ChooseColor, ADDR cc
		test eax, eax
		jz error
		mov eax, cc.rgbResult
		mov fill_color, eax
		mov fill, 1
		mov fill_style, 0
		
	error:
		ret
ChangeColorFill ENDP


; 处理 VM_COMMAND
HandleCommand PROC USES ebx ecx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM

	LOCAL cursor:LPCTSTR
	LOCAL hCursor:HCURSOR
	LOCAL ps:PAINTSTRUCT 
	LOCAL hdc:HDC

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
	.ELSEIF wParam == IDM_MENU_BRUSH_WRITEBRUSH
		mov mode, IDM_MODE_WRITEBRUSH
	.ELSEIF wParam == IDM_MENU_BRUSH_DOUBLELINE
		mov mode, IDM_MODE_DOUBLELINE
	.ELSEIF wParam == IDM_MENU_BRUSH_PENCIL
		mov mode, IDM_MODE_PENCIL
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
	.ELSEIF wParam == IDM_MENU_SHAPE_ROUND_RECT
		mov mode, IDM_MODE_SHAPE_ROUND_RECT
	.ELSEIF wParam == IDM_MENU_SHAPE_TRIANGLE
		mov mode, IDM_MODE_SHAPE_TRIANGLE
	;更改笔触大小
	.ELSEIF wParam == IDM_MENU_SIZE_ONE
		.IF mode == IDM_MODE_ERASE
			mov eraser_size, 1
		.ELSE
			mov pen_width, 1 
		.ENDIF
	.ELSEIF wParam == IDM_MENU_SIZE_THREE
		.IF mode == IDM_MODE_ERASE
			mov eraser_size, 3
		.ELSE
			mov pen_width, 3
		.ENDIF
	.ELSEIF wParam == IDM_MENU_SIZE_FIVE
		.IF mode == IDM_MODE_ERASE
			mov eraser_size, 5
		.ELSE
			mov pen_width, 5
		.ENDIF
	.ELSEIF wParam == IDM_MENU_SIZE_SEVEN
		.IF mode == IDM_MODE_ERASE
			mov eraser_size, 7
		.ELSE
			mov pen_width, 7
		.ENDIF
	.ELSEIF wParam == IDM_MENU_SIZE_NINE
		.IF mode == IDM_MODE_ERASE
			mov eraser_size, 9
		.ELSE
			mov pen_width, 9
		.ENDIF
	.ELSEIF wParam == IDM_MENU_SIZE_ELEVEN
		.IF mode == IDM_MODE_ERASE
			mov eraser_size, 11
		.ELSE
			mov pen_width, 11
		.ENDIF
	.ELSEIF wParam == IDM_MENU_SIZE_THIRTEEN
		.IF mode == IDM_MODE_ERASE
			mov eraser_size, 13
		.ELSE
			mov pen_width, 13
		.ENDIF
	.ELSEIF wParam == IDM_MENU_SIZE_FIFTEEN
		.IF mode == IDM_MODE_ERASE
			mov eraser_size, 15
		.ELSE
			mov pen_width, 15
		.ENDIF
	;更改颜色
	.ELSEIF wParam == IDM_MENU_COLOR_LINE_NULL
		mov border, 0
	.ELSEIF wParam == IDM_MENU_COLOR_LINE_COLOR
		INVOKE ChangeColorLine, hWnd
	.ELSEIF wParam == IDM_MENU_COLOR_FILL_NULL
		mov fill, 0
	.ELSEIF wParam == IDM_MENU_COLOR_FILL_COLOR
		INVOKE ChangeColorFill, hWnd
	.ELSEIF wParam == IDM_MENU_COLOR_FILL_STYLE_1
		mov fill_style, 1
	.ELSEIF wParam == IDM_MENU_COLOR_FILL_STYLE_2
		mov fill_style, 2
	.ELSEIF wParam == IDM_MENU_COLOR_FILL_STYLE_3
		mov fill_style, 3
	.ELSEIF wParam == IDM_MENU_COLOR_FILL_STYLE_4
		mov fill_style, 4
	.ELSEIF wParam == IDM_MENU_COLOR_FILL_STYLE_5
		mov fill_style, 5
	.ELSEIF wParam == IDM_MENU_COLOR_FILL_STYLE_6
		mov fill_style, 6
	; 选择文件
	.ELSEIF wParam == IDM_MENU_FILE_OPEN
		INVOKE Openfile, hWnd
	.ELSEIF wParam == IDM_MENU_FILE_SAVE
		INVOKE Savefile, hWnd
	.ENDIF

	; 保存当前画面（仅用于形状）
	.IF wParam == IDM_MENU_SHAPE_CIRCLE || wParam == IDM_MENU_SHAPE_LINE || wParam == IDM_MENU_SHAPE_RECT || wParam == IDM_MENU_SHAPE_ROUND_RECT || wParam == IDM_MENU_SHAPE_TRIANGLE
		; 创建内存DC和内存位图
		INVOKE GetDC, hWnd
		mov hdc, eax
		INVOKE CreateCompatibleDC, hdc
		mov memDC, eax
		INVOKE CreateCompatibleBitmap, hdc, 988, 600
		mov memBitmap, eax
		INVOKE SelectObject, memDC, memBitmap
		INVOKE ReleaseDC, hWnd, hdc
		
		INVOKE BeginPaint, hWnd, ADDR ps
		INVOKE BitBlt, memDC, 0, 0, drawingArea.right, drawingArea.bottom, ps.hdc, 0, 0, SRCCOPY
		INVOKE EndPaint, hWnd, ADDR ps
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
	.IF mode == IDM_MODE_FREEHAND || mode == IDM_MODE_WRITEBRUSH || \
		mode == IDM_MODE_DOUBLELINE || mode == IDM_MODE_PENCIL || mode == IDM_MODE_ERASE	;画图模式
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
			;INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号WM_PAINT
		.ENDIF
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_LINE || mode == IDM_MODE_SHAPE_CIRCLE || mode == IDM_MODE_SHAPE_RECT || mode == IDM_MODE_SHAPE_ROUND_RECT || mode == IDM_MODE_SHAPE_TRIANGLE
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

			;重绘
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
	.ELSEIF mode == IDM_MODE_TEXT
		mov ebx, curX
		mov fixedX, ebx
		mov ebx, curY
		mov fixedY, ebx
	.ELSEIF mode == IDM_MODE_SHAPE_LINE || mode == IDM_MODE_SHAPE_CIRCLE || mode == IDM_MODE_SHAPE_RECT || mode == IDM_MODE_SHAPE_ROUND_RECT || mode == IDM_MODE_SHAPE_TRIANGLE
		mov isDrawing, 1
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
	LOCAL ps:PAINTSTRUCT

	mov lastX, 0
	mov lastY, 0
	mov beginX, 0
	mov endX, 0
	mov beginY, 0
	mov endY, 0
	mov	lMouseFlag, 0

	.IF mode == IDM_MODE_SHAPE_LINE || mode == IDM_MODE_SHAPE_CIRCLE || mode == IDM_MODE_SHAPE_RECT || mode == IDM_MODE_SHAPE_ROUND_RECT || mode == IDM_MODE_SHAPE_TRIANGLE
		mov isDrawing, 0
		INVOKE BeginPaint, hWnd, ADDR ps
		INVOKE BitBlt, memDC, 0, 0, drawingArea.right, drawingArea.bottom, ps.hdc, 0, 0, SRCCOPY
		INVOKE EndPaint, hWnd, ADDR ps
	.ENDIF

	ret
HandleLButtonUp	ENDP

;键盘按下
HandleKeyboard PROC USES eax ebx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	extern buf:BYTE
	extern cnt:DWORD

	.IF mode == IDM_MODE_TEXT
		.IF wParam == 0dh	;回车按下
			mov cnt, 0
			add fixedY,20
		.ELSE
			mov eax, wParam
			mov ebx, cnt
			mov buf[ebx], al
			inc cnt
		.ENDIF
		INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;触发窗口重绘信号WM_PAINT
	.ENDIF

	ret
HandleKeyboard ENDP

; 重绘
HandlePaint PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM

	LOCAL ps:PAINTSTRUCT
	LOCAL hPen:HPEN
	LOCAL brush:HBRUSH
	LOCAL hBrush:HBRUSH
	LOCAL hOldBrush:HBRUSH
	LOCAL eraser:HPEN

	INVOKE BeginPaint, hWnd, ADDR ps

	;自定义画笔
	;处理形状无轮廓情况
	.IF mode == IDM_MODE_SHAPE_CIRCLE || mode == IDM_MODE_SHAPE_RECT || mode == IDM_MODE_SHAPE_ROUND_RECT || mode == IDM_MODE_SHAPE_TRIANGLE
		.IF border == 0
			INVOKE CreatePen, pen_style, pen_width, fill_color
			mov hPen, eax
		.ELSE
			INVOKE CreatePen, pen_style, pen_width, pen_color
			mov hPen, eax
		.ENDIF
	.ELSE
		INVOKE CreatePen, pen_style, pen_width, pen_color
		mov hPen, eax
	.ENDIF
	INVOKE GetStockObject, NULL_BRUSH
	mov brush, eax
	;纯色填充与纹理填充
	.IF fill_style == 0
		INVOKE CreateSolidBrush, fill_color
	.ELSEIF fill_style == 1
		INVOKE CreateHatchBrush, HS_HORIZONTAL, fill_color
	.ELSEIF fill_style == 2
		INVOKE CreateHatchBrush, HS_VERTICAL, fill_color
	.ELSEIF fill_style == 3
		INVOKE CreateHatchBrush, HS_CROSS, fill_color
	.ELSEIF fill_style == 4
		INVOKE CreateHatchBrush, HS_DIAGCROSS, fill_color
	.ELSEIF fill_style == 5
		INVOKE CreateHatchBrush, HS_FDIAGONAL, fill_color
	.ELSEIF fill_style == 6
		INVOKE CreateHatchBrush, HS_BDIAGONAL, fill_color
	.ENDIF
	mov hBrush, eax
	;橡皮擦
	INVOKE CreatePen, pen_style, eraser_size, 0FFFFFFh
	mov eraser, eax

	;从内存加载旧图像（仅适用于绘制形状）
	.IF mode == IDM_MODE_SHAPE_LINE || mode == IDM_MODE_SHAPE_CIRCLE || mode == IDM_MODE_SHAPE_RECT || mode == IDM_MODE_SHAPE_ROUND_RECT || mode == IDM_MODE_SHAPE_TRIANGLE
		INVOKE BitBlt, ps.hdc, 0, 0, drawingArea.right, drawingArea.bottom, memDC, 0, 0, SRCCOPY
	.ENDIF

	.IF mode == IDM_MODE_FREEHAND	; 自由绘制
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Freehand, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_WRITEBRUSH	;毛笔
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE WriteBrush, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_PENCIL	;铅笔
		push pen_width
		.WHILE pen_width
		INVOKE SetPixel,ps.hdc,curX,curY,pen_color
		inc curX
		inc curY
		INVOKE SetPixel,ps.hdc,curX,curY,pen_color
		dec pen_width
		.ENDW
		pop pen_width

		push pen_width
		mov eax,pen_width
		sub curX,eax
		.WHILE pen_width
		INVOKE SetPixel,ps.hdc,curX,curY,pen_color
		inc curX
		dec curY
		dec pen_width
		.ENDW
		pop pen_width
	.ENDIF

	.IF mode == IDM_MODE_DOUBLELINE	;双线
		INVOKE SetPixel,ps.hdc,curX,curY,pen_color
		add curX,5
		add curY,5
		INVOKE SetPixel,ps.hdc,curX,curY,pen_color
	.ENDIF

	.IF mode == IDM_MODE_ERASE	; 橡皮擦
		INVOKE SelectObject, ps.hdc, eraser
		INVOKE Freehand, ps.hdc
		;INVOKE Erase, ps.hdc
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
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Draw_Line, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_CIRCLE	;圆
		INVOKE SelectObject, ps.hdc, hPen	;轮廓画笔	
		.IF fill == 0
			INVOKE SelectObject, ps.hdc, brush	;空心画刷
		.ELSE
			INVOKE SelectObject, ps.hdc, hBrush
			mov hOldBrush, eax
		.ENDIF
		INVOKE Draw_Circle, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_RECT	;矩形
		INVOKE SelectObject, ps.hdc, hPen
		.IF fill == 0
			INVOKE SelectObject, ps.hdc, brush	;空心画刷
		.ELSE
			INVOKE SelectObject, ps.hdc, hBrush
			mov hOldBrush, eax
		.ENDIF
		INVOKE Draw_Rect, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_ROUND_RECT	;圆角矩形
		INVOKE SelectObject, ps.hdc, hPen
		.IF fill == 0
			INVOKE SelectObject, ps.hdc, brush	;空心画刷
		.ELSE
			INVOKE SelectObject, ps.hdc, hBrush
			mov hOldBrush, eax
		.ENDIF
		INVOKE Draw_Round_Rect, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_TRIANGLE
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Draw_Triangle, ps.hdc
	.ENDIF

	; 回收资源
	INVOKE SelectObject, ps.hdc, hOldBrush
	INVOKE DeleteObject, hBrush
	INVOKE EndPaint, hWnd, ADDR ps

	ret
HandlePaint ENDP

END