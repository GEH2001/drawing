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

PUBLIC char
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

;��������
char	WPARAM	"2"
;���ּ���
cnt		DWORD	0


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

;�ı�
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