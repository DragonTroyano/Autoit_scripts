#Region Header

#CS
	Name:				ScrollText UDF
	Description:		Scrolling text module using GDI+.
	Author:				Copyright © 2012 - 2015 CreatoR's Lab (G.Sandler), www.creator-lab.ucoz.ru, www.autoit-script.ru. All rights reserved.
	AutoIt version:		3.3.10.2+
	UDF version:		0.4
	
	Notes:				* The scroll control can be dragged by mouse primary button.
						* Only one scroll control can be created each time.
						* If Obfuscator is used, set "#Obfuscator_Ignore_Funcs=__ST_Handler", if Au3Stripper is used, set "#Au3Stripper_Ignore_Funcs=__ST_Handler".
	
	Credits:			UEZ (scrolling mechanism), Yashied (gradient cover)
	
	History:
	v0.4
	* _ScrollText_Create now checks if this control was already created (wich is not supported at the moment).
	+ Added _ScrollText_SetData function to set data dynamicly.
	
	v0.3
	* Now the library works only with AutoIt 3.3.10.2 and above (checked up to 3.3.12.0).
	* Fixed cursor blinking issue.
	* Fixed issue with creating controls after _ScrollText_Create usage, controls was created inside scrolling child GUI.
	* Fixed issue with unset cursor untill text is scrolled.
	+ Added $iBorderStyle parameter.
	+ Added $iDefMouseCursor and $iScrollMouseCursor parameters to set default and scroll mouse cursors.
	+ Added ability to use image inside scrolling text (use <img[ width=N[ height=N ]]>Local\Image\Path.bmp</img> tag to insert an image).
	
	v0.2
	* Changed scrolling text format (check the example).
	+ Added Color and Style parameters to each line (check UDF header).
	+ Added $iLeft, $iTop, $iWidth and $iHeight parameters to set ScrollText control initial position.
	  Parameters are added before $bStartScroll.
	
	v0.1
	* First version.
	
#CE

;Includes
#include-once
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <Misc.au3>
#include <Timers.au3>

#Au3Stripper_Ignore_Funcs=__ST_Handler
#Obfuscator_Ignore_Funcs=__ST_Handler

#EndRegion Header

#Region Global Variables

Global $_ST_iWidth, $_ST_iHeight
Global $_ST_iLastMouseYPos, $_ST_aText, $_ST_hTimer, $_ST_hGraphicCntxt, $_ST_hStrFormat, $_ST_hBitmap, $_ST_hGraphic
Global $_ST_ahScroll_GUI, $_ST_hTopCoverBrush, $_ST_hBottomCoverBrush
Global $_ST_iCoverHeight = 70
Global $_ST_iBkColor = 0xFFFFFF ;_WinAPI_GetSysColor($COLOR_3DFACE)
Global $_ST_iScrollSpeed = 1 ;Scrolling speed
Global $_ST_iMouseScroll = 1 ;Enables scroll by mouse drag
Global $_ST_iMouseCursorDefault = 0 ;Default mouse cursor (on hover)
Global $_ST_iMouseCursorScroll = 11 ;Scroll mouse cursor (on scroll)
Global $_ST_iIsPressedOut = 0
Global $_ST_iIsPressedIn = 0

Global $_ST_sDef_FontName = 'Arial'
Global $_ST_iDef_FontSize = 16
Global $_ST_iDef_Color = 0x00007F
Global $_ST_iDef_Style = 0

Global Enum _
	$_ST_iElmnt_sTxt, $_ST_iElmnt_sFntName, $_ST_iElmnt_iFntSize, $_ST_iElmnt_iColor, $_ST_iElmnt_iStyle, _
	$_ST_iElmnt_hFamily, $_ST_iElmnt_hFont, $_ST_iElmnt_iInfoHeight, $_ST_iElmnt_iWidth, $_ST_iElmnt_iHeight, _
	$_ST_iElmnt_iTotal ;This should be last

Global Const $_ST_hGDIPDLL = 'gdiplus.dll'

_GDIPlus_Startup($_ST_hGDIPDLL)
OnAutoItExitRegister('__ST_OnExit')

#EndRegion Global Variables

