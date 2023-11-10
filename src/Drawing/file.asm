.386
.model flat, stdcall
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc
include comdlg32.inc
include msvcrt.inc
include gdi32.inc

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
filterString    BYTE      "图片文件 (*.bmp)", 0, "*.bmp", 0, "所有文件 (*.*)", 0, "*.*", 0, 0
fileNameBuffer  BYTE      MAX_PATH dup(0)
dialogTitle     BYTE      "选择文件", 0
imagePath       DWORD     ?

; DrawImage
hBitmap         HANDLE    ?

;Savefile
iWidth          DWORD       0
iHeight         DWORD       0
bmpInfo         BITMAPINFO  <>
hdcMem          HANDLE      ?
hBmp            HANDLE      ?
hOldObj         HANDLE      ?
bmInfoHeader    BITMAPINFOHEADER    <>
bmFileHeader    BITMAPFILEHEADER    <>
hFile           HANDLE      ?         
dwWrite         DWORD       0
pData           DWORD       0
vtData          DWORD       0        ; vtData 是一个指向 BYTE 的指针
vtDataHandle    HANDLE      ?
vtDataSize      DWORD       0
szofn           OPENFILENAME        <>
szFile          BYTE        "test.bmp", MAX_PATH dup(?)
szFilter        BYTE        "图片文件 (*.bmp)", 0, "*.bmp", 0, "All Files (*.*)", 0, "*.*", 0, 0
szTitle         BYTE        "保存文件", 0


.code
DrawImage PROC
        ; 调用 LoadImageA 函数加载图像
        INVOKE LoadImageA, NULL, ADDR imagePath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
        test eax, eax
        jz loadFail
        mov hBitmap, eax    ; 将返回值保存到 hBitmap 变量中

        ; 在此处可以使用 hBitmap 句柄来进行绘制操作

        ; 清理资源
        INVOKE DeleteObject, hBitmap

        ; 加载资源失败
    loadFail:
        ret

DrawImage ENDP


Openfile PROC, hWnd: HWND
        ; 初始化 OPENFILENAME 结构体
        mov ofn.lStructSize, sizeof OPENFILENAME   ; 设置结构体的大小
        mov ofn.hwndOwner, 0                       ; 设置拥有窗口的句柄（如果适用）
        mov ofn.lpstrFilter, OFFSET filterString   ; 设置文件过滤器字符串
        mov ofn.lpstrFile, OFFSET fileNameBuffer   ; 设置文件名缓冲区
        mov ofn.nMaxFile, MAX_PATH                 ; 设置文件名缓冲区的最大大小
        mov ofn.lpstrInitialDir, 0                 ; 设置初始目录（如果适用）
        mov ofn.lpstrTitle, OFFSET dialogTitle     ; 设置对话框标题（如果适用）
        mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST ; 设置对话框标志

        ; 调用 GetOpenFileName
        INVOKE GetOpenFileName, ADDR ofn
        test eax, eax
        jz exitProc

        ; 获取文件名
        mov esi, ofn.lpstrFile
        mov imagePath, esi

        ; 输出选择的文件名
        INVOKE MessageBox, NULL, imagePath, ADDR dialogTitle, MB_OK

        ; 绘制图像
        INVOKE DrawImage

    exitProc:
        ret

Openfile ENDP


