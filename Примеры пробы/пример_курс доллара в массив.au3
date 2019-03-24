#Include <Array.au3>

;$aRate[n][0] = Цифровой код валюты
;$aRate[n][1] = Буквенный код валюты
;$aRate[n][2] = Номинал
;$aRate[n][3] = Валюта
;$aRate[n][4] = Значение

$aRate = GetRateOfExchange()
If IsArray($aRate) Then
    _ArrayDisplay($aRate)
EndIf

Func GetRateOfExchange($iTimeout = 5000)

    Local $aRates[1][5], $sUrl, $iTimer, $sXml, $aCourse, $aData

    $sUrl = 'http://www.cbr.ru/scripts/XML_daily.asp'

    $iTimer = TimerInit()
    Do
        $sXml = BinaryToString(InetRead($sUrl, 1))
        If ($sXml <> '') Then
            $aCourse = StringRegExp($sXml, '(?is)<valute.*?>(.*?)</valute>', 3)
            If ((Not @error) And IsArray($aCourse) And (UBound($aCourse) > 0)) Then
                For $i = 0 To Ubound($aCourse) -1
                    $aData = StringRegExp($aCourse[$i], '<.*?>(.*?)</.*?>', 3)
                    If ((Not @error) And IsArray($aData) And (UBound($aData) > 0) And (UBound($aData) <= 5)) Then
                        $aRates[0][0] += 1
                        ReDim $aRates[$aRates[0][0] + 1][5]
                        For $x = 0 To UBound($aData) -1
                            $aRates[$aRates[0][0]][$x] = $aData[$x]
                        Next
                    EndIf
                Next
            EndIf
            ExitLoop
        EndIf
    Until (TimerDiff($iTimer) >= $iTimeout)

    Return $aRates
 EndFunc



 ;---->
;~  #include <Array.au3>

;~ HttpSetProxy(1)

;~ Local $s_Xml, $a_Tmp, $i_Ub, $a_Ret[1]

;~ $s_Xml = BinaryToString(InetRead('http://www.cbr.ru/scripts/XML_daily.asp', 1))
;~ If @error Then Exit 13
;~ $a_Tmp = StringRegExp($s_Xml, '(?i)<[a-z]+>(.+?)<', 3)
;~ $i_Ub = UBound($a_Tmp)
;~ If (Not $i_Ub) Or (Mod($i_Ub, 5)) Then Exit 13
;~ ReDim $a_Ret[$i_Ub / 5 + 1][5]
;~ For $i = 0 To $i_Ub - 1 Step 5
;~     $a_Ret[0][0] += 1
;~     For $j = 0 To 4
;~         $a_Ret[$a_Ret[0][0]][$j] = $a_Tmp[$i + $j]
;~     Next
;~ Next
;~ $a_Tmp = 0
;~ _ArrayDisplay($a_Ret)
;---->