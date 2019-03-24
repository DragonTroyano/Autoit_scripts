#pragma compile(Out, ..\GT.exe)
#pragma compile(Icon, Resources\Icon.ico)
#pragma compile(ExecLevel, HighestAvailable)
#pragma compile(UPX, True)
#pragma compile(Stripper, True)
#pragma compile(FileVersion, '0.7.0.0')
#pragma compile(ProductVersion, '0.7')
#pragma compile(ProductName, 'Google Translator')
#pragma compile(FileDescription, 'Simple Google Translator')
#pragma compile(LegalCopyright, '© G.Sandler 2010-2015 (www.creator-lab.ucoz.ru, www.autoit-script.ru). All rights reserved')
#pragma compile(CompanyName, 'CreatoR's Lab')
#pragma compile(Sign, G.Sandler)

#Au3Stripper_Ignore_Funcs=_MouseDown_Event,_MouseUp_Event,_SoundPlay_Proc

#Region Header

#CS Info

AutoIt version:	3.3.10.2 - 3.3.12.1

History: 		See $sApp_History variable in "Variables and Constants" region section.

Credits:
				* Stephen Podhajecki {gehossafats at netmdc. com}
				* AZJIO
				* madmasles

#CE

#NoTrayIcon

#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <InetConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#include <Array.au3>
#include <ClipBoard.au3>
#include <File.au3>
#include <Sound.au3>
#include <String.au3>
#include <GUIImageList.au3>
#include <GUIComboBoxEx.au3>
#include <GUIToolTip.au3>

#include 'Includes\AboutBox.au3'
#include 'Includes\Encoding.au3'
#include 'Includes\HTMLEntities.au3'
#include 'Includes\Translation.au3'
#include 'Includes\MouseOnEvent.au3'

#EndRegion Header

#Region Variables and Constants

Global Const $sTmpDir = _TempFile(@TempDir, '~', '')

Global Const $sConfig_File = @ScriptDir & '\' & (@Compiled ? '' : '..\') & 'Config.ini'
Global Const $sIcons_File = $sTmpDir & '\Icons.icl'
Global Const $sFlagsIcons_File = $sTmpDir & '\Flags.icl'
Global Const $sSound_File = $sTmpDir & '\About.mid'
Global Const $sYandex_Img = $sTmpDir & '\Yandex.png'

Global Const $sUserAgent = 'Opera/9.80 (Windows NT 6.1) Presto/2.12.388 Version/12.17'
Global Const $sGoogleMain_Server = 'translate.google.com'
Global Const $sGoogleTranslate_Server = 'translate.googleusercontent.com'

Global Const $sApp_Title = _GetResData('ProductName')
Global Const $sApp_Ver = _GetResData('ProductVersion')
Global Const $sApp_Desc = _GetResData('FileDescription')

Global Const $sApp_History = _
	'v0.7' & @CRLF & _
	'* Fixed issue with not saved Speaker selection.' & @CRLF & _
	'* Speaker now can be selected even if "Translate by selection" is disabled.' & @CRLF & _
	'' & @CRLF & _
	'v0.6' & @CRLF & _
	'+ Added "Translate by selection" option.' & @CRLF & _
	'+ Added Speak option (using Yandex SpeechKit).' & @CRLF & _
	'+ Added "Settings" dialog (with few basic options).' & @CRLF & _
	'+ Added "About" dialog.' & @CRLF & _
	'' & @CRLF & _
	'v0.5' & @CRLF & _
	'+ Added "Translate while typing" option.' & @CRLF & _
	'* Removed chars limits (thanks to madmasles).' & @CRLF & _
	'* Better language change handling.' & @CRLF & _
	'' & @CRLF & _
	'v0.4' & @CRLF & _
	'* Fixed issue with translating to unicode languages not from Autodetect mode (thanks to Garrett & madmasles).' & @CRLF & _
	'* Now changing program language does not requires restart.' & @CRLF & _
	'* Now language selection should be restored correctly after changing program language.' & @CRLF & _
	'* Now the languages dropdown sorted in alphabetic order.' & @CRLF & _
	'' & @CRLF & _
	'v0.3' & @CRLF & _
	'* Fixed main translation module.' & @CRLF & _
	'* _HTTPRead replaced with InetGet (there is an issue to get page source code from https).' & @CRLF & _
	'+ Added program languages support.' & @CRLF & _
	'+ Added icons to language dropdown (thanks to madmasles).' & @CRLF & _
	'+ Added RTL transforming support.' & @CRLF & _
	'+ Better unicode handling.' & @CRLF & _
	'' & @CRLF & _
	'v0.2' & @CRLF & _
	'* Fixed translation url.' & @CRLF & _
	'' & @CRLF & _
	'v0.1' & @CRLF & _
	'* First release' & @CRLF

Global Const $iGUI_Width = 480
Global Const $iGUI_Height = 500

Global $iMouse_X_Position = MouseGetPos(0)
Global $bText_Selected = False
Global $bText_Speaking = False
Global $hGUI = 0
Global $hSpeaker = 0
Global $hToolTip = 0

Global $sDef_App_Language = 'English'
Global $sDef_TrnsltTo_Language = 'English'
Global $iDef_TranslateWhileType = 0
Global $iDef_StartWithWindows = Number(RegRead('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run', $sApp_Title) <> '')
Global $iDef_StartMinimized = 0
Global $iDef_MinToTray = 1
Global $iDef_SetOnTop = 0
Global $iDef_TranslateBySel = 0
Global $iDef_SpeakSelTranslation = 0
Global $sDef_TranslationSpeaker = 'zahar'
Global $iDef_GetLangsDataIntrvl = 72

Global $sApp_Language = _IniReadEx($sConfig_File, 'Main Prefs', 'Language', $sDef_App_Language)
Global $aTXT = _AppTranslation_Register($LANGS_DIR & '\' & $sApp_Language & '.lng')
Global $aApp_Langs = _AppTranslation_GetLanguages($LANGS_DIR, True)
Global $sApp_Name = $aTXT[$iMSG_sApp_Name_GoogleTranslator]

Global $iTranslateWhileType = _IniReadEx($sConfig_File, 'Translate Prefs', 'Translate While Typing', $iDef_TranslateWhileType)
Global $sTranslateFrom = _IniReadEx($sConfig_File, 'Translate Prefs', 'Translate From', $aTXT[$iMSG__GUICtrlComboBo_odetectLanguage])
Global $sTranslateTo = _IniReadEx($sConfig_File, 'Translate Prefs', 'Translate To', $sDef_TrnsltTo_Language)
Global $sTranslateFrom_Text = _IniReadEx($sConfig_File, 'Translate Prefs', 'Translate Text', $aTXT[$iMSG_SimpleTranslator])

Global $iStartWithWindows = _IniReadEx($sConfig_File, 'Main Prefs', 'Start With Windows', $iDef_StartWithWindows)
Global $iStartMinimized = _IniReadEx($sConfig_File, 'Main Prefs', 'Start Minimized', $iDef_StartMinimized)
Global $iMinToTray = _IniReadEx($sConfig_File, 'Main Prefs', 'Minimize To Tray', $iDef_MinToTray)
Global $iSetOnTop = _IniReadEx($sConfig_File, 'Main Prefs', 'Set On Top', $iDef_SetOnTop)
Global $iTranslateBySel = _IniReadEx($sConfig_File, 'Translate Prefs', 'Translate By Selection', $iDef_TranslateBySel)
Global $iSpeakSelTranslation = _IniReadEx($sConfig_File, 'Translate Prefs', 'Speak Selected Translation', $iDef_SpeakSelTranslation)
Global $sTranslationSpeaker = _IniReadEx($sConfig_File, 'Translate Prefs', 'Translation Speaker', $sDef_TranslationSpeaker)
Global $iGetLangsDataIntrvl = _IniReadEx($sConfig_File, 'Main Prefs', 'Get Langs Data Interval', $iDef_GetLangsDataIntrvl)

DirCreate($sTmpDir)

FileInstall('Resources\Icons.icl', $sIcons_File, 1)
FileInstall('Resources\Flags.icl', $sFlagsIcons_File, 1)
FileInstall('Resources\About.mid', $sSound_File, 1)
FileInstall('Resources\Yandex.png', $sYandex_Img, 1)

TCPStartup()
HttpSetUserAgent($sUserAgent)
OnAutoItExitRegister('_OnExit_Event')

Global $hSound = _SoundOpen($sSound_File)
Global $hImageList = _GUIImageList_Create(16, 16, 5, BitOR($ILC_MASK, $ILC_COLOR32), 1)
Global $oSAPI = ObjCreate('SAPI.SpVoice')
Global $aTranslate_Langs = _GoogleTranslateGetLangs()

_GUIImageList_AddIcon($hImageList, $sIcons_File, 0, 0)
_SetMouseEvents(True)

#EndRegion Variables and Constants

#Region Tray

Opt('TrayOnEventMode', 1)
Opt('TrayMenuMode', 3)
TraySetClick(16)

$iAbout_TrayItem = TrayCreateItem($aTXT[$iMSG_GUICtrlCreateButton_About] & ' ' & $sApp_Name)
TrayItemSetOnEvent($iAbout_TrayItem, '_Tray_Events')

TrayCreateItem('')

$iShowApp_TrayItem = TrayCreateItem(StringFormat($aTXT[$iMSG_TrayCreateItem_Show], $sApp_Name))
TrayItemSetOnEvent($iShowApp_TrayItem, '_Tray_Events')
TrayItemSetState($iShowApp_TrayItem, $TRAY_DEFAULT)

$iSettings_TrayItem = TrayCreateItem($aTXT[$iMSG_Settings_Title])
TrayItemSetOnEvent($iSettings_TrayItem, '_Tray_Events')

TrayCreateItem('')

$iExit_TrayItem = TrayCreateItem($aTXT[$iMSG_TrayCreateItem_Exit])
TrayItemSetOnEvent($iExit_TrayItem, '_Tray_Events')

If $iStartMinimized Then
	TraySetState(1)
	TraySetIcon($sIcons_File, 0)
	TraySetToolTip($sApp_Name & ' v' & $sApp_Ver)
EndIf

#EndRegion

#Region GUI

$hGUI = GUICreate($sApp_Name & ' v' & $sApp_Ver, $iGUI_Width, $iGUI_Height, -1, -1, -1, ($iSetOnTop ? $WS_EX_TOPMOST : -1))
GUISetIcon($sIcons_File, 0, $hGUI)

$nLangsFrom_Label = GUICtrlCreateLabel($aTXT[$iMSG_GUICtrlCreateLa_l_TranslateFrom], 20, 12, 100, 15)
$hLangsFrom_ComboBox = _GUICtrlComboBoxEx_Create($hGUI, '', $iGUI_Width - 240, 10, 200, 250, $CBS_DROPDOWNLIST)
_GUICtrlComboBoxEx_SetLangs($hLangsFrom_ComboBox, $sTranslateFrom, $aTXT[$iMSG__GUICtrlComboBo_odetectLanguage])

$nLangsTo_Label = GUICtrlCreateLabel($aTXT[$iMSG_GUICtrlCreateLabel_TranslateTo], 20, 37, 100, 15)
$hLangsTo_ComboBox = _GUICtrlComboBoxEx_Create($hGUI, '', $iGUI_Width - 240, 35, 200, 250, $CBS_DROPDOWNLIST)
_GUICtrlComboBoxEx_SetLangs($hLangsTo_ComboBox, $sTranslateTo)

$nInvertLangs_Btn = GUICtrlCreateButton('', $iGUI_Width - 38, 9, 21, 48, $BS_ICON)
GUICtrlSetImage($nInvertLangs_Btn, $sIcons_File, 2, 0)

$nTranslateFrom_Label = GUICtrlCreateLabel($aTXT[$iMSG_GUICtrlCreateLa_l_TranslateText], 20, 80, 300, 15)
$nTranslateFrom_Edit = GUICtrlCreateEdit(StringFormat($sTranslateFrom_Text), 20, 100, $iGUI_Width - 40, 120, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))