Savefile PROC, hWnd: HWND
        ; 获取 HDC
        LOCAL ps:PAINTSTRUCT
        INVOKE BeginPaint, hWnd, ADDR ps
        
        ; 获取 HDC 的尺寸
        INVOKE GetDeviceCaps, ps.hdc, HORZRES
        mov iWidth, eax
        INVOKE GetDeviceCaps, ps.hdc, VERTRES
        mov iHeight, eax

        ; 填充 bmpInfo 各字段
        mov eax, sizeof BITMAPINFOHEADER
        mov dword ptr [bmpInfo.bmiHeader.biSize], eax
        mov eax, iWidth
        mov dword ptr [bmpInfo.bmiHeader.biWidth], eax
        mov eax, iHeight
        mov dword ptr [bmpInfo.bmiHeader.biHeight], eax
        mov word ptr [bmpInfo.bmiHeader.biPlanes], 1
        mov word ptr [bmpInfo.bmiHeader.biBitCount], 24

        ; 创建缓存 HDC
        INVOKE CreateCompatibleDC, ps.hdc
        mov hdcMem, eax

        ; 创建 DIB Section 并获取数据指针
        INVOKE CreateDIBSection, hdcMem, OFFSET bmpInfo, DIB_RGB_COLORS, OFFSET pData, NULL, 0
        mov hBmp, eax
        
        ; 选择对象并获取旧对象句柄
        INVOKE SelectObject, hdcMem, hBmp
        mov hOldObj, eax

        ; 将 HDC 的内容用 BitBlt 绘制到缓存中
        INVOKE StretchBlt, hdcMem, 0, 0, iWidth, iHeight, ps.hdc, 1, 1, 977, 548, SRCCOPY
        ; INVOKE BitBlt, hdcMem, 0, 0, iWidth, iHeight, ps.hdc, 0, 0, SRCCOPY

        ; 将 bmInfoHeader 变量初始化为零
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
        ; 填充 bmInfoHeader 信息
        mov eax, sizeof BITMAPINFOHEADER
        mov dword ptr [bmInfoHeader.biSize], eax
        mov eax, iWidth
        mov dword ptr [bmInfoHeader.biWidth], eax
        mov eax, iHeight
        mov dword ptr [bmInfoHeader.biHeight], eax
        mov word ptr [bmInfoHeader.biPlanes], 1
        mov word ptr [bmInfoHeader.biBitCount], 24

        ; 将 bmFileHeader 变量初始化为零
        xor eax, eax
        mov word ptr [bmFileHeader.bfType], ax
        mov dword ptr [bmFileHeader.bfSize], eax
        mov word ptr [bmFileHeader.bfReserved1], ax
        mov word ptr [bmFileHeader.bfReserved2], ax
        mov dword ptr [bmFileHeader.bfOffBits], eax
        ; 设置 bmFileHeader 字段
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

        ; 初始化 OPENFILENAME 结构体
        mov szofn.lStructSize, SIZEOF OPENFILENAME
        mov szofn.hwndOwner, 0
        mov szofn.lpstrFilter, OFFSET szFilter
        mov szofn.lpstrFile, OFFSET szFile
        mov szofn.nMaxFile, SIZEOF szFile
        mov szofn.lpstrInitialDir, 0
        mov szofn.lpstrTitle, OFFSET szTitle
        mov szofn.Flags, OFN_OVERWRITEPROMPT

        ; 调用 GetSaveFileName 函数
        invoke GetSaveFileName, ADDR szofn

        ; 检查返回值，如果用户点击了“保存”按钮
        cmp eax, FALSE
        je errorOccurred

        ; 获取用户选择的文件路径和文件名
        mov edx, OFFSET szFile
        invoke MessageBox, 0, edx, offset szTitle, MB_OK

        ; 调用 CreateFileA 函数
        INVOKE CreateFileA, ADDR szFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        mov hFile, eax              ; 将返回的文件句柄保存到 hFile 变量中

        ; 调用 WriteFile 函数写入 bmFileHeader
        INVOKE WriteFile, hFile, ADDR bmFileHeader, SIZEOF BITMAPFILEHEADER, ADDR dwWrite, NULL
        ; 调用 WriteFile 函数写入 bmInfoHeader
        INVOKE WriteFile, hFile, ADDR bmInfoHeader, SIZEOF BITMAPINFOHEADER, ADDR dwWrite, NULL

        ; 计算 vtData 缓冲区的大小
        mov eax, iWidth
        mul iHeight
        mov ecx, 3
        mul ecx
        mov vtDataSize, eax                ; vtDataSize = sizeImgX * sizeImgY * 3

        ; 分配 vtData 缓冲区的内存
        INVOKE GlobalAlloc, GMEM_FIXED, vtDataSize
        mov vtDataHandle, eax              ; 将分配的内存地址保存到 vtDataHandle 变量中
        ; 锁定内存并获取指针
        INVOKE GlobalLock, vtDataHandle
        mov vtData, eax               ; 将获取的指针保存到 vtData 变量中

         ; 将 pData 指针指向的数据拷贝到 vtData 缓冲区中
        INVOKE crt_memcpy, vtData, pData, vtDataSize

        ; 调用 WriteFile 函数写入 vtData
        INVOKE WriteFile, hFile, vtData, vtDataSize, ADDR dwWrite, NULL

        ; 释放 vtData 缓冲区的内存
        INVOKE GlobalFree, vtData
        ; 调用 CloseHandle 函数
        INVOKE CloseHandle, hFile

    errorOccurred:
        ret
Savefile ENDP

END