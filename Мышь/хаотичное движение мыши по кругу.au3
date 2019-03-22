HotKeySet ("{F5}", "ScriptExit")
HotKeySet("{F1}", 'OnOff')
$bNeed = False
While 1
    Sleep(1000)
WEnd

Func OnOff()
    $bNeed = Not $bNeed
    Play()
EndFunc

Func Play()
    While $bNeed
    $iXCenter = @DesktopWidth / 2
    $iYCenter = @DesktopHeight / 2
    $iRadius = 100
    $pi = 3.14159265358979
;~  $iDelay = 50000 / 360 ;?
    $iDelay = 1
;~  BlockInput(1)
        For $i = 1 to 360

		   $iRadius = $iRadius + Random (-10, 10, 1)
            MouseMove($iXCenter + $iRadius * Cos($i*$pi/180), $iYCenter + $iRadius * Sin($i*$pi/180), 0)
            Sleep($iDelay)
        Next
;~  BlockInput(0)
WEnd
EndFunc

Func ScriptExit()
    Exit
EndFunc

