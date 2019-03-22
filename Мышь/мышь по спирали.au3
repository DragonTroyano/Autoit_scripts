$iR = @DesktopHeight / 4
$iX = @DesktopWidth / 4
$iY = @DesktopHeight / 4

HotKeySet('{F5}', '_MouseSpiral')
HotKeySet('{ESC}', '_Exit')

While 1
    Sleep(20)
WEnd

Func _MouseSpiral()
    Local Const $degToRad = 3.14159265358979 / 180
    Local $iRn = $iR
    MouseMove($iX + $iR, $iY, 0)
    $i = 0
    While 1
        $i += 4
        $iRn = $iR - $i / 10
        If $iRn <= 0 Then
            ExitLoop
        EndIf
        MouseMove($iX + $iRn * Cos($i * $degToRad), $iY + $iRn * Sin($i * $degToRad), 0)
        Sleep(1)
    WEnd
    MouseMove($iX, $iY, 0)
EndFunc   ;==>_MouseSpiral

Func _Exit()
    Exit
EndFunc   ;==>_Exit
