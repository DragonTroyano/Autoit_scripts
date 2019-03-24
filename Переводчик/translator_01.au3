#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         Тестовый переводчик Просто для понимания работы с API гугла

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here


$mytext = "So I'm trying to create a translation script to translate text from english to spanish. " & @crlf & "It seems my program crashes..."
$from = "en"
$to = "ru"
$url = "https://translate.googleapis.com/translate_a/single?client=gtx"
$url &= "&sl=" & $from & "&tl=" & $to & "&dt=t&q=" & $mytext

$oHTTP = ObjCreate("Microsoft.XMLHTTP")
$oHTTP.Open("POST", $url, False)
$oHTTP.Send()
$sData = $oHTTP.ResponseText
$sData = StringRegExpReplace($sData, '.*?\["(.*?)(?<!\\)"[^\[]*', "$1" & @crlf)
Msgbox(0,"", $sData)
