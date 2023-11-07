;�¼�����

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc

;PUBLIC lMouseFlag

.data

;lMouseFlag	DWORD	0		;������״̬��down(1)��up(0)��ֻ��down��ʱ��Ż����
drawingArea	RECT <0,0,800,600>	;�������򣬾��Ǵ��ڵ� client area
drawingText LPCTSTR "draw"
color		DWORD	0


.code

; ���� VM_COMMAND
HandleCommand PROC USES ebx ecx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	
	;extern mode:DWORD	; ����ģʽ�������� paint.asm
	;���Ļ�������
	.IF wParam == IDM_MENU_BRUSH_BASIC
		mov mode, IDM_MODE_FREEHAND
	.ELSEIF wParam == IDM_MENU_BRUSH_DASH
		mov pen_style, PS_DASH
		mov pen_width, 1
	;ѡ�񹤾�
	.ELSEIF wParam == IDM_MENU_TOOL_ERASER
		mov mode, IDM_MODE_ERASE
	.ELSEIF wParam == IDM_MENU_TOOL_TEXT
		mov mode, IDM_MODE_TEXT
	.ELSEIF wParam == IDM_MENU_TOOL_COLPIC
		mov mode, IDM_MODE_COLPIC
	;ѡ����״
	.ELSEIF wParam == IDM_MENU_SHAPE_LINE
		mov mode, IDM_MODE_SHAPE_LINE
	.ELSEIF wParam == IDM_MENU_SHAPE_CIRCLE
		mov mode, IDM_MODE_SHAPE_CIRCLE
	.ELSEIF wParam == IDM_MENU_SHAPE_RECT
		mov mode, IDM_MODE_SHAPE_RECT
	;���ıʴ���С
	.ELSEIF wParam == IDM_MENU_SIZE_ONE
		mov pen_width, 1 
	.ELSEIF wParam == IDM_MENU_SIZE_THREE
		mov pen_width, 3 
	.ELSEIF wParam == IDM_MENU_SIZE_FIVE
		mov pen_width, 5 
	.ELSEIF wParam == IDM_MENU_SIZE_SEVEN
		mov pen_width, 7 
	;������ɫ
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
	.IF mode == IDM_MODE_FREEHAND	;��ͼģʽ
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
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�VM_PAINT
		.ENDIF
	.ENDIF

	.IF mode == IDM_MODE_ERASE
		.IF lMouseFlag == 1
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�VM_PAINT
		.ENDIF
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_LINE || mode == IDM_MODE_SHAPE_CIRCLE || mode == IDM_MODE_SHAPE_RECT
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
			INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�VM_PAINT
		.ENDIF
	.ENDIF

	ret
HandleMouseMove ENDP

; ����������
HandleLButtonDown PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM


	mov lMouseFlag, 1
	.IF mode == IDM_MODE_TEXT
		INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�VM_PAINT
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

	mov lastX, 0
	mov lastY, 0
	mov beginX, 0
	mov endX, 0
	mov beginY, 0
	mov endY, 0
	mov	lMouseFlag, 0

	ret
HandleLButtonUp	ENDP

; �ػ�
HandlePaint PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM

	LOCAL ps:PAINTSTRUCT
	LOCAL hPen:HPEN
	LOCAL hPenInverse:HPEN

	INVOKE BeginPaint, hWnd, ADDR ps

	;�Զ��廭��
	INVOKE CreatePen, pen_style, pen_width, pen_color
	mov hPen, eax
	;ʵʱ�����û���
	INVOKE CreatePen, pen_style, 10, 0FFFFFFh
	mov hPenInverse, eax


	.IF mode == IDM_MODE_FREEHAND	; ���ɻ���
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Freehand, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_ERASE	; ��Ƥ��
		INVOKE Erase, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_TEXT	;�ı�
		INVOKE Draw_Text, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_LINE	;ֱ��
		;����ǰͼ
		INVOKE SelectObject, ps.hdc, hPenInverse
		INVOKE Draw_Line_Inverse, ps.hdc
		;�滭��ͼ
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Draw_Line, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_CIRCLE	;Բ
		;����ǰͼ
		INVOKE SelectObject, ps.hdc, hPenInverse
		INVOKE Draw_Circle_Inverse, ps.hdc
		;�滭��ͼ
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Draw_Circle, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_SHAPE_RECT	;����
		;����ǰͼ
		INVOKE SelectObject, ps.hdc, hPenInverse
		INVOKE Draw_Rect_Inverse, ps.hdc
		;�滭��ͼ
		INVOKE SelectObject, ps.hdc, hPen
		INVOKE Draw_Rect, ps.hdc
	.ENDIF
	INVOKE EndPaint, hWnd, ADDR ps

	ret
HandlePaint ENDP

END