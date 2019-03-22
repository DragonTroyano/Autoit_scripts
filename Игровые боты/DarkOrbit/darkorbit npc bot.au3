;=============================================================
; Author: trickkiste
; Download: https://thetrickkiste.com/darkorbit/npc-bot/download.html
; Help: https://thetrickkiste.com/darkorbit/npc-bot/help.html
; ieframe.dll: https://thetrickkiste.com/darkorbit/npc-bot/res/browser/embeded/ieframe.dll
;=============================================================

#include <String.au3>
#include <ImageSearch.au3>

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

$browser = ObjCreate('shell.explorer.2') ;ieframe.dll COM

$Form1 = GUICreate("DarkOrbit NPC", 1044, 603, 328, 133)
GUISetFont(10, 400, 2, "Muli")
;$Pic1 = GUICtrlCreatePic("", 0, 0, 800, 600, BitOR($SS_NOTIFY,$WS_GROUP,$WS_CLIPSIBLINGS))
$browser_obj = GUICtrlCreateObj($browser, 0, 0, 800, 600, BitOR($ES_AUTOHSCROLL, $ES_AUTOVSCROLL, $ES_WANTRETURN))
$Group1 = GUICtrlCreateGroup("Login", 808, 0, 225, 121)
$Label1 = GUICtrlCreateLabel("Username", 816, 24, 67, 20)
$Label2 = GUICtrlCreateLabel("Password", 816, 56, 64, 20)
$ip_username = GUICtrlCreateInput("", 888, 24, 137, 24)
$ip_password = GUICtrlCreateInput("", 888, 56, 137, 24, BitOR($ES_PASSWORD,$ES_AUTOHSCROLL))
$b_login = GUICtrlCreateButton("Login", 888, 88, 139, 25, $WS_GROUP)
$Checkbox1 = GUICtrlCreateCheckbox("Save", 816, 92, 57, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("General Settings", 808, 128, 225, 121)
$Checkbox2 = GUICtrlCreateCheckbox("Passiv PET", 816, 152, 89, 17)
$Checkbox3 = GUICtrlCreateCheckbox("Guard Mode", 912, 152, 97, 17)
$Checkbox4 = GUICtrlCreateCheckbox("Show FPS", 816, 184, 89, 17)
$Checkbox5 = GUICtrlCreateCheckbox("Allow Jump", 912, 184, 97, 17)
$Checkbox6 = GUICtrlCreateCheckbox("Change Config (Under Attack)", 816, 216, 209, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("NPC Settings", 808, 256, 225, 225)
$Checkbox7 = GUICtrlCreateCheckbox("Attack NPC", 816, 280, 97, 17)
$List1 = GUICtrlCreateList("", 816, 312, 209, 102, BitOR($LBS_SORT,$LBS_MULTIPLESEL,$LBS_STANDARD,$WS_VSCROLL,$WS_BORDER))
GUICtrlSetData(-1, "Devolarium|Kristallin|Kristallon|Lordakia|Lordakium|Mordon|Saimon|Sibelonit|Sibleon|StrueneR|Struener")
$Checkbox8 = GUICtrlCreateCheckbox("Circle NPC", 816, 408, 97, 17)
$Checkbox9 = GUICtrlCreateCheckbox("Follow NPC", 920, 408, 97, 17)
$Ammunition = GUICtrlCreateCombo("", 896, 440, 129, 25, BitOR($ES_READONLY,$CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "LCB-10|MCB-25|MCB-50|UCB-100")
$Label4 = GUICtrlCreateLabel("Ammunition", 816, 442, 80, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group4 = GUICtrlCreateGroup("Flee Settings", 808, 488, 225, 105)
$Checkbox10 = GUICtrlCreateCheckbox("Flee On Attack", 816, 512, 113, 17)
$Label3 = GUICtrlCreateLabel("HP % Flee", 816, 538, 67, 20)
GUICtrlCreateCombo("", 888, 536, 137, 25, BitOR($ES_READONLY,$CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "90%|80%|70%|60%|50%|40%|30%|20%|10%")
$Checkbox11 = GUICtrlCreateCheckbox("Wait For 100% HP", 816, 568, 137, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
			
			Case $b_login
				$rUsername = GUICtrlRead($ip_username)
				$rPassword = GUICtrlRead($ip_password)
				$rSave = GUICtrlRead($Checkbox1)
				
				If $rUsername == '' Or $rPassword == '' Then
					MsgBox(48, 'Login Error', 'No username or password was entered')
				EndIf
				
				If $rSave == 1 Then
					IniWrite('userdata.ini', 'auth', 'username', $rUsername)
					IniWrite('userdata.ini', 'auth', 'password', $rPassword)
				EndIf
				
				Local $a = __darkorbit_login($rUsername, $rPassword, 'http://www.darkorbit.com')
				If $a  == 0 Then
					MsgBox(48, 'Login Failed', 'Chould not login')
				Else
					__darkorbit_load_game($a)
				EndIf

	EndSwitch
WEnd


Func __darkorbit_load_game($url)
	RunWait('RunDLL32.exe InetCpl.cpl, ClearMyTracksByProcess 255')
	$browser.navigate($url)
	$browser = 0
EndFunc   ;==>__darkorbit_load_game

Func __darkorbit_login($u, $p, $l)
	$http = ObjCreate('winhttp.winhttprequest.5.1') ;open winhttp COM
	$http.open('GET', $l) ;opens a connection to darkorbit.com
	$http.send() ;sends request
	$http.WaitForResponse(5000) ;waits maximum of 5 seconds for return
	$www_darkorbit_response = $http.ResponseText() ;gets the html source code of darkorbit.com
	$auth_bpsecure_token = _StringBetween($www_darkorbit_response, 'class="bgcdw_login_form" action="', '">') ;reads the bpsecure token
	$auth_bpsecure_token = StringTrimLeft($auth_bpsecure_token[0], StringInStr($auth_bpsecure_token[0], '')) ;trims token from array to regular string
	$auth_bpsecure_token = StringReplace($auth_bpsecure_token, '&amp;', '&') ;replace &amp; with & symbol
	$http.open('POST', $auth_bpsecure_token) ;opens a POST connection to bpsecure with token url
	$http.SetRequestHeader('Content-Type', 'application/x-www-form-urlencoded') ;set request header
	$net_post_login = 'username=' & _Encode($u) & '&password=' & $p ;packet format for username and password. username must be encoded to support special char
	$http.send($net_post_login) ;sends request
	$http.WaitForResponse(5000) ;waits maximum of 5 seconds for return
	$auth_session_location = $http.GetResponseHeader('Location') ;gets ProjectApi authorization user and token
	$http.open('GET', $auth_session_location) ;opens connection with new token url
	$http.send() ;sends request
	$http.WaitForResponse(5000) ;waits maximum of 5 seconds for return
	$http_response_auth = $http.ResponseBody() ;gets html source in binary
	$bin2string_auth = BinaryToString($http_response_auth) ;converts to string
	$auth_cookie = $http.GetResponseHeader('Set-Cookie') ;reads cookie headers
	$auth_bpsecure_sid = _StringBetween($auth_cookie, 'dosid=', '; path=/') ;gets dosid (session id)
	$auth_bpsecure_sid = StringTrimLeft($auth_bpsecure_sid[0], StringInStr($auth_bpsecure_sid[0], '')) ;trims sid from array to regular string

	$user_darkorbit_server = _StringBetween($bin2string_auth, 'rel="meta" href="http://', '.darkorbit.bigpoint') ;reads current server. also used to see if login username and/or password are correct/incorrect
	If @error Then
		Return 0
	EndIf
	If $user_darkorbit_server[0] == 0 Then ;checks if array is equar to 0 (no server was found)
		Return 0
	EndIf

	$http = 0 ;closes connection
	Return 'http://' & $user_darkorbit_server[0] & '.darkorbit.bigpoint.com/indexInternal.es?action=internalMapRevolution&dosid=' & $auth_bpsecure_sid ;complete link
EndFunc   ;==>__darkorbit_login

Func _Encode($string) ;username encoding function
	$UBinary = StringToBinary($string, 4)
	$UBinary2 = StringReplace($UBinary, '0x', '', 1)
	$UBinaryLength = StringLen($UBinary2)
	Local $encoded
	For $i = 1 To $UBinaryLength Step 2
		$UBinaryChar = StringMid($UBinary2, $i, 2)
		If StringInStr("", BinaryToString('0x' & $UBinaryChar, 4)) Then
			$encoded &= BinaryToString('0x' & $UBinaryChar)
		Else
			$encoded &= '%' & $UBinaryChar
		EndIf
	Next
	Return $encoded
EndFunc   ;==>_Encode
