;�¼�����

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc
INCLUDE gdiplus.inc

;PUBLIC lMouseFlag

.data
;�޸���ɫ
acrCustClr		COLORREF	16 DUP(0)
; �ڴ滺��
memDC		HDC			?
memBitmap	HBITMAP		?
isDrawing	DWORD		0

.code

; ѡ��������ɫ
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


; ѡ�������ɫ
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


; ���� VM_COMMAND
HandleCommand PROC USES ebx ecx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM

	LOCAL cursor:LPCTSTR
	LOCAL hCursor:HCURSOR
	LOCAL ps:PAINTSTRUCT 
	LOCAL hdc:HDC

	;�����״�Ļ�
	.IF wParam != IDM_MENU_TOOL_TEXT
		.IF wParam != IDM_MENU_TOOL_COLPIC
			mov cursor, IDC_ARROW  
			INVOKE LoadCursor, NULL, cursor
			mov hCursor, eax
			INVOKE SetClassLong, hWnd, GCL_HCURSOR, hCursor
			INVOKE ShowCursor, TRUE
		.ENDIF
	.ENDIF

	;���Ļ�������
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
	;ѡ�񹤾�
	.ELSEIF wParam == IDM_MENU_TOOL_ERASER
		mov mode, IDM_MODE_ERASE
	.ELSEIF wParam == IDM_MENU_TOOL_TEXT
		mov mode, IDM_MODE_TEXT
		; �޸Ĺ����״
		mov cursor, IDC_IBEAM 
		INVOKE LoadCursor, NULL, cursor
		mov hCursor, eax
		INVOKE SetClassLong, hWnd, GCL_HCURSOR, hCursor
		INVOKE ShowCursor, TRUE
	.ELSEIF wParam == IDM_MENU_TOOL_COLPIC
		mov mode, IDM_MODE_COLPIC
		; �޸Ĺ����״
		mov cursor, IDC_CROSS  
		INVOKE LoadCursor, NULL, cursor
		mov hCursor, eax
		INVOKE SetClassLong, hWnd, GCL_HCURSOR, hCursor
		INVOKE ShowCursor, TRUE
	;ѡ����״
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
	;���ıʴ���С
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
	;������ɫ
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
	; ѡ���ļ�
	.ELSEIF wParam == IDM_MENU_FILE_OPEN
		INVOKE Openfile, hWnd
	.ELSEIF wParam == IDM_MENU_FILE_SAVE
		INVOKE Savefile, hWnd
	.ENDIF

	; ���浱ǰ���棨��������״��
	.IF wParam == IDM_MENU_SHAPE_CIRCLE || wParam == IDM_MENU_SHAPE_LINE || wParam == IDM_MENU_SHAPE_RECT || wParam == IDM_MENU_SHAPE_ROUND_RECT || wParam == IDM_MENU_SHAPE_TRIANGLE
		; �����ڴ�DC���ڴ�λͼ
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
	
	;���������� paint.asm
	;extern mode:DWORD
	extern lastX:DWORD
	extern lastY:DWORD
	extern curX:DWORD
	extern curY:DWORD
	extern beginX:DWORD
	extern beginY:DWORD
	extern endX:DWORD
	extern endY:DWORD

	;��ȡ��굱ǰλ�ã�lParam ��16λ��x���꣬��16λ��y����
	mov ebx, lParam
	mov ecx, 0
	mov cx, bx	; x
	shr ebx, 16	; y
	mov curX, ecx
	mov curY, ebx
	

	;���� begin(x,y) end(x,y)
	.IF mode == IDM_MODE_FREEHAND || mode == IDM_MODE_WRITEBRUSH || \
		mode == IDM_MODE_DOUBLELINE || mode == IDM_MODE_PENCIL || mode == IDM_MODE_ERASE	;��ͼģʽ
		.IF lMouseFlag == 1
			.IF	endX == 0	; ����һ�ν��� client area, begin��end����Ϊ��ȣ����������ľ���Ϊ0��Ҳ���ǲ����ƣ�
				mov beginX, ecx
			.ELSE
				mov eax, endX	;��begin����Ϊ�ϴε�end
				mov beginX, eax
			.ENDIF
			
			.IF endY == 0
				mov beginY, ebx
			.ELSE
				mov eax, endY
				mov beginY, eax
			.ENDIF
			;��end����Ϊcur
			mov endX, ecx	;curX
			mov endY, ebx	;curY
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�WM_PAINT
		.ENDIF
	.ENDIF

	.IF mode == IDM_MODE_ERASE
		.IF lMouseFlag == 1
			;INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�WM_PAINT
		.ENDIF
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_LINE || mode == IDM_MODE_SHAPE_CIRCLE || mode == IDM_MODE_SHAPE_RECT || mode == IDM_MODE_SHAPE_ROUND_RECT || mode == IDM_MODE_SHAPE_TRIANGLE
		.IF lMouseFlag == 1
			.IF	endX == 0	; ����һ�ν��� client area, last������Ҫ��cur
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

			;��end����Ϊcur
			mov endX, ecx	;curX
			mov endY, ebx	;curY

			;�ػ�
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�WM_PAINT
		.ENDIF
	.ENDIF

	ret
