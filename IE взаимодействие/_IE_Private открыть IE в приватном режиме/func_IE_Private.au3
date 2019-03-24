#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
Func _IE_Private()
    Local $url = 'about:' & Random()
;~  Local $pid = Run(@ProgramFilesDir & "\Internet Explorer\iexplore.exe -noframemerging -private " & " " & $url)
    ;или
    Local $pid = ShellExecute("iexplore.exe", "-noframemerging -private " & " " & $url)
    If @error Then Return SetError(1, @error, False)
    Local $win = WinWait("[CLASS:IEFrame]", $url, 30)
    For $oie In ObjCreate("Shell.Application").Windows()
        If $win = HWnd($oie.hwnd) Then Return SetExtended($pid, $oie)
    Next
    If $pid Then ProcessClose($pid)
    Return SetError(2, @error, False)
EndFunc   ;==>_IE_Private
