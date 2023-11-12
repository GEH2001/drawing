.386
.model flat, stdcall
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc
include comdlg32.inc
include msvcrt.inc
include gdi32.inc
include header.inc

includelib kernel32.lib
includelib user32.lib
includelib comdlg32.lib
includelib gdi32.lib
includelib msvcrt.lib
includelib gdi32.lib

GetOpenFileName PROTO :DWORD

.data
; Openfile
ofn             OPENFILENAME <>
filterString    BYTE      "ͼƬ�ļ� (*.bmp)", 0, "*.bmp", 0, "�����ļ� (*.*)", 0, "*.*", 0, 0
fileNameBuffer  BYTE      MAX_PATH dup(0)
dialogTitle     BYTE      "ѡ���ļ�", 0
imagePath       DWORD     ?

;Savefile
iWidth          DWORD       0
iHeight         DWORD       0
bmpInfo         BITMAPINFO  <>
hBmp            HANDLE      ?
bmInfoHeader    BITMAPINFOHEADER    <>
bmFileHeader    BITMAPFILEHEADER    <>
hFile           HANDLE      ?         
dwWrite         DWORD       0
pData           DWORD       0
vtData          DWORD       0        ; vtData ��һ��ָ�� BYTE ��ָ��
vtDataHandle    HANDLE      ?
vtDataSize      DWORD       0
szofn           OPENFILENAME        <>
szFile          BYTE        "test.bmp", MAX_PATH dup(?)
szFilter        BYTE        "ͼƬ�ļ� (*.bmp)", 0, "*.bmp", 0, "All Files (*.*)", 0, "*.*", 0, 0
szTitle         BYTE        "�����ļ�", 0


.code
WindowResize PROC, hWnd: HWND, bitmap:BITMAP
        LOCAL rect:RECT
        LOCAL windowX:DWORD
        LOCAL windowY:DWORD
        LOCAL w:DWORD   ; ����Ŀ��ߴ�
        LOCAL h:DWORD
        LOCAL wb:DWORD  ; λͼ�ߴ�
        LOCAL hb:DWORD
        LOCAL ww:DWORD  ; �������гߴ�
        LOCAL hw:DWORD

        ; �󴰿����Ͻ�λ��
        INVOKE GetWindowRect, hWnd, ADDR rect
        mov eax, rect.left
        mov windowX, eax
        mov eax, rect.top
        mov windowY, eax

        ; �󴰿ڴ�С
        ; ��ʼֵ
        mov eax, bitmap.bmWidth
        mov w, eax
        mov wb, eax
        mov eax, bitmap.bmHeight
        mov h, eax
        mov hb, eax
        mov eax, drawingArea.right
        sub eax, WINDOW_FRAME_WIDTH
        mov ww, eax
        mov eax, drawingArea.bottom
        sub eax, WINDOW_FRAME_HEIGHT
        mov hw, eax

        ; �ȽϿ��
        mov eax, ww
        cmp w, eax
        jle compareHeight
        mov w, eax          ; w=ww
        mov eax, h          ; ���ó���
        mov ebx, w          ; ���ñ�����
        mul ebx             ; ִ�г˷�����
        mov h, eax          ; �洢�˷����
        mov eax, h          ; ���ñ�����
        xor edx, edx        ; ���������λ�Ĵ���
        mov ebx, wb         ; ���ó���
        div ebx             ; ִ�г�������
        mov h, eax          ; �洢��

        ; �Ƚϸ߶�
    compareHeight:
        mov eax, hw
        cmp h, eax
        jle completed
        mov eax, w          ; ���ó���
        mov ebx, hw         ; ���ñ�����
        mul ebx             ; ִ�г˷�����
        mov w, eax          ; �洢�˷����
        xor edx, edx        ; ���������λ�Ĵ���
        mov ebx, h          ; ���ó���
        div ebx             ; ִ�г�������
        mov w, eax          ; �洢��
        mov eax, hw
        mov h, eax

    completed:
        mov eax, w
        add eax, WINDOW_FRAME_WIDTH
        mov drawingArea.right, eax
        mov eax, h
        add eax, WINDOW_FRAME_HEIGHT
        mov drawingArea.bottom, eax

        ; ��������λ�úʹ�С
        INVOKE MoveWindow, hWnd, windowX, windowY, drawingArea.right, drawingArea.bottom, TRUE
        ret
WindowResize ENDP


