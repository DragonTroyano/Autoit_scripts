#include <IE.au3>
#include <Array.au3>

Dim $aoIE[101][3] = [[100, 'Url', 'Title']]
$iCount = 0
$oIE = _IECreate('http://www.google.ru/')
$oForm = _IEGetObjById($oIE, 'tsf')
$oInput = _IEFormElementGetObjByName($oForm, 'q')
_IEFormElementSetValue($oInput, 'AutoIt')
_IEFormSubmit($oForm)
$oLinks = _IETagNameGetCollection($oIE, 'a')
For $oLink In $oLinks
    If $oLink.classname == 'LC20lb' Then
        $iCount += 1
        _IEAction($oLink, 'click')
    EndIf
    If $iCount = 9 Then ExitLoop
Next
$oLink = 0
$oLinks = 0
$oInput = 0
$oForm = 0
$oIE = 0
$iCount = 0
While 1
    $iCount += 1
    $aoIE[$iCount][0] = _IEAttach('', 'Instance', $iCount)
    If @error Then ExitLoop
    $aoIE[$iCount][1] = _IEPropertyGet($aoIE[$iCount][0], 'locationurl')
    $aoIE[$iCount][2] = _IEPropertyGet($aoIE[$iCount][0], 'title')
WEnd
ReDim $aoIE[$iCount][3]
$aoIE[0][0] = $iCount - 1
_ArrayDisplay($aoIE)
For $i = 1 To $aoIE[0][0]
    If StringInStr($aoIE[$i][2], 'Русское сообщество AutoIt') Then
        _IELinkClickByText($aoIE[$i][0], 'Автоматизация IE и Web-интерфейса')
    Else
        _IEQuit($aoIE[$i][0])
    EndIf
    Sleep(1000)
Next