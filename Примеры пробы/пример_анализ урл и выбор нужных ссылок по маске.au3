#include <IE.au3>
#include <Array.au3>

Dim $sMyString = "http://krasimvannu.ru/"
Dim $sMyString2 = "#"
;~ Dim $sMyString3 = "ali"
Dim $aResult[1]

$sURL = 'http://krasimvannu.ru'
$oIE = _IECreate($sURL)
$oLinks = _IELinkGetCollection($oIE)

For $oLink in $oLinks
    If  StringInStr($oLink.href, $sMyString, 1) _; Если присутствует вхождение $sMyString
	   And $oLink.href <> $aResult [$aResult[0]] _;Если следующая ссылка не равна предыдущей
	   And Not StringInStr($oLink.href, $sMyString2, 1) _;если НЕ присутствует вхождение $sMyString2
	   Then
        $aResult[0] = UBound($aResult)
        _ArrayAdd($aResult, $oLink.href);добавление ссылки $oLink.href в массив $aResult
    EndIf
  Next

_ArrayDisplay($aResult) ; смотрим массив с найденными ссылками
 $randomlink = Random(2, $aResult[0], 1)
  ConsoleWrite('--->>    $aResult ' & $aResult[0] & @CRLF) ;> Запустили функцию "_test"
 ConsoleWrite('--->>    random ' & $randomlink & @CRLF) ;> Запустили функцию "_test"
 ConsoleWrite('--->>    link ' & $aResult[$randomlink] & @CRLF) ;> Запустили функцию "_test"
;~ _IEAction($aResult[$randomlink], "click")
