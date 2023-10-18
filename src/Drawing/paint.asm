; 绘制相关

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc

;PUBLIC mode
PUBLIC curX
PUBLIC curY
PUBLIC beginX
PUBLIC beginY
PUBLIC endX
PUBLIC endY

.data
;mode    DWORD   ?	;绘图模式：画画、橡皮

curX	DWORD	0	;当前坐标
curY	DWORD	0
beginX	DWORD	0	;Freehand：	MoveTo
beginY	DWORD	0
endX	DWORD	0	;Freehand：	LineTo
endY	DWORD	0

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


END