#Region Public Functions

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_Create
; Description....: Creates scroll text control using GDI+.
; Syntax.........: _ScrollText_Create($hWnd, $sScrollData, $iLeft = -1, $iTop = -1, $iWidth = 500, $iHeight = 300, $bStartScroll = True, $iBorderStyle = 1)
; Parameters.....: $hWnd - Window handle.
;                  $sScrollData - String with data for scrolling text, format should be as follows:
;                                         $sScrollData = 'First text line(FontName,FontSize,Color,Style)\n(Arial,50)\nThird line'
;                                         Where each line is separated with \n, to set empty line omit the text.
;                                         Between the brackets at the end of line,
;                                           should be set line font name (FontName), line size (FontSize), text color (Color), and text style (Style).
;                                           The following flags can be used for Style:
;                                                                                      0 - Normal weight or thickness of the typeface (default)
;                                                                                      1 - Bold typeface
;                                                                                      2 - Italic typeface
;                                                                                      4 - Underline
;                                                                                      8 - Strikethrough
;                                         The parameters between the brackets can be omitted, in this case defaults will be used: (Arial,16,0x00007F,0).
;                  $iLeft - [Optional] Left position of ScrollText control. -1 (default) will set the control at the horizontal center of the parent GUI.
;                  $iTop - [Optional] Top position of ScrollText control. -1 (default) will set the control at the vertical center of the parent GUI.
;                  $iWidth - [Optional] Width of ScrollText control (minimum is 50, default is 300).
;                  $iHeight - [Optional] Height of ScrollText control (minimum is 40, default is 200).
;                  $bStartScroll - [Optional] If this parameter is True (default), then the scroll will start automatically, otherwise use _ScrollText_SetPause(False) later.
;                  $iBorderStyle - [Optional] Defines scroll text box border size. 0 - no style, 1 (default) - rounded corners, 2 - GUI border ($WS_BORDER).
;                  $iDefMouseCursor - [Optional] Default mouse cursor ID (when hovering scroll box). Default is 0 (grabbing hand icon - UNKNOWN).
;                  $iScrollMouseCursor - [Optional] Scroll mouse cursor ID (when scrolling text). Default is 11 (up and down arrow - SIZENS).
;                  
;                 
; Return values..: Success - Returns 1.
;                  Failure - @error is set to 1. Returns 0 if unable to create the ScrollGUI, or -1 if this control was already created (wich is not supported at the moment).
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: It is recommended to create ScrollText right *after* the main (parent) GUI is shown.
; Related........: 
; Link...........: 
; Example........: Yes.
; ===============================================================================================================
Func _ScrollText_Create($hWnd, $sScrollData, $iLeft = -1, $iTop = -1, $iWidth = 300, $iHeight = 200, $bStartScroll = True, $iBorderStyle = 1, $iDefMouseCursor = 0, $iScrollMouseCursor = 11)
	Local $aParentSize, $aGUISize, $aInfo, $iInfoWidth, $iLineHeight
	Local $aSplitData, $aSplitParams, $sText, $sFont, $iSize, $iColor, $iStyle
	Local $sImageFile, $iImageW, $iImageH, $iImageMaxWidth, $iImageMaxHeight, $iImageWidth, $iImageHeight, $hImage, $hImageResized
	Local $iGUIStyle = $WS_CHILD
	
	If IsHWnd($_ST_ahScroll_GUI) Then
		Return SetError(1, 0, -1)
	EndIf
	
	If $iBorderStyle = 2 Then
		$iGUIStyle = BitOR($iGUIStyle, $WS_BORDER)
	EndIf
	
	$aParentSize = WinGetClientSize($hWnd)
	
	If $iLeft = -1 Or $iLeft == Default Then
		$iLeft = ($aParentSize[0] / 2) - ($iWidth / 2)
	EndIf
	
	If $iTop = -1 Or $iTop == Default Then
		$iTop = ($aParentSize[1] / 2) - ($iHeight / 2)
	EndIf
	
	If $iWidth < 50 Then
		$iWidth = 50
	EndIf
	
	If $iHeight < 40 Then
		$iHeight = 40
	EndIf
	
	If $iDefMouseCursor = -1 Or $iDefMouseCursor == Default Then
		$iDefMouseCursor = 0
	EndIf
	
	If $iScrollMouseCursor = -1 Or $iScrollMouseCursor == Default Then
		$iScrollMouseCursor = 11
	EndIf
	
	$_ST_iMouseCursorDefault = $iDefMouseCursor
	$_ST_iMouseCursorScroll = $iScrollMouseCursor
	
	$_ST_ahScroll_GUI = GUICreate('', $iWidth, $iHeight, $iLeft, $iTop, $iGUIStyle, -1, $hWnd)
	If @error Then Return SetError(1, 0, 0)
	
	GUISetCursor($_ST_iMouseCursorDefault, 1, $_ST_ahScroll_GUI)
	
	If @OSBuild < 7600 Then
		WinSetTrans($_ST_ahScroll_GUI, "", 0xFF)
	EndIf
	
	If $iBorderStyle = 1 Then
		__ST_GUIRoundCorners($_ST_ahScroll_GUI, 5, 5, 30, 30)
	EndIf
	
	$aGUISize = WinGetClientSize($_ST_ahScroll_GUI)
	
	$_ST_iWidth = $aGUISize[0]
	$_ST_iHeight = $aGUISize[1]
	$_ST_iBkColor = Hex($_ST_iBkColor, 6)
	
	;=== Gradient ===
	$tRect = DllStructCreate($tagGDIPRECTF)
	DllStructSetData($tRect, 1, 0)
	DllStructSetData($tRect, 2, 0)
	DllStructSetData($tRect, 3, $_ST_iWidth)
	DllStructSetData($tRect, 4, $_ST_iCoverHeight)
	$_ST_hTopCoverBrush = __ST_GDIPlus_LineBrushCreateFromRect($tRect, '0xFF' & $_ST_iBkColor, '0x00' & $_ST_iBkColor, 1)
	DllStructSetData($tRect, 1, 0)
	DllStructSetData($tRect, 2, $_ST_iHeight - $_ST_iCoverHeight)
	DllStructSetData($tRect, 3, $_ST_iWidth)
	DllStructSetData($tRect, 4, $_ST_iCoverHeight)
	$_ST_hBottomCoverBrush = __ST_GDIPlus_LineBrushCreateFromRect($tRect, '0x00' & $_ST_iBkColor, '0xFF' & $_ST_iBkColor, 1)
	
	GUISetState(@SW_SHOW, $_ST_ahScroll_GUI)
	GUISwitch($hWnd)
	
	_ScrollText_SetData($sScrollData)
	
	; Draw a string
	$_ST_hGraphic = _GDIPlus_GraphicsCreateFromHWND($_ST_ahScroll_GUI)
	$_ST_hBitmap = _GDIPlus_BitmapCreateFromGraphics($_ST_iWidth, $_ST_iHeight, $_ST_hGraphic)
	$_ST_hGraphicCntxt = _GDIPlus_ImageGetGraphicsContext($_ST_hBitmap)
	_GDIPlus_GraphicsClear($_ST_hGraphicCntxt, '0xFF' & $_ST_iBkColor)
	_GDIPlus_GraphicsSetSmoothingMode($_ST_hGraphicCntxt, 2)
	DllCall($_ST_hGDIPDLL, "uint", "GdipSetTextRenderingHint", "handle", $_ST_hGraphicCntxt, "int", 4)
	
	$_ST_hStrFormat = _GDIPlus_StringFormatCreate()
	$tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
	
	For $z = 0 To UBound($_ST_aText) - 1
		If $_ST_aText[$z][$_ST_iElmnt_sTxt] = '' Then
			ContinueLoop
		EndIf
		
		$_ST_aText[$z][$_ST_iElmnt_hFamily] = _GDIPlus_FontFamilyCreate($_ST_aText[$z][$_ST_iElmnt_sFntName]) ;$hFamily
		$_ST_aText[$z][$_ST_iElmnt_hFont] = _GDIPlus_FontCreate($_ST_aText[$z][$_ST_iElmnt_hFamily], $_ST_aText[$z][$_ST_iElmnt_iFntSize], $_ST_aText[$z][$_ST_iElmnt_iStyle]) ;$hFont
		$aInfo = _GDIPlus_GraphicsMeasureString($_ST_hGraphic, $_ST_aText[$z][$_ST_iElmnt_sTxt], $_ST_aText[$z][$_ST_iElmnt_hFont], $tLayout, $_ST_hStrFormat)
		
		If @error Then
			Dim $aInfo[1] = [0]
		EndIf
		
		$iInfoWidth = Floor(DllStructGetData($aInfo[0], "Width"))
		$_ST_aText[$z][$_ST_iElmnt_iInfoHeight] = Floor(DllStructGetData($aInfo[0], "Height"))
		$_ST_aText[$z][$_ST_iElmnt_iWidth] = Floor($_ST_iWidth / 2 - ($iInfoWidth / 2))
		$_ST_aText[$z][$_ST_iElmnt_iHeight] = Floor($_ST_iHeight + $iLineHeight)
		$iLineHeight += $_ST_aText[$z][$_ST_iElmnt_iInfoHeight]
	Next
	
	_ScrollText_SetPos($_ST_iScrollSpeed)
	_ScrollText_SetPause(Not $bStartScroll)
	
	Return 1
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_Destroy
; Description....: Destroys ScrollText control.
; Syntax.........: _ScrollText_Destroy()
; Parameters.....: None.
;                  
;                 
; Return values..: None.
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: 
; Related........: 
; Link...........: 
; Example........: 
; ===============================================================================================================
Func _ScrollText_Destroy()
	If $_ST_ahScroll_GUI = 0 Then
		Return
	EndIf
	
	_Timer_KillTimer($_ST_ahScroll_GUI, $_ST_hTimer)
	
	For $i = 0 To UBound($_ST_aText) - 1
		If IsPtr($_ST_aText[$i][$_ST_iElmnt_sTxt]) Then
			_GDIPlus_ImageDispose($_ST_aText[$i][$_ST_iElmnt_sTxt])
		EndIf
		
		_GDIPlus_FontDispose($_ST_aText[$i][$_ST_iElmnt_hFont])
		_GDIPlus_FontFamilyDispose($_ST_aText[$i][$_ST_iElmnt_hFamily])
	Next
	
	_GDIPlus_StringFormatDispose($_ST_hStrFormat)
	_GDIPlus_BitmapDispose($_ST_hBitmap)
	_GDIPlus_GraphicsDispose($_ST_hGraphicCntxt)
	_GDIPlus_GraphicsDispose($_ST_hGraphic)
	
	_GDIPlus_BrushDispose($_ST_hTopCoverBrush)
	_GDIPlus_BrushDispose($_ST_hBottomCoverBrush)
	
	GUIDelete($_ST_ahScroll_GUI)
	
	$_ST_hTimer = 0
	$_ST_aText = 0
	$_ST_hStrFormat = 0
	$_ST_hBitmap = 0
	$_ST_hGraphicCntxt = 0
	$_ST_hGraphic = 0
	$_ST_hTopCoverBrush = 0
	$_ST_hBottomCoverBrush = 0
	$_ST_ahScroll_GUI = 0
