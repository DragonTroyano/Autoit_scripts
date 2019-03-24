#include-once
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <WindowsConstants.au3>

Global Enum _
	$iMSG_First = 0, _
		$iMSG_sApp_Name_GoogleTranslator, $iMSG_SplashTextOn_LoadingTrnsModl, $iMSG_MsgBox_ServerIsOffline, $iMSG_MsgBox_CheckInetConn, $iMSG_MsgBox_OKEXIT, $iMSG_SimpleTranslator, _
		$iMSG_GUICtrlCreateLa_l_TranslateFrom, $iMSG__GUICtrlComboBo_odetectLanguage, $iMSG_GUICtrlCreateLabel_TranslateTo, _
		$iMSG_GUICtrlCreateLa_l_TranslateText, $iMSG_GUICtrlCreateChckBox_TrnsltWhileType, $iMSG_GUICtrlCreateLa_TranslateResult, $iMSG_GUICtrlSetTip_Speak, $iMSG_GUICtrlCreateButton_About, $iMSG_GUICtrlCreateButton_Settings, _
		$iMSG_GUICtrlCreateButton_Translate, $iMSG_MsgBox_Attention, $iMSG_MsgBox_NothingToTranslate, $iMSG_MsgBox_SetDiffe_ationDirections, $iMSG_GUICtrlSetData_PleaseWait, $iMSG_GUICtrlSetData_Done, _
		$iMSG_TrayCreateItem_Show, $iMSG_TrayCreateItem_Exit, $iMSG_About_Version, $iMSG_About_PlaySound, $iMSG_Settings_Title, $iMSG_Settings_StartWithWindows, $iMSG_Settings_StartMinimized, _
		$iMSG_Settings_MinimizeToTray, $iMSG_Settings_SetOnTop, $iMSG_Settings_TranslateBySelection, $iMSG_Settings_SpeakSelTranslation, $iMSG_Settings_TranslationSpeaker, _
		$iMSG_Settings_GetLangsDataIntrvl, $iMSG_Settings_0ToGetAlways, $iMSG_Settings_OK, $iMSG_Settings_Cancel, _
	$iMSG_Last

Global Const $LANGS_DIR = @ScriptDir & '\' & (@Compiled ? '' : '..\') & 'Langs'
Global $aTXT_IDs[$iMSG_Last] = [$iMSG_Last-1]
Global $aTXT = _AppTranslation_Register($LANGS_DIR & '\English.lng')

If StringInStr($CmdLineRaw, '/GenerateLangFile') Then
	$sLngName = StringRegExpReplace($CmdLineRaw, '(?i).*?/GenerateLangFile:(?:"([^"]*)".*|.*?)', '\1')
	$sLangFile = $LANGS_DIR & '\' & $sLngName & '.lng'
	If @extended = 0 Or $sLngName = '' Then $sLangFile = '' ;Generate strings for languages found in $LANGS_DIR
	_AppTranslation_GenerateLangFile($sLangFile)
	Exit
EndIf

