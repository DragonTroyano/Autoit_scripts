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
    For $i = 1 to 10
	  $iRadius = Random (30, 100, 1)
	  $aMousePos = MouseGetPos();получаем позицию мышьки
	  $iXCenter = $aMousePos[0] ; - $iRadius ;@DesktopWidth / 2
	  $iYCenter = $aMousePos[1] ;@DesktopHeight / 2
	  $ugolx = Random(90, 180, 1);180
	  $ugoly = Random(90, 180, 1);180
	  $pi = 3.14159265358979
;~  $iDelay = 5000 / 360 ;?
    $iDelay = 1
;~  BlockInput(1)
        For $i = 1 to 50
			$myx = $iXCenter + $iRadius * Cos ($i*$pi/$ugolx)
			$myy = $iYCenter + $iRadius * Sin ($i*$pi/$ugoly)

			MouseMove($myx, $myy, $iDelay)


			 If @DesktopHeight <= $aMousePos[1] Or @DesktopWidth <= $aMousePos[0] Then ExitLoop
           ; Sleep($iDelay)
        Next
;~  BlockInput(0)
Next
EndFunc

Func ScriptExit()
    Exit
EndFunc

