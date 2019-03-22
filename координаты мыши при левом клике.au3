#include <Misc.au3>
HotKeySet("{ESC}","stop")


$dll = DllOpen("user32.dll")


While 1
    Sleep(50)
    If _IsPressed("01", $dll) Then ;Ожидание, в цикле, нажатия ЛКМ
        $aCoord=MouseGetPos()
         ToolTip("Нажата ЛКМ"&@CRLF&"Координаты: x="&$aCoord[0]&" y="&$aCoord[1], Default, Default, '_IsPressed', 1)
;~      Sleep(800)
;~         ExitLoop
    EndIf

WEnd
Func stop()
    Exit
EndFunc

DllClose($dll)