EndFunc

Func _ScrollText_SetData($sScrollData)
	Local $sNewLines
	
	For $i = 1 To Ceiling($_ST_iHeight / 60)
		$sNewLines &= '\\n'
	Next
	
	If $sNewLines = '' Then
		$sNewLines &= '\\n\\n\\n\\n\\n\\n\\n'
	EndIf
	
	$sScrollData = StringRegExpReplace($sScrollData, '(<img>.*?</img>)', '\1' & $sNewLines)
	$aSplitData = StringSplit($sScrollData, '\n', 1)
	
	$_ST_aText = 0
	Dim $_ST_aText[UBound($aSplitData)-1][$_ST_iElmnt_iTotal]
	
	For $i = 1 To $aSplitData[0]
		$sText = StringRegExpReplace($aSplitData[$i], '\h*\([^)]*\)$', '')
		
		If $sText = '' Then
			$sText = ' '
		EndIf
		
		$aSplitParams = StringSplit(StringRegExpReplace($aSplitData[$i], '.*?(\(([^)]*)\)|)$', '\2'), ',')
		ReDim $aSplitParams[5]
		
		For $j = 1 To $aSplitParams[0]
			$aSplitParams[$j] = StringStripWS($aSplitParams[$j], 3)
		Next
		
		$sFont = ($aSplitParams[1] = '' ? $_ST_sDef_FontName : $aSplitParams[1])
		$iSize = ($aSplitParams[2] = '' ? $_ST_iDef_FontSize : $aSplitParams[2])
		$iColor = Hex(($aSplitParams[3] = '' ? $_ST_iDef_Color : $aSplitParams[3]), 6)
		$iStyle = ($aSplitParams[4] = '' ? $_ST_iDef_Style : $aSplitParams[4])
		
		;ConsoleWrite($sText & ", " & $sFont & ", " & $iSize & ", " & $iColor & ", " & $iStyle & @LF)
		
		If StringRegExp($sText, '<img.*?>.*?</img>') Then
			$sImageFile = StringRegExpReplace($sText, '<img.*?>(.*?)</img>', '\1')
			$iImageW = StringRegExpReplace($sText, '<img.*? width="?(\d+)"?.*?>.*?</img>', '\1')
			$iImageH = StringRegExpReplace($sText, '<img.*? height="?(\d+)"?.*?>.*?</img>', '\1')
			
			$hImage = _GDIPlus_ImageLoadFromFile($sImageFile)
			
			$iImageMaxWidth = (StringIsDigit($iImageW) ? $iImageW : ($_ST_iWidth / 2))
			$iImageMaxHeight = (StringIsDigit($iImageH) ? $iImageH : ($_ST_iHeight / 2))
			
			$iImageWidth = _GDIPlus_ImageGetWidth($hImage)
			$iImageHeight = _GDIPlus_ImageGetHeight($hImage)
			
			If $iImageWidth < $iImageMaxWidth Then
				$iImageMaxWidth = $iImageWidth
			EndIf
			
			If $iImageHeight < $iImageMaxHeight Then
				$iImageMaxHeight = $iImageHeight
			EndIf
			
			$hImageResized = _GDIPlus_ImageResize($hImage, $iImageMaxWidth, $iImageMaxHeight)
			_GDIPlus_ImageDispose($hImage)
			
			$sText = $hImageResized
			
			If Not IsPtr($sText) Then
				$sText = ' '
			EndIf
		EndIf
		
		$_ST_aText[$i-1][$_ST_iElmnt_sTxt] = $sText
		$_ST_aText[$i-1][$_ST_iElmnt_sFntName] = $sFont
		$_ST_aText[$i-1][$_ST_iElmnt_iFntSize] = Number($iSize)
		$_ST_aText[$i-1][$_ST_iElmnt_iColor] = $iColor
		$_ST_aText[$i-1][$_ST_iElmnt_iStyle] = $iStyle
		$_ST_aText[$i-1][$_ST_iElmnt_hFamily] = 0
		$_ST_aText[$i-1][$_ST_iElmnt_hFont] = 0
		$_ST_aText[$i-1][$_ST_iElmnt_iInfoHeight] = 0
		$_ST_aText[$i-1][$_ST_iElmnt_iWidth] = 0
		$_ST_aText[$i-1][$_ST_iElmnt_iHeight] = 0
	Next
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_SetPause
; Description....: 
; Syntax.........: _ScrollText_SetPause($bPause = True)
; Parameters.....: $bPause [Optional] - Determines whether to pause the scrolling or not.
;                  
;                 
; Return values..: None.
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: 
; Related........: 
; Link...........: 
; Example........: 
; ===============================================================================================================
Func _ScrollText_SetPause($bPause = True)
	If $bPause Then
		If $_ST_hTimer Then
			_Timer_KillTimer($_ST_ahScroll_GUI, $_ST_hTimer)
			$_ST_hTimer = 0
		EndIf
	Else
		$_ST_hTimer = _Timer_SetTimer($_ST_ahScroll_GUI, 10, "__ST_Handler")
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_SetPos
; Description....: Sets scrolling position, used to move the ScrollText by mouse drag (up/down).
; Syntax.........: _ScrollText_SetPos($iPos)
; Parameters.....: $iPos - Vertical position move to.
;                  
;                 
; Return values..: None.
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: 
; Related........: 
; Link...........: 
; Example........: 
; ===============================================================================================================
Func _ScrollText_SetPos($iPos)
	Local $tLayout, $hBrush
	Local $iImageWidth, $iImageHeight
	
	_GDIPlus_GraphicsClear($_ST_hGraphicCntxt, '0xFF' & $_ST_iBkColor)
	
	For $i = 0 To UBound($_ST_aText) - 1
		;If ($_ST_aText[$i][$_ST_iElmnt_iHeight] < $_ST_iHeight And $_ST_aText[$i][$_ST_iElmnt_iInfoHeight] > - $_ST_aText[$i][$_ST_iElmnt_iHeight]) Then
			If IsPtr($_ST_aText[$i][$_ST_iElmnt_sTxt]) Then
				$iImageWidth = _GDIPlus_ImageGetWidth($_ST_aText[$i][$_ST_iElmnt_sTxt])
				$iImageHeight = _GDIPlus_ImageGetHeight($_ST_aText[$i][$_ST_iElmnt_sTxt])
				
				_GDIPlus_GraphicsDrawImageRect($_ST_hGraphicCntxt, $_ST_aText[$i][$_ST_iElmnt_sTxt], ($_ST_iWidth / 2) - ($iImageWidth / 2), $_ST_aText[$i][$_ST_iElmnt_iHeight], $iImageWidth, $iImageHeight)
			Else
				$tLayout = _GDIPlus_RectFCreate($_ST_aText[$i][$_ST_iElmnt_iWidth], $_ST_aText[$i][$_ST_iElmnt_iHeight], 0, 0)
				$hBrush = _GDIPlus_BrushCreateSolid('0xFF' & $_ST_aText[$i][$_ST_iElmnt_iColor])
				_GDIPlus_GraphicsDrawStringEx($_ST_hGraphicCntxt, $_ST_aText[$i][$_ST_iElmnt_sTxt], $_ST_aText[$i][$_ST_iElmnt_hFont], $tLayout, $_ST_hStrFormat, $hBrush)
				_GDIPlus_BrushDispose($hBrush)
			EndIf
		;EndIf
		
		$_ST_aText[$i][$_ST_iElmnt_iHeight] -= $iPos
	Next
	
	_GDIPlus_GraphicsFillRect($_ST_hGraphicCntxt, 0, -1, $_ST_iWidth, $_ST_iCoverHeight, $_ST_hTopCoverBrush)
	_GDIPlus_GraphicsFillRect($_ST_hGraphicCntxt, 0, $_ST_iHeight - $_ST_iCoverHeight, $_ST_iWidth, $_ST_iCoverHeight, $_ST_hBottomCoverBrush)
	
	_GDIPlus_GraphicsDrawImageRect($_ST_hGraphic, $_ST_hBitmap, 0, 0, $_ST_iWidth, $_ST_iHeight)
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_SetScrollSpeed
; Description....: 
; Syntax.........: _ScrollText_SetScrollSpeed($iSpeed)
; Parameters.....: $iSpeed - Scroll speed. Value between 1 to 10, where 10 is fastest scroll speed.
;                  
;                 
; Return values..: None.
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: 
; Related........: 
; Link...........: 
; Example........: 
; ===============================================================================================================
Func _ScrollText_SetScrollSpeed($iSpeed)
	$iSpeed = Int($iSpeed)
	
	If $iSpeed < 1 Or $iSpeed > 10 Then
		$iSpeed = 1
	EndIf
	
	$_ST_iScrollSpeed = $iSpeed
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_EnableMouseScroll
; Description....: 
; Syntax.........: _ScrollText_EnableMouseScroll($bEnable)
; Parameters.....: $bEnable - Determines whether to enable text scrolling by mouse or not.
;                  
;                 
; Return values..: None.
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: 
; Related........: 
; Link...........: 
; Example........: 
; ===============================================================================================================
Func _ScrollText_EnableMouseScroll($bEnable)
	$_ST_iMouseScroll = Int($bEnable)
