HotKeySet('{ESC}', '_Exit') ;установка горячей клавиши для выхода

While 1
    MouseMove((@DesktopWidth / 2) + 50, @DesktopHeight / 5) ;в право от центра на 50px
    MouseMove((@DesktopWidth / 3) - 40, @DesktopHeight / 2) ;в лево от центра на 50px
WEnd

Func _Exit() ;функция для выхода
    Exit
EndFunc

