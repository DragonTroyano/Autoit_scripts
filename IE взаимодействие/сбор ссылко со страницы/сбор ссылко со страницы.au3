; Open browser with basic example, get link collection,
; loop through items and display the associated link URL references

#include <IE.au3>
#include <MsgBoxConstants.au3>

$sLogin = 'orraz@yandex.ru'
$sPass = 'anwcub'
$sUrl = '192.168.8.1'

Local $oIE = _IECreate($sUrl)

;Local $oIE = _IE_Example("basic")
Local $oLinks = _IELinkGetCollection($oIE)
Local $iNumLinks = @extended

Local $sTxt = $iNumLinks & " links found" & @CRLF & @CRLF
For $oLink In $oLinks
   ConsoleWrite($oLink.href & @CRLF) ;> Запустили функцию "_modem"
    $sTxt &= $oLink.href & @CRLF
Next
MsgBox($MB_SYSTEMMODAL, "Link Info", $sTxt)
ConsoleWrite('---->>    Run Func _modem:' & @CRLF) ;> Запустили функцию "_modem"