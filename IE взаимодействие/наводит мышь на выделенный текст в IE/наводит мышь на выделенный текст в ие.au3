#include <ie.au3>
Local $oIe = _IEAttach('', 'instance', 1);подключается к текущему ие
If Not IsObj($oIe) Then Exit MsgBox(0, 0, -1);если такого объекта нет, то выход

Local $selection = $oIe.document.getSelection();получение выделения в переменную
If Not IsObj($selection) Then Exit MsgBox(0, 0, -2);если нет то выход

Local $selectText = $selection.toString()
If Not $selectText Then Exit MsgBox(0, 0, -1)
ConsoleWrite('Выделен фрагмент: ' & $selectText & @CRLF)

Local $oDispHTMLDOMRange = $selection.getRangeAt(0)
If Not IsObj($oDispHTMLDOMRange) Then Exit MsgBox(0, 0, -3)

Local $oIHTMLRect = $oDispHTMLDOMRange.getBoundingClientRect()
If Not IsObj($oIHTMLRect) Then Exit MsgBox(0, 0, -4)

Local $tPoint = DllStructCreate("int X;int Y")
DllStructSetData($tPoint, "X", $oIHTMLRect.left)
DllStructSetData($tPoint, "Y", $oIHTMLRect.top)

Local $hCtrl = ControlGetHandle(HWnd($oIe.hwnd), '', '[CLASS:Internet Explorer_Server; INSTANCE:1]')
DllCall("user32.dll", "bool", "ClientToScreen", "hwnd", $hCtrl, "struct*", $tPoint)

WinActivate(HWnd($oIe.hwnd))
MouseMove(DllStructGetData($tPoint, "X"), DllStructGetData($tPoint, "Y"))
