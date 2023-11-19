; �������

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc
INCLUDE comdlg32.inc

;PUBLIC mode
PUBLIC lastX
PUBLIC lastY
PUBLIC curX
PUBLIC curY
PUBLIC beginX
PUBLIC beginY
PUBLIC endX
PUBLIC endY
PUBLIC fixedX
PUBLIC fixedY

PUBLIC buf
PUBLIC cnt

.data
;mode    DWORD   ?	;��ͼģʽ����������Ƥ

lastX	DWORD	0	;ǰ�λ�������
lastY	DWORD	0
curX	DWORD	0	;��ǰ����
curY	DWORD	0
beginX	DWORD	0	;Freehand��	MoveTo
beginY	DWORD	0
endX	DWORD	0	;Freehand��	LineTo
endY	DWORD	0
fixedX	DWORD	0	;drawText
fixedY	DWORD	0
tempX	DWORD	0	;writeBrush
tempY	DWORD   0

;���ּ���
cnt			DWORD	0
;��������
buf			BYTE	"abcdefghijk"
;������
pointArray	POINT	5 DUP(<>)
;������
points		POINT	6 DUP(<>)

.code

;��Ƥ��
Erase PROC USES ebx ecx edx, hdc: HDC

	;���û���
	INVOKE GetStockObject, NULL_PEN 
	INVOKE SelectObject, hdc, eax
	;���ƿհ׾��Σ�(curX-10,curY-10) -> (curX+10, curY+10)
	mov	ecx, 10
	mov ebx, curX
	mov edx, curY
	sub curX, ecx	;curX - 10
	sub curY, ecx
	add ebx, ecx	;curX + 10
	add edx, ecx
	INVOKE Rectangle, hdc, curX, curY, ebx, edx
	add curX, ecx
	add curY, ecx

	ret
Erase ENDP

;���ɻ���
Freehand PROC, hdc:HDC
	INVOKE MoveToEx, hdc, beginX, beginY, NULL
	INVOKE LineTo, hdc, endX, endY
	ret
Freehand ENDP

;ֱ��
Draw_Line PROC, hdc:HDC
	INVOKE MoveToEx, hdc, beginX, beginY, NULL
	INVOKE LineTo, hdc, endX, endY
	ret
Draw_Line ENDP

;Բ��
Draw_Circle PROC, hdc:HDC
	INVOKE Ellipse, hdc, beginX, beginY, endX, endY
	ret
Draw_Circle ENDP

;����
Draw_Rect PROC, hdc:HDC
	INVOKE Rectangle, hdc, beginX, beginY, endX, endY
	ret
Draw_Rect ENDP

;Բ�Ǿ���
Draw_Round_Rect PROC, hdc:HDC
	LOCAL w:DWORD
	LOCAL h:DWORD

	mov eax, beginX
	.IF eax > endX
		mov eax, beginX
		sub eax, endX
	.ELSE
		mov eax, endX
		sub eax, beginX
	.ENDIF
    xor edx, edx        ; ���������λ�Ĵ���
    mov ebx, 4			; ���ó���
    div ebx             ; ִ�г�������
    mov w, eax          ; �洢��
	mov eax, beginY
	.IF eax > endY
		mov eax, beginY
		sub eax, endY
	.ELSE
		mov eax, endY
		sub eax, beginY
	.ENDIF
    xor edx, edx        ; ���������λ�Ĵ���
    mov ebx, 4			; ���ó���
    div ebx             ; ִ�г�������
    mov h, eax          ; �洢��
	INVOKE RoundRect, hdc, beginX, beginY, endX, endY, w, h
	ret
Draw_Round_Rect ENDP

