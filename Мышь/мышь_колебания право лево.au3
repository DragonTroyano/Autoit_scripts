;	скрипт двигает мышь по нажатию клавиши i вправо и влево.
;	имитирует рабочий процесс на компе

If Not HotKeySet('i','on') Then Exit MsgBox(0,'Ошибка','Эту кнопку нельзя использовать')
While 1
    Sleep(250)
WEnd
Func Mouse()
    Local $timer = TimerInit()
    Local $mouse_pos = MouseGetPos()
    Do
        MouseMove($mouse_pos[0] + 50,$mouse_pos[1],10)
        Sleep(100)
        MouseMove($mouse_pos[0] - 50,$mouse_pos[1],10)
        Sleep(100)
    Until TimerDiff($timer) > 5 * 1000 ;Двигаем мышь в течении 5 секунд
         MouseMove($mouse_pos[0],$mouse_pos[1],10)
EndFunc
Func on()
    Local Static $work = False
    $work = Not $work
    If $work Then
        ConsoleWrite('Включено' & @LF)
        Mouse()
        AdlibRegister('Mouse',10 * 60 * 1000) ;Функция Mouse автоматически запуститься через 10 минут
    Else
        ConsoleWrite('Выключено' & @LF)
        AdlibUnRegister('Mouse')
    EndIf
EndFunc