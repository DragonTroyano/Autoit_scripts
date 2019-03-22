#include <IE.au3>
Dim $sResult
$sUrl = @ScriptDir & '\1.html'
$oIE = _IECreate($sUrl)
$oElements = _IETagNameGetCollection($oIE, 'span')
For $oElement In $oElements
    If $oElement.className == 'user2' Then
        $oElement = _IETagNameGetCollection($oElement, 'span', 1)
        ConsoleWrite(_IEPropertyGet($oElement, 'innertext'))
        ExitLoop
    EndIf
Next