Func _AppTranslation_Register($sLangFile, $sSetDataFunc = "")
	Local $aTXT[$iMSG_Last] = [$iMSG_Last-1]
	Local $iFileEncoding = FileGetEncoding($sLangFile)
	
	;Default values
	$aTXT[$iMSG_sApp_Name_GoogleTranslator] = _AppTranslation_GetString($sLangFile, "sApp_Name_GoogleTranslator", 'Google Translator', $iFileEncoding)
	$aTXT[$iMSG_SplashTextOn_LoadingTrnsModl] = _AppTranslation_GetString($sLangFile, "SplashTextOn_LoadingTrnsModl", 'Please wait, loading translation module...', $iFileEncoding)
	$aTXT[$iMSG_MsgBox_ServerIsOffline] = _AppTranslation_GetString($sLangFile, "MsgBox_ServerIsOffline", 'Server [%s] is offline.', $iFileEncoding)
	$aTXT[$iMSG_MsgBox_CheckInetConn] = _AppTranslation_GetString($sLangFile, "MsgBox_CheckInetConn", '(check internet connection)', $iFileEncoding)
	$aTXT[$iMSG_MsgBox_OKEXIT] = _AppTranslation_GetString($sLangFile, "MsgBox_OKEXIT", 'OK ==> EXIT', $iFileEncoding)
	$aTXT[$iMSG_SimpleTranslator] = _AppTranslation_GetString($sLangFile, "SimpleTranslator", _
		'Simple translator using translate.google.com service.\r\n* Supports automatic language detection.\r\n* Supports selection translation.\r\n* Supports speak text (using Yandex SpeechKit Cloud).', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlCreateLa_l_TranslateFrom] = _AppTranslation_GetString($sLangFile, "GUICtrlCreateLa_l_TranslateFrom", 'Translate From:', $iFileEncoding)
	$aTXT[$iMSG__GUICtrlComboBo_odetectLanguage] = _AppTranslation_GetString($sLangFile, "_GUICtrlComboBo_odetectLanguage", 'Autodetect language', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlCreateLabel_TranslateTo] = _AppTranslation_GetString($sLangFile, "GUICtrlCreateLabel_TranslateTo", 'Translate To:', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlCreateLa_l_TranslateText] = _AppTranslation_GetString($sLangFile, "GUICtrlCreateLa_l_TranslateText", 'Translate text:', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlCreateChckBox_TrnsltWhileType] = _AppTranslation_GetString($sLangFile, "GUICtrlCreateChckBox_TrnsltWhileType", 'Translate while typing', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlCreateLa_TranslateResult] = _AppTranslation_GetString($sLangFile, "GUICtrlCreateLa_TranslateResult", 'Translate result:', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlSetTip_Speak] = _AppTranslation_GetString($sLangFile, "GUICtrlSetTip_Speak", 'Speak...', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlCreateButton_About] = _AppTranslation_GetString($sLangFile, "GUICtrlCreateButton_About", 'About', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlCreateButton_Settings] = _AppTranslation_GetString($sLangFile, "GUICtrlCreateButton_Settings", 'Settings', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlCreateButton_Translate] = _AppTranslation_GetString($sLangFile, "GUICtrlCreateButton_Translate", 'Translate', $iFileEncoding)
	$aTXT[$iMSG_MsgBox_Attention] = _AppTranslation_GetString($sLangFile, "MsgBox_Attention", 'Attention', $iFileEncoding)
	$aTXT[$iMSG_MsgBox_NothingToTranslate] = _AppTranslation_GetString($sLangFile, "MsgBox_NothingToTranslate", 'Nothing to translate', $iFileEncoding)
	$aTXT[$iMSG_MsgBox_SetDiffe_ationDirections] = _AppTranslation_GetString($sLangFile, "MsgBox_SetDiffe_ationDirections", 'Set different translation directions.', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlSetData_PleaseWait] = _AppTranslation_GetString($sLangFile, "GUICtrlSetData_PleaseWait", 'Please wait...', $iFileEncoding)
	$aTXT[$iMSG_GUICtrlSetData_Done] = _AppTranslation_GetString($sLangFile, "GUICtrlSetData_Done", 'Done', $iFileEncoding)
	
	;Tray
	$aTXT[$iMSG_TrayCreateItem_Show] = _AppTranslation_GetString($sLangFile, "TrayCreateItem_Show", 'Show %s', $iFileEncoding)
	$aTXT[$iMSG_TrayCreateItem_Exit] = _AppTranslation_GetString($sLangFile, "TrayCreateItem_Exit", 'Exit', $iFileEncoding)
	
	;About
	$aTXT[$iMSG_About_Version] = _AppTranslation_GetString($sLangFile, "About_Version", 'Version', $iFileEncoding)
	$aTXT[$iMSG_About_PlaySound] = _AppTranslation_GetString($sLangFile, "About_PlaySound", 'Play sound', $iFileEncoding)
	
	;Settings
	$aTXT[$iMSG_Settings_Title] = _AppTranslation_GetString($sLangFile, "Settings_Title", 'Settings', $iFileEncoding)
	$aTXT[$iMSG_Settings_StartWithWindows] = _AppTranslation_GetString($sLangFile, "Settings_StartWithWindows", 'Start with windows', $iFileEncoding)
	$aTXT[$iMSG_Settings_StartMinimized] = _AppTranslation_GetString($sLangFile, "Settings_StartMinimized", 'Start minimized', $iFileEncoding)
	$aTXT[$iMSG_Settings_MinimizeToTray] = _AppTranslation_GetString($sLangFile, "Settings_MinimizeToTray", 'Minimize to tray', $iFileEncoding)
	$aTXT[$iMSG_Settings_SetOnTop] = _AppTranslation_GetString($sLangFile, "Settings_SetOnTop", 'Set on top', $iFileEncoding)
	$aTXT[$iMSG_Settings_TranslateBySelection] = _AppTranslation_GetString($sLangFile, "Settings_TranslateBySelection", 'Translate by selection', $iFileEncoding)
	$aTXT[$iMSG_Settings_SpeakSelTranslation] = _AppTranslation_GetString($sLangFile, "Settings_SpeakSelTranslation", 'Speak translated selection', $iFileEncoding)
	$aTXT[$iMSG_Settings_TranslationSpeaker] = _AppTranslation_GetString($sLangFile, "Settings_TranslationSpeaker", 'Speaker:', $iFileEncoding)
	$aTXT[$iMSG_Settings_GetLangsDataIntrvl] = _AppTranslation_GetString($sLangFile, "Settings_GetLangsDataIntrvl", 'Get languages data interval (in hours):', $iFileEncoding)
	$aTXT[$iMSG_Settings_0ToGetAlways] = _AppTranslation_GetString($sLangFile, "Settings_0ToGetAlways", '(0 - get always)', $iFileEncoding)
	$aTXT[$iMSG_Settings_OK] = _AppTranslation_GetString($sLangFile, "Settings_OK", 'OK', $iFileEncoding)
	$aTXT[$iMSG_Settings_Cancel] = _AppTranslation_GetString($sLangFile, "Settings_Cancel", 'Cancel', $iFileEncoding)
	
	If $sSetDataFunc <> "" Then
		Call($sSetDataFunc, $aTXT)
	EndIf
	
	Return $aTXT
