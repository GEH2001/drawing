; �������

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
drawingText	LPCTSTR "ward"

.code

;��Ƥ��
Erase PROC USES ebx ecx edx, hdc:HDC
	;���û���
	INVOKE GetStockObject, NULL_PEN 
	INVOKE SelectObject, hdc, eax
	;���ƿհ׾��Σ�(curX-10,curY-10) -> (curX+10, curY+10)
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

Draw_Line_Inverse PROC, hdc:HDC
	INVOKE MoveToEx, hdc, beginX, beginY, NULL
	INVOKE LineTo, hdc, lastX, lastY
	ret
Draw_Line_Inverse ENDP

;Բ��
Draw_Circle PROC, hdc:HDC
	INVOKE Ellipse, hdc, beginX, beginY, endX, endY
	ret
Draw_Circle ENDP

Draw_Circle_Inverse PROC, hdc:HDC
	INVOKE Ellipse, hdc, beginX, beginY, lastX, lastY
	ret
Draw_Circle_Inverse ENDP


;����
Draw_Rect PROC, hdc:HDC
	INVOKE Rectangle, hdc, beginX, beginY, endX, endY
	ret
Draw_Rect ENDP

Draw_Rect_Inverse PROC, hdc:HDC
	INVOKE Rectangle, hdc, beginX, beginY, lastX, lastY
	ret
Draw_Rect_Inverse ENDP

;�ı�
Draw_Text PROC, hdc:HDC
	INVOKE TextOutA, hdc, curX, curY, ADDR drawingText, 4
	ret
Draw_Text ENDP


END