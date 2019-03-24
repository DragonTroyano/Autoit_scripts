; ������������ ������������� Chrome ������ 53

#include "UIAutomate.au3"

Opt("WinTitleMatchMode", 2)

; ������ �����������
Global $sLogin = "User"
Global $sPassword = "12345"

; ������ Chrome � ���������� --force-renderer-accessibility
; ��� ���������� ����� ��������� ������ � ��������� �������� ����� ��������
Run(@ProgramFilesDir & "\Google\Chrome\Application\chrome.exe --force-renderer-accessibility")
$hWnd = WinWait(" - Google Chrome", "", 3)
If Not $hWnd Then Exit

; �������� �������� � �������������� ����������� ����
$oParent = _UIA_GetElementFromHandle($hWnd)

; ����� ������ � ������ "����� �������" � ���� �� ���
$oElement = _UIA_GetControlTypeElement($oParent, "UIA_ButtonControlTypeId", "����� �������")
_UIA_ElementMouseClick($oElement)

; ����� ������ ������ � ��������� ������
$oElement = _UIA_GetControlTypeElement($oParent, "UIA_EditControlTypeId", "�������� ������ � ������ ������")
_UIA_ElementTextSetValue($oElement, "autoit-script.ru")

; ������� �� ����
Send("{enter}")

; �������� �������� �������� �� ������� �������� "�������� ���������"
_UIA_WaitControlTypeElement($oParent, "UIA_TextControlTypeId", "�������� ���������")

; ���������� ������ ������
$UIA_ConsoleWriteError = 0

; ����� �������� ��� ����� ������
$oElement = _UIA_GetControlTypeElement($oParent, "UIA_EditControlTypeId", True, "IsPassword")

; ��������� ������ ������
$UIA_ConsoleWriteError = 1

; ����������� ��� ������� ���� ������
If IsObj($oElement) Then

  ; ��������� ������ � ���� ������ � ���� ������
  _UIA_ElementSetFocus($oElement)
  Send($sPassword)

  ; ���������� ���� ������
  Send("+{tab}")
  Send($sLogin)

  ; ����� � ������� ������ "����"
  $oElement = _UIA_GetControlTypeElement($oParent, "UIA_ButtonControlTypeId", "����")
  _UIA_ElementDoDefaultAction($oElement)
EndIf

; �������� �������� �������� �� ������� ������ "������� � ������� �������"
$oElement = _UIA_WaitControlTypeElement($oParent, "UIA_HyperlinkControlTypeId", "������� � ������� �������")

; �������� �������� �����������
If Not IsObj($oElement) Then Exit

; ������� �� ������ "������� � ������� �������"
_UIA_ElementDoDefaultAction($oElement)

; �������� �������� �������� �� ������� ����� ����� �������� " ��� �� ������ �� ����� ��������"
_UIA_WaitControlTypeElement($oParent, 0xC364, "�� ������ �� �����", Default, True)

; ����� �������� ������, ��������� ������, ���� ������
$oElement = _UIA_GetControlTypeElement($oParent, "UIA_EditControlTypeId", "")
_UIA_ElementSetFocus($oElement)
Send("UIAutomate")

; ����� � ������� ������ "�����"
$oElement = _UIA_GetControlTypeElement($oParent, 0xC350, "�����")
_UIA_ElementDoDefaultAction($oElement)