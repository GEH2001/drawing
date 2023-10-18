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
	INVOKE AppendMenu, hBrushMenu, MF_STRING, IDM_MENU_BRUSH_PENCIL, ADDR str_menu_brush_pencil
	INVOKE AppendMenu, hMenu, MF_POPUP, hBrushMenu, ADDR str_menu_brush

	;工具
	INVOKE CreatePopupMenu
	mov hToolMenu, eax
	INVOKE AppendMenu, hToolMenu, MF_STRING, IDM_MENU_TOOL_ERASER, ADDR str_menu_tool_eraser
	INVOKE AppendMenu, hToolMenu, MF_STRING, IDM_MENU_TOOL_FILL, ADDR str_menu_tool_fill
	INVOKE AppendMenu, hToolMenu, MF_STRING, IDM_MENU_TOOL_TEXT, ADDR str_menu_tool_text
	INVOKE AppendMenu, hToolMenu, MF_STRING, IDM_MENU_TOOL_COLPIC, ADDR str_menu_tool_colpic
	INVOKE AppendMenu, hToolMenu, MF_STRING, IDM_MENU_TOOL_SELECT, ADDR str_menu_tool_select
	INVOKE AppendMenu, hMenu, MF_POPUP, hToolMenu, ADDR str_menu_tool

	;形状
	INVOKE CreatePopupMenu
	mov hShapeMenu, eax
	INVOKE AppendMenu, hShapeMenu, MF_STRING, IDM_MENU_SHAPE_LINE, ADDR str_menu_shape_line
	INVOKE AppendMenu, hShapeMenu, MF_STRING, IDM_MENU_SHAPE_ROUND, ADDR str_menu_shape_round
	INVOKE AppendMenu, hShapeMenu, MF_STRING, IDM_MENU_SHAPE_TRI, ADDR str_menu_shape_tri
	INVOKE AppendMenu, hShapeMenu, MF_STRING, IDM_MENU_SHAPE_RECT, ADDR str_menu_shape_rect
	INVOKE AppendMenu, hMenu, MF_POPUP, hShapeMenu, ADDR str_menu_shape
	
	;大小
	INVOKE CreatePopupMenu
	mov hSizeMenu, eax
	INVOKE AppendMenu, hSizeMenu, MF_STRING, IDM_MENU_SIZE_ONE, ADDR str_menu_size_one
	INVOKE AppendMenu, hSizeMenu, MF_STRING, IDM_MENU_SIZE_THREE, ADDR str_menu_size_three
	INVOKE AppendMenu, hSizeMenu, MF_STRING, IDM_MENU_SIZE_FIVE, ADDR str_menu_size_five
	INVOKE AppendMenu, hSizeMenu, MF_STRING, IDM_MENU_SIZE_SEVEN, ADDR str_menu_size_seven
	INVOKE AppendMenu, hMenu, MF_POPUP, hSizeMenu, ADDR str_menu_size


	ret
CreateMainMenu ENDP


END