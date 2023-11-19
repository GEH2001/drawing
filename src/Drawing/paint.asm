; 绘制相关

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
;mode    DWORD   ?	;绘图模式：画画、橡皮

lastX	DWORD	0	;前次绘制坐标
lastY	DWORD	0
curX	DWORD	0	;当前坐标
curY	DWORD	0
beginX	DWORD	0	;Freehand：	MoveTo
beginY	DWORD	0
endX	DWORD	0	;Freehand：	LineTo
endY	DWORD	0
fixedX	DWORD	0	;drawText
fixedY	DWORD	0
tempX	DWORD	0	;writeBrush
tempY	DWORD   0

;文字计数
cnt			DWORD	0
;键盘输入
buf			BYTE	"abcdefghijk"
;三角形
pointArray	POINT	5 DUP(<>)
;六边形
points		POINT	6 DUP(<>)

.code

;橡皮擦
Erase PROC USES ebx ecx edx, hdc: HDC

	;设置画笔
	INVOKE GetStockObject, NULL_PEN 
	INVOKE SelectObject, hdc, eax
	;绘制空白矩形，(curX-10,curY-10) -> (curX+10, curY+10)
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

;自由绘制
Freehand PROC, hdc:HDC
	INVOKE MoveToEx, hdc, beginX, beginY, NULL
	INVOKE LineTo, hdc, endX, endY
	ret
Freehand ENDP

;直线
Draw_Line PROC, hdc:HDC
	INVOKE MoveToEx, hdc, beginX, beginY, NULL
	INVOKE LineTo, hdc, endX, endY
	ret
Draw_Line ENDP

;圆形
Draw_Circle PROC, hdc:HDC
	INVOKE Ellipse, hdc, beginX, beginY, endX, endY
	ret
Draw_Circle ENDP

;矩形
Draw_Rect PROC, hdc:HDC
	INVOKE Rectangle, hdc, beginX, beginY, endX, endY
	ret
Draw_Rect ENDP

;圆角矩形
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
    xor edx, edx        ; 清零除数高位寄存器
    mov ebx, 4			; 设置除数
    div ebx             ; 执行除法运算
    mov w, eax          ; 存储商
	mov eax, beginY
	.IF eax > endY
		mov eax, beginY
		sub eax, endY
	.ELSE
		mov eax, endY
		sub eax, beginY
	.ENDIF
    xor edx, edx        ; 清零除数高位寄存器
    mov ebx, 4			; 设置除数
    div ebx             ; 执行除法运算
    mov h, eax          ; 存储商
	INVOKE RoundRect, hdc, beginX, beginY, endX, endY, w, h
	ret
Draw_Round_Rect ENDP

;三角形
Draw_Triangle PROC, hdc:HDC
	LOCAL pX:DWORD
	LOCAL pY:DWORD
	LOCAL region:HRGN 

	;绘制边框
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

	;绘制填充
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

;六边形
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

	;填充
	INVOKE SetPolyFillMode, hdc, ALTERNATE
	INVOKE Polygon, hdc, OFFSET points, 6
	ret
Draw_Hexagon ENDP

;毛笔
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

;文本
Draw_Text PROC, hdc:HDC
	INVOKE TextOutA, hdc, fixedX, fixedY, ADDR buf, cnt
	ret
Draw_Text ENDP

END