DrawImage PROC, hWnd: HWND
        LOCAL hdcMem:HANDLE
        LOCAL hOldBitmap:HANDLE
        LOCAL hBitmap:HANDLE
        LOCAL bitmap:BITMAP
        LOCAL imageWidth:DWORD
        LOCAL imageHeight:DWORD
        LOCAL ps:PAINTSTRUCT

        ; ��ʼ����
        INVOKE BeginPaint, hWnd, ADDR ps

        ; ������ָ���豸���ݵ��ڴ��豸������
        INVOKE CreateCompatibleDC, ps.hdc
        mov hdcMem, eax

        ; ����ļ�·��
        mov edx, imagePath
        INVOKE MessageBox, 0, edx, OFFSET dialogTitle, MB_OK

        ; ���� LoadImageA ��������ͼ��
        INVOKE LoadImageA, NULL, imagePath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
        mov hBitmap, eax    ; ������ֵ���浽 hBitmap ������
        test eax, eax
        jz exitProc

        ; ��ȡλͼ����
        INVOKE GetObject, hBitmap, SIZEOF bitmap, ADDR bitmap
        INVOKE SelectObject, hdcMem, hBitmap

        ; �޸Ĵ��ڳߴ�
        INVOKE WindowResize, hWnd, bitmap

        ; ����
        mov eax, drawingArea.right
        sub eax, WINDOW_FRAME_WIDTH
        mov ebx, drawingArea.bottom
        sub ebx, WINDOW_FRAME_HEIGHT
        INVOKE StretchBlt, ps.hdc, 0, 0, eax, ebx, hdcMem, 0, 0, bitmap.bmWidth, bitmap.bmHeight, SRCCOPY
    exitProc:
        ; ������Դ
        INVOKE DeleteObject, hBitmap
        INVOKE DeleteDC, hdcMem
        INVOKE EndPaint, hWnd, ADDR ps
        ret

DrawImage ENDP


Openfile PROC, hWnd: HWND
        ; ��ʼ�� OPENFILENAME �ṹ��
        mov ofn.lStructSize, sizeof OPENFILENAME   ; ���ýṹ��Ĵ�С
        mov ofn.hwndOwner, 0                       ; ����ӵ�д��ڵľ����������ã�
        mov ofn.lpstrFilter, OFFSET filterString   ; �����ļ��������ַ���
        mov ofn.lpstrFile, OFFSET fileNameBuffer   ; �����ļ���������
        mov ofn.nMaxFile, MAX_PATH                 ; �����ļ���������������С
        mov ofn.lpstrInitialDir, 0                 ; ���ó�ʼĿ¼��������ã�
        mov ofn.lpstrTitle, OFFSET dialogTitle     ; ���öԻ�����⣨������ã�
        mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST ; ���öԻ����־

        ; ���� GetOpenFileName
        INVOKE GetOpenFileName, ADDR ofn
        test eax, eax
        jz exitProc

        ; ��ȡ�ļ���
        mov esi, ofn.lpstrFile
        mov imagePath, esi

        INVOKE InvalidateRect, hWnd, ADDR drawingArea, 0	;���������ػ��ź�WM_PAINT

        ; ����ͼ��
        INVOKE DrawImage, hWnd
    exitProc:
        ret

Openfile ENDP


