#include <Constants.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>

 _AvtoStart ()	;автоматический старт виртуальных машин при запуске утилиты
 _Config ()		;чтение конфиг файла, обычно он находиться в @ScriptDir&"\conf.ini"

;Получаем список виртуальных машин
;Local $pid = Run(@HomeDrive & $sReadDir & "VBoxManage.exe" & " list vms", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
Local $pid = Run(_Config() & "VBoxManage.exe" & " list vms", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

   ProcessWaitClose($pid)
	  $output=StdoutRead($pid)

$iList = StringRegExpReplace($output, '\{.+', '')
	$stringListTemp= StringRegExpReplace($iList, '"', '')
		$stringList = StringRegExpReplace($stringListTemp, ' ', '')
				$array_Sum=StringSplit($stringList,@CRLF,1)

$hGUI = GUICreate("VBoxUtils - Фоновый запуск", 350, 235)

GUICtrlCreateLabel("Выберите виртуальную систему для запуска в фоновом режиме."& @LF & @LF & _
					 "Список ваших виртуальных машин" & @LF & @LF & $stringList & @LF, 10, 23)
   $iF_Input = GUICtrlCreateInput("", 10, 200, 180, 20)
   $iOK_Button = GUICtrlCreateButton("Пуск", 200, 199, 80, 23)

GUISetState(@SW_SHOW, $hGUI)

While 1
    Switch GUIGetMsg()

        Case $GUI_EVENT_CLOSE
            Exit

		Case $iOK_Button
			$iGoto = GUICtrlRead($iF_Input)

		$i = 0
		While $i <= $array_Sum[0]-1 ;-1 потому, что  $output=StdoutRead($pid) выдает лишнюю пустую строку в конце
					If ($array_Sum[$i] = $iGoto) Then
						$iStart = _Config() & "VBoxHeadless.exe --startvm " & $array_Sum[$i]
						ConsoleWrite($iStart)
						Run($iStart,"",@SW_HIDE)
						MsgBox(64, 'Start VBox', 'Старт виртуальной машины ' & $iGoto)
					EndIf
			$i = $i + 1
		WEnd

EndSwitch
WEnd

Func _Config ()
	If FileExists(@ScriptDir & "\conf.ini") Then
	$sPath_ini = @ScriptDir & "\conf.ini"
		$sReadDir = IniRead($sPath_ini, "workdir", "VMdir", "Значение по умолчанию")
			If $sReadDir = "" Then
				MsgBox(64, "Error", "Не найден путь до VirtualBox, удалите файл настроек conf.ini и запустите утилиту еще раз")
				Exit
			EndIf
				Return $sReadDir
Else
	;MsgBox(0,'Первый запуск','Cейчас вам будет предложенно выбрать рабочую папку VirtualBox')
	$sPath = FileSelectFolder('Выберите системную папку VBox', @DesktopDir)
		If FileExists($sPath & "\VirtualBox.exe") Then
			FileWrite(@ScriptDir & "\conf.ini", "[workdir]"& @CRLF & "VMdir="&$sPath & @CRLF)
			FileWrite(@ScriptDir & "\conf.ini", "[avtostart]"& @CRLF & "startvm=" & @CRLF)
		Else
			MsgBox(16,'Ой всё', 'эта папка не VirtualBox, выберите другую')
			$sPath = FileSelectFolder('Выберите системную папку VBox', @DesktopDir)
				If FileExists($sPath & "\VirtualBox.exe") Then
					FileWrite(@ScriptDir & "\conf.ini", "[workdir]"& @CRLF & "VMdir="&$sPath & @CRLF)
					FileWrite(@ScriptDir & "\conf.ini", "[avtostart]"& @CRLF & "startvm=" & @CRLF)
				Else
					MsgBox(16,'','ОЙ ВСЁ, Вы не знаете что такое VirtualBox')
						Exit
				EndIf
		EndIf
	EndIf
EndFunc

Func _AvtoStart ()
	If FileExists(@ScriptDir & "\conf.ini") Then
		$sPath_ini = @ScriptDir & "\conf.ini"
		$sReadDir = IniRead($sPath_ini, "workdir", "VMdir", "Значение по умолчанию")
		$sReadVM = IniRead($sPath_ini, "avtostart", "startvm", "Значение по умолчанию")
			$iSpit = StringSplit($sReadVM, ",")
				If $iSpit[1]  = "" Then
;~ 					_ArrayDisplay($iSpit)
					Sleep(500)
				Else
					$i =0
						While $i <= $iSpit[0]
							If ($iSpit[$i]  = 0) Then
								$iStart = $sReadDir& "VBoxHeadless.exe --startvm " & $iSpit[$i]
								;ConsoleWrite($iStart & @CRLF)
							EndIf
					$i = $i + 1
				WEnd
			EndIf
	EndIf
EndFunc