$nTranslateWhileType_CB = GUICtrlCreateCheckbox($aTXT[$iMSG_GUICtrlCreateChckBox_TrnsltWhileType], 20, 220, 220, 20)
If $iTranslateWhileType = 1 Then GUICtrlSetState($nTranslateWhileType_CB, $GUI_CHECKED)

$nMoveUpText_Btn = GUICtrlCreateButton('', $iGUI_Width - 40, $iGUI_Height - 240, 20, 25, $BS_ICON)
GUICtrlSetImage($nMoveUpText_Btn, $sIcons_File, 3, 0)

$nTranslateTo_Label = GUICtrlCreateLabel($aTXT[$iMSG_GUICtrlCreateLa_TranslateResult], 20, $iGUI_Height - 230, 300, 15)
$nTranslateTo_Edit = GUICtrlCreateEdit('', 20, $iGUI_Height - 210, $iGUI_Width - 40, 120, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))

$nSpeak_Btn = GUICtrlCreateButton('', 20, $iGUI_Height - 80, 25, 25, $BS_ICON)
GUICtrlSetImage($nSpeak_Btn, $sIcons_File, 5, 0)
GUICtrlSetTip($nSpeak_Btn, $aTXT[$iMSG_GUICtrlSetTip_Speak])

If Not IsObj($oSAPI) Then
	GUICtrlSetState($nSpeak_Btn, $GUI_DISABLE)
EndIf

$nAbout_Btn = GUICtrlCreateButton($aTXT[$iMSG_GUICtrlCreateButton_About], $iGUI_Width - 340, $iGUI_Height - 70, 100, 25)
$nSettings_Btn = GUICtrlCreateButton($aTXT[$iMSG_GUICtrlCreateButton_Settings], $iGUI_Width - 230, $iGUI_Height - 70, 80, 25)
$nTranslate_Btn = GUICtrlCreateButton($aTXT[$iMSG_GUICtrlCreateButton_Translate], $iGUI_Width - 90, $iGUI_Height - 70, 70, 25, BitOR($GUI_SS_DEFAULT_BUTTON, $BS_DEFPUSHBUTTON))
$nTranslate_Dummy = GUICtrlCreateDummy()

GUICtrlCreateLabel('', 10, $iGUI_Height - 35, $iGUI_Width - 20, 2, $SS_SUNKEN)

$nStatus_Label = GUICtrlCreateLabel('', 20, $iGUI_Height - 30, $iGUI_Width - 40, 28)
GUICtrlSetFont(-1, 8.5, 800)
GUICtrlSetColor(-1, 0x0000FF)

GUISetState(($iStartMinimized ? @SW_HIDE : @SW_SHOW), $hGUI)
GUIRegisterMsg($WM_COMMAND, 'WM_COMMAND')

#EndRegion GUI

#Region Main Loop

While 1
	$nMsg = GUIGetMsg()
	
	If $bText_Selected Then
		$nMsg = $nTranslate_Dummy
	EndIf
	
	If $bText_Speaking And Not BitAND(WinGetState($hToolTip), 2) Then
		$bText_Speaking = False
		_Speak_Stop()
	EndIf
	
	Switch $nMsg
		Case $GUI_EVENT_MINIMIZE
			If $iMinToTray Then
				GUISetState(@SW_HIDE, $hGUI)
				TraySetState(1)
				TraySetIcon($sIcons_File, 0)
				TraySetToolTip($sApp_Name & ' v' & $sApp_Ver)
			EndIf
		Case $GUI_EVENT_CLOSE
			Exit
		Case $nAbout_Btn
			_About_GUI($aTXT[$iMSG_GUICtrlCreateButton_About] & ' ' & $sApp_Title, $hGUI)
		Case $nSettings_Btn
			_Settings_GUI($aTXT[$iMSG_Settings_Title], $hGUI)
		Case $nInvertLangs_Btn
			Local $iLangFrom = _GUICtrlComboBoxEx_GetCurSel($hLangsFrom_ComboBox)
			Local $iLangTo = _GUICtrlComboBoxEx_GetCurSel($hLangsTo_ComboBox)
			
			If $iLangFrom > 0 Then
				_GUICtrlComboBoxEx_SetCurSel($hLangsFrom_ComboBox, $iLangTo + 1)
				_GUICtrlComboBoxEx_SetCurSel($hLangsTo_ComboBox, $iLangFrom - 1)
			EndIf
		Case $nMoveUpText_Btn
			Local $sTranslateTo_Text = GUICtrlRead($nTranslateTo_Edit)
			
			If $sTranslateTo_Text <> '' Then
				GUICtrlSetData($nTranslateTo_Edit, '')
				GUICtrlSetData($nTranslateFrom_Edit, $sTranslateTo_Text)
				
				If _WinAPI_GetWindowLong(GUICtrlGetHandle($nTranslateTo_Edit), $GWL_EXSTYLE) <> $WS_EX_CLIENTEDGE Then
					GUICtrlSetStyle($nTranslateFrom_Edit, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL), BitOR($WS_EX_CLIENTEDGE, $WS_EX_LAYOUTRTL))
				Else
					GUICtrlSetStyle($nTranslateFrom_Edit, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL), $WS_EX_CLIENTEDGE)
				EndIf
			EndIf
		Case $nSpeak_Btn
			_Speak_Stop()
			
			$aLangs = _Translate_GetComboLangs()
			$sLang_To = (@error ? 'en' : $aLangs[1])
			
			_Speak_Start(GUICtrlRead($nTranslateTo_Edit), $sLang_To)
		Case $nTranslateWhileType_CB
			If GUICtrlRead($nTranslateWhileType_CB) = $GUI_CHECKED Then
				$nMsg = $nTranslate_Dummy
				ContinueCase
			EndIf
		Case $nTranslate_Btn, $nTranslate_Dummy
			$bTxtSel = $bText_Selected
			$bText_Selected = False
			
			GUIRegisterMsg($WM_COMMAND, '')
			
			If Not $bTxtSel Then
				GUICtrlSetBkColor($nTranslateTo_Edit, 0xFFD7D7)
				GUICtrlSetData($nTranslateTo_Edit, '')
				GUICtrlSetState($nTranslate_Btn, $GUI_DISABLE)
				_SetStatusData($aTXT[$iMSG_GUICtrlSetData_PleaseWait])
			EndIf
			
			Local $s_Langs
			Local $sText = _Translate_Proc($bTxtSel, $s_Langs)
			Local $iError = @error, $iExtended = @extended
			
			If Not $bTxtSel Then
				GUICtrlSetState($nTranslate_Btn, $GUI_ENABLE)
				GUICtrlSetBkColor($nTranslateTo_Edit, 0xFFFFFF)
				_SetStatusData($aTXT[$iMSG_GUICtrlSetData_Done], 5000)
			EndIf
			
			If Not $iError Then
				If $bTxtSel Then
					_GUIToolTipEx_Create($sApp_Name & ' (' & $s_Langs & ')', $sText, -1, -1, BitOR($TTS_BALLOON, $TTS_CLOSE, $TTS_NOPREFIX, $TTS_ALWAYSTIP), ($iError ? $TTI_WARNING : $TTI_INFO))
					
					If $iSpeakSelTranslation Then
						$bText_Speaking = True
						
						$aLangs = _Translate_GetComboLangs()
						$sLang_To = (@error ? 'en' : $aLangs[1])
						
						_Speak_Stop()
						_Speak_Start($sText, $sLang_To)
					EndIf
				Else
					If $iExtended Then
						GUICtrlSetStyle($nTranslateTo_Edit, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL), BitOR($WS_EX_CLIENTEDGE, $WS_EX_LAYOUTRTL))
					Else
						GUICtrlSetStyle($nTranslateTo_Edit, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL), $WS_EX_CLIENTEDGE)
					EndIf
					
					GUICtrlSetData($nTranslateTo_Edit, $sText)
				EndIf
			Else
				If $bTxtSel Then
					If $iError = 1 Then
						;Unable to get selected text
					EndIf
				Else
					Switch $iError
						Case -1
							_SetStatusData(StringFormat($aTXT[$iMSG_MsgBox_ServerIsOffline], $sGoogleMain_Server) & ($iExtended <> 0 ? (@CRLF & $aTXT[$iMSG_MsgBox_CheckInetConn]) : ''), 3000)
						Case 2
							_SetStatusData($aTXT[$iMSG_MsgBox_NothingToTranslate], 3000)
							GUICtrlSetData($nTranslateTo_Edit, '')
						Case 3
							_SetStatusData($aTXT[$iMSG_MsgBox_SetDiffe_ationDirections], 3000)
						Case 4
							_SetStatusData($sText, 3000)
					EndSwitch
				EndIf
			EndIf
			
			GUIRegisterMsg($WM_COMMAND, 'WM_COMMAND')
	EndSwitch
