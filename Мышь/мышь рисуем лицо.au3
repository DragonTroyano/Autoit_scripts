$MsPaintPid = Run("mspaint")

WinWait("[CLASS:MSPaintApp]")
WinActivate("[CLASS:MSPaintApp]")
WinWaitActive("[CLASS:MSPaintApp]")

BlockInput(1)

_MouseMoveCircle(220, 180, 100, 625, 1) ;Лицо
Sleep(200)
_MouseMoveCircle(180, 155, 100, 100, 1) ;улыбка (кривая :D)
Sleep(400)
_MouseMoveCircle(175, 140, 20, 625, 1) ;левый глаз
Sleep(20)
_MouseMoveCircle(260, 140, 20, 625, 1) ;правый глаз
Sleep(400)
_MouseMoveCircle(182, 145, 10, 625, 1) ;зрачек левого глаза
Sleep(20)
_MouseMoveCircle(268, 145, 10, 625, 1) ;зрачек правого глаза

BlockInput(0)

Func _MouseMoveCircle($iXPos, $iYPos, $iRadius, $iTimeExp, $iMouseClick=0); x coord, y coord, radius, time to loop (milliseconds)
    Local $TimeInit = TimerInit()
    Local $xPosMov, $yPosMov
    Local $MouseClick_Mark = 1

    Do
        $TimeDiff = TimerDiff($TimeInit)

        $xPosMov = $iXPos + ($iRadius * Sin($TimeDiff/100))
        $yPosMov = $iYPos + ($iRadius * Cos($TimeDiff/100))

        MouseMove($xPosMov, $yPosMov, 1)
        If $MouseClick_Mark = 1 And $iMouseClick <> 0 Then MouseDown("Left")
        $MouseClick_Mark = 0
    Until $TimeDiff > $iTimeExp

    If $iMouseClick <> 0 Then MouseUp("Left")
EndFunc
