#NoEnv
#SingleInstance, force
SetBatchLines, -1

global  MAX_URL_LENGTH := 2076, IMAGE_ICON := 1, WM_SETICON := 0x80, ICON_BIG := 1
		, WM_INPUTLANGCHANGEREQUEST := 0x50, EVENT_SYSTEM_MOVESIZESTART := 0xA, EVENT_SYSTEM_MOVESIZEEND := 0xB
		, GUIs := [], LangArray := {}, Player, Voice := [], ColorGui := "Default", MainTransText
		, SIZING, Edit1HPos, Edit2HPos, Edit2YPos, Button2YPos, Button6YPos, Edit1FontSize, Edit2FontSize
		, IsControlPos, GetControlPos, ScriptPID, GuiActive, SaveSize, AllowMultiWindow
		, IniName := RegExReplace(A_ScriptName, "(.*\.).*", "$1ini")

ModifyTrayIcon(ExtractIcon("Google16", 16), A_ScriptHwnd)
DetectHiddenWindows, On
SendMessage, WM_SETICON, ICON_BIG, ExtractIcon("Google32", 32),, ahk_id %A_ScriptHwnd%
DetectHiddenWindows, Off
Process, Exist
ScriptPID := ErrorLevel
InitLangArray()

Hotkey, IfWinActive
Hotkey, ~^vk43, HotkeyRun, Off
Hotkey, ~^Ins , HotkeyRun, Off

IniRead, Hotkey				, % IniName, Hotkey	, Hotkey					, C
IniRead, ShowWindowOnStart	, % IniName, Settings, ShowWindowOnStart	, 0
IniRead, SaveSize				, % IniName, Settings, SaveSize				, 0
IniRead, AllowMultiWindow	, % IniName, Settings, AllowMultiWindow	, 0
IniRead, Edit1FontSize		, % IniName, Location, Edit1FontSize		, 8
IniRead, Edit2FontSize		, % IniName, Location, Edit2FontSize		, 8

if InStr(Hotkey, "C")
	Hotkey, ~^vk43, On
if InStr(Hotkey, "Ins")
	Hotkey, ~^Ins, On

Menu, Tray, NoStandard

Menu, Tray, Add, Открыть, Open
Menu, Tray, Default, Открыть
Menu, Tray, Add

Menu, Tray, Add, Показывать окно при запуске, ShowWindowOnStart
if ShowWindowOnStart
	Menu, Tray, Check, Показывать окно при запуске

Menu, Tray, Add, Сохранять размеры окна, SaveSize
if SaveSize
	Menu, Tray, Check, Сохранять размеры окна

Menu, Tray, Add, Разрешить много окон, AllowMultiWindow
if AllowMultiWindow
	Menu, Tray, Check, Разрешить много окон

Menu, Tray, Add
Menu, Tray, Add, Использовать Ctrl+C+C, Hotkey
Menu, Tray, Add, Использовать Ctrl+Ins+Ins, Hotkey
if InStr(Hotkey, "C")
	Menu, Tray, Check, Использовать Ctrl+C+C
if InStr(Hotkey, "Ins")
	Menu, Tray, Check, Использовать Ctrl+Ins+Ins
Menu, Tray, Add

if !A_IsCompiled
{
	Menu, Tray, Add, Edit, Edit
	Menu, Tray, Add, Reload, Reload
	Menu, Tray, Add
}
Menu, Tray, Add, Выход, ExitApp

HWINEVENTHOOK := SetWinEventHook(EVENT_SYSTEM_MOVESIZESTART, EVENT_SYSTEM_MOVESIZEEND, 0
														, RegisterCallback("WinGetControlPos", "F"), 0, 0, 0)
OnExit, Exit

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x111, "WM_COMMAND")
OnMessage(0x214, "WM_SIZING")

ShowWindowOnStart ? ShowTranslation("", "", "en", "ru")
Return

Open:
	if !WinExist("Google Translate ahk_pid" ScriptPID) || AllowMultiWindow
	ShowTranslation("", "", "en", "ru")
	return
	
ShowWindowOnStart:
AllowMultiWindow:
SaveSize:
	Menu, Tray, ToggleCheck, % A_ThisMenuItem
	%A_ThisLabel% := !%A_ThisLabel%
	IniWrite, % %A_ThisLabel%, % IniName, Settings, %A_ThisLabel%
	return

Edit:
	Edit
	return
	
Reload:
	Reload
	return

Hotkey:
	Menu, Tray, ToggleCheck, % A_ThisMenuItem
	
	if InStr(A_ThisMenuItem, "Ins")
		Hotkey := InStr(Hotkey, "Ins") ? RegExReplace(Hotkey, "Ins") : Hotkey . "Ins"
	if InStr(A_ThisMenuItem, "C+C")
		Hotkey := InStr(Hotkey, "C") ? RegExReplace(Hotkey, "C") : Hotkey . "C"
	
	Hotkey, ~^Ins, % InStr(Hotkey, "Ins") ? "On" : "Off"
	Hotkey, ~^vk43, % InStr(Hotkey, "C") ? "On" : "Off"
	
	IniWrite, % Hotkey, % IniName, Hotkey, Hotkey
	return

HotkeyRun:
	DoublePress()
	return

ExchangeLang:
	GuiControlGet, to,, ComboBox1
	GuiControlGet, from,, ComboBox2
	
	SourceLangNames := TargetLangNames := ""
	for k In LangArray
		SourceLangNames .= "|" . k . (k = from ? "|" : "")
	 , TargetLangNames .= "|" . k . (k = to   ? "|" : "")

	SourceLangNames := RegExReplace(SourceLangNames, "\|$", "||")
	
	GuiControl,, ComboBox1, % SourceLangNames
	GuiControl,, ComboBox2, % TargetLangNames
	GuiControl, Focus, Edit1
   return
   
Exit:
	WinGet, List, List, % "Google Translate ahk_pid" ScriptPID
	Loop % List
	{
		if (List%A_Index% = GUIs.1)
		{
			IniWriteSizeGui(GUIs.1), SaveSize ? IniWriteSizeEdit(GUIs.1)
			break
		}
	}
	DllCall("UnhookWinEvent", Ptr, HWINEVENTHOOK)
	GUIs := LangArray := Voice := ""
ExitApp:
   ExitApp

^!vk56::SendInput, {Raw}%MainTransText%

#If hActive := WinActive("Google Translate ahk_pid" ScriptPID)
Esc::WinClose, A
Enter::ControlClick, Button4, % "Google Translate ahk_pid" ScriptPID
^Tab::
	Gui, %hActive%:Default
	GuiControl, Focus, Static1
	Gosub, ExchangeLang
	Return

#If WinActive("Google Translate ahk_pid" ScriptPID) && NN := GetEditFocus()
^WheelUp::
^WheelDown::
	InStr(A_ThisHotkey, "Up") ? ++Edit%NN%FontSize : --Edit%NN%FontSize
	Edit%NN%FontSize < 6 ? Edit%NN%FontSize := 6
	Edit%NN%FontSize > 25 ? Edit%NN%FontSize := 25
	ToolTip % "FontSize = " . Edit%NN%FontSize
	
	Gui, % WinExist("A") . ":Default"
	Gui, Font, % "q5 s" . Edit%NN%FontSize, Verdana
	GuiControl, Font, Edit%NN%
	SetTimer, IniWriteFontSize, -500
	return
	
IniWriteFontSize:
	ToolTip
	IniWrite, %Edit1FontSize%, % IniName, Location, Edit1FontSize
	IniWrite, %Edit2FontSize%, % IniName, Location, Edit2FontSize
	return

DoublePress()
{
	static pressed1 = 0
	if pressed1 and A_TimeSincePriorHotkey <= 400 And Clipboard
	{
		pressed1 := 0
		if (!(hwnd := WinExist("Google Translate ahk_pid" ScriptPID)) || AllowMultiWindow)
			GuiActive := GetActiveWindow(), Translate(RegExReplace(Clipboard, "\R", "`r`n"))
		else
			TranslateInTheSameWindow(hwnd, Clipboard)
	}	
	else
		pressed1 := 1
}

Translate(str, ByRef _from="", ByRef _to="", NewWindow = 1)
{
	if !Ping("translate.google.com")
	{
		MsgBox, 16, Ошибка!, Нет ответа от сервера.`nПроверьте соединение с интернетом!
		Return
	}

	if (_from = "" && _to = "")
	{
		cyr := RegExMatch(str, "[А-Яа-я]")
		from := cyr ? "ru" : "auto", to := cyr ? "en" : "ru"
	}
	else
		from := _from, to := _to

	json := SendRequest(str,to,from,proxy:="")
	JS := new ActiveScript("JScript")
	JS.eval("delete ActiveXObject; delete GetObject;")
	oJSON := JS.eval("(" . JSON . ")")
	
	if !IsObject(oJSON[1])
		Loop % oJSON[0].length
			trans .= oJSON[0][A_Index - 1][0]
	else  {
		MainTransText := oJSON[0][0][0]
		Loop % oJSON[1].length  {
			trans .= "`n+"
			obj := oJSON[1][A_Index-1][1]
			Loop % obj.length  {
				txt := obj[A_Index - 1]
				trans .= (MainTransText = txt ? "" : "`n" txt)
			}
		}
	}
	if !IsObject(oJSON[1])
		MainTransText := trans := Trim(trans, ",+`n ")
	else
		trans := MainTransText . "`n+`n" . Trim(trans, ",+`n ")
	
	from := oJSON[2]
	trans := Trim(trans, ",+`n ")
	
	If NewWindow
		ShowTranslation(Clipboard, trans, from, to)
	else
	{
		_from := from, _to := to
		Return trans
	}
}