WEnd

#EndRegion Main Loop

#Region Program Functions

Func _OnExit_Event()
	GUISetState(@SW_HIDE, $hGUI)
	
	_GUIImageList_Destroy($hImageList)
	
	If @exitCode <> -1 Then
		_IniWriteEx($sConfig_File, 'Translate Prefs', 'Translate While Typing', Number(GUICtrlRead($nTranslateWhileType_CB) = $GUI_CHECKED))
		_IniWriteEx($sConfig_File, 'Translate Prefs', 'Translate From', ControlCommand($hGUI, '', $hLangsFrom_ComboBox, 'GetCurrentSelection'))
		_IniWriteEx($sConfig_File, 'Translate Prefs', 'Translate To', ControlCommand($hGUI, '', $hLangsTo_ComboBox, 'GetCurrentSelection'))
		_IniWriteEx($sConfig_File, 'Translate Prefs', 'Translate Text', StringReplace(GUICtrlRead($nTranslateFrom_Edit), @CRLF, '\r\n'))
	EndIf
	
	DirRemove($sTmpDir, 1)
EndFunc

Func _Tray_Events()
	TraySetState(2)
	
	Switch @TRAY_ID
		Case $iShowApp_TrayItem
			GUISetState(@SW_SHOWNORMAL, $hGUI)
		Case $iAbout_TrayItem
			_About_GUI($aTXT[$iMSG_GUICtrlCreateButton_About] & ' ' & $sApp_Title, $hGUI)
		Case $iSettings_TrayItem
			_Settings_GUI($aTXT[$iMSG_Settings_Title], $hGUI)
		Case $iExit_TrayItem
			Exit
	EndSwitch
	
	If Not BitAND(WinGetState($hGUI), 2) Then
		TraySetState(1)
		TraySetIcon($sIcons_File, 0)
		TraySetToolTip($sApp_Name & ' v' & $sApp_Ver)
	EndIf
EndFunc

Func _Translate_Proc($bTxtSel, ByRef $s_Langs)
	If Not _GoogleTranslateServerIsOnline() Then
		Return SetError(-1, @error, '')
	EndIf
	
	Local $sText
	
	If $bTxtSel Then
		$sText = _ClipBoard_GetSelText()
		
		If @error Then
			Return SetError(1, 0, '')
		EndIf
	Else
		$sText = GUICtrlRead($nTranslateFrom_Edit)
	EndIf
	
	If StringStripWS($sText, 8) = '' Then
		Return SetError(2, 0, '')
	EndIf
	
	Local $aLangs = _Translate_GetComboLangs()
	
	If @error Then
		Return SetError(3, 0, '')
	EndIf
	
	Local $sLang_From = $aLangs[0]
	Local $sLang_To = $aLangs[1]
	Local $sLang_From_Combo = $aLangs[2]
	Local $sLang_To_Combo = $aLangs[3]
	
	$sResult = _GoogleTranslateString($sText, $sLang_From, $sLang_To)
	Local $iIsRTL = @extended
	
	If @error Then
		Return SetError(4, 0, $sResult)
	EndIf
	
	$s_Langs = ($sLang_From = 'auto' ? '' : $sLang_From_Combo & ' --> ') & $sLang_To_Combo
	
	Return SetExtended($iIsRTL, $sResult)
EndFunc

Func _Translate_GetComboLangs()
	Local $iLangFrom, $iLangTo, $sLang_From, $sLang_To
	Local $sLang_From_Combo, $sLang_To_Combo, $iLng_Col
	
	$iLangFrom = _GUICtrlComboBoxEx_GetCurSel($hLangsFrom_ComboBox)
	$iLangTo = _GUICtrlComboBoxEx_GetCurSel($hLangsTo_ComboBox)
	
	_GUICtrlComboBoxEx_GetItemText($hLangsFrom_ComboBox, $iLangFrom, $sLang_From)
	_GUICtrlComboBoxEx_GetItemText($hLangsTo_ComboBox, $iLangTo, $sLang_To)
	
	$sLang_From_Combo = $sLang_From
	$sLang_To_Combo = $sLang_To
	
	If $sLang_From = $sLang_To Then
		Return SetError(1)
	EndIf
	
	$iLng_Col = _ArraySearchCol($aTranslate_Langs, $sApp_Language, 0, 2, 1)
	
	$iLangFrom = _ArraySearch($aTranslate_Langs, $sLang_From, 1, 0, 0, 2, 1, $iLng_Col)
	$iLangTo = _ArraySearch($aTranslate_Langs, $sLang_To, 1, 0, 0, 2, 1, $iLng_Col)
	
	$sLang_From = ($iLangFrom = -1) ? 'auto' : $aTranslate_Langs[$iLangFrom][0]
	$sLang_To = ($iLangTo = -1) ? 'auto' : $aTranslate_Langs[$iLangTo][0]
	
	Local $aRet[4] = [$sLang_From, $sLang_To, $sLang_From_Combo, $sLang_To_Combo]
	Return $aRet
EndFunc

Func _SoundPlay_Proc($sAction)
	If Not IsArray($hSound) Then
		Return
	EndIf
	
	Switch $sAction
		Case $ABX_SOUND_PLAY
			_SoundResume($hSound)
			If @error Then _SoundPlay($hSound)
		Case $ABX_SOUND_PAUSE
			_SoundPause($hSound)
	EndSwitch
EndFunc

Func _SetMouseEvents($bSet)
	_MouseSetOnEvent_RI($MOUSE_SECONDARYDOWN_EVENT, ($bSet ? '_MouseDown_Event' : ''))
	_MouseSetOnEvent_RI($MOUSE_PRIMARYDOWN_EVENT, ($bSet ? '_MouseDown_Event' : ''))
	_MouseSetOnEvent_RI($MOUSE_PRIMARYUP_EVENT, ($bSet ? '_MouseUp_Event' : ''))
	_MouseSetOnEvent_RI($MOUSE_PRIMARYDBLCLK_EVENT, ($bSet ? '_MouseUp_Event' : ''))
EndFunc

Func _MouseDown_Event($iEvent)
	If BitAND(WinGetState($hToolTip), 2) Then
		_GUIToolTip_Destroy($hToolTip)
		$hToolTip = 0
	EndIf
	
	If $iEvent = $MOUSE_SECONDARYDOWN_EVENT Then
		Return
	EndIf
	
	If $iTranslateBySel = 0 Or BitAND(WinGetState($hGUI), 8) Then
		Return
	EndIf
	
	$iMouse_X_Position = MouseGetPos(0)
