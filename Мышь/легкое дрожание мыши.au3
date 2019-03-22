;Переменные
$moushaos = 100;переменная паузы во время дрожания мыши

$time = Random(5, 10, 1) * 1000

$start = TimerInit(); старт
While TimerDiff($start) < $time

$aMousePos = MouseGetPos();получаем позицию мышьки
$iX = $aMousePos[0]
$iY = $aMousePos[1]
MouseMove($iX + Random (-1, 1, 1), $iY + Random(-1, 1, 1), 100);Сдвиг курсора на один пиксель "Вниз"
Sleep (100)

WEnd

