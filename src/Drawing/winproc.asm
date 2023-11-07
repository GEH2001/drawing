;�¼�����

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc

;PUBLIC lMouseFlag

.data

;lMouseFlag	DWORD	0		;������״̬��down(1)��up(0)��ֻ��down��ʱ��Ż����
drawingArea	RECT <0,0,800,600>	;�������򣬾��Ǵ��ڵ� client area

.code

; ���� VM_COMMAND
HandleCommand PROC USES ebx ecx,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	
	;extern mode:DWORD	; ����ģʽ�������� paint.asm
	;���Ļ�������
	.IF wParam == IDM_MENU_BRUSH_BASIC
		mov mode, IDM_MODE_FREEHAND
	;ѡ�񹤾�
	.ELSEIF wParam == IDM_MENU_TOOL_ERASER
		mov mode, IDM_MODE_ERASE
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

	ret
HandleMouseMove ENDP

; ����������
HandleLButtonDown PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM
	mov lMouseFlag, 1

	ret
HandleLButtonDown ENDP

; �������ɿ�
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

; �ػ�
HandlePaint PROC,
	hWnd: HWND, wParam: WPARAM, lParam: LPARAM

	LOCAL ps:PAINTSTRUCT
	LOCAL hPen:HPEN

	INVOKE BeginPaint, hWnd, ADDR ps

	;�Զ��廭��
	INVOKE CreatePen, pen_style, pen_width, pen_color
	mov hPen, eax
	INVOKE SelectObject, ps.hdc, hPen

	.IF mode == IDM_MODE_FREEHAND	; ���ɻ���
		INVOKE Freehand, ps.hdc
	.ENDIF

	.IF mode == IDM_MODE_ERASE	; ��Ƥ��
		INVOKE Erase, ps.hdc
	.ENDIF

	INVOKE EndPaint, hWnd, ADDR ps

	ret
HandlePaint ENDP

END