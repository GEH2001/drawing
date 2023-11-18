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

PUBLIC char
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

;键盘输入
char	WPARAM	"2"
;文字计数
cnt		DWORD	0


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
	ret
Draw_Triangle ENDP

;文本
Draw_Text PROC, hdc:HDC
	push eax
	MOV eax,cnt
	IMUL eax,5
	add	eax,fixedX
	INVOKE TextOutA, hdc, eax, fixedY, ADDR char, 1
	inc cnt
	inc cnt
	.IF char == "f" || char == "i" || char == "j" || char == "l" || char == "t" || char == " "
		dec cnt
	.ELSEIF char == "m" || char == "w"
		inc cnt
	.ENDIF
	pop eax
	ret
Draw_Text ENDP

END