;������
Draw_Triangle PROC, hdc:HDC
	LOCAL pX:DWORD
	LOCAL pY:DWORD
	LOCAL region:HRGN 

	;���Ʊ߿�
	mov eax, beginX
	add eax, beginX
	sub eax, endX
	mov pX, eax
	mov eax, endY
	mov pY, eax
	INVOKE MoveToEx, hdc, beginX, beginY, NULL
	INVOKE LineTo, hdc, endX, endY
	INVOKE MoveToEx, hdc, endX, endY, NULL
	INVOKE LineTo, hdc, pX, pY
	INVOKE MoveToEx, hdc, pX, pY, NULL
	INVOKE LineTo, hdc, beginX, beginY

	;�������
	mov eax, beginX
	mov pointArray[0].x, eax
	mov eax, beginY
	mov pointArray[0].y, eax
	mov eax, endX
	mov pointArray[8].x, eax
	mov eax, endY
	mov pointArray[8].y, eax
	mov eax, pX
	mov pointArray[16].x, eax
	mov eax, pY
	mov pointArray[16].y, eax

	INVOKE SetPolyFillMode, hdc, ALTERNATE
	INVOKE Polygon, hdc, OFFSET pointArray, 3

	ret
Draw_Triangle ENDP

;������
Draw_Hexagon PROC, hdc:HDC
	LOCAL w:DWORD
	LOCAL h:DWORD
	LOCAL x:DWORD
	LOCAL y:DWORD

	mov eax, endX
	sub eax, beginX
	shr eax, 1
	mov w, eax
	mov eax, endY
	sub eax, beginY
	shr eax, 2
	mov h, eax

	mov eax, beginX
	add eax, w
	mov x, eax
	mov points[0].x, eax
	mov eax, beginY
	mov y, eax
	mov points[0].y, eax
	INVOKE MoveToEx, hdc, x, y, NULL		;A
	mov eax, endX
	mov x, eax
	mov points[8].x, eax
	mov points[16].x, eax
	mov ebx, beginY
	add ebx, h
	mov y, ebx
	mov points[8].y, ebx
	INVOKE LineTo, hdc, x, y				;B
	INVOKE MoveToEx, hdc, x, y, NULL
	mov ebx, y
	add ebx, h
	add ebx, h
	mov y, ebx
	mov points[16].y, ebx
	INVOKE LineTo, hdc, x, y				;C
	INVOKE MoveToEx, hdc, x, y, NULL
	mov eax, beginX
	add eax, w
	mov x, eax
	mov points[24].x, eax
	mov ebx, endY
	mov y, ebx
	mov points[24].y, ebx
	INVOKE LineTo, hdc, x, y				;D
	INVOKE MoveToEx, hdc, x, y, NULL
	mov eax, beginX
	mov x, eax
	mov points[32].x, eax
	mov points[40].x, eax
	mov ebx, y
	sub ebx, h
	mov y, ebx
	mov points[32].y, ebx
	INVOKE LineTo, hdc, x, y				;E
	INVOKE MoveToEx, hdc, x, y, NULL
	sub ebx, h
	sub ebx, h
	mov y, ebx
	mov points[40].y, ebx
	INVOKE LineTo, hdc, x, y				;F
	INVOKE MoveToEx, hdc, x, y, NULL
	mov eax, beginX
	add eax, w
	mov x, eax
	mov points[48].x, eax
	mov eax, beginY
	mov y, eax
	mov points[48].y, eax
	INVOKE LineTo, hdc, x, y

	;���
	INVOKE SetPolyFillMode, hdc, ALTERNATE
	INVOKE Polygon, hdc, OFFSET points, 6
	ret
Draw_Hexagon ENDP