Savefile PROC, hWnd: HWND
        LOCAL hdcMem:HANDLE
        LOCAL hOldObj:HANDLE
        LOCAL ps:PAINTSTRUCT

        INVOKE BeginPaint, hWnd, ADDR ps


        
        ; ��ȡ HDC �ĳߴ�
        INVOKE GetDeviceCaps, ps.hdc, HORZRES
        mov iWidth, eax
        INVOKE GetDeviceCaps, ps.hdc, VERTRES
        mov iHeight, eax

        ; ��� bmpInfo ���ֶ�
        mov eax, sizeof BITMAPINFOHEADER
        mov dword ptr [bmpInfo.bmiHeader.biSize], eax
        mov eax, iWidth
        mov dword ptr [bmpInfo.bmiHeader.biWidth], eax
        mov eax, iHeight
        mov dword ptr [bmpInfo.bmiHeader.biHeight], eax
        mov word ptr [bmpInfo.bmiHeader.biPlanes], 1
        mov word ptr [bmpInfo.bmiHeader.biBitCount], 24

        ; �������� HDC
        INVOKE CreateCompatibleDC, ps.hdc
        mov hdcMem, eax

        ; ���� DIB Section ����ȡ����ָ��
        INVOKE CreateDIBSection, hdcMem, OFFSET bmpInfo, DIB_RGB_COLORS, OFFSET pData, NULL, 0
        mov hBmp, eax
        
        ; ѡ����󲢻�ȡ�ɶ�����
        INVOKE SelectObject, hdcMem, hBmp
        mov hOldObj, eax

        ; �� HDC �������� BitBlt ���Ƶ�������
        mov eax, drawingArea.right
        sub eax, WINDOW_FRAME_WIDTH
        mov ebx, drawingArea.bottom
        sub ebx, WINDOW_FRAME_HEIGHT
        INVOKE StretchBlt, hdcMem, 0, 0, iWidth, iHeight, ps.hdc, 1, 1, eax, ebx, SRCCOPY

        ; �� bmInfoHeader ������ʼ��Ϊ��
        xor eax, eax
        mov dword ptr [bmInfoHeader.biSize], eax
        mov dword ptr [bmInfoHeader.biWidth], eax
        mov dword ptr [bmInfoHeader.biHeight], eax
        mov word ptr [bmInfoHeader.biPlanes], ax
        mov word ptr [bmInfoHeader.biBitCount], ax
        mov dword ptr [bmInfoHeader.biCompression], eax
        mov dword ptr [bmInfoHeader.biSizeImage], eax
        mov dword ptr [bmInfoHeader.biXPelsPerMeter], eax
        mov dword ptr [bmInfoHeader.biYPelsPerMeter], eax
        mov dword ptr [bmInfoHeader.biClrUsed], eax
        mov dword ptr [bmInfoHeader.biClrImportant], eax
        ; ��� bmInfoHeader ��Ϣ
        mov eax, sizeof BITMAPINFOHEADER
        mov dword ptr [bmInfoHeader.biSize], eax
        mov eax, iWidth
        mov dword ptr [bmInfoHeader.biWidth], eax
        mov eax, iHeight
        mov dword ptr [bmInfoHeader.biHeight], eax
        mov word ptr [bmInfoHeader.biPlanes], 1
        mov word ptr [bmInfoHeader.biBitCount], 24

        ; �� bmFileHeader ������ʼ��Ϊ��
        xor eax, eax
        mov word ptr [bmFileHeader.bfType], ax
        mov dword ptr [bmFileHeader.bfSize], eax
        mov word ptr [bmFileHeader.bfReserved1], ax
        mov word ptr [bmFileHeader.bfReserved2], ax
        mov dword ptr [bmFileHeader.bfOffBits], eax
        ; ���� bmFileHeader �ֶ�
        mov word ptr [bmFileHeader.bfType], 4d42h
        mov eax, sizeof BITMAPFILEHEADER
        add eax, sizeof BITMAPINFOHEADER
        mov dword ptr [bmFileHeader.bfOffBits], eax
        mov eax, dword ptr [bmFileHeader.bfOffBits]
        mov ebx, dword ptr [bmInfoHeader.biWidth]
        imul ebx, dword ptr [bmInfoHeader.biHeight]
        imul ebx, 3
        add eax, ebx
        mov dword ptr [bmFileHeader.bfSize], eax

        ; ��ʼ�� OPENFILENAME �ṹ��
        mov szofn.lStructSize, SIZEOF OPENFILENAME
        mov szofn.hwndOwner, 0
        mov szofn.lpstrFilter, OFFSET szFilter
        mov szofn.lpstrFile, OFFSET szFile
        mov szofn.nMaxFile, SIZEOF szFile
        mov szofn.lpstrInitialDir, 0
        mov szofn.lpstrTitle, OFFSET szTitle
        mov szofn.Flags, OFN_OVERWRITEPROMPT

        ; ���� GetSaveFileName ����
        INVOKE GetSaveFileName, ADDR szofn

        ; ��鷵��ֵ������û�����ˡ����桱��ť
        cmp eax, FALSE
        je errorOccurred

        ; ��ȡ�û�ѡ����ļ�·�����ļ���
        mov edx, OFFSET szFile
        INVOKE MessageBox, 0, edx, OFFSET szTitle, MB_OK

        ; ���� CreateFileA ����
        INVOKE CreateFileA, ADDR szFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        mov hFile, eax              ; �����ص��ļ�������浽 hFile ������

        ; ���� WriteFile ����д�� bmFileHeader
        INVOKE WriteFile, hFile, ADDR bmFileHeader, SIZEOF BITMAPFILEHEADER, ADDR dwWrite, NULL
        ; ���� WriteFile ����д�� bmInfoHeader
        INVOKE WriteFile, hFile, ADDR bmInfoHeader, SIZEOF BITMAPINFOHEADER, ADDR dwWrite, NULL

        ; ���� vtData �������Ĵ�С
        mov eax, iWidth
        mul iHeight
        mov ecx, 3
        mul ecx
        mov vtDataSize, eax                ; vtDataSize = sizeImgX * sizeImgY * 3

        ; ���� vtData ���������ڴ�
        INVOKE GlobalAlloc, GMEM_FIXED, vtDataSize
        mov vtDataHandle, eax              ; ��������ڴ��ַ���浽 vtDataHandle ������
        ; �����ڴ沢��ȡָ��
        INVOKE GlobalLock, vtDataHandle
        mov vtData, eax               ; ����ȡ��ָ�뱣�浽 vtData ������

         ; �� pData ָ��ָ������ݿ����� vtData ��������
        INVOKE crt_memcpy, vtData, pData, vtDataSize

        ; ���� WriteFile ����д�� vtData
        INVOKE WriteFile, hFile, vtData, vtDataSize, ADDR dwWrite, NULL

        ; �ͷ� vtData ���������ڴ�
        INVOKE GlobalFree, vtData
        ; ���� CloseHandle ����
        INVOKE CloseHandle, hFile

    errorOccurred:
        ret
Savefile ENDP

END