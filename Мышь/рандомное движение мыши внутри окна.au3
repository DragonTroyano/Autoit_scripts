; случайное время от 3 до 10 секунд
$time = Random(5, 15, 1) * 1000
; запуск
Run("calc.exe")
$wnd = WinWaitActive("Calculator")
; позиция окна
$pos = WinGetPos($wnd)
; старт
$start = TimerInit()
; двигаем мышь по случайным координатам внутри окна, пока не выйдет время
While TimerDiff($start) < $time
  MouseMove(Random($pos[0], $pos[0] + $pos[2], 1), Random($pos[1], $pos[1] + $pos[3], 1))
WEnd
; кликаем кнопку
ControlClick($wnd, "", "Button3")

