; 初始化菜单项，定义菜单点击的响应函数

.386 
.model flat,stdcall 
option casemap:none

INCLUDE header.inc

.data

.code
CreateMainMenu PROC
	extern hMenu:HMENU		;main.asm
	LOCAL hFileMenu:HMENU
	LOCAL hDrawMenu:HMENU
	LOCAL hBrushMenu:HMENU
	LOCAL hToolMenu:HMENU
	LOCAL hShapeMenu:HMENU
	LOCAL hSizeMenu:HMENU
	LOCAL hColorMenu:HMENU
	LOCAL hColorLineMenu:HMENU
	LOCAL hColorFillMenu:HMENU

	; 菜单栏
	INVOKE CreateMenu
	mov hMenu, eax

	;文件
	INVOKE CreatePopupMenu
	mov hFileMenu, eax
	INVOKE AppendMenu, hFileMenu, MF_STRING, IDM_MENU_FILE_OPEN, ADDR str_menu_file_open
	INVOKE AppendMenu, hFileMenu, MF_STRING, IDM_MENU_FILE_SAVE, ADDR str_menu_file_save
	INVOKE AppendMenu, hMenu, MF_POPUP, hFileMenu, ADDR str_menu_file

	;画笔
	INVOKE CreatePopupMenu
	mov hBrushMenu, eax
	INVOKE AppendMenu, hBrushMenu, MF_STRING, IDM_MENU_BRUSH_BASIC, ADDR str_menu_brush_basic
	INVOKE AppendMenu, hBrushMenu, MF_STRING, IDM_MENU_BRUSH_DASH, ADDR str_menu_brush_dash
	INVOKE AppendMenu, hMenu, MF_POPUP, hBrushMenu, ADDR str_menu_brush

	;工具
	INVOKE CreatePopupMenu
	mov hToolMenu, eax
	INVOKE AppendMenu, hToolMenu, MF_STRING, IDM_MENU_TOOL_ERASER, ADDR str_menu_tool_eraser
	INVOKE AppendMenu, hToolMenu, MF_STRING, IDM_MENU_TOOL_TEXT, ADDR str_menu_tool_text
	INVOKE AppendMenu, hToolMenu, MF_STRING, IDM_MENU_TOOL_COLPIC, ADDR str_menu_tool_colpic
	INVOKE AppendMenu, hMenu, MF_POPUP, hToolMenu, ADDR str_menu_tool

	;形状
	INVOKE CreatePopupMenu
	mov hShapeMenu, eax
	INVOKE AppendMenu, hShapeMenu, MF_STRING, IDM_MENU_SHAPE_LINE, ADDR str_menu_shape_line
	INVOKE AppendMenu, hShapeMenu, MF_STRING, IDM_MENU_SHAPE_CIRCLE, ADDR str_menu_shape_circle
	INVOKE AppendMenu, hShapeMenu, MF_STRING, IDM_MENU_SHAPE_RECT, ADDR str_menu_shape_rect
	INVOKE AppendMenu, hShapeMenu, MF_STRING, IDM_MENU_SHAPE_ROUND_RECT, ADDR str_menu_shape_round_rect
	INVOKE AppendMenu, hMenu, MF_POPUP, hShapeMenu, ADDR str_menu_shape
	
	;大小
	INVOKE CreatePopupMenu
	mov hSizeMenu, eax
	INVOKE AppendMenu, hSizeMenu, MF_STRING, IDM_MENU_SIZE_ONE, ADDR str_menu_size_one
	INVOKE AppendMenu, hSizeMenu, MF_STRING, IDM_MENU_SIZE_THREE, ADDR str_menu_size_three
	INVOKE AppendMenu, hSizeMenu, MF_STRING, IDM_MENU_SIZE_FIVE, ADDR str_menu_size_five
	INVOKE AppendMenu, hSizeMenu, MF_STRING, IDM_MENU_SIZE_SEVEN, ADDR str_menu_size_seven
	INVOKE AppendMenu, hMenu, MF_POPUP, hSizeMenu, ADDR str_menu_size

	;颜色
	INVOKE CreatePopupMenu
	mov hColorMenu, eax
	INVOKE AppendMenu, hMenu, MF_POPUP, hColorMenu, ADDR str_menu_color
	INVOKE CreatePopupMenu
	mov hColorLineMenu, eax
	INVOKE AppendMenu, hColorLineMenu, MF_STRING, IDM_MENU_COLOR_LINE_NULL, ADDR str_menu_color_line_null
	INVOKE AppendMenu, hColorLineMenu, MF_STRING, IDM_MENU_COLOR_LINE_COLOR, ADDR str_menu_color_line_color
	INVOKE AppendMenu, hColorMenu, MF_POPUP, hColorLineMenu, ADDR str_menu_color_line
	INVOKE CreatePopupMenu
	mov hColorFillMenu, eax
	INVOKE AppendMenu, hColorFillMenu, MF_STRING, IDM_MENU_COLOR_FILL_NULL, ADDR str_menu_color_fill_null
	INVOKE AppendMenu, hColorFillMenu, MF_STRING, IDM_MENU_COLOR_FILL_COLOR, ADDR str_menu_color_fill_color
	INVOKE AppendMenu, hColorMenu, MF_POPUP, hColorFillMenu, ADDR str_menu_color_fill

	ret
CreateMainMenu ENDP


END