EndFunc

Func _MouseUp_Event($iEvent)
	If $iTranslateBySel = 0 Or BitAND(WinGetState($hGUI), 8) Then
		Return
	EndIf
	
	If $iEvent = $MOUSE_PRIMARYDBLCLK_EVENT Or ($iEvent <> $MOUSE_PRIMARYDBLCLK_EVENT And $iMouse_X_Position <> MouseGetPos(0)) Then
		$bText_Selected = True
	EndIf
EndFunc

Func _About_GUI($sTitle, $hParent)
	Local $iLinkColor, $iBkColor, $aData[5], $aHyperLinks[3], $bVisible
	
	$iLinkColor = 0x0000FF
	$iBkColor = 0xFFFFFF
	
	$aData[0] = $sApp_Name
	$aData[1] = $aTXT[$iMSG_About_Version] & ': ' & @CRLF & 'v' & $sApp_Ver
	$aData[2] = _
		$sApp_Desc & '(Georgia,12,0xFF0000)\n\n\n\n\n\nCREDITS:(Georgia,12,0x000000)\n\n\nGoogle (Translation module)(Impact,15)\n\n' & _
		'Yandex(Impact,15)\n(using "Yandex SpeechKit Cloud")(Impact,15)\n(https://tech.yandex.ru/speechkit/cloud)(Impact,8)\n<img width=50 height=23>' & $sYandex_Img & '</img>\n\n' & _
		'Stephen Podhajecki(Impact,16)\n\nAZJIO(Impact,16)\n\nmadmasles(Impact,16)\n\n\n\n\n\n\n' & _
		'HISTORY:(Georgia,12,0x000000)\n' & _GetHistoryData($sApp_History)
	
	$aData[3] = _GetResData('LegalCopyright')
	$aData[4] = $aTXT[$iMSG_About_PlaySound]
	
	$aHyperLinks[0] = UBound($aHyperLinks) - 1
	$aHyperLinks[1] = 'AutoIt Russian Community|http://autoit-script.ru'
	$aHyperLinks[2] = _GetResData('CompanyName') & '|http://creator-lab.ucoz.ru'
	
	$bVisible = (BitAND(WinGetState($hParent), 2) = 2)
	
	_AboutBox($sTitle, $aData, $aHyperLinks, $hParent, $sIcons_File, $iLinkColor, $iBkColor, 1, -1, ($bVisible ? -1 : $WS_EX_APPWINDOW), '', '_SoundPlay_Proc')
	_SoundStop($hSound)
EndFunc

#Region _Settings_GUI