EndFunc

Func _AppTranslation_GetLanguages($sLangs_Dir, $bRetArray = False, $bRetRealName = False)
	Local $sRet, $sLngFileName, $hSearch = FileFindFirstFile($sLangs_Dir & "\*.lng")
	If $hSearch = -1 Then Return SetError(-1, 0, '')
	
	While 1
		$sLngFileName = FileFindNextFile($hSearch)
		If @error <> 0 Then ExitLoop
		
		$sName = StringRegExpReplace($sLngFileName, "\.[^\.]+$", "")
		
		If $bRetRealName Then
			$sRet &= IniRead($sLangs_Dir & "\" & $sLngFileName, "Info", "Language", $sName) & "|"
		Else
			$sRet &= $sName & "|"
		EndIf
	WEnd
	
	FileClose($hSearch)
	
	If $sRet = "" Then Return SetError(1, 0, "")
	
	$sRet = StringTrimRight($sRet, 1)
	If $bRetArray Then $sRet = StringSplit($sRet, "|")
	Return $sRet
EndFunc

Func _AppTranslation_GetLangFileByLangName($sLangs_Dir, $sLngName)
	Local $aLangs = _AppTranslation_GetLanguages($sLangs_Dir, True)
	
	For $i = 1 To UBound($aLangs) - 1
		If IniRead($sLangs_Dir & "\" & $aLangs[$i] & ".lng", "Info", "Language", "") = $sLngName Then
			Return $sLangs_Dir & "\" & $aLangs[$i] & ".lng"
		EndIf
	Next
	
	Return SetError(1, 0, $sLangs_Dir & "\" & $sLngName & ".lng")
EndFunc

Func _AppTranslation_GetString($sLangFile, $sIdentifier, $sDefault = "", $iFileEncoding = 0)
	$aTXT_IDs[Eval('iMSG_' & $sIdentifier)] = $sIdentifier
	
	Local $sStr = IniRead($sLangFile, "Translation", $sIdentifier, $sDefault)
	
	If $iFileEncoding >= 128 Then
		$sStr = BinaryToString(StringToBinary($sStr), 4)
	EndIf
	
	Return $sStr
EndFunc

Func _AppTranslation_GenerateLangFile($sLangFile = '', $sAppName = @ScriptName, $sAppVer = -1, $sLngAuthor = '')
	Local $aLangs[2] = [1, $sLangFile]
	
	If $sLangFile = '' Then
		$aLangs = _AppTranslation_GetLanguages($LANGS_DIR, True)
	ElseIf Not FileExists($sLangFile) Then
		If $sAppName = @ScriptName Then $sAppName = StringRegExpReplace($sAppName, '\.[^\.]*$', '')
		
		If $sAppVer = -1 Then
			If @Compiled Then
				$sAppVer = StringLeft(FileGetVersion(@ScriptFullPath, 'FileVersion'), 3)
			Else
				$sAppVer = '1.0'
			EndIf
		EndIf
		
		IniWrite($sLangFile, 'Info', 'Program', $sAppName)
		IniWrite($sLangFile, 'Info', 'Version', $sAppVer)
		IniWrite($sLangFile, 'Info', 'Language', StringRegExpReplace($sLangFile, '^.*\\|\.[^\.]*$', ''))
		IniWrite($sLangFile, 'Info', 'Author', '')
	EndIf
	
	For $iLng = 1 To $aLangs[0]
		If $aLangs[$iLng] = '' Then ContinueLoop
		
		If $sLangFile = '' Then
			$aLangs[$iLng] = $LANGS_DIR & '\' & $aLangs[$iLng] & '.lng'
		EndIf
		
		For $i = 1 To $aTXT[0]
			If IniRead($aLangs[$iLng], 'Translation', $aTXT_IDs[$i], '@DEFAULT@') == '@DEFAULT@' Then
				IniWrite($aLangs[$iLng], 'Translation', $aTXT_IDs[$i], $aTXT[$i])
			EndIf
		Next
	Next
EndFunc

Func _AppTranslation_SelectLangGUI($sAppName, $hParent = 0, $sDefLng = "")
	Local $hGUI, $nLng_Combo, $nOK_Bttn, $iMsg
	
	GUISetState(@SW_DISABLE, $hParent)
	$hGUI = GUICreate($sAppName, 300, 120, -1, -1, -1, $WS_EX_TOOLWINDOW, $hParent)
	
	GUICtrlCreateLabel("Language:", 20, 22, 80, 17)
	$nLng_Combo = GUICtrlCreateCombo("", 110, 20, 170, 50, BitOr($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
	GUICtrlSetData($nLng_Combo, _AppTranslation_GetLanguages($LANGS_DIR), $sDefLng)
	$nOK_Bttn = GUICtrlCreateButton("OK", 20, 90, 70, 20)
	
	GUISetState(@SW_SHOW, $hGUI)
	
	While 1
		$iMsg = GUIGetMsg()
		
		Switch $iMsg
			Case $GUI_EVENT_CLOSE, $nOK_Bttn
				ExitLoop
			Case $nLng_Combo
				$sDefLng = GUICtrlRead($nLng_Combo)
				$aTXT = _AppTranslation_Register($LANGS_DIR & "\" & $sDefLng & ".lng")
		EndSwitch
	WEnd
	
	GUISetState(@SW_ENABLE, $hParent)
	GUIDelete($hGUI)
	
	Return $sDefLng
EndFunc
