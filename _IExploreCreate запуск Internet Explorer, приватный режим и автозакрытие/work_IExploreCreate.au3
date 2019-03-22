#include <WinAPIProc.au3>
#include <WinAPI.au3>
#include <func_IExploreCreate.au3>

$oIe = _IExploreCreate('ya.ru')
ConsoleWrite('PID: ' & @extended & @CRLF)
MsgBox(0, '', 'Когда завершится этот скрипт, то закроется браузер' & @CRLF & 'Нажмите OK что бы завершить скрипт')