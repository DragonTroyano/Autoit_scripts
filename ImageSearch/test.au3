;	откройте картинку test.bmp
;	запустите срипт test.au3
;	управляйте старт стоп

#include <ImageSearch.au3>

HotKeySet("{F9}","Start")
HotKeySet("{F10}","Stop")

while 1
    sleep(1000)
WEnd



Func Start()
    Local $x1 = 0, $y1 = 0
    $result = _ImageSearch("test.bmp",1,$x1,$y1,0)
    if $result=1 Then
        MouseMove($x1,$y1,3)
    EndIf
EndFunc

Func stop()
    Exit
EndFunc