Draw_Star PROC, hdc:HDC
	LOCAL px:DWORD
	LOCAL py:DWORD
	LOCAL qx:DWORD
	LOCAL qy:DWORD
	LOCAL sx:DWORD
	LOCAL sy:DWORD
	LOCAL tx:DWORD
	LOCAL ty:DWORD
	LOCAL w:DWORD
	LOCAL h:DWORD

	mov eax, endX
	sub eax, beginX
	shr eax, 1
	mov w, eax
	mov eax, endY
	sub eax, beginY
	shr eax, 1
	mov h, eax

	mov eax, beginX
	add eax, w
	mov px, eax
	mov eax, beginY
	sub eax, h
	mov py, eax
	mov eax, endX
	add eax, w
	mov qx, eax
	mov eax, beginY
	add eax, h
	mov qy, eax
	INVOKE Arc, hdc, px, py, qx, qy, beginX, beginY, endX, endY

	mov eax, beginX
	add eax, w
	mov px, eax
	mov eax, beginY
	add eax, h
	mov py, eax
	mov eax, endX
	add eax, w
	mov qx, eax
	mov eax, endY
	add eax, h
	mov qy, eax
	mov eax, endX
	mov sx, eax
	mov eax, beginY
	mov sy, eax
	mov eax, beginX
	mov tx, eax
	mov eax, endY
	mov ty, eax
	INVOKE Arc, hdc, px, py, qx, qy, sx, sy, tx, ty

	mov eax, beginX
	sub eax, w
	mov px, eax
	mov eax, beginY
	add eax, h
	mov py, eax
	mov eax, endX
	sub eax, w
	mov qx, eax
	mov eax, endY
	add eax, h
	mov qy, eax
	INVOKE Arc, hdc, px, py, qx, qy, endX, endY, beginX, beginY

	mov eax, beginX
	sub eax, w
	mov px, eax
	mov eax, beginY
	sub eax, h
	mov py, eax
	mov eax, endX
	sub eax, w
	mov qx, eax
	mov eax, endY
	sub eax, h
	mov qy, eax
	mov eax, beginX
	mov sx, eax
	mov eax, endY
	mov sy, eax
	mov eax, endX
	mov tx, eax
	mov eax, beginY
	mov ty, eax
	INVOKE Arc, hdc, px, py, qx, qy, sx, sy, tx, ty
	ret
Draw_Star ENDP

Draw_Love PROC, hdc:HDC
		LOCAL px:DWORD
		LOCAL py:DWORD
		LOCAL qx:DWORD
		LOCAL qy:DWORD
		LOCAL sx:DWORD
		LOCAL sy:DWORD
		LOCAL tx:DWORD
		LOCAL ty:DWORD
		LOCAL ox:DWORD
		LOCAL oy:DWORD
		LOCAL w:DWORD
		LOCAL h:DWORD

		mov eax, beginX
		cmp eax, endX
		jge invalid
		mov eax, beginY
		cmp eax, endY
		jge invalid

		mov eax, endX
		sub eax, beginX
		shr eax, 1
		mov w, eax
		mov eax, endY
		sub eax, beginY
		shr eax, 2
		mov h, eax

		mov eax, beginX
		add eax, w
		mov qx, eax
		mov eax, beginY
		add eax, h
		add eax, h
		mov qy, eax
		mov eax, endX
		mov sx, eax
		mov eax, beginY
		add eax, h
		mov sy, eax
		mov eax, beginX
		mov tx, eax
		mov eax, beginY
		add eax, h
		mov ty, eax
		INVOKE Arc, hdc, beginX, beginY, qx, qy, sx, sy, tx, ty

		mov eax, beginX
		add eax, w
		mov px, eax
		mov eax, beginY
		mov py, eax
		mov eax, endX
		mov qx, eax
		mov eax, beginY
		add eax, h
		add eax, h
		mov qy, eax
		INVOKE Arc, hdc, px, py, qx, qy, sx, sy, tx, ty

		INVOKE MoveToEx, hdc, sx, sy, NULL
		mov ebx, beginX
		add ebx, w
		mov ox, ebx
		mov edx, endY
		mov oy, edx
		INVOKE LineTo, hdc, ox, oy
		INVOKE MoveToEx, hdc, ox, oy, NULL
		INVOKE LineTo, hdc, tx, ty

	invalid:
		ret
Draw_Love ENDP

;ë��
WriteBrush PROC hdc:HDC
	mov ecx,5
	dec curY
	dec curY
	.WHILE ecx
	push ecx

	mov eax,curX
	mov tempX,eax
	sub curX,2
	add tempX,2
	INVOKE MoveToEx, hdc, curX, curY, NULL
	INVOKE LineTo, hdc, tempX, curY
	inc curY

	pop ecx
	dec ecx
	.ENDW

	ret
WriteBrush ENDP

;�ı�
Draw_Text PROC, hdc:HDC
	INVOKE TextOutA, hdc, fixedX, fixedY, ADDR buf, cnt
	ret
Draw_Text ENDP

END