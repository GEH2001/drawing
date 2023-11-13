
;----------------------include-----------------------------
INCLUDE windows.inc
INCLUDE user32.inc
INCLUDE kernel32.inc
INCLUDE gdi32.inc
INCLUDE comdlg32.inc

INCLUDELIB user32.lib
INCLUDELIB kernel32.lib
INCLUDELIB gdi32.lib
INCLUDELIB comdlg32.lib

;----------------------function-----------------------------

; menu.asm	菜单控制
CreateMainMenu		PROTO	;初始化菜单

; winproc.asm	消息处理
HandleCommand		PROTO hWnd:HWND, wParam:WPARAM, lParam:LPARAM		; VM_COMMAND 处理函数
HandleMouseMove		PROTO hWnd:HWND, wParam:WPARAM, lParam:LPARAM		; VM_MOUSEMOVE 处理函数
HandleLButtonDown	PROTO hWnd:HWND, wParam:WPARAM, lParam:LPARAM		; VM_LBUTTONDOWN
HandleLButtonUp		PROTO hWnd:HWND, wParam:WPARAM, lParam:LPARAM		; VM_LBUTTONUP
HandleKeyboard		PROTO hwnd:HWND, wParam:WPARAM, lParam:LPARAM		; VM_CHAR
HandlePaint			PROTO hWnd:HWND, wParam:WPARAM, lParam:LPARAM		; VM_PAIN

; paint.asm		绘制函数
Erase				PROTO hdc:HDC	; 橡皮擦
Freehand			PROTO hdc:HDC	; 自由绘制
Draw_Line			PROTO hdc:HDC	; 直线
Draw_Line_Inverse	PROTO hdc:HDC
Draw_Circle			PROTO hdc:HDC	; 圆形
Draw_Circle_Inverse	PROTO hdc:HDC
Draw_Rect			PROTO hdc:HDC	; 矩形
Draw_Rect_Inverse	PROTO hdc:HDC
Draw_Text			PROTO hdc:HDC	; 文本

;file.asm		文件处理
Openfile			PROTO hWnd:HWND	; 打开文件
Savefile			PROTO hWnd:HWND	; 保存文件

;----------------------const-----------------------------