Volatile Func _Settings_GUI($sTitle, $hParent, $iWidth = 450, $iHeight = 300)
	Local $hSttngs_GUI, $iStartWithWindows_CB, $iStartMinimized_CB, $iMinToTray_CB, $iSetOnTop_CB, $iTranslateBySel_CB, $iGetLangsDataIntrvl_Input, $iLang_Combo, $iOK_Bttn, $iCancel_Bttn, $iMsg
	Local $bVisible = (BitAND(WinGetState($hParent), 2) = 2)
	
	GUISetState(@SW_DISABLE, $hParent)
	$hSttngs_GUI = GUICreate($sTitle, $iWidth, $iHeight, -1, -1, -1, BitOR(($bVisible ? 0 : $WS_EX_APPWINDOW), $WS_EX_TOOLWINDOW), $hParent)
	
	$iStartWithWindows_CB = GUICtrlCreateCheckbox($aTXT[$iMSG_Settings_StartWithWindows], 20, 20)
	GUICtrlSetState(-1, ($iStartWithWindows = 1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	
	$iStartMinimized_CB = GUICtrlCreateCheckbox($aTXT[$iMSG_Settings_StartMinimized], 20, 40)
	GUICtrlSetState(-1, ($iStartMinimized = 1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	
	$iMinToTray_CB = GUICtrlCreateCheckbox($aTXT[$iMSG_Settings_MinimizeToTray], 20, 60)
	GUICtrlSetState(-1, ($iMinToTray = 1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	
	$iSetOnTop_CB = GUICtrlCreateCheckbox($aTXT[$iMSG_Settings_SetOnTop], 20, 80)
	GUICtrlSetState(-1, ($iSetOnTop = 1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	
	$iTranslateBySel_CB = GUICtrlCreateCheckbox($aTXT[$iMSG_Settings_TranslateBySelection], 20, 100)
	GUICtrlSetState(-1, ($iTranslateBySel = 1 ? $GUI_CHECKED : $GUI_UNCHECKED))
	
	$iSpeakSelTranslation_CB = GUICtrlCreateCheckbox($aTXT[$iMSG_Settings_SpeakSelTranslation], 20, 120)
	GUICtrlSetState(-1, BitOR(($iSpeakSelTranslation = 1 ? $GUI_CHECKED : $GUI_UNCHECKED), ($iTranslateBySel = 1 ? $GUI_ENABLE : $GUI_DISABLE)))
	
	GUICtrlCreateLabel($aTXT[$iMSG_Settings_TranslationSpeaker], $iWidth - 150, 123, 60, 15)
	$iTranslationSpeaker_Combo = GUICtrlCreateCombo('', $iWidth - 90, 120, 70, 50, BitOr($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
	GUICtrlSetData(-1, 'zahar|ermil|jane|omazh', ($sTranslationSpeaker ? $sTranslationSpeaker : 'zahar'))
	;GUICtrlSetState(-1, ($iTranslateBySel = 1 ? $GUI_ENABLE : $GUI_DISABLE))
	
	GUICtrlCreateLabel($aTXT[$iMSG_Settings_GetLangsDataIntrvl], 20, 162)
	$iGetLangsDataIntrvl_Input = GUICtrlCreateInput($iGetLangsDataIntrvl, $iWidth - 175, 160, 45, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
	GUICtrlCreateUpdown($iGetLangsDataIntrvl_Input)
	GUICtrlSetLimit(-1, 8760, 0)
	GUICtrlCreateLabel($aTXT[$iMSG_Settings_0ToGetAlways], $iWidth - 120, 162, 120)
	GUICtrlSetColor(-1, 0x818181)
	
	GUICtrlCreateLabel('Language:', 20, $iHeight - 100)
	$iLang_Combo = GUICtrlCreateCombo('', 110, $iHeight - 102, 150, 50, BitOr($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
	GUICtrlSetData($iLang_Combo, _AppTranslation_GetLanguages($LANGS_DIR), $sApp_Language)
	
	$iOK_Bttn = GUICtrlCreateButton($aTXT[$iMSG_Settings_OK], 20, $iHeight - 30, 70, 20)
	$iCancel_Bttn = GUICtrlCreateButton($aTXT[$iMSG_Settings_Cancel], 100, $iHeight - 30, 70, 20)
	
	GUISetState(@SW_SHOW, $hSttngs_GUI)
	
	While 1
		$iMsg = GUIGetMsg()
		
		Switch $iMsg
			Case $GUI_EVENT_CLOSE, $iCancel_Bttn
				ExitLoop
			Case $iTranslateBySel_CB
				Local $iState = (GUICtrlRead($iTranslateBySel_CB) = $GUI_CHECKED ? $GUI_ENABLE : $GUI_DISABLE)
				
				GUICtrlSetState($iSpeakSelTranslation_CB, $iState)
				;GUICtrlSetState($iTranslationSpeaker_Combo, $iState)
			Case $iOK_Bttn
				$iStartWithWindows = Number(GUICtrlRead($iStartWithWindows_CB) = $GUI_CHECKED)
				$iStartMinimized = Number(GUICtrlRead($iStartMinimized_CB) = $GUI_CHECKED)
				$iMinToTray = Number(GUICtrlRead($iMinToTray_CB) = $GUI_CHECKED)
				$iSetOnTop = Number(GUICtrlRead($iSetOnTop_CB) = $GUI_CHECKED)
				$iTranslateBySel = Number(GUICtrlRead($iTranslateBySel_CB) = $GUI_CHECKED)
				$iSpeakSelTranslation = Number(GUICtrlRead($iSpeakSelTranslation_CB) = $GUI_CHECKED)
				$sTranslationSpeaker = GUICtrlRead($iTranslationSpeaker_Combo)
				$iGetLangsDataIntrvl = GUICtrlRead($iGetLangsDataIntrvl_Input)
				
				If $iStartWithWindows Then
					RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run', $sApp_Title, 'REG_SZ', FileGetShortName(@AutoItExe) & (@Compiled ? '' : ' /AutoIt3ExecuteScript "' & @ScriptFullPath & '"'))
				Else
					RegDelete('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run', $sApp_Title)
				EndIf
				
				If $iSetOnTop Then
					WinSetOnTop($hParent, '', 1)
				Else
					WinSetOnTop($hParent, '', 0)
				EndIf
				
				If $iGetLangsDataIntrvl <> _IniReadEx($sConfig_File, 'Main Prefs', 'Get Langs Data Interval', $iDef_GetLangsDataIntrvl) Then
					_IniWriteEx($sConfig_File, 'Main Prefs', 'Get Langs Data TimeStamp', 0)
				EndIf
				
				_IniWriteEx($sConfig_File, 'Main Prefs', 'Start With Windows', $iStartWithWindows)
				_IniWriteEx($sConfig_File, 'Main Prefs', 'Start Minimized', $iStartMinimized)
				_IniWriteEx($sConfig_File, 'Main Prefs', 'Minimize To Tray', $iMinToTray)
				_IniWriteEx($sConfig_File, 'Main Prefs', 'Set On Top', $iSetOnTop)
				_IniWriteEx($sConfig_File, 'Translate Prefs', 'Translate By Selection', $iTranslateBySel)
				_IniWriteEx($sConfig_File, 'Translate Prefs', 'Speak Selected Translation', $iSpeakSelTranslation)
				_IniWriteEx($sConfig_File, 'Translate Prefs', 'Translation Speaker', $sTranslationSpeaker)
				_IniWriteEx($sConfig_File, 'Main Prefs', 'Get Langs Data Interval', $iGetLangsDataIntrvl)
				
				Local $sLang = GUICtrlRead($iLang_Combo)
				
				If $sLang <> $sApp_Language Then
					$aTXT = _AppTranslation_Register($LANGS_DIR & '\' & $sLang & '.lng')
					
					$iLng_Col_Old = _ArraySearchCol($aTranslate_Langs, $sApp_Language, 0, 2, 1) ;Must be placed before applying $sApp_Language = $sLang
					$iLng_Col_New = _ArraySearchCol($aTranslate_Langs, $sLang, 0, 2, 1)
					
					$sApp_Language = $sLang
					$sApp_Name = $aTXT[$iMSG_sApp_Name_GoogleTranslator]
					
					$sTranslateFrom = ControlCommand($hParent, '', $hLangsFrom_ComboBox, 'GetCurrentSelection')
					$sTranslateTo = ControlCommand($hParent, '', $hLangsTo_ComboBox, 'GetCurrentSelection')
					
					$iFind_LangFrom = _ArraySearch($aTranslate_Langs, $sTranslateFrom, 1, 0, 0, 2, 1, $iLng_Col_Old)
					$iFind_LangTo = _ArraySearch($aTranslate_Langs, $sTranslateTo, 1, 0, 0, 2, 1, $iLng_Col_Old)
					
					If $iFind_LangFrom <> -1 Then
						$sTranslateFrom = $aTranslate_Langs[$iFind_LangFrom][$iLng_Col_New]
					Else
						$sTranslateFrom = $aTXT[$iMSG__GUICtrlComboBo_odetectLanguage]
					EndIf
					
					$sTranslateTo = $aTranslate_Langs[($iFind_LangTo = -1 ? 1 : $iFind_LangTo)][$iLng_Col_New]
					
					_GUIImageList_Remove($hImageList, -1)
					_GUIImageList_AddIcon($hImageList, $sIcons_File, 0, 0)
					
					_GUICtrlComboBoxEx_ResetContent($hLangsFrom_ComboBox)
					_GUICtrlComboBoxEx_ResetContent($hLangsTo_ComboBox)
					
					_GUICtrlComboBoxEx_SetLangs($hLangsFrom_ComboBox, $sTranslateFrom, $aTXT[$iMSG__GUICtrlComboBo_odetectLanguage])
					_GUICtrlComboBoxEx_SetLangs($hLangsTo_ComboBox, $sTranslateTo)
					
					WinSetTitle($hParent, '', $sApp_Name & ' v' & $sApp_Ver)
					TraySetToolTip($sApp_Name & ' v' & $sApp_Ver)
					TrayItemSetText($iAbout_TrayItem, $aTXT[$iMSG_GUICtrlCreateButton_About] & ' ' &  $sApp_Name)
					TrayItemSetText($iShowApp_TrayItem, StringFormat($aTXT[$iMSG_TrayCreateItem_Show], $sApp_Name))
					TrayItemSetText($iSettings_TrayItem, $aTXT[$iMSG_Settings_Title])
					TrayItemSetText($iExit_TrayItem, $aTXT[$iMSG_TrayCreateItem_Exit])
					
					GUICtrlSetData($nLangsFrom_Label, $aTXT[$iMSG_GUICtrlCreateLa_l_TranslateFrom])
					GUICtrlSetData($nLangsTo_Label, $aTXT[$iMSG_GUICtrlCreateLabel_TranslateTo])
					GUICtrlSetData($nTranslateFrom_Label, $aTXT[$iMSG_GUICtrlCreateLa_l_TranslateText])
					GUICtrlSetData($nTranslateWhileType_CB, $aTXT[$iMSG_GUICtrlCreateChckBox_TrnsltWhileType])
					GUICtrlSetData($nTranslateTo_Label, $aTXT[$iMSG_GUICtrlCreateLa_TranslateResult])
					GUICtrlSetTip($nSpeak_Btn, $aTXT[$iMSG_GUICtrlSetTip_Speak])
					GUICtrlSetData($nAbout_Btn, $aTXT[$iMSG_GUICtrlCreateButton_About])
					GUICtrlSetData($nSettings_Btn, $aTXT[$iMSG_GUICtrlCreateButton_Settings])
					GUICtrlSetData($nTranslate_Btn, $aTXT[$iMSG_GUICtrlCreateButton_Translate])
					
					_IniWriteEx($sConfig_File, 'Main Prefs', 'Language', $sApp_Language)
				EndIf
				
				ExitLoop
		EndSwitch
	WEnd
	
	GUISetState(@SW_ENABLE, $hParent)
	GUIDelete($hSttngs_GUI)
EndFunc

Func _GoogleTranslateServerIsOnline()
	Local $iTimeout = 3000, $iPort = 80
	Local $sName_To_IP = TCPNameToIP($sGoogleMain_Server)
	Local $iSocket = TCPConnect($sName_To_IP, $iPort)
	
	If $iSocket = -1 Then
		TCPCloseSocket($iSocket)
		Return SetError(1, 0, "")
	EndIf
	
	Local $sCommand = 'HEAD / HTTP/1.0' & @CRLF
	
	$sCommand &= 'Host: ' & $sGoogleMain_Server & @CRLF
	$sCommand &= 'User-Agent: ' & $sUserAgent & @CRLF
	$sCommand &= 'Connection: close' & @CRLF & @CRLF
	
	Local $iBytesSent = TCPSend($iSocket, $sCommand)
	
	If $iBytesSent = 0 Then
		Return SetError(2, @error, 0)
	EndIf
	
	Local $iTimer = TimerInit(), $sRecv = '', $sCurrentRecv = ''
	Local $iOpt_TO = Opt('TCPTimeout', $iTimeout)
	
	While 1
		$sCurrentRecv = TCPRecv($iSocket, 8192)
		
		If @error <> 0 Then
			ExitLoop
		EndIf
		
		If $sCurrentRecv <> '' Then
			$sRecv &= $sCurrentRecv
		EndIf
		
		If TimerDiff($iTimer) >= $iTimeout Then
			ExitLoop
		EndIf
	WEnd
	
	TCPCloseSocket($iSocket)
	Opt('TCPTimeout', $iOpt_TO)
	
	Return StringRegExp($sRecv, '(?i)HTTP/\d.\d (200|30[1-2])') And Not StringRegExp($sRecv, '(?i)Server: Microsoft.*')
EndFunc

Func _GoogleTranslateString($sText, $sFrom, $sTo)
	Local $sBound, $sPost, $sRecv, $sRet, $sConDis = 'Content-Disposition: form-data; name='
	Local $iTimeout = 3000, $iPort = 80
	
	$sBound = StringFormat('----------------%s%s%smzF', @MIN, @HOUR, @SEC)
	$sPost &= $sBound & @CRLF
	$sPost &= $sConDis & '"sl"' & @CRLF & @CRLF
	$sPost &= $sFrom & @CRLF
	$sPost &= $sBound & @CRLF
	$sPost &= $sConDis & '"tl"' & @CRLF & @CRLF
	$sPost &= $sTo & @CRLF
	$sPost &= $sBound & @CRLF
	$sPost &= $sConDis & '"js"' & @CRLF & @CRLF
	$sPost &= 'y' & @CRLF
	$sPost &= $sBound & @CRLF
	$sPost &= $sConDis & '"prev"' & @CRLF & @CRLF
	$sPost &= '_t' & @CRLF
	$sPost &= $sBound & @CRLF
	$sPost &= $sConDis & '"hl"' & @CRLF & @CRLF
	;$sPost &= $sLangTo & @CRLF
	$sPost &= StringLeft($sApp_Language, 2) & @CRLF
	$sPost &= $sBound & @CRLF
	$sPost &= $sConDis & '"ie"' & @CRLF & @CRLF
	$sPost &= 'UTF-8' & @CRLF
	$sPost &= $sBound & @CRLF
	$sPost &= $sConDis & '"text"' & @CRLF & @CRLF
	$sPost &= '' & @CRLF
	$sPost &= $sBound & @CRLF
	$sPost &= $sConDis & '"file"; filename="results.txt"' & @CRLF
	$sPost &= 'Content-Type: text/plain' & @CRLF & @CRLF
	$sPost &= BinaryToString(StringToBinary($sText, 4)) & @CRLF
	$sPost &= $sBound & @CRLF
	$sPost &= $sConDis & '"edit-text"' & @CRLF & @CRLF
	$sPost &= $sBound & '--' & @CRLF
	
	Local $iOpt_TO = Opt('TCPTimeout', $iTimeout)
	Local $sName_To_IP = TCPNameToIP($sGoogleTranslate_Server)
	Local $iSocket = TCPConnect($sName_To_IP, $iPort)
	
	If $iSocket = -1 Then
		TCPCloseSocket($iSocket)
		Opt('TCPTimeout', $iOpt_TO)
		Return SetError(-1, 0, 'Unable to connect to ' & $sGoogleTranslate_Server)
	EndIf
	
	Local $sCommand = 'POST /translate_f HTTP/1.1' & @CRLF
	
	$sCommand &= 'Host: ' & $sGoogleTranslate_Server & @CRLF
	$sCommand &= 'User-Agent: ' & $sUserAgent & @CRLF
	$sCommand &= 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' & @CRLF
	$sCommand &= 'Accept-Language: ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3' & @CRLF
	$sCommand &= 'Connection: close' & @CRLF
	$sCommand &= 'Content-Type: multipart/form-data; boundary=' & StringTrimLeft($sBound, 2) & @CRLF
	$sCommand &= 'Content-Length: ' & StringLen($sPost) & @CRLF & @CRLF
	$sCommand &= $sPost
	
	TCPSend($iSocket, $sCommand)
	
	While 1
		$sRecv &= TCPRecv($iSocket, 8192)
		
		If @error <> 0 Then
			ExitLoop
		EndIf
	WEnd
	
	TCPCloseSocket($iSocket)
	Opt('TCPTimeout', $iOpt_TO)
	
	$sRecv = BinaryToString(StringToBinary($sRecv), 4)
	$sRet = StringRegExpReplace($sRecv, '(?is).*?<pre>(.*?)</pre>.*', '$1')
	
	If @extended = 0 Then
		$sRet = StringRegExpReplace($sRecv, '(?is).*?<title>(.*?)</title>.*', '$1')
	EndIf
	
	$sRet = _HTMLEntities_Decode($sRet)
	
	If Not StringRegExp($sRecv, '^HTTP/1.1 200 OK') Then
		Return SetError(1, 0, $sRet)
	EndIf
	
	Return SetExtended(StringRegExp($sTo, '(?i)^(Ar|Fa|Iw|Ur|Yi)$'), $sRet)
EndFunc

Func _GoogleTranslateGetLangs()
	Local $iUbnd = UBound($aApp_Langs)
	Local $aRet[1000][$iUbnd]
	Local $vTest, $hFile, $aLangs, $iFind, $iCount
	
	Local $iTimeStamp = _IniReadEx($sConfig_File, 'Main Prefs', 'Get Langs Data TimeStamp', 0)
	Local $bLoad = (TimerDiff($iTimeStamp) >= ($iGetLangsDataIntrvl * 1000 * 60 * 60) Or ($iGetLangsDataIntrvl = 0))
	
	For $iLng = 1 To $iUbnd - 1
		If FileGetSize($LANGS_DIR & '\' & StringLeft($aApp_Langs[$iLng], 2) & '.dat') = 0 Then
			$bLoad = True
			ExitLoop
		EndIf
	Next
	
	If $bLoad Then
		_IniWriteEx($sConfig_File, 'Main Prefs', 'Get Langs Data TimeStamp', TimerInit())
		SplashTextOn($sApp_Name, $aTXT[$iMSG_SplashTextOn_LoadingTrnsModl], 600, 100, Default, Default, 32)
		
		If Not _GoogleTranslateServerIsOnline() Then
			Local $iError = @error
			
			SplashOff()
			
			MsgBox($MB_ICONWARNING, $sApp_Name & ' - ' & $aTXT[$iMSG_MsgBox_Attention], _
				StringFormat($aTXT[$iMSG_MsgBox_ServerIsOffline], $sGoogleMain_Server) & ($iError <> 0 ? (@CRLF & $aTXT[$iMSG_MsgBox_CheckInetConn]) : '') & @CRLF & @CRLF & $aTXT[$iMSG_MsgBox_OKEXIT])
			
			Exit -1
		EndIf
	EndIf
	
	For $iLng = 1 To $iUbnd - 1
		If $bLoad Then
			$vTest = BinaryToString(InetRead('https://' & $sGoogleMain_Server & '/?hl=' & StringLeft($aApp_Langs[$iLng], 2), BitOR($INET_FORCERELOAD, $INET_IGNORESSL)), 4)
			
			$hFile = FileOpen($LANGS_DIR & '\' & StringLeft($aApp_Langs[$iLng], 2) & '.dat', 128 + 2)
			FileWrite($hFile, $vTest)
			FileClose($hFile)
		Else
			$hFile = FileOpen($LANGS_DIR & '\' & StringLeft($aApp_Langs[$iLng], 2) & '.dat', 128)
			$vTest = FileRead($hFile)
			FileClose($hFile)
		EndIf
		
		$aLangs = StringRegExp($vTest, '<option\h+value=(\w{2,5})>(.*?)</option>', 3)
		
		$aRet[0][$iLng] = $aApp_Langs[$iLng]
		
		For $i = 0 To UBound($aLangs) - 1 Step 2
			If $iLng > 1 Then
				$iFind = _ArraySearch($aRet, $aLangs[$i], 1, 0, 1, 2, 1, 0)
				
				If $iFind = -1 Then
					$iFind = $iCount
				EndIf
			Else
				If _ArraySearch($aRet, $aLangs[$i], 1, 0, 1, 2, 1, 0) <> -1 Then
					ContinueLoop
				EndIf
				
				$iCount += 1
				$aRet[$iCount][0] = $aLangs[$i]
				$iFind = $iCount
			EndIf
			
			$aRet[$iFind][$iLng] = StringUpper(StringLeft($aLangs[$i + 1], 1)) & StringTrimLeft($aLangs[$i + 1], 1)
		Next
	Next
	
	ReDim $aRet[$iCount + 1][$iUbnd]
	_ArraySort($aRet, 0, 1, 0, 1)
	
	If $bLoad Then
		SplashOff()
	EndIf
	
	Return $aRet
EndFunc

Func _SetStatusData($sData, $iTime = 0)
	GUICtrlSetData($nStatus_Label, $sData)
	
	If $iTime Then
		AdlibRegister('_ClearStatusData', $iTime)
	EndIf
EndFunc

Func _ClearStatusData()
	AdlibUnRegister('_ClearStatusData')
	GUICtrlSetData($nStatus_Label, '')
EndFunc

Func _GetResData($sRes)
	If @Compiled Then
		Return FileGetVersion(@AutoItExe, $sRes)
	EndIf
	
	Return StringStripWS(_StringBetween(FileRead(@ScriptFullPath), "#pragma compile(" & $sRes & ", '", "')" & @CR)[0], 3)
EndFunc

Func _GetHistoryData($sHistory)
	$sHistory = _StringAlignment(StringStripWS($sHistory, 3), 50)
	$sHistory = StringRegExpReplace($sHistory, '([*+-])\r\n', '\1 ')
	$sHistory = StringRegExpReplace($sHistory, '([*+-])\h+', '\1 ')
	$sHistory = StringReplace($sHistory, @CR, @LF)
	$sHistory = StringReplace($sHistory, @LF & @LF, @LF)
	$sHistory = StringReplace($sHistory, @LF & 'v', @LF & @LF & 'v')
	$sHistory = StringReplace($sHistory, @LF, '(Georgia,8)\n')
	
	Return $sHistory & '(Georgia,8)'
EndFunc

Func _StringAlignment($sStr, $iWidth, $iIndent = 0, $iMaxExpand = -1, $fLastExpand = 0)
	Local $Part, $Pos, $Count = 0, $Prev = 0, $Stop = 0, $Result = '', $Tab = ''
	
	If $iIndent > 0 Then
		For $i = 1 To $iIndent
			$Tab &= @TAB
		Next
	EndIf
	
	$sStr = $Tab & StringStripWS($sStr, 7)
	
	Do
		$Pos = StringInStr($sStr, ' ', 0, 1, $Prev + 1)
		
		If Not $Pos Then
			$Pos = StringLen($sStr)
			$Stop = 1
		EndIf
		
		If $Pos > $iWidth + 1 Then
			$Part = StringLeft($sStr, $Prev - 1)
			$sStr = StringTrimLeft($sStr, $Prev)
			$Result &= _StringExpand($Part, $iWidth, $iMaxExpand) & @CRLF
			$Prev = $Pos - $Prev
			$Count += 1
		Else
			$Prev = $Pos
		EndIf
	Until $Stop
	
	If $fLastExpand And $Count Then
		$sStr = _StringExpand($sStr, $iWidth, $iMaxExpand)
	EndIf
	
	$Result &= $sStr
	
	If $iIndent > 0 Then
		$Result = StringReplace($Result, $Tab, StringReplace($Tab, @TAB, ' '), 1)
	EndIf
	
	Return $Result
EndFunc

Func _StringExpand($sStr, $iWidth, $iMaxExpand)
	Local $aWord, $Add, $Num, $Space
	
	$aWord = StringSplit($sStr, ' ')
	
	If $aWord[0] < 2 Then
		Return $sStr
	EndIf
	
	$Num = $iWidth - (StringLen($sStr) - $aWord[0] + 1)
	$Add = Mod($Num, $aWord[0] - 1)
	$Num = ($Num - $Add) / ($aWord[0] - 1)
	
	If ($iMaxExpand > 0) And ($Num >= $iMaxExpand) Then
		$Num = $iMaxExpand
		$Add = 0
	EndIf
	
	$Space = StringFormat('%' & $Num & 's', '')
	
	For $i = 1 To $Add
		$aWord[$i] &= ' '
	Next
	
	$sStr = $aWord[1]
	
	For $i = 2 To $aWord[0]
		$sStr &= $Space & $aWord[$i]
	Next
	
	Return $sStr
EndFunc

Func _ClipBoard_GetSelText()
    Local $aOld_Clip, $iTimer, $sSelText
    
    $aOld_Clip = _ClipBoard_Remember()
    
    If @error Or Not _ClipBoard_Open(0) Then
        Return SetError(1, 0, '')
    EndIf
	
    ClipPut('')
    Send('^{INS}')
    $iTimer = TimerInit()
    
    Do
        If _ClipBoard_IsFormatAvailable($CF_TEXT) Then
            $sSelText = ClipGet()
        EndIf

        Sleep(10)
    Until TimerDiff($iTimer) > 250 Or $sSelText <> ''
    
    _ClipBoard_Close()
	
	;If Not (ClipGet() == '') Then
		_ClipBoard_Restore($aOld_Clip)
	;EndIf
	
    _ClipBoard_MemFree($aOld_Clip)
    
    If StringStripWS($sSelText, 8) = '' Then
        Return SetError(2, 0, '')
    EndIf
    
    Return $sSelText
EndFunc

Func _ClipBoard_Remember()
	Local $iFormat = 0, $hMem, $hMem_New, $pSource, $pDest, $aResult, $iSize, $iErr = 0, $iErr2 = 0
	Local $avClip
	
	Dim $avClip[1][2]
	
	If Not _ClipBoard_Open(0) Then
		Return SetError(-1, 0, 0)
	EndIf
	
	Do
		$iFormat = _ClipBoard_EnumFormats($iFormat)
		
		If $iFormat <> 0 Then
			ReDim $avClip[UBound($avClip) + 1][2]
			$avClip[0][0] += 1
			; aClip[n][0] = iFormat, aClip[n][1] = hMem
			$avClip[UBound($avClip) - 1][0] = $iFormat
			$hMem = _ClipBoard_GetDataEx($iFormat)
			
			If $hMem = 0 Then
				$iErr += 1
				ContinueLoop
			EndIf
			
			$pSource = _MemGlobalLock($hMem)
			$iSize = _MemGlobalSize($hMem)
			$hMem_New = _MemGlobalAlloc($iSize, $GHND)
			$pDest = _MemGlobalLock($hMem_New)
			
			Local $aResult = DllCall("msvcrt.dll", "int:cdecl", "memcpy_s", "ptr", $pDest, "ulong_ptr", $iSize, "ptr", $pSource, "ulong_ptr", $iSize)
			
			If @error Or $aResult[0] <> 0 Then
				$iErr2 += 1
			EndIf
			
			_MemGlobalUnlock($hMem)
			_MemGlobalUnlock($hMem_New)
			$avClip[UBound($avClip) - 1][1] = $hMem_New
		EndIf
	Until $iFormat = 0
	
	_ClipBoard_Close()
	
	; Return:
	; | 0       - no errors
	; |-2       - _MemGlobalAlloc errors
	; |-4       - _MemCopyMemory errors
	; |-6       - both errors
	; @extended:
	;           - total number of errors
	Local $ErrRet = 0
	If $iErr Then $ErrRet -= 2
	If $iErr2 Then $ErrRet -= 4
	
	If $ErrRet Then
		Return SetError($ErrRet, $iErr + $iErr2, 0)
	EndIf
	
	Return $avClip
EndFunc

Func _ClipBoard_Restore(ByRef $avClip)
	; DO NOT free the memory handles after a call to this function
	; the system now owns the memory
	Local $iErr = 0
	
	If Not IsArray($avClip) Or UBound($avClip, 0) <> 2 Or $avClip[0][0] <= 0 Then
		Return SetError(-1, 0, 0)
	EndIf
	
	If Not _ClipBoard_Open(0) Then
		Return SetError(-2, 0, 0)
	EndIf
	
	If Not _ClipBoard_Empty() Then
		_ClipBoard_Close()
		Return SetError(-3, 0, 0)
	EndIf
	
	; seems to work without closing / reopening the clipboard, but MSDN implies we should do this
	; since a call to EmptyClipboard after opening with a NULL handle sets the owner to NULL,
	; and SetClipboardData is supposed to fail, so we close and reopen it to be safe
	_ClipBoard_Close()
	
	If Not _ClipBoard_Open(0) Then
		Return SetError(-3, 0, 0)
	EndIf
	
	For $i = 1 To $avClip[0][0]
		If _ClipBoard_SetDataEx($avClip[$i][1], $avClip[$i][0]) = 0 Then
			$iErr += 1
		EndIf
	Next
	
	_ClipBoard_Close()
	
	If $iErr Then
		Return SetError(-4, $iErr, 0)
	EndIf
	
	Return 1
EndFunc

Func _ClipBoard_MemFree(ByRef $avClip)
	Local $iErr = 0
	
	If Not IsArray($avClip) Or UBound($avClip, 0) <> 2 Or $avClip[0][0] <= 0 Then
		Dim $avClip[1][2]
		Return SetError(-1, 0, 0)
	EndIf
	
	For $i = 1 To $avClip[0][0]
		If Not _MemGlobalFree($avClip[$i][1]) Then
			$iErr += 1
		EndIf
	Next
	
	Dim $avClip[1][2]
	
	If $iErr Then
		Return SetError(-2, $iErr, 0)
	EndIf
	
	Return 1
EndFunc

Func _GUICtrlComboBoxEx_SetLangs($hCombo, $sDefault, $sAdd = '')
	Local $iSearch, $iImage
	
	#Region Language Icons
	
	Local $aLang_Icons[][] = [[80], _
		['af', 1], _;'za', 'South Africa', 'Южная Африка'
		['ar', 2], _;'ae', 'United Arab Emirates', 'Объединенные Арабские Эмираты'
		['az', 3], _;'az', 'Azerbaijan', 'Азербайджан'
		['be', 4], _;'by', 'Belarus', 'Беларусь'
		['bg', 5], _;'bg', 'Bulgaria', 'Болгария'
		['bn', 6], _;'in', 'India', 'Индия
		['bs', 7], _;'ba', 'Bosnia and Herzegovina', 'Босния и Герцеговина'
		['ca', 8], _;'es', 'Spain', 'Испания'
		['ceb', 65], _;ph', 'Philippines', 'Филиппины'
		['cs', 9], _;'cz', 'Czech Republic', 'Чешская Республика'
		['cy', 10], _;'Wales', 'Уэльс'
		['da', 11], _;'dk', 'Denmark', 'Дания'
		['de', 12], _;'de', 'Germany', 'Германия'
		['el', 13], _;'gr', 'Greece', 'Греция'
		['en', 14], _;14 - 'gb', 'United Kingdom', 'Великобритания' or 14_1 - 'us', 'United States', 'Соединенные Штаты'
		['eo', 15], _;eo
		['es', 8], _;'es', 'Spain', 'Испания'
		['et', 16], _;'ee', 'Estonia', 'Эстония'
		['eu', 8], _;'es', 'Spain', 'Испания'
		['fa', 17], _;'ir', 'Iran, Islamic Republic of', 'Иран, Исламская Республика'
		['fi', 18], _;'fi', 'Finland', 'Финляндия'
		['fr', 19], _;'fr', 'France', 'Франция'
		['ga', 20], _;'ie', 'Ireland', 'Ирландия'
		['gl', 8], _;'es', 'Spain', 'Испания'
		['gu', 6], _;'in', 'India', 'Индия
		['ha', 21], _;'bj', 'Benin', 'Бенин'
		['hi', 6], _;'in', 'India', 'Индия
		['hmn', 64], _;'cn', 'China', 'Китай'
		['hr', 22], _;'hr', 'Croatia', 'Хорватия'
		['ht', 23], _;'ht', 'Haiti', 'Гаити'
		['hu', 24], _;'hu', 'Hungary', 'Венгрия'
		['hy', 25], _;'am', 'Armenia', 'Армения'
		['id', 26], _;'id', 'Indonesia', 'Индонезия'
		['ig', 27], _;'ng', 'Nigeria', 'Нигерия'
		['is', 28], _;'is', 'Iceland', 'Исландия'
		['it', 29], _;'it', 'Italy', 'Италия'
		['iw', 30], _;'il', 'Israel', 'Израиль'
		['ja', 31], _;'jp', 'Japan', 'Япония'
		['jw', 26], _;'id', 'Indonesia', 'Индонезия'
		['ka', 32], _;'ge', 'Georgia', 'Грузия'
		['km', 33], _;'kh', 'Cambodia', 'Камбоджа'
		['kn', 6], _;'in', 'India', 'Индия'
		['ko', 34], _;'kr', 'Korea, Republic of', 'Южная Корея'
		['la', 35], _;'Vatican', 'Ватикан'
		['lo', 36], _;'Laos', 'Лаос'
		['lt', 37], _;'lt', 'Lithuania', 'Литва'
		['lv', 38], _;'lv', 'Latvia', 'Латвия'
		['mi', 39], _;'nz', 'New Zealand', 'Новая Зеландия'
		['mk', 40], _;'mk', 'Macedonia', 'Республика Македония'
		['mn', 41], _;'mn', 'Mongolia', 'Монголия'
		['mr', 6], _;'in', 'India', 'Индия
		['ms', 42], _;'my', 'Malaysia', 'Малайзия'
		['mt', 43], _;'mt', 'Malta', 'Мальта'
		['ne', 44], _;'np', 'Nepal', 'Непал'
		['nl', 45], _;'nl', 'Netherlands', 'Нидерланды'
		['no', 46], _;'no', 'Norway', 'Норвегия'
		['pa', 47], _;'pk', 'Pakistan', 'Пакистан'
		['pl', 48], _;'pl', 'Poland', 'Польша'
		['pt', 49], _;'pt', 'Portugal', 'Португалия'
		['ro', 50], _;'ro', 'Romania', 'Румыния'
		['ru', 51], _;'ru', 'Russian Federation', 'Россия'
		['sk', 52], _;'sk', 'Slovakia', 'Словакия'
		['sl', 53], _;'si', 'Slovenia', 'Словения'
		['so', 54], _;'so', 'Somalia', 'Сомали'
		['sq', 55], _;'al', 'Albania', 'Албания'
		['sr', 56], _;'rs', 'Serbia', 'Сербия'
		['sv', 57], _;'se', 'Sweden', 'Швеция'
		['sw', 58], _;'tz', 'Tanzania, United Republic of', 'Танзания, Объединенная Республика'
		['ta', 6], _;'in', 'India', 'Индия
		['te', 6], _;'in', 'India', 'Индия
		['th', 59], _;'th', 'Thailand', 'Таиланд'
		['tl', 60], _;'ph', 'Philippines', 'Филиппины'
		['tr', 61], _;'tr', 'Turkey', 'Турция'
		['uk', 62], _;'ua', 'Ukraine', 'Украина'
		['ur', 6], _;'in', 'India', 'Индия
		['vi', 63], _;'vn', 'Vietnam', 'Вьетнам'
		['yi', 30], _;'il', 'Israel', 'Израиль'
		['yo', 27], _;'ng', 'Nigeria', 'Нигерия'
		['zu', 1], _;'za', 'South Africa', 'Южная Африка'
		['zh-CN', 64]];'cn', 'China', 'Китай'
	
	#EndRegion Language Icons
	
	_GUICtrlComboBoxEx_SetUnicode($hCombo, True)
	_GUICtrlComboBoxEx_SetImageList($hCombo, $hImageList)
	
	If $sAdd <> '' Then
		_GUICtrlComboBoxEx_AddString($hCombo, $sAdd, 0, 0)
	EndIf
	
	Local $iLang_Col = _ArraySearchCol($aTranslate_Langs, $sApp_Language, 0, 2, 1)
	
	_ArraySort($aTranslate_Langs, 0, 1, 0, $iLang_Col)
	
	For $i = 1 To UBound($aTranslate_Langs) - 1
		$iSearch = _ArraySearch($aLang_Icons, $aTranslate_Langs[$i][0], 1, 0, 0, 2, 1, 0)
		
		If $iSearch <> -1 Then
			$iImage = _GUIImageList_AddIcon($hImageList, $sFlagsIcons_File, $aLang_Icons[$iSearch][1] - 1, 0)
			_GUICtrlComboBoxEx_AddString($hCombo, $aTranslate_Langs[$i][$iLang_Col], $iImage, $iImage)
		Else
			$iImage = _GUIImageList_AddIcon($hImageList, $sIcons_File, 3, 0) ;Unknown icon
			_GUICtrlComboBoxEx_AddString($hCombo, $aTranslate_Langs[$i][$iLang_Col], $iImage, $iImage)
		EndIf
	Next
	
	_GUICtrlComboBoxEx_SetCurSel($hCombo, _GUICtrlComboBoxEx_FindStringExact($hCombo, $sDefault))
EndFunc

Func _GUIToolTipEx_Create($sTitle, $sText, $iX = -1, $iY = -1, $iFlags = 0, $iIcon = 0)
	If BitAND(WinGetState($hToolTip), 2) Then
		_GUIToolTip_Destroy($hToolTip)
	EndIf
	
	$hToolTip = _GUIToolTip_Create(0, $iFlags)
	WinSetOnTop($hToolTip, '', 1)
	
    _GUIToolTip_AddTool($hToolTip, 0, $sText, 0, 0, 0, 0, 0, $TTF_SUBCLASS)
	_GUIToolTip_SetMaxTipWidth($hToolTip, Default)
    _GUIToolTip_SetTitle($hToolTip, $sTitle, $iIcon)
    _GUIToolTip_TrackPosition($hToolTip, $iX, $iY)
    _GUIToolTip_TrackActivate($hToolTip, True, 0, 0)
EndFunc

;Male Speakers: zahar|ermil
;Female Speakers: jane|omazh
Func _Speak_Start($sText, $sLang = 'en')
	If $sText = '' Then
		Return SetError(1, 0, 0)
	EndIf
	
	$sText = StringReplace(StringStripCR($sText), @LF, ' ', 0, 2)
	$sLang &= '-' & StringUpper($sLang)
	
	;https://tech.yandex.ru/speechkit/cloud/doc/dg/concepts/speechkit-dg-tts-docpage/?ncrnd=3588
	Local $sLink = 'http://tts.voicetech.yandex.net/generate?text=' & _Encoding_URIEncode($sText) & '&format=mp3&lang=' & $sLang & '&speaker=' & $sTranslationSpeaker & '&key=d373adef-5817-40a3-850b-7a78fa0205b2&emotion=good&drunk=false&ill=false&robot=false'
	Local $sFile = @TempDir & '\~YA_Speak_Sound.mp3'
	
	_Speak_Stop()
	FileDelete($sFile)
	
	Local $hInet = InetGet($sLink, $sFile, BitOR($INET_FORCERELOAD, $INET_IGNORESSL), $INET_DOWNLOADBACKGROUND)
	
	Do
        Sleep(250)
    Until InetGetInfo($hInet, $INET_DOWNLOADCOMPLETE)
	
	InetClose($hInet)
	
	$hSpeaker = _SoundOpen($sFile)
	_SoundPlay($hSpeaker)
	
	If @error Then
		If IsObj($oSAPI) Then
			$oSAPI.Speak($sText, 1)
		EndIf
	EndIf
EndFunc

Func _Speak_Stop()
	_SoundStop($hSpeaker)
	_SoundClose($hSpeaker)
	
	If @error Then
		$oSAPI = ObjCreate('SAPI.SpVoice')
	EndIf
EndFunc

Func _ArraySearchCol($aArray, $sSearch, $iRow = 0, $iUbnd = 2, $iDefRet = 1)
	For $i = 1 To UBound($aArray, $iUbnd) - 1
		If $aArray[$iRow][$i] = $sSearch Then
			Return $i
		EndIf
	Next
	
	Return $iDefRet
EndFunc

Func _IniWriteEx($sIniFile, $sSection, $sKey, $sValue, $bUTF8 = True)
	If $bUTF8 Then
		$sValue = BinaryToString(StringToBinary($sValue, 4))
	EndIf
	
	Return IniWrite($sIniFile, $sSection, $sKey, $sValue)
EndFunc

Func _IniReadEx($sIniFile, $sSection, $sKey, $sDefault = '', $bUTF8 = True)
	Local $sRet = IniRead($sIniFile, $sSection, $sKey, $sDefault)
	
	If $bUTF8 Then
		$sRet = BinaryToString(StringToBinary($sRet), 4)
	EndIf
	
	If StringIsDigit($sRet) Then
		$sRet = Number($sRet)
	EndIf
	
	Return $sRet
EndFunc

Func WM_COMMAND($hWnd, $nMsg, $wParam, $lParam)
	Local $nNotifyCode = BitShift($wParam, 16)
	Local $nID = BitAND($wParam, 0xFFFF)
	Local $hCtrl = $lParam
	
	Switch $nID
		Case $nTranslateFrom_Edit
			Switch $nNotifyCode
				Case $EN_UPDATE
					GUICtrlSendToDummy($nTranslate_Dummy)
			EndSwitch
	EndSwitch
	
	Return $GUI_RUNDEFMSG
EndFunc

#EndRegion Program Functions
