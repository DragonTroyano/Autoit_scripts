#include <IE.au3>

Local $oIE = _IECreate("http://www.google.ru")
Sleep (5000)
$oIE.Navigate("http://ya.ru", 2048)
Sleep (3000)
$oIE.Navigate("http://bing.com", 2048)
Sleep (5000)
Local $oTabIE = _IEAttach ("ya.ru", "URL")
Sleep (10000)
;~ $oTabIE.Quit()
Local $oTabIE = _IEAttach('', 'instance', 1);подключается к текущему ие

$hWnd = WinGetHandle("[ACTIVE]")
ConsoleWrite('' & $hWnd & @CRLF) ;> Если выключен то и базарить нехуй, остановились.
;~ MsgBox(4096, "", $hWnd)

$handle = WinGetHandle("[CLASS:IEFrame]")
MsgBox(4096, "", $handle)
ConsoleWrite('' & $handle & @CRLF) ;> Если выключен то и базарить нехуй, остановились.