EndFunc

#EndRegion Public Functions

#Region Internal Functions

Func __ST_Handler($hWnd, $iMsg, $iIDTimer, $dwTime)
	Local $tLayout, $aInfo, $iLineHeight, $iPos
	Local $iMouseYPos = MouseGetPos(1)
	Local $tRect = _WinAPI_GetMousePos()
	Local $hWinFromPoint = _WinAPI_WindowFromPoint($tRect)
	Local $iIsPressed_Key = '01'
	
	Static $__ST_Flag = 0
	
	If _WinAPI_GetSystemMetrics($SM_SWAPBUTTON) Then
		$iIsPressed_Key = '02'
	EndIf
	
	If Not $_ST_iIsPressedIn And _IsPressed($iIsPressed_Key) And $hWinFromPoint <> $hWnd Then
		$_ST_iIsPressedOut = 1
		$_ST_iIsPressedIn = 0
	ElseIf Not $_ST_iIsPressedOut And _IsPressed($iIsPressed_Key) And $hWinFromPoint = $hWnd Then
		$_ST_iIsPressedOut = 0
		$_ST_iIsPressedIn = 1
	EndIf
	
	If Not _IsPressed($iIsPressed_Key) Then
		$_ST_iIsPressedOut = 0
		$_ST_iIsPressedIn = 0
	EndIf
	
	Local $bScroll = ($_ST_iMouseScroll And $_ST_iIsPressedIn And _IsPressed($iIsPressed_Key))
	
	If $bScroll Then
		If $__ST_Flag = 0 Then
			GUISetCursor($_ST_iMouseCursorScroll, 1, $hWnd)
			$__ST_Flag = 1
		EndIf
		
		If $iMouseYPos > $_ST_iLastMouseYPos Then
			$iPos -= ($iMouseYPos - $_ST_iLastMouseYPos)
			$_ST_iLastMouseYPos = $iMouseYPos
		ElseIf $iMouseYPos < $_ST_iLastMouseYPos Then
			$iPos += ($_ST_iLastMouseYPos - $iMouseYPos)
			$_ST_iLastMouseYPos = $iMouseYPos
		EndIf
	Else
		If $__ST_Flag = 1 Then
			GUISetCursor($_ST_iMouseCursorDefault, 1, $hWnd)
			$__ST_Flag = 0
		EndIf
		
		$iPos = $_ST_iScrollSpeed
		$_ST_iLastMouseYPos = $iMouseYPos
	EndIf
	
	_ScrollText_SetPos($iPos)
	
	If $_ST_aText[UBound($_ST_aText) - 1][$_ST_iElmnt_iHeight] < - $_ST_aText[UBound($_ST_aText) - 1][$_ST_iElmnt_iInfoHeight] * 2.5 Then ;Reached the ceiling
		$tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
		
		For $z = 0 To UBound($_ST_aText) - 1
			$aInfo = _GDIPlus_GraphicsMeasureString($_ST_hGraphic, $_ST_aText[$z][$_ST_iElmnt_sTxt], $_ST_aText[$z][$_ST_iElmnt_hFont], $tLayout, $_ST_hStrFormat)
			$_ST_aText[$z][$_ST_iElmnt_iHeight] = Floor($_ST_iHeight + $iLineHeight)
			
			If IsArray($aInfo) Then
				$iLineHeight += Floor(DllStructGetData($aInfo[0], "Height"))
			EndIf
		Next
	ElseIf $bScroll And $_ST_aText[0][$_ST_iElmnt_iHeight] > $_ST_iHeight Then ;Reached the floor
		$tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
		
		For $z = UBound($_ST_aText) - 1 To 0 Step -1
			$aInfo = _GDIPlus_GraphicsMeasureString($_ST_hGraphic, $_ST_aText[$z][$_ST_iElmnt_sTxt], $_ST_aText[$z][$_ST_iElmnt_hFont], $tLayout, $_ST_hStrFormat)
			
			If IsArray($aInfo) Then
				$iLineHeight += Floor(DllStructGetData($aInfo[0], "Height"))
				$_ST_aText[$z][$_ST_iElmnt_iHeight] = Floor(-$iLineHeight)
			EndIf
		Next
	EndIf