.data
	
	;--------------全局变量-----------------------------

	;工作模式
	mode			DWORD   IDM_MODE_FREEHAND	;绘图模式：画画、橡皮

	;画笔属性
	pen_style		DWORD	PS_SOLID
	pen_width		DWORD	3
	pen_color		DWORD	0h

	
	;橡皮擦
	eraser_size		DWORD	10

	;鼠标状态
	lMouseFlag	DWORD	0		;鼠标左键状态：down(1)、up(0)，只有down的时候才会绘制
	;mouseStatus	;定义更多的状态



	; BUG: 这些变量如果在这里定义，绘图会失效（不知道为什么）
	;鼠标位置
	;curX	DWORD	0	;当前坐标
	;curY	DWORD	0
	;beginX	DWORD	0	;Freehand：	MoveTo
	;beginY	DWORD	0
	;endX	DWORD	0	;Freehand：	LineTo
	;endY	DWORD	0

	; 绘图区大小
	drawingArea				RECT		<0,0,988,600>	;绘制区域，就是窗口的 client area

	; 窗框厚度（会占用drawingArea）
	WINDOW_FRAME_WIDTH		DWORD		15	; 窗框横向厚度（左右合计）
	WINDOW_FRAME_HEIGHT		DWORD		60	; 窗框纵向厚度（上下合计）

	; 窗口最大尺寸
	MAX_WINDOW_WIDTH		DWORD		988
	MAX_WINDOW_HEIGHT		DWORD		600
	
	;--------------编号-----------------------------

	;绘制模式编号
	IDM_MODE_FREEHAND		equ	501		;自由绘制
	IDM_MODE_ERASE			equ	502		;橡皮擦
	IDM_MODE_SHAPE_LINE		equ 503		;绘制直线
	IDM_MODE_SHAPE_CIRCLE	equ 504		;绘制圆形
	IDM_MODE_SHAPE_RECT		equ 505		;绘制矩形
	IDM_MODE_TEXT			equ 506		;输入文字
	IDM_MODE_COLPIC			equ 507		;选择颜色

	;菜单-文件：打开，保存
	IDM_MENU_FILE			equ 420
	IDM_MENU_FILE_OPEN		equ	421
	IDM_MENU_FILE_SAVE		equ	422

	;菜单-画笔：画笔、铅笔
	IDM_MENU_BRUSH			equ	430
	IDM_MENU_BRUSH_BASIC	equ	431
	IDM_MENU_BRUSH_DASH		equ	432

	;菜单-工具：橡皮擦，文本，颜色取色器，框选
	IDM_MENU_TOOL			equ	440
	IDM_MENU_TOOL_ERASER	equ 441
	IDM_MENU_TOOL_TEXT		equ	442
	IDM_MENU_TOOL_COLPIC	equ	443		;color picker

	;菜单-形状：直线，圆形，三角形，矩形
	IDM_MENU_SHAPE			equ	450
	IDM_MENU_SHAPE_LINE		equ	451
	IDM_MENU_SHAPE_CIRCLE	equ	452
	IDM_MENU_SHAPE_RECT		equ	454

	;菜单-大小：1px, 3px, 5px, 7px
	IDM_MENU_SIZE			equ	460
	IDM_MENU_SIZE_ONE		equ	461
	IDM_MENU_SIZE_THREE		equ	462
	IDM_MENU_SIZE_FIVE		equ	463
	IDM_MENU_SIZE_SEVEN		equ 464

	;菜单-颜色：黑色、红色、绿色、黄色、蓝色、白色
	IDM_MENU_COLOR			equ	470
	IDM_MENU_COLOR_BLACK	equ	471
	IDM_MENU_COLOR_RED		equ	472
	IDM_MENU_COLOR_ORANGE	equ	473
	IDM_MENU_COLOR_GREEN	equ	474
	IDM_MENU_COLOR_YELLOW	equ	475
	IDM_MENU_COLOR_PURPLE	equ	476
	IDM_MENU_COLOR_CYAN		equ	477
	IDM_MENU_COLOR_BLUE		equ	478
	IDM_MENU_COLOR_CELESTE	equ	479
	IDM_MENU_COLOR_WHITE	equ	480
	IDM_MENU_COLOR_CHANGE	equ	481
	

	;--------------字符串-----------------------------
	
	;文件
	str_menu_file			BYTE	"文件", 0
	str_menu_file_open		BYTE	"打开", 0
	str_menu_file_save		BYTE	"保存", 0
	
	;画笔
	str_menu_brush			BYTE	"画笔", 0
	str_menu_brush_basic	BYTE	"实线", 0
	str_menu_brush_dash		BYTE	"虚线(仅对形状生效)", 0
	
	;工具
	str_menu_tool			BYTE	"工具",	0
	str_menu_tool_eraser	BYTE	"橡皮擦", 0
	str_menu_tool_text		BYTE	"文本", 0
	str_menu_tool_colpic	BYTE	"取色器", 0
	str_menu_tool_select	BYTE	"框选", 0

	;形状
	str_menu_shape			BYTE	"形状", 0
	str_menu_shape_line		BYTE	"直线", 0
	str_menu_shape_circle	BYTE	"圆形", 0
	str_menu_shape_rect		BYTE	"矩形", 0

	;大小
	str_menu_size			BYTE	"大小", 0
	str_menu_size_one		BYTE	"1 像素", 0
	str_menu_size_three		BYTE	"3 像素", 0
	str_menu_size_five		BYTE	"5 像素", 0
	str_menu_size_seven		BYTE	"7 像素", 0

	;颜色
	str_menu_color			BYTE	"颜色", 0
	str_menu_color_black	BYTE	"黑色", 0
	str_menu_color_red		BYTE	"红色", 0
	str_menu_color_orange	BYTE	"橙色", 0
	str_menu_color_green	BYTE	"绿色", 0
	str_menu_color_yellow	BYTE	"黄色", 0
	str_menu_color_purple	BYTE	"紫色", 0
	str_menu_color_cyan		BYTE	"青色", 0
	str_menu_color_blue		BYTE	"蓝色", 0
	str_menu_color_celeste	BYTE	"蔚蓝", 0
	str_menu_color_white	BYTE	"白色", 0

	str_menu_color_change	BYTE	"更改颜色",0