; 绘制相关

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc

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
Erase PROC USES ebx ecx edx, hdc:HDC
	;设置画笔
	INVOKE GetStockObject, NULL_PEN 
	INVOKE SelectObject, hdc, eax
	;绘制空白矩形，(curX-10,curY-10) -> (curX+10, curY+10)
	mov	ecx, eraser_size
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

Draw_Line_Inverse PROC, hdc:HDC
	INVOKE MoveToEx, hdc, beginX, beginY, NULL
	INVOKE LineTo, hdc, lastX, lastY
	ret
Draw_Line_Inverse ENDP

;圆形
Draw_Circle PROC, hdc:HDC
	INVOKE Ellipse, hdc, beginX, beginY, endX, endY
	ret
Draw_Circle ENDP

Draw_Circle_Inverse PROC, hdc:HDC
	INVOKE Ellipse, hdc, beginX, beginY, lastX, lastY
	ret
Draw_Circle_Inverse ENDP


;矩形
Draw_Rect PROC, hdc:HDC
	INVOKE Rectangle, hdc, beginX, beginY, endX, endY
	ret
Draw_Rect ENDP

Draw_Rect_Inverse PROC, hdc:HDC
	INVOKE Rectangle, hdc, beginX, beginY, lastX, lastY
	ret
Draw_Rect_Inverse ENDP

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