HandleMouseMove ENDP

; ����������
HandleLButtonDown PROC USES ebx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	extern fixedX:DWORD
	extern fixedY:DWORD
	extern cnt:DWORD

	;����ı�����
	mov cnt,0

	mov lMouseFlag, 1

	.IF mode == IDM_MODE_COLPIC
		INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�WM_PAINT
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

; �������ɿ�
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

;���̰���
HandleKeyboard PROC USES eax ebx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	extern buf:BYTE
	extern cnt:DWORD

	.IF mode == IDM_MODE_TEXT
		.IF wParam == 0dh	;�س�����
			mov cnt, 0
			add fixedY,20
		.ELSE
			mov eax, wParam
			mov ebx, cnt
			mov buf[ebx], al
			inc cnt
		.ENDIF
		INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�WM_PAINT
	.ENDIF

	ret
HandleKeyboard ENDP

; �ػ�
HandlePaint PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM

	LOCAL ps:PAINTSTRUCT
	LOCAL hPen:HPEN
	LOCAL brush:HBRUSH
	LOCAL hBrush:HBRUSH
	LOCAL hOldBrush:HBRUSH
	LOCAL eraser:HPEN

	INVOKE BeginPaint, hWnd, ADDR ps

	;�Զ��廭��
	;������״���������
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
	;��ɫ������������
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
	;��Ƥ��
	INVOKE CreatePen, pen_style, eraser_size, 0FFFFFFh
	mov eraser, eax

	;���ڴ���ؾ�ͼ�񣨽������ڻ�����״��
	.IF mode == IDM_MODE_SHAPE_LINE || mode == IDM_MODE_SHAPE_CIRCLE || mode == IDM_MODE_SHAPE_RECT || mode == IDM_MODE_SHAPE_ROUND_RECT || mode == IDM_MODE_SHAPE_TRIANGLE
		INVOKE BitBlt, ps.hdc, 0, 0, drawingArea.right, drawingArea.bottom, memDC, 0, 0, SRCCOPY
	.ENDIF

	.IF mode == IDM_MODE_FREEHAND	; ���ɻ���
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Freehand, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_WRITEBRUSH	;ë��
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE WriteBrush, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_PENCIL	;Ǧ��
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

	.IF mode == IDM_MODE_DOUBLELINE	;˫��
		INVOKE SetPixel,ps.hdc,curX,curY,pen_color
		add curX,5
		add curY,5
		INVOKE SetPixel,ps.hdc,curX,curY,pen_color
	.ENDIF

	.IF mode == IDM_MODE_ERASE	; ��Ƥ��
		INVOKE SelectObject, ps.hdc, eraser
		INVOKE Freehand, ps.hdc
		;INVOKE Erase, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_TEXT	;�ı�
		; ����������ɫ		
		INVOKE SetTextColor, ps.hdc, pen_color
		INVOKE Draw_Text, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_COLPIC	;ȡɫ��
		INVOKE GetPixel, ps.hdc, curX, curY
		mov pen_color, eax
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_LINE	;ֱ��
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Draw_Line, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_CIRCLE	;Բ
		INVOKE SelectObject, ps.hdc, hPen	;��������	
		.IF fill == 0
			INVOKE SelectObject, ps.hdc, brush	;���Ļ�ˢ
		.ELSE
			INVOKE SelectObject, ps.hdc, hBrush
			mov hOldBrush, eax
		.ENDIF
		INVOKE Draw_Circle, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_RECT	;����
		INVOKE SelectObject, ps.hdc, hPen
		.IF fill == 0
			INVOKE SelectObject, ps.hdc, brush	;���Ļ�ˢ
		.ELSE
			INVOKE SelectObject, ps.hdc, hBrush
			mov hOldBrush, eax
		.ENDIF
		INVOKE Draw_Rect, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_ROUND_RECT	;Բ�Ǿ���
		INVOKE SelectObject, ps.hdc, hPen
		.IF fill == 0
			INVOKE SelectObject, ps.hdc, brush	;���Ļ�ˢ
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

	; ������Դ
	INVOKE SelectObject, ps.hdc, hOldBrush
	INVOKE DeleteObject, hBrush
	INVOKE EndPaint, hWnd, ADDR ps

	ret
HandlePaint ENDP

END