EndFunc

Func __ST_GUIRoundCorners($hWnd, $iX1, $iY1, $iX2, $iY2)
	Local $aWPos = WinGetPos($hWnd)
	
	If Not IsArray($aWPos) Then
		Return SetError(1, 0, 0)
	EndIf
	
	Local $aRet = DllCall("gdi32.dll", "long", "CreateRoundRectRgn", _
			"long", $iX1, _
			"long", $iX1, _
			"long", $aWPos[2], _
			"long", $aWPos[3], _
			"long", $iX2, _
			"long", $iY2)
	
	If IsArray($aRet) And $aRet[0] Then
		Return DllCall("user32.dll", "long", "SetWindowRgn", "hwnd", $hWnd, "long", $aRet[0], "int", 1)
	EndIf
	
	Return SetError(2, 0, 0)
EndFunc

Func __ST_GDIPlus_LineBrushCreateFromRect($tRectF, $iARGBClr1, $iARGBClr2, $iGradientMode = 0, $iWrapMode = 0)
	Local $pRectF, $aResult
	
	$pRectF = DllStructGetPtr($tRectF)
	$aResult = DllCall($_ST_hGDIPDLL, "uint", "GdipCreateLineBrushFromRect", "ptr", $pRectF, "uint", $iARGBClr1, "uint", $iARGBClr2, "int", $iGradientMode, "int", $iWrapMode, "int*", 0)
	
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[6]
EndFunc

Func __ST_OnExit()
	_ScrollText_Destroy()
	_GDIPlus_Shutdown()
EndFunc

#EndRegion Internal Functions