URIEncode(Str)
{
	b_Format:=A_FormatInteger
	SetFormat, IntegerFast, H
	Loop, % StrPutVar(Str, Var, "UTF-8")
	{
		Ch:=NumGet(Var, A_Index-1, "UChar")
		If Ch=0
			Break
		If (Ch>0x7f Or Ch<0x30 Or Ch=0x3d)
			s.="%"((StrLen(c:=SubStr(Ch, 3))<2) ? "0"c:c)
		else
			s.=Chr(Ch)
	}
	SetFormat, IntegerFast, % b_Format
	Return, s
}

WM_LBUTTONDOWN()
{
	PostMessage, WM_NCLBUTTONDOWN := 0xA1, HTCAPTION := 2
}

ShowTranslation(SourceText, TransText, from, to)
{
	static PlayPause1, PlayPause2, Stop1, Stop2, hGui, Control, ExChange1, ExChange2, Source
		  , hIconPlayPause, hIconStop, hIconTranslate, hIconGoogle, hIconChange, Icons
		  , hButtPlayPause1, hButtPlayPause2, hButtStop1, hButtStop2, hButtTranslate, hButtChange1, hButtChange2
		  , BS_ICON := 0x40, BM_SETIMAGE := 0xF7, ES_NOHIDESEL := 0x100
		  , WMSZ_TOP := 3, WMSZ_TOPLEFT := 4, WMSZ_TOPRIGHT := 5

	Gui, New, +AlwaysOnTop +LastFound +Resize +hwndhGui +Owner +MinSize199x220 -MaximizeBox
	Gui, Color, %ColorGui%
	
	oSize := IniReadSizeEdit()
	if (SaveSize && Edit1H := oSize.Edit1H)
		Edit1W := oSize.Edit1W, Edit2H := oSize.Edit2H
	
	Gui, Font, q5 s8, Verdana
	Gui, Add, Text, % "x" (Edit1W > 310 ? 10 + (Edit1W - 310)//2 : 10) " y15", Исходный язык:

	SourceLangNames := TargetLangNames := ""
	For k,v In LangArray
		SourceLangNames .= (A_Index = 1 ? "" : "|") . k . (v = from ? "|" : "")
	 , TargetLangNames .= (A_Index = 1 ? "" : "|") . k . (v = to   ? "|" : "")

	SourceLangNames := RegExReplace(SourceLangNames, "\|$", "||")

	Gui, Add, DDL, % "x" (Edit1W > 310 ? 112 + (Edit1W - 310)//2 : 112) " yp-4 w182", % SourceLangNames
	Gui, Add, Button, % "x" (Edit1W > 310 ? 297 + (Edit1W - 310)//2 : 297)
							. " yp-1 w23 h23 " BS_ICON " hwndhButtChange1 gExchangeLang vExChange1"

	Gui, Font, q5 s%Edit1FontSize%, Verdana
	if !(SaveSize && Edit1H)
	{
		Gui, Add, Edit, x10 y+9 w310 Multi %ES_NOHIDESEL% vSource, % SourceText
		GuiControlGet, Edit1, Pos
		
		Edit1H < 45 ? Edit1H := 45
		Edit1H > 250 ? Edit1H := 250
		GuiControl, Move, Edit1, h%Edit1H%
	}
	else
		Gui, Add, Edit, % "x10 y+9 w" (Edit1W ? Edit1W : 310) " Multi h" Edit1H " vSource " ES_NOHIDESEL, % SourceText

	GuiControlGet, Edit1, Pos
	Gui, Font, q5 s8, Verdana
	Gui, Add, Button, % "x10 y" Edit1Y + Edit1H + 5 " w52 h23 hwndhButtPlayPause1 gPlayPause vPlayPause1 " BS_ICON
	Gui, Add, Button, % "x+3 yp w52 h23 " BS_ICON " hwndhButtStop1 gStop vStop1" (Player ? "" : " Disabled")
	Gui, Add, Button, % "x" (Edit1W ? Edit1W - 60 : 250) " yp w70 h23 " BS_ICON " hwndhButtTranslate gTranslate"

	Gui, Add, Text, % "x" (Edit1W > 310 ? 10 + (Edit1W - 310)//2 : 10) " y+20", Язык перевода:

	Gui, Add, DDL, % "x" (Edit1W > 310 ? 112 + (Edit1W - 310)//2 : 112) " yp-4 w182", % TargetLangNames
	Gui, Add, Button, % "x" (Edit1W > 310 ? 297 + (Edit1W - 310)//2 : 297)
							. " yp-1 w23 h23 " BS_ICON " hwndhButtChange2 gExchangeLang vExChange2"

	Gui, Font, q5 s%Edit2FontSize%, Verdana
	if !(SaveSize && Edit1H := oSize.Edit1H)
	{
		Gui, Add, Edit, x10 y+9 w310 Multi %ES_NOHIDESEL%, % TransText
		GuiControlGet, Edit2, Pos
		
		Edit2H < 45 ? Edit2H := 45
		Edit2H > 250 ? Edit2H := 250
		GuiControl, Move, Edit2, h%Edit2H%
	}
	else
		Gui, Add, Edit, % "x10 y+9 w" (Edit1W ? Edit1W : 310) " Multi h" Edit2H " " ES_NOHIDESEL, % TransText

	GuiControlGet, Edit2, Pos
	Gui, Font, q5 s8, Verdana
	Gui, Add, Button, % "x10 y" Edit2Y + Edit2H + 5 " w52 h23 hwndhButtPlayPause2 gPlayPause vPlayPause2 " BS_ICON
	Gui, Add, Button, % "x+3 yp w52 h23 " BS_ICON " hwndhButtStop2 gStop vStop2" (Player ? "" : " Disabled")
	Gui, Add, Button, % "x" (Edit1W ? Edit1W - 60 : 250) " yp w70 h23 gGuiClose", OK

	if !IsObject(Icons)
	{
		hIconGoogle := ExtractIcon("Google16", 16)
		hIconChange := ExtractIcon("Change", 16)
		hIconPlayPause := ExtractIcon("PlayPause", 25)
		hIconStop := ExtractIcon("Stop", 12)
		hIconTranslate := ExtractIcon("Translate", 16)
		Icons := [hIconGoogle, hIconChange, hIconPlayPause, hIconStop, hIconTranslate]
	}

	DetectHiddenWindows, On
	Loop 2
	{
		PostMessage, BM_SETIMAGE, IMAGE_ICON, hIconChange		,, % "ahk_id" hButtChange%A_Index%
		PostMessage, BM_SETIMAGE, IMAGE_ICON, hIconPlayPause	,, % "ahk_id" hButtPlayPause%A_Index%
		PostMessage, BM_SETIMAGE, IMAGE_ICON, hIconStop			,, % "ahk_id" hButtStop%A_Index%
	}
	PostMessage, BM_SETIMAGE, IMAGE_ICON, hIconTranslate,, ahk_id %hButtTranslate%
	PostMessage, WM_SETICON,, hIconGoogle,, ahk_id %hGui%
	PostMessage, WM_INPUTLANGCHANGEREQUEST,, GetLayoutList()[from = "ru" ? "Ru" : "En"],, ahk_id %A_ScriptHwnd%
	DetectHiddenWindows, Off
	
	GuiControlGet, Button8, Pos
	Gui, Show, % "hide h" Button8Y + Button8H + 6, Google Translate
	GuiControl, Focus, Edit1

	if !WinExist("Google Translate ahk_pid" ScriptPID)
	{
		IniRead, xGUI, % IniName, Location, xGUI, % " "
		IniRead, yGUI, % IniName, Location, yGUI, % " "
		Gui, Show, % (xGUI = "" ? "" : "x" xGUI " y" yGUI " ") "w" (SaveSize && Edit1W ? Edit1W + 20 : 330)
	}
	else
	{
		WinGetPos, X, Y,,, % "ahk_id " (GuiActive ? GuiActive : GUIs[GUIs.MaxIndex()])
		Gui, Show, % "x" X + 60 " y" Y + 40 " w" (SaveSize && Edit1W ? Edit1W + 20 : 330)
	}
	GUIs.Insert(hGui), GuiActive := ""
	Return
   
GuiSize:
   if !IsControlPos
      return

	SetWinDelay, 0
	if (SIZING ~= WMSZ_TOP "|" WMSZ_TOPLEFT "|" WMSZ_TOPRIGHT)
	{
		if A_GuiHeight - Edit1HPos > 32
			Resizing(A_GuiWidth, A_GuiHeight, 1)
		else
		{
			if (GetControlPos = "")
				_WinGetControlPos(A_Gui), GetControlPos := 1
			Resizing(A_GuiWidth, A_GuiHeight, 2)
		}
	}
	else
	{
		if A_GuiHeight - Edit2HPos > 32
			Resizing(A_GuiWidth, A_GuiHeight, 2)
		else
		{
			if (GetControlPos = "")
				_WinGetControlPos(A_Gui), GetControlPos := 1
			Resizing(A_GuiWidth, A_GuiHeight, 1)
		}
	}
	return

PlayPause:
	if IsObject(Player)
	{
		if Playing := !Playing
			Player.Controls.pause()
		else
			Player.Controls.play()
	}
	else
	{
		hGui := A_Gui, Control := A_GuiControl
		SetTimer, PlayPauseTimer, -1
	}
	return

PlayPauseTimer:
	n := SubStr(Control, 0)
	ControlGet, Text, Selected,, Edit%n%, ahk_id %hGui%
	if (Text = "")
		ControlGetText, Text, Edit%n%, ahk_id %hGui%
	ControlGetText, lng, ComboBox%n%, ahk_id %hGui%
	Say(RegExReplace(Text, "\R+", "`n"), LangArray[lng])
	return

Stop:
	Player.close()
	Playing := Player := ""
	StopButtonEnableDisable(0)
	return
	
Translate:
	GuiControlGet, from,, ComboBox1
	from := LangArray[from]
	GuiControlGet, to,, ComboBox2
	to := LangArray[to]
	GuiControlGet, SourseText,, Edit1
	if (SourseText = "")  {
		ToolTip Введите в окно текст для перевода!
		Sleep, 1500
		ToolTip
		Return
	}
	TransText := Translate(RegExReplace(SourseText, "\R", "`r`n"), from, to, 0)

	GuiControl,, Edit2, % TransText
	GuiControl, Focus, Edit1
	Return

GuiClose:
	if (A_Gui = GUIs.1)
		IniWriteSizeGui(A_Gui), SaveSize ? IniWriteSizeEdit(A_Gui)
	else
	{
		for k,v in GUIs
			if (A_Gui = v)
				break
		GUIs.Remove(k)
	}
	
	Gui, %A_Gui%: Destroy
	IfWinNotExist, Google Translate ahk_pid %ScriptPID%
	{
		Player.close(), Player := "", Voice := []
		FileDelete, % A_ScriptDir "\mp3\*.mp3"
		Loop % Icons.MaxIndex()
			DllCall("DestroyIcon", Ptr, Icons[A_Index])
		Icons := "", GUIs := []
	}
	return
}

TranslateInTheSameWindow(hwnd, SourceText)
{
	Translation := Translate(RegExReplace(SourceText, "\R", "`r`n"), from, to, 0)

	For k,v In LangArray
		SourceLangNames .= "|" . k . (v = from ? "|" : "")
	 , TargetLangNames .= "|" . k . (v = to   ? "|" : "")
	
	Gui, %hwnd%:Default
	GuiControl,, ComboBox1, % SourceLangNames
	GuiControl,, ComboBox2, % TargetLangNames
	GuiControl,, Edit1, % SourceText
	GuiControl,, Edit2, % Translation
}

Resizing(W, H, mode)
{
	E1H := H - Edit1HPos
	E2Y := H - Edit2YPos, E2H := H - Edit2HPos
	B2Y := H - Button2YPos, B6Y := H - Button6YPos

	if mode = 1
	{
		GuiControl, Move, Edit1, % "w" W - 20 " h" E1H
		GuiControl, Move, Edit2, % "w" W - 20 " y" E2Y
		GuiControl, MoveDraw, Button2, % "y" B2Y
		GuiControl, MoveDraw, Button3, % "y" B2Y
		GuiControl, MoveDraw, Button4, % "x" (W > 200 ? W - 80 : 120) " y" B2Y
		GuiControl, MoveDraw, Static2, % "x" (W > 330 ? 10 + (W - 330)//2 : 10) " y" B2Y + 43
		GuiControl, Move, ComboBox2, % "x" (W > 330 ? 112 + (W - 330)//2 : 112) " y" B2Y + 39
		GuiControl, MoveDraw, Button5, % "x" (W > 330 ? 297 + (W - 330)//2 : 297) " y" B2Y + 38
	}
	else
	{
		GuiControl, Move, Edit1, % "w" W - 20
		GuiControl, Move, Edit2, % "w" W - 20 " h" (E2H > 32 ? E2H : 32)
		GuiControl, MoveDraw, Static2, % "x" (W > 330 ? 10 + (W - 330)//2 : 10)
		GuiControl, Move, ComboBox2, % "x" (W > 330 ? 112 + (W - 330)//2 : 112)
		GuiControl, MoveDraw, Button5, % "x" (W > 330 ? 297 + (W - 330)//2 : 297)
		GuiControl, MoveDraw, Button4, % "x" (W > 200 ? W - 80 : 120)
	}
	GuiControl, Move, Static1, % "x" (W > 330 ? 10 + (W - 330)//2 : 10)
	GuiControl, Move, ComboBox1, % "x" (W > 330 ? 112 + (W - 330)//2 : 112)
	GuiControl, MoveDraw, Button1, % "x" (W > 330 ? 297 + (W - 330)//2 : 297)
	GuiControl, MoveDraw, Button6, % "y" B6Y
	GuiControl, MoveDraw, Button7, % "y" B6Y
	GuiControl, MoveDraw, Button8, % "x" (W > 200 ? W - 80 : 120) " y" B6Y
}

Ping(strHost)
{
   Loop 4
      bRet := ComObjGet("winmgmts:").Get("Win32_PingStatus.address='" . strHost . "'").StatusCode = 0
   until bRet
   return bRet
}

Say(Text, lng)
{
	static PlaylistOpenNoMedia := 6, Stopped := 1
	
	Player := ComObjCreate("WMPlayer.OCX")
	objPlaylist := Player.currentPlaylist

	for k,v in Voice
		if (v.Text = RegExReplace(Text, "^\s*(\S.+\S)(\s+$|$)", "$1") && v.lng = lng)
		{
			var := 1
			break
		}

	if var
	{
		Loop % v.mp3.MaxIndex()
			objPlaylist.appendItem(Player.newMedia(v.mp3[A_Index]))
	}
	else
	{
		if !Ping("translate.google.com")
		{
			MsgBox, 16, Ошибка!, Нет ответа от сервера.`nПроверьте соединение с интернетом!
			Return
		}

		PreUrl := "https://translate.google.ru/translate_tts?ie=UTF-8&tl=" lng "&total=1&idx=0&client=t&prev=input"
		Strings := []
		If StrLen(Text) > 100
		{
			StartPos := 1
			While StartPos := RegExMatch(Text, ".+?(\.|$)", Found, StartPos) + StrLen(Found)
			{
				if StrLen(Found) > 100
				{
					StartPos_ := 1
					While StartPos_ := RegExMatch(Found, "(.{1,99}([ ,\t\n]|$))|(.{1,100})", Found_, StartPos_) + StrLen(Found_)
						Strings.Insert(Found_)
				}
				else
					Strings.Insert(Found)
			}
		}
		else
			Strings.1 := Text

		if !FileExist(A_ScriptDir "\mp3")
			FileCreateDir, %A_ScriptDir%\mp3

		Voice.Insert(o := {Text: RegExReplace(Text, "^\s*(\S.+\S)(\s+$|$)", "$1"), lng: lng, mp3: []})
		Loop % Strings.MaxIndex()
		{
			txt := Strings[A_Index]
			URLDownloadToFile, % PreUrl . "&textlen=" . StrLen(txt) . "&tk=" . TK(txt)
				. "&q=" URIEncode(RegExReplace(Strings[A_Index], "^\s*([^\s]+)\s*$", "$1"))
				, % mp3file := A_ScriptDir "\mp3\" A_TickCount ".mp3"
			objPlaylist.appendItem(Player.newMedia(mp3file))
			o.mp3.Insert(mp3file)
		}
	}
	StopButtonEnableDisable(1)
	Player.Controls.play()
	While Player.PlayState != Stopped && Player.OpenState != PlaylistOpenNoMedia && IsObject(Player)
		Sleep, 100
	Player.close(), Player := objPlaylist := ""
	StopButtonEnableDisable(0)
}

StopButtonEnableDisable(key)
{
	WinGet, List, List, Google Translate ahk_pid %ScriptPID%
	Loop % List
	{
		Control , % key ? "Enable" : "Disable",, Button3, % "ahk_id" List%A_Index%
		Control , % key ? "Enable" : "Disable",, Button7, % "ahk_id" List%A_Index%
	}
}

WM_COMMAND(wp, lp)
{
	static EN_SETFOCUS := 0x100, CBN_SETFOCUS := 3
	
	if !WinActive("Google Translate") || !(wp>>16 = EN_SETFOCUS || wp>>16 = CBN_SETFOCUS)
		return
	
	Gui, %A_Gui%:Default
	DetectHiddenWindows, On
	
	if (wp>>16 = EN_SETFOCUS)
	{
		GuiControlGet, Name, Name, %lp%
		if Name != Source
			return
		
		GuiControlGet, lang,, ComboBox1
		PostMessage, WM_INPUTLANGCHANGEREQUEST,, GetLayoutList()[lang = "Русский" ? "Ru" : "En"],, ahk_id %A_ScriptHwnd%
	}
	
	if (wp>>16 = CBN_SETFOCUS)
		PostMessage, WM_INPUTLANGCHANGEREQUEST,, GetLayoutList().Ru,, ahk_id %A_ScriptHwnd%
	
	DetectHiddenWindows, Off
}

GetLayoutList()
{
	SetFormat, IntegerFast, H
	VarSetCapacity(List, A_PtrSize*2)
	DllCall("GetKeyboardLayoutList", Int, 2, Ptr, &List)
	Locale1 := NumGet(List)
	b := SubStr(Locale2 := NumGet(List, A_PtrSize), -3) = 0409
	En := b ? Locale2 : Locale1
	Ru := b ? Locale1 : Locale2
	SetFormat, IntegerFast, D
	Return {En: En, Ru: Ru}
}

WM_SIZING(wp)
{
	SIZING := wp
}

SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags)
{
   return DllCall("SetWinEventHook" , UInt, eventMin, UInt, eventMax
                                    , Ptr, hmodWinEventProc, Ptr, lpfnWinEventProc
                                    , UInt, idProcess, UInt, idThread
                                    , UInt, dwFlags, Ptr)
}

WinGetControlPos(hWinEventHook, event, hwnd)
{
	if !GetActiveWindow()
		return
	
	if (event = EVENT_SYSTEM_MOVESIZEEND)
		IsControlPos := GetControlPos := "", CorrectPos(hwnd)
	else
		_WinGetControlPos(hwnd)
}

_WinGetControlPos(hwnd)
{
	Gui, %hwnd%:Default
	
	GuiControlGet, Edit1, Pos
	GuiControlGet, Edit2, Pos
	GuiControlGet, Button2, Pos
	GuiControlGet, Button6, Pos
	
	VarSetCapacity(Rect, 16)
	DllCall("GetClientRect", Ptr, hwnd, Ptr, &Rect)
	ClientH := NumGet(Rect, 12, "UInt")

	Edit1HPos := ClientH - Edit1H
	Edit2HPos := ClientH - Edit2H
	Edit2YPos := ClientH - Edit2Y
	Button2YPos := ClientH - Button2Y
	Button6YPos := ClientH - Button6Y
	IsControlPos := 1
}

CorrectPos(hwnd)
{
	VarSetCapacity(Rect, 16)
	DllCall("GetClientRect", Ptr, hwnd, Ptr, &Rect)
	ClientH := NumGet(Rect, 12, "UInt")
	
	Gui, %hwnd%:Default
	GuiControlGet, Edit2, Pos
	GuiControl, Move, Edit2, % "h" ClientH - Edit2Y - 34
	
	Loop 3
		GuiControl, MoveDraw, % "Button" A_Index + 5, % "y" ClientH - 29
}

GetActiveWindow()
{
	WinGetActiveTitle, Title
	WinGetClass, Class, A
	WinGet, PID, PID, A
	Return (Title = "Google Translate" && Class = "AutoHotkeyGUI" && PID = ScriptPID) ? WinExist("A") : ""
}

IniReadSizeEdit()
{
	IniRead, Edit1W, % IniName, Location, Edit1W, % " "
	IniRead, Edit1H, % IniName, Location, Edit1H, % " "
	IniRead, Edit2H, % IniName, Location, Edit2H, % " "
	Return {Edit1W: Edit1W, Edit1H: Edit1H, Edit2H: Edit2H}
}

IniWriteSizeEdit(hwnd)
{
	ControlGetPos,,, Edit1W, Edit1H, Edit1, % "ahk_id" hwnd
	ControlGetPos,,,, Edit2H, Edit2, % "ahk_id" hwnd
	
	IniWrite, % Edit1W, % IniName, Location, Edit1W
	IniWrite, % Edit1H, % IniName, Location, Edit1H
	IniWrite, % Edit2H, % IniName, Location, Edit2H
}

IniWriteSizeGui(hwnd)
{
	WinGetPos, X, Y,,, % "ahk_id" hwnd
	IniWrite, % X, % IniName, Location, xGUI
	IniWrite, % Y, % IniName, Location, yGUI
}

GetEditFocus()
{
	if !WinActive("Google Translate ahk_pid" ScriptPID)
		return
	
	ControlGetFocus, Control, A
	return InStr(Control, "Edit") ? SubStr(Control, 0) : ""
}

SendRequest(str, tl := "", sl := "", proxy := "") {
	ComObjError(false)
	http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	proxy ? http.SetProxy(2, proxy) : "", tl ? "" : tl := "en"
	http.open( "POST", "https://translate.google.com/translate_a/single?client=t&sl="
		. (sl ? sl : "auto") "&tl=" tl "&hl=" tl
		. "&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe=UTF-8&otf=1&ssel=3&tsel=3&pc=1&kc=2"
		. "&tk=" TK(str), 1 )
 
	http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
	http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
	http.send("q=" URIEncode(str))
	http.WaitForResponse(-1)
	Return http.responsetext
}

TK(string)  {
	js := new ActiveScript("JScript")
	js.Exec(GetJScript())
	Return js.tk(string)
}

StrPutVar(string, ByRef var, encoding = "CP0")
{
	 VarSetCapacity( var, StrPut(string, encoding) * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
	 return StrPut(string, &var, encoding)
}

ExtractIcon(name, size)
{
	Base64 := GetBase64String(name)
	Return hIcon := CreateIconFromBase64(Base64, size)
}

CreateIconFromBase64(StringBASE64, Size)
{
   StringBase64ToData(StringBASE64, IconData)
   Return DllCall("CreateIconFromResourceEx", Ptr, &IconData + 4
      , UInt, NumGet(&IconData, "UInt"), UInt, true, UInt, 0x30000, Int, Size, Int, Size, UInt, 0)
}
   
StringBase64ToData(StringBase64, ByRef OutData)
{
   DllCall("Crypt32.dll\CryptStringToBinary", Ptr, &StringBase64 
      , UInt, StrLen(StringBase64), UInt, CRYPT_STRING_BASE64 := 1, UInt, 0, UIntP, Bytes, UIntP, 0, UIntP, 0)

   VarSetCapacity(OutData, Bytes) 
   DllCall("Crypt32.dll\CryptStringToBinary", Ptr, &StringBase64 
      , UInt, StrLen(StringBase64), UInt, CRYPT_STRING_BASE64, Str, OutData, UIntP, Bytes, UIntP, 0, UIntP, 0)
   Return Bytes
}

ModifyTrayIcon(hIcon, hGui, uID = 0x404)
{
   static NIM_MODIFY := 1, NIF_ICON := 2
   VarSetCapacity(NOTIFYICONDATA, size := A_PtrSize = 8 ? 848 : A_IsUnicode? 828 : 444, 0)
   NumPut(size, NOTIFYICONDATA, "UInt")
   NumPut(hGui, NOTIFYICONDATA, A_PtrSize)
   NumPut(uID, NOTIFYICONDATA, 2*A_PtrSize, "UInt")
   NumPut(NIF_ICON, NOTIFYICONDATA, 2*A_PtrSize + 4, "UInt")
   NumPut(hIcon, NOTIFYICONDATA, 3*A_PtrSize+8)
   
   res := DllCall("shell32\Shell_NotifyIcon", UInt, NIM_MODIFY, Ptr, &NOTIFYICONDATA)
   DllCall("DestroyIcon", Ptr, hIcon)
   Return res
}

GetBase64String(name)
{
	IconGoogle16 = 
	(
		aAQAACgAAAAQAAAAIAAAAAEAIAAAAAAAQAQAAAAAAAAAAAAAAAAAAAAAAADt5+GR
		/Pr49/78+//p0Ln/sUsA/71iAP+8YQD/vGEA/7xhAP+8YQD/vGEA/7xhAP+8YQD/
		vGEA/7thAPqxawGU/f38+/7+/v7//////Pr4/8yANf/HZwD/y3IQ/8tyEP/Lcg//
		ym8J/8txDv/LchD/y3EP/8puCf/LcQ/+ynMR+v7+/f/////////////////y3cr/
		1XYR/+GLJ//giSf/4Isq/+GPM//fiCX/4Ioo/9+IJP/hjzP/4Iss/96IJv/+/v7/
		/////////////////////+Wnbf/niCD/7ZY1/+mSMP/57eD/8bJr/+h9B//vqVz/
		+/Tu/+uYPP/rki///f7+//7////+/////v/////////37ef/4IQq/++YNP/sjiT/
		9NSx//vn0f/ytHL/+eLI//jiyv/sjiX/7pk6//z9/v/9/v///f7///3+///9/v//
		/////+m5kP/ohR7/8ZYv//CtZP/7+vn/78ab//v7+v/zuXn/75Eq//CbPf/8/P3/
		/v7///7////9/v///f3///7+///7+vv/4o0///GVL//wnD3/+Ora//SxZ//68OT/
		8aFH//GZOP/ynT///f3+//z59//89vH///////7//////////////+/Ruf/nhCD/
		9Zct//XSq////fz/+d2///KULP/0n0D/9J9B//39/v/7+PP/8cmi//PCk//9+vf/
		88WY/+ybS//7+PX/5aBj//KOI//1smj/9uzh//W3dP/2mTT/9qBC//ahQ//7+/3/
		/f7///3////ww5f/6o0y/+uVQv/yxZj//Pjy//Tl2//mhSn/+KA9//ScO//3nz7/
		+KJF//iiRP/4o0X//Pv+//38///+////+e/n/+Z6Ef/0y6T///////3+////////
		6K18//COKf/7pUX/+aNF//mjRv/5o0b/+aRH//v7/f/8/f///v////XWuf/yzqz/
		65VA//3////9/////f7///jx7v/mijb/+qFA//umSP/7pUj/+6VI//ulSf/8/P7/
		+/r7//Xhz//02L7/9+nc/+qcUf/wvYv/+e7i//v9///+////7MGf/+2JJ//9qUv/
		+6ZJ//umSf/7pkr//Pv+//v6/f/59O7/9+3k/+qZSv/58u7/8cqk//nv6P/8/f//
		/P3///r7/f/mk0v/+Jw7//2pS//8p0r//adL//v6/fn8/P/+/P////ny7v/23sr/
		/P3///3////8/v//+/v///v7///+////8tbB/+uKL//+qEn//qhL/v2oTfn69/Sb
		+/v++fr6/v/8///+/v///vv8//77+/7++/v+/vv7/v77/P7++/7+/vv///7nk0/+
		+Jk7//6oTPv5qFOXAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==
	)
	IconGoogle32 = 
	(
		qBAAACgAAAAgAAAAQAAAAAEAIAAAAAAAgBAAAAAAAAAAAAAAAAAAAAAAAADn3tQD6OHatvv49P/8+PX8+/j0/vz59f/58ev/t2ER/7daAf+8YgL/umAA/7thAf+7YQH/
		u2EB/7thAf+7YQH/u2EB/7thAf+7YQH/u2EB/7thAf+7YQH/u2EB/7thAf+7YQH/u2EB/7thAf+7YQH+u2AA/LtgAP+sWwHEzogDCfLu6MX+/f38//////////7/////
		/fz6///////Zqn7/tVMA/8RsC//DaAb/w2kG/8NpBv/DaQb/w2kG/8NpBv/DaQb/w2kG/8NpBv/DaQb/w2kG/8NpBv/DaQb/w2kG/8NpBv/DaQb/w2kG/8NpBv/DaQb+
		wmgF/8NpBv64bA7E///+///////////////////////+/f3//v7+//v38//EciX/xGgJ/8x0Ev/KcQ//y3IQ/8tyEP/LchD/y3IQ/8tyEP/LchD/y3IQ/8tyEP/LchD/
		y3IQ/8tyEP/LchD/y3IQ/8tyEP/LchD/y3IQ/8tyEP/Lcg//ynEP/811Ef/+/fz9/////v/////+/v7////////////9/Pv//////+nIqP/DYwb/1H4f/9R8Gv/UfBr/
		1H0b/9R9G//UfRv/1H0b/9R9G//Vfh3/1X4e/9V9HP/UfRv/1H0b/9R9G//UfRv/1H0b/9V+Hf/Vfh7/1X0c/9R8Gv/UfBr+1X8d/f79+/7/////////////////////
		/v7+//7+/v/+/Pv//v79/9eSUf/Sdhb/34so/92HJf/eiCb/3ogm/96IJv/eiCb/3ogm/92DHP/dghr/3oYi/96JJ//eiCb/3ogm/96IJv/eiSf/3YQd/92CGv/dhR//
		3okn/92HJf/eiyn+/v38//////////////////////////////////38+//+////9eLR/9J1Hf/jjS//55Ew/+WQL//nkTD/5pEw/+aRMP/lkC//6qpm/+2xcv/onUj/
		5o8s/+aRMf/nkTD/5pEx/+aQLv/qqF//7bFy/+mjVf/mjiv/5pEw/+eTM//9/f3//v////7////+/////v////7////+/v7//v////38+v//////46l1/9p5G//slzn/
		6pQ0/+uUNf/rlTX/65Y4/+iMKP/w2L7///////XSq//pjSb/65Y4/+uUNf/rkzP/65pB//v28v//////7ruE/+mOKP/rljj/65c4//79/P//////////////////////
		/////////////v7//v38//7+/f/57+b/130t/+WNMP/tmDj/65Y2/+yXN//smDn/7JAo/+qydf/9/fz/++/h/+yXOP/sljT/7Jg5/+uQKv/vtXT//v79//r07f/qnET/
		7JUz/+yWN//smTr//f39//7////+/////v////7////+/////v////7//v/+/////fz7///////pvpn/2Xgd/+yYO//umDj/7Zc3/+2YOf/uljT/6pxG//j07///////
		8a9n/+ySMP/tmj7/65Iu//bXtf/+/v7/9dy//+uRLP/umTv/7Zc3/+6aPP/8/f3//f7///3+///9/v///f7///3+///9/v///f7///3+/v/9/v7//f38//z59v/bi0X/
		44cr/++bPP/umTn/75k5/++aPP/sky//8trA//7+/v/99e7///bu///48f/+9e3//fr2///////xv4f/7pIr/++bPf/umDn/75s9//39/f/+/v///v3///7+///+/v//
		/v7///7+///+/v///v7///7+///8+/r///////DSuv/Zdx//7JY6//CaO//vmTr/8Js9//CULv/tuoH//v////r18P/t3Mr/7dvJ//Dk2P//////+/n2/+6jUP/wlzX/
		75o8//CZOv/wnD7//f39//79///+/P///v3///79///+/f///v3///79///+/f///f3+//39/v/9/Pz//v///+CbYf/gfyP/8Jw///CbPP/wmzz/8Zk3/+yhTv/5+fj/
		/PTq/+uYO//qih//77yD//7+/v/34Mf/75Uy//GcPf/wmzv/8Jo7//GdP//9/f3//v7///79///+/v///v7///7+///+/v///v7///7+///+/v///v7///38/P/+/v7/
		9eTW/9p7J//qkzj/8p0+//GcPf/ynkD/75c1//Pex///////9rl3//GULP/65c7///////LBi//xlTD/8p5A//KcPv/xnD3/8p5B//39/f/9/v///fz+//39/v/9/f7/
		/f3+//39/v/+/v///v7///7+///9/f7//v7///z8+///////5q+A/959I//wmz//850+//KeQf/ylzL/776I//7+/v/506n/8aBH//37+v/8+/j/8adW//OaOf/ynT//
		850+//KcPf/zn0L//P39//79///+/f///v////39///9/Pv//f3+//3+/v/9/f7//f3+//7+///9/P3//fv6//38/P/68+3/3YU5/+iMMv/0nkD/855A//SbOv/vpVP/
		+vz9//3r2P/0voP///////jizP/ymTj/9J9B//SeP//0nj//850+//SgQ//9/f3//f7+//38/f/67uP//v/////////+/////fz8//7+///9/f7//fz9////////////
		/f7////+/v/txaT/3Xog//CZP//1oEH/9aBC//KaOP/15NL//vr2//nkzv/+/v3/9cWR//SZNP/1oUT/9Z9B//WfQf/0nkD/9aFE//z8/f/9/f3//fz8//HStP/sq2z/
		9cme//z38//+/////fz7//3+///+////+OLN/++vcP/21bX///////z6+f/gk1L/5YYt//SfQ//2okX/9Zkz//HFlP////////////3////zq1v/9p08//WgQ//2oEL/
		9qBC//WfQf/2okX/+/39//z+/v/8/P3//v////bn2f/nmk7/6o40//XQq//9////+/j0//C0eP/pii3/6YIe/+qKK//22r3//v////HXwv/ceST/7ZU+//ahRP/2nTz/
		8ahZ/+zXv//t2cL/7syo//WeP//2oEP/9qBC//agQv/2oEL/9Z9B//aiRf/8/P3//f3+//38///8+/v//v////v9/v/pqm3/53wT//C0ef/tpV7/6IId/+mHJ//qlUL/
		7a5w//PQrv/8+/v//v///+Skbv/igSj/851D//eiRP/2n0D/85s5//ObOf/0nDr/96JE//ehQ//3oUP/96FD//ehQ//2oEL/96NG//z7/f/9/P///Pv+//39///8+/z/
		/fz9//r8/f/qqWn/6YMg/+qKLP/qkz7/8cGT//nx6f/9/////v////z7/P/9/v7/9+rg/92BMf/qkDn/96FE//eiRP/4o0b/+aRG//ijRv/4okT/+KJE//iiRP/4okT/
		+KJE//ehQ//4pEj//Pz9//39///9/P///Pz+//39///7+fr//v////Tcxv/piSr/6ogo//PHnP///////P3///z7/P/8+/z//f3///v6+v//////6reM/+B8Iv/ynEL/
		+aRF//iiRP/5o0X/+aNF//mjRf/5o0X/+aNF//mjRf/5o0X/+KJE//mlSf/8/P3//P3///z8///8/f///Pz+//z7/P/9////7axt/+iHKf/piy7/7Z9S//z49f/8/Pz/
		/Pz+//z8/v/8/P7//Pz9//z8/f/79fH/4IpB/+iKMv/2oUT/+aRG//ijRf/5pEb/+aRG//mkRv/5pEb/+aRG//mjRf/4o0X/+aVJ//z7/f/9/P///fv///38///8+/3/
		/f7///js4v/pkDj/9N3H/+mcUP/pgh7/9ti9//3+/f/7+vv//fz+//38///9/f//+/r7///////wzLD/33wl//CZQv/6pUf/+aRH//qlR//6pUf/+qVH//qlR//6pUf/
		+qVH//qkRv/6pkr//Pz9//z8/v/8/P///Pz9//v49//9/fz/8cSa//C7iP//////7beC/+h+F//wtXv//v////v4+P/8+/z//P3///z8/v/8/P7//Pv8//38+//kmFj/
		5oYu//afRf/7pkj/+qRH//ulSP/7pUj/+6VI//ulSP/7pUj/+6RH//umS//8+/3//P3///v7///8/////f////3////wxJn/+/r5//7////z38z/6Ico/+uQNv/35NH/
		/f////z////7/P7//P3///z8///6+vv//f7///Tfzv/ffyv/7ZQ9//mjR//7pkj/+qVI//umSP/7pkj/+6ZI//umSP/7pUf/+6dL//z7/f/7+/3//Pz///fo3P/zz6z/
		8tK0/++/kP/13ML/9uHM//LWuv/njTX/6JpN//HAkP/20rH/9di8//z9///7+/3/+/z+//v8///6+fv//v///+iref/jgCj/85xE//ymSP/6pEj/+6VI//ulSP/7pUj/
		+6VI//ukR//7p0z//Pr9//v7/f/8/P//9+vh//TdyP/14tL/9eTV//Xi0f/rqWn/8MCR//fp2//05tn/6JVF/+d+Fv/007P//P7+//v6/P/8+////Pv+//v6/P/8/f3/
		+O3k/+CDNf/rjzr/+KJG//ynSf/7pUj//KZJ//ymSf/8pkn//KVI//yoTP/8+/3+/Pz///v6///8/////f////z////9////+fLt/+mGJf/slUD//Pz9//3////z38z/
		9NrC//3////7+v3//Pz///z8///7/P7//Pz///r5+//+////7b2X/+J/KP/xmkT//KdJ//ynSv/8p0r//adK//2nSv/9pkn//ahN/vz7/f37+/7+/Pv///v7/f/7+v3/
		+vn6//v9/f/tuYf/6I41//HIoP/7/Pv/+/n7//3////9////+/r9//z8///8+/7/+/z///v8///7+/7/+/v+//v7/P/7+Pb/45BL/+mJM//3n0X//qhL//ymSf/9p0v/
		/adK//2mSf79qE79/Pv9//z8///7+v///Pz///v7/v/7/P//+/v+//ju5v/59fT//P////z7/v/8+/7/+/r8//v6/P/8/P///Pv+//z8///8/P///Pz///z8///8/P//
		+vn7//3////y0rn/4X0l/++WQP/7pUj//ahL//2nSv/+qEv//adK//6pTv/79fLG+/v9+vv7/v/7+/7++/z///v7///7/P///P////z9///7+v3/+/z///v8///7+/7/
		+/z///v8///7/P//+/z///v8///7/P//+/z///v7/v/7+/7/+/r8//3+///noWf/5oUu//ScRP/9qEv//ahL/v6oS//9qUz896lTwPv28Av6+fjD+vv+//r7/vz7+/7+
		+/v+/vv7/v76+/3++vv+/vv7/v77+/7++/v+/vv7/v77+/7++/v+/vv7/v77+/7++/v+/vv7/v77+/7++/v+/vv7/v75+Pr+/P/+/vPTvP7ieCX+75A//vufRv7/pEn8
		/qJI/vylT8z2pE4IgAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAE=
	)
	IconChange = 
	(
		aAQAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAQAAAAGQAAABsAAAAS
		AAAACAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHx8fFt
		+Pj4tfj4+LXPz89/AAAAJgAAABMAAAAFAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAADy8vIuyLqzyGI3IP9iNyD/+Pj4tTs7O0MAAAAiAAAADAAAAAIAAAAA
		AAAAAAAAAAAAAAACAAAABAAAAAUAAAAEAAAAAvb29mv4+Pi1fkcq/7GRgNrCwsKI
		AAAANAAAABcAAAAFAAAAAAAAAAAAAAACAAAACQAAABIAAAAYAAAAEgAAAAsAAAAI
		5ubmcr6YhNqUVDH/2MO4yG9vb2UAAAAsAAAAEgAAAAAAAAACAAAACd/f33b4+Pi1
		ysrKggAAADAAAAAgAAAAFsXFxWPNqZPWpmE3/8igh9qzs7OTAAAARAAAACQAAAAC
		AAAACd/f33b4+Pi1sms5//j4+LW5ubmOx8fHhPj4+LX4+Pi1ypt64LJrOf+yazn/
		+Pj4tfj4+LXPz89/AAAABOjo6HH4+Pi1uHE5/7hxOf+4cTn/+Pj4tfj4+LW4cTn/
		uHE5/7hxOf+4cTn/uHE5/7hxOf+4cTn/+Pj4tfPz82z4+Pi1vXg5/714Of+9eDn/
		vXg5/714Of/4+Pi1+Pj4tb14Of+9eDn/vXg5/714Of+9eDn/+Pj4td/f33b4+Pi1
		wn85/8J/Of/Cfzn/wn85/8J/Of/Cfzn/wn85//j4+LX4+Pi1wn85/8J/Of/Cfzn/
		+Pj4td/f33YAAAAJ9vb2a/j4+LX4+Pi1xoc5/8aHOf/Xrnrg+Pj4tfj4+LXm5uZy
		8fHxbfj4+LXGhzn/+Pj4tejo6HEAAAAJAAAAAgAAAAAAAAAA8/PzbN26iNrKjjn/
		4MGU1qenp3UAAAAqAAAAEAAAAAP29vZr+Pj4tfPz82wAAAAEAAAAAgAAAAAAAAAA
		AAAAAPLy8i7q2brIzpc4/9+/iNrHx8eEAAAALQAAABYAAAAFAAAAAQAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB8/PzbOTJhtrVqDX/+Pj4tdTU1HwAAAAZ
		AAAACAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOnp6RH4+Pi1
		2rUz/9q1M//u4rnIw8PDOQAAAAUAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAA9vb2a/j4+LX4+Pi17+/vbgAAAAcAAAADAAAAAQAAAAAAAAAA
		AAAAAAAAAAAAAAAA/gEAAP4AAAD+AAAA4AAAAMAAAACAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAADAAQAAwB8AAMAfAADgHwAA8B8AAA==
	)
	IconPlayPause = 
	(
		UAoAACgAAAAZAAAAMgAAAAEAIAAAAAAAxAkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAQAAAAEAAAABAAAAAQAAAAAAAAAA
		AAAAAAAAAAAAAAABAAAAAQAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB
		AAAAAQAAAAIAAAACAAAAAgAAAAIAAAABAAAAAQAAAAEAAAABAAAAAQAAAAIAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAHAAAADwAAABAAAAAKAAAAAwAAAAIAAAABAAAAAQAAAAIAAAAE
		AAAAAwAAAAIAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKmpqQPJyckTAAAAFgAAABcAAAAX
		AAAAFwAAABUAAAAHAAAAA+zs7Cnn5+cqAAAACQAAAAgAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAPv7+0D+/PqS9uXTnfHx8W66uro8AAAAFwAAABcAAAAXAAAAF+vr61nsxJ2t7MSdreXl5VcAAAANAAAAAwAAAAEAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///wL+/PqS0nQY7s1mAf/Wgi/g9d/Kn9/f31k9PT0dAAAAFwAAABf9/f2P
		zmgE/M5qCPr9/f2LAAAAEQAAAAQAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD///8K+e3hmdBpBP/QaQT/
		0GkE/9FtC/rjpWfD/vz6ks3NzUgAAAAX////kdBpBP/QaQT/////kQAAABEAAAAEAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAA////Cfvx55fTbAf/02wH/9NsB//TbAf/02wH/9h9Iury1bam5OTkXv///5HTbAf/02wH/////5EAAAAR
		AAAABAAAAAIAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///wn78eeX13AL/9dwC//XcAv/13AL/9dwC//XcAv/
		13EN/uakZMf///+R13AL/9dwC/////+RAAAADQAAAAMAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD///8J
		+/Hnl9t0D//bdA//23QP/9t0D//bdA//23QP/9t0D//bdhL8/vz6ktt0D//bdA//////kQAAAAcAAAACAAAAAQAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////Cfzy6JfgeRP/4HkT/+B5E//geRP/4HkT/+B5E//gehX+7Kxsxv///5HgeRP/
		4HkT/////5EAAAADAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///wn88uiX5X4Y/+V+GP/lfhj/
		5X4Y/+V+GP/ojjXp+Ny/pP///1T///+R5X4Y/+V+GP////+RAAAAAgAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAD///8K/PDkmemCHP/pghz/6YIc/+qFIvryt3zB//37kv///zgAAAAA////kemCHP/pghz/////kQAAAAEAAAAB
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////Av/9+5LvjzHy7och//GeS9/86dWe////Tv///wMAAAAA
		AAAAAP///47uiCT87oon+v///4oAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD///9E
		/vjylf3n0p////9m////KwAAAAAAAAAAAAAAAAAAAAD///9S+9WvrPvVr6z///9OAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///wX///8TAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///yT///8k
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////gP///4D///+A////gP8Hh4D+AAOA/gADgP4AA4D8AAOA+AABgPgAAYD4AAGA
		+AADgPgAA4D4AAOA+AADgPgCB4D4Bh+A/B4fgP5/P4D///+A////gP///4D///+A////gA==
	)
	IconStop = 
	(
		aAQAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAANmrlAC4WysAuFsrAL5gLQDBYy4AwWMuAMtqMADLajAA
		y2owANFvMgDRbzIA13Q0ANd0NADtupkAAAAAAAAAAAC0WCoA3HA7AOB6RQDjgU4A
		5YxXAOiVXwDqnGYA7aVuAPCtdgD0t34A976FAPnEiQD5xIkA13Q0AAAAAAAAAAAA
		tFgqAN1sNgDSYSUA1GYoANhtLQDXdDQA4H05AOSEPgDpjkYA7ZdMAPCdUAD0pVYA
		+cSJANd0NAAAAAAAAAAAALRYKgDdbDYA0F0iANJhJQDYbS0A13Q0AOB9OQDkhD4A
		5olCAOqQRwDtl0wA8J1QAPe+hQDRbzIAAAAAAAAAAACyVikA3Ww2ANBdIgDSYSUA
		2G0tANhtLQDddjQA4H05AOSEPgDmiUIA6Y5GAO2XTADztHwA0W8yAAAAAAAAAAAA
		slYpAN1yQQDOWiAA0mElANJhJQDYbS0A13Q0AN12NADgfTkA5IQ+AOaJQgDmiUIA
		8K12AMtqMAAAAAAAAAAAALJWKQDjiV0AzlogANBdIgDSYSUA2G0tANhtLQDXdDQA
		3XY0AOB9OQDgfTkA5IQ+AO2lbgDLajAAAAAAAAAAAACvVCkA5ZRsANd3RQDUZigA
		0F0iANJhJQDVaCkA2G0tAN12NADddjQA4H05AN54NgDqnGYAyGcwAAAAAAAAAAAA
		r1QpAOWZcgDYeUcA2HlHAN1yQQDWbjYA2G0tANVoKQDVaCkA2G0tANhtLQDXdDQA
		6JVfAMFjLgAAAAAAAAAAAK9UKQDlnXgA13hIANd4SADYeUcA2HlHANh5RwDYeUcA
		4HpFANx7QQDbeT4A3HtBAOiVYwDBYy4AAAAAAAAAAACqUScA5qF+ANZ3SADYeUcA
		2HlHANh5RwDYeUcA2HlHANx7QQDYeUcA3H1JANh5RwDolWMAwWMuAAAAAAAAAAAA
		qE8mAOajggDagVUA2oFVANqBVQDagVUA3H1JANqBVQDcfUkA3H1JANh5RwDjgU4A
		44ldALhbKwAAAAAAAAAAAKZNJgDlnXgA5qOCAOahfgDlmXIA5ZlyAOWUbADolWMA
		44ldAOKCUgDjfEoA44FOAOKCUgC4WysAAAAAAAAAAADRpZEApk0mAKhPJgCvVCkA
		r1QpAK9UKQCvVCkAslYpALJWKQC0WCoAtFgqALRYKgC0WCoA2auUAAAAAAAAAAAA
		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		AAAAAAAAAAAAAAAA//8AAIABAACAAQAAgAEAAIABAACAAQAAgAEAAIABAACAAQAA
		gAEAAIABAACAAQAAgAEAAIABAACAAQAA//8AAA==
	)
	IconTranslate = 
	(
		aAQAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAABILAAASCwAAAAAAAAAAAAD///8A
		////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
		////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
		////AP///wD///8A////AP///wD///8A////AP///wD///8A////ALJnFgCpXhAA
		olcKAJxRBQCXTAJIl0wCSJxRBQCiVwoAqV4QALJnFgD///8A////AP///wD///8A
		////AP///wCyZxYAqV4QAKJXCgCdUgZcnFEFzJxRBcydUgZcolcKAKleEACyZxYA
		////AP///wD///8A////AP///wD///8AsmcWAKleEACjWAtcolcKzP+8Hv//uxv/
		olcKzKNYC1ypXhAAsmcWAP///wD///8A////AP///wD///8A////ALJnFgCqXxFc
		qV4QzP/DMf//sgD//7IA//++I/+pXhDMql8RXLJnFgD///8A////AP///wD///8A
		////AP///wCzaBdcsmcWzP3JSf/9vSb//bYU//y1Ev/9uh7//cAv/7JnFsyzaBdc
		////AP///wD///8A////AP///wD///8Aum8cmbtwHcy7cB3Mu3AdzPK3OP/ytTX/
		u3AdzLtwHcy7cB3Mum8cmf///wD///8A////AP///wD///8A////ALtwHQC9ch4A
		wHUgAMR5JMznslD/57BN/8R5JMzAdSAAvXIeALtwHQD///8A////AP///wD///8A
		////AP///wC7cB0AwnciAM2CKwDNgivM67pr/+a1Zf/NgivMzYIrAMJ3IgC7cB0A
		////AP///wD///8A////AP///wD///8Ayn8oANaLMQDWizEA1osxzPXIfP/1xnr/
		1osxzNaLMQDWizEAyn8oAP///wD///8A////AP///wD///8A////AN6TNwDekzcA
		3pM3AN6TN8z60YX/+tCE/96TN8zekzcA3pM3AN6TNwD///8A////AP///wD///8A
		////AP///wDkmTwA5Jk8AOSZPADkmTzM/9+T///fk//kmTzM5Jk8AOSZPADkmTwA
		////AP///wD///8A////AP///wD///8A6J0+AOidPgDonT4A6Z4/memeP8zpnj/M
		6Z4/meidPgDonT4A6J0+AP///wD///8A////AP///wD///8A////AP///wD///8A
		////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
		////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
		////AP///wD///8A//8AAP//AAD+fwAA/D8AAPgfAADwDwAA4AcAAOAHAAD8PwAA
		/D8AAPw/AAD8PwAA/D8AAPw/AAD//wAA//8AAA==
	)
	Return Icon%name%
}

InitLangArray()
{
	Languages =
	(LTrim C
		Азербайджанский|az
		Албанский|sq
		Английский|en
		Арабский|ar
		Армянский|hy
		Африкаанс|af
		Баскский|eu
		Белорусский|be
		Бенгальский|bn
		Бирманский|my
		Болгарский|bg
		Боснийский|bs
		Ваалийский|cy
		Венгерский|hu
		Вьетнамский|vi
		Галисийский|gl
		Греческий|el
		Грузинский|ka
		Гуджарати|gu
		Датский|da
		Зулу|zu
		Иврит|iw
		Игбо|ig
		Идиш|yi
		Индонезийский|id
		Ирландский|ga
		Исландский|is
		Испанский|es
		Итальянский|it
		Йоруба|yo
		Казахский|kk
		Каннада|kn
		Каталанский|ca
		Китайский|zh
		Китайский (Аомынь)|zh-cn
		Китайский (Тайвань)|zh-tw
		Корейский|ko
		Латынь|la
		Латышский|lv
		Литовский|lt
		Македонский|mk
		Малагасийский|mg
		Малайский|ms
		Малайялам|ml
		Мальтийский|mt
		Маори|mi
		Маратхи|mr
		Монгольский|mn
		Немецкий|de
		Непали|ne
		Нидерландский|nl
		Норвежский|no
		Панджаби|pa
		Персидский|fa
		Польский|pl
		Португальский|pt
		Румынский|ro
		Русский|ru
		Себуанский|ceb
		Сербский|sr
		Сесото|st
		Сингальский|si
		Словацкий|sk
		Словенский|sl
		Сомали|so
		Суахили|sw
		Суданский|su
		Тагальский|tl
		Таджикский|tg
		Тайский|th
		Тамильский|ta
		Телугу|te
		Турецкий|tr
		Узбекский|uz
		Украинский|uk
		Урду|ur
		Финский|fi
		Французский|fr
		Хауса|ha
		Хинди|hi
		Хмонг|hmn
		Хорватский|hr
		Чева|ny
		Чешский|cs
		Шведский|sv
		Эсперанто|eo
		Эстонский|et
		Яванский|jw
		Японский|ja
	)

	Loop, parse, Languages, `n, `r
	{
		Key := RegExReplace(A_LoopField, "(.*)\|.*", "$1")
		Value := RegExReplace(A_LoopField, ".*\|(.*)", "$1")
		LangArray[Key] := Value
	}
}

/*
 *  ActiveScript for AutoHotkey v1.1
 *
 *  Provides an interface to Active Scripting languages like VBScript and JScript,
 *  without relying on Microsoft's ScriptControl, which is not available to 64-bit
 *  programs.
 *
 *  License: Use, modify and redistribute without limitation, but at your own risk.
 */
class ActiveScript extends ActiveScript._base
{
    __New(Language)
    {
        if this._script := ComObjCreate(Language, ActiveScript.IID)
            this._scriptParse := ComObjQuery(this._script, ActiveScript.IID_Parse)
        if !this._scriptParse
            throw Exception("Invalid language", -1, Language)
        this._site := new ActiveScriptSite(this)
        this._SetScriptSite(this._site.ptr)
        this._InitNew()
        this._objects := {}
        this.Error := ""
        this._dsp := this._GetScriptDispatch()  ; Must be done last.
        try
            if this.ScriptEngine() = "JScript"
                this.SetJScript58()
    }

    SetJScript58()
    {
        static IID_IActiveScriptProperty := "{4954E0D0-FBC7-11D1-8410-006008C3FBFC}"
        if !prop := ComObjQuery(this._script, IID_IActiveScriptProperty)
            return false
        VarSetCapacity(var, 24, 0), NumPut(2, NumPut(3, var, "short") + 6)
        hr := DllCall(NumGet(NumGet(prop+0)+4*A_PtrSize), "ptr", prop, "uint", 0x4000
            , "ptr", 0, "ptr", &var), ObjRelease(prop)
        return hr >= 0
    }
    
    Eval(Code)
    {
        pvar := NumGet(ComObjValue(arr:=ComObjArray(0xC,1)) + 8+A_PtrSize)
        this._ParseScriptText(Code, 0x20, pvar)  ; SCRIPTTEXT_ISEXPRESSION := 0x20
        return arr[0]
    }
    
    Exec(Code)
    {
        this._ParseScriptText(Code, 0x42, 0)  ; SCRIPTTEXT_ISVISIBLE := 2, SCRIPTTEXT_ISPERSISTENT := 0x40
        this._SetScriptState(2)  ; SCRIPTSTATE_CONNECTED := 2
    }
    
    AddObject(Name, DispObj, AddMembers := false)
    {
        static a, supports_dispatch ; Test for built-in IDispatch support.
            := a := ((a:=ComObjArray(0xC,1))[0]:=[42]) && a[0][1]=42
        if IsObject(DispObj) && !(supports_dispatch || ComObjType(DispObj))
            throw Exception("Adding a non-COM object requires AutoHotkey v1.1.17+", -1)
        this._objects[Name] := DispObj
        this._AddNamedItem(Name, AddMembers ? 8 : 2)  ; SCRIPTITEM_ISVISIBLE := 2, SCRIPTITEM_GLOBALMEMBERS := 8
    }
    
    _GetObjectUnk(Name)
    {
        return !IsObject(dsp := this._objects[Name]) ? dsp  ; Pointer
            : ComObjValue(dsp) ? ComObjValue(dsp)  ; ComObject
            : &dsp  ; AutoHotkey object
    }
    
    class _base
    {
        __Call(Method, Params*)
        {
            if ObjHasKey(this, "_dsp")
                try
                    return (this._dsp)[Method](Params*)
                catch e
                    throw Exception(e.Message, -1, e.Extra)
        }
        
        __Get(Property, Params*)
        {
            if ObjHasKey(this, "_dsp")
                try
                    return (this._dsp)[Property, Params*]
                catch e
                    throw Exception(e.Message, -1, e.Extra)
        }
        
        __Set(Property, Params*)
        {
            if ObjHasKey(this, "_dsp")
            {
                Value := Params.Pop()
                try
                    return (this._dsp)[Property, Params*] := Value
                catch e
                    throw Exception(e.Message, -1, e.Extra)
            }
        }
    }
    
    _SetScriptSite(Site)
    {
        hr := DllCall(NumGet(NumGet((p:=this._script)+0)+3*A_PtrSize), "ptr", p, "ptr", Site)
        if (hr < 0)
            this._HRFail(hr, "IActiveScript::SetScriptSite")
    }
    
    _SetScriptState(State)
    {
        hr := DllCall(NumGet(NumGet((p:=this._script)+0)+5*A_PtrSize), "ptr", p, "int", State)
        if (hr < 0)
            this._HRFail(hr, "IActiveScript::SetScriptState")
    }
    
    _AddNamedItem(Name, Flags)
    {
        hr := DllCall(NumGet(NumGet((p:=this._script)+0)+8*A_PtrSize), "ptr", p, "wstr", Name, "uint", Flags)
        if (hr < 0)
            this._HRFail(hr, "IActiveScript::AddNamedItem")
    }
    
    _GetScriptDispatch()
    {
        hr := DllCall(NumGet(NumGet((p:=this._script)+0)+10*A_PtrSize), "ptr", p, "ptr", 0, "ptr*", pdsp)
        if (hr < 0)
            this._HRFail(hr, "IActiveScript::GetScriptDispatch")
        return ComObject(9, pdsp, 1)
    }
    
    _InitNew()
    {
        hr := DllCall(NumGet(NumGet((p:=this._scriptParse)+0)+3*A_PtrSize), "ptr", p)
        if (hr < 0)
            this._HRFail(hr, "IActiveScriptParse::InitNew")
    }
    
    _ParseScriptText(Code, Flags, pvarResult)
    {
        VarSetCapacity(excp, 8 * A_PtrSize, 0)
        hr := DllCall(NumGet(NumGet((p:=this._scriptParse)+0)+5*A_PtrSize), "ptr", p
            , "wstr", Code, "ptr", 0, "ptr", 0, "ptr", 0, "uptr", 0, "uint", 1
            , "uint", Flags, "ptr", pvarResult, "ptr", 0)
        if (hr < 0)
            this._HRFail(hr, "IActiveScriptParse::ParseScriptText")
    }
    
    _HRFail(hr, what)
    {
        if e := this.Error
        {
            this.Error := ""
            throw Exception("`nError code:`t" this._HRFormat(e.HRESULT)
                . "`nSource:`t`t" e.Source "`nDescription:`t" e.Description
                . "`nLine:`t`t" e.Line "`nColumn:`t`t" e.Column
                . "`nLine text:`t`t" e.LineText, -3)
        }
        throw Exception(what " failed with code " this._HRFormat(hr), -2)
    }
    
    _HRFormat(hr)
    {
        return Format("0x{1:X}", hr & 0xFFFFFFFF)
    }
    
    _OnScriptError(err) ; IActiveScriptError err
    {
        VarSetCapacity(excp, 8 * A_PtrSize, 0)
        DllCall(NumGet(NumGet(err+0)+3*A_PtrSize), "ptr", err, "ptr", &excp) ; GetExceptionInfo
        DllCall(NumGet(NumGet(err+0)+4*A_PtrSize), "ptr", err, "uint*", srcctx, "uint*", srcline, "int*", srccol) ; GetSourcePosition
        DllCall(NumGet(NumGet(err+0)+5*A_PtrSize), "ptr", err, "ptr*", pbstrcode) ; GetSourceLineText
        code := StrGet(pbstrcode, "UTF-16"), DllCall("OleAut32\SysFreeString", "ptr", pbstrcode)
        if fn := NumGet(excp, 6 * A_PtrSize) ; pfnDeferredFillIn
            DllCall(fn, "ptr", &excp)
        wcode := NumGet(excp, 0, "ushort")
        hr := wcode ? 0x80040200 + wcode : NumGet(excp, 7 * A_PtrSize, "uint")
        this.Error := {HRESULT: hr, Line: srcline, Column: srccol, LineText: code}
        static Infos := "Source,Description,HelpFile"
        Loop Parse, % Infos, `,
            if pbstr := NumGet(excp, A_Index * A_PtrSize)
                this.Error[A_LoopField] := StrGet(pbstr, "UTF-16"), DllCall("OleAut32\SysFreeString", "ptr", pbstr)
        return 0x80004001 ; E_NOTIMPL (let Exec/Eval get a fail result)
    }
    
    __Delete()
    {
        if this._script
        {
            DllCall(NumGet(NumGet((p:=this._script)+0)+7*A_PtrSize), "ptr", p)  ; Close
            ObjRelease(this._script)
        }
        if this._scriptParse
            ObjRelease(this._scriptParse)
    }
    
    static IID := "{BB1A2AE1-A4F9-11cf-8F20-00805F2CD064}"
    static IID_Parse := A_PtrSize=8 ? "{C7EF7658-E1EE-480E-97EA-D52CB4D76D17}" : "{BB1A2AE2-A4F9-11cf-8F20-00805F2CD064}"
}

class ActiveScriptSite
{
    __New(Script)
    {
        ObjSetCapacity(this, "_site", 3 * A_PtrSize)
        NumPut(&Script
        , NumPut(ActiveScriptSite._vftable("_vft_w", "31122", 0x100)
        , NumPut(ActiveScriptSite._vftable("_vft", "31125232211", 0)
            , this.ptr := ObjGetAddress(this, "_site"))))
    }
    
    _vftable(Name, PrmCounts, EIBase)
    {
        if p := ObjGetAddress(this, Name)
            return p
        ObjSetCapacity(this, Name, StrLen(PrmCounts) * A_PtrSize)
        p := ObjGetAddress(this, Name)
        Loop Parse, % PrmCounts
        {
            cb := RegisterCallback("_ActiveScriptSite", "F", A_LoopField, A_Index + EIBase)
            NumPut(cb, p + (A_Index-1) * A_PtrSize)
        }
        return p
    }
}

_ActiveScriptSite(this, a1:=0, a2:=0, a3:=0, a4:=0, a5:=0)
{
    Method := A_EventInfo & 0xFF
    if A_EventInfo >= 0x100  ; IActiveScriptSiteWindow
    {
        if Method = 4  ; GetWindow
        {
            NumPut(0, a1+0) ; *phwnd := 0
            return 0 ; S_OK
        }
        if Method = 5  ; EnableModeless
        {
            return 0 ; S_OK
        }
        this -= A_PtrSize     ; Cast to IActiveScriptSite
    }
    ;else: IActiveScriptSite
    if Method = 1  ; QueryInterface
    {
        iid := _AS_GUIDToString(a1)
        if (iid = "{00000000-0000-0000-C000-000000000046}"  ; IUnknown
         || iid = "{DB01A1E3-A42B-11cf-8F20-00805F2CD064}") ; IActiveScriptSite
        {
            NumPut(this, a2+0)
            return 0 ; S_OK
        }
        if (iid = "{D10F6761-83E9-11cf-8F20-00805F2CD064}") ; IActiveScriptSiteWindow
        {
            NumPut(this + A_PtrSize, a2+0)
            return 0 ; S_OK
        }
        NumPut(0, a2+0)
        return 0x80004002 ; E_NOINTERFACE
    }
    if Method = 5  ; GetItemInfo
    {
        a1 := StrGet(a1, "UTF-16")
        , (a3 && NumPut(0, a3+0))  ; *ppiunkItem := NULL
        , (a4 && NumPut(0, a4+0))  ; *ppti := NULL
        if (a2 & 1) ; SCRIPTINFO_IUNKNOWN
        {
            if !(unk := Object(NumGet(this + A_PtrSize*2))._GetObjectUnk(a1))
                return 0x8002802B ; TYPE_E_ELEMENTNOTFOUND
            ObjAddRef(unk), NumPut(unk, a3+0)
        }
        return 0 ; S_OK
    }
    if Method = 9  ; OnScriptError
        return Object(NumGet(this + A_PtrSize*2))._OnScriptError(a1)
    
    ; AddRef and Release don't do anything because we want to avoid circular references.
    ; The site and IActiveScript are both released when the AHK script releases its last
    ; reference to the ActiveScript object.
    
    ; All of the other methods don't require implementations.
    return 0x80004001 ; E_NOTIMPL
}

_AS_GUIDToString(pGUID)
{
    VarSetCapacity(String, 38*2)
    DllCall("ole32\StringFromGUID2", "ptr", pGUID, "str", String, "int", 39)
    return String
}

GetJScript()
{
	script =
	(
		var TKK = ((function() {
		  var a = 561666268;
		  var b = 1526272306;
		  return 406398 + '.' + (a + b);
		})());

		function b(a, b) {
		  for (var d = 0; d < b.length - 2; d += 3) {
				var c = b.charAt(d + 2),
					 c = "a" <= c ? c.charCodeAt(0) - 87 : Number(c),
					 c = "+" == b.charAt(d + 1) ? a >>> c : a << c;
				a = "+" == b.charAt(d) ? a + c & 4294967295 : a ^ c
		  }
		  return a
		}

		function tk(a) {
			 for (var e = TKK.split("."), h = Number(e[0]) || 0, g = [], d = 0, f = 0; f < a.length; f++) {
				  var c = a.charCodeAt(f);
				  128 > c ? g[d++] = c : (2048 > c ? g[d++] = c >> 6 | 192 : (55296 == (c & 64512) && f + 1 < a.length && 56320 == (a.charCodeAt(f + 1) & 64512) ?
				  (c = 65536 + ((c & 1023) << 10) + (a.charCodeAt(++f) & 1023), g[d++] = c >> 18 | 240,
				  g[d++] = c >> 12 & 63 | 128) : g[d++] = c >> 12 | 224, g[d++] = c >> 6 & 63 | 128), g[d++] = c & 63 | 128)
			 }
			 a = h;
			 for (d = 0; d < g.length; d++) a += g[d], a = b(a, "+-a^+6");
			 a = b(a, "+-3^+b+-f");
			 a ^= Number(e[1]) || 0;
			 0 > a && (a = (a & 2147483647) + 2147483648);
			 a `%= 1E6;
			 return a.toString() + "." + (a ^ h)
		}
	)
	Return script
}