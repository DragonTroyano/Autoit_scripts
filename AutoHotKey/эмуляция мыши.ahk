#SingleInstance, force
Menu, Tray, Icon, %A_WinDir%\system32\main.cpl, 1, 0
DetectHiddenWindows, on
SetNumLockState AlwaysOn
CoordMode, Mouse, Screen
SetDefaultMouseSpeed, 0
SetMouseDelay 0
N = 5    ; ����������� ���������, ����� ������ 0-20
s = 3    ; ����������� ��������, ����� ������ 1-20

Gui, Color, aaaaaa
Gui, Add, Progress, vMyProgress1 w7 h50 cRed  Range1-20  Vertical, %N%
Gui, Add, Progress, vMyProgress2 w7 h50 cGreen Range0-20  Vertical x+1, %s%
GUI, Show, hide, cmspeed
WinSet, TransColor, aaaaaa 180, cmspeed
GUI, -Caption +ToolWindow ;+AlwaysOnTop

GUI2Text=
(
����������� �������:

- �����                 {Num4}
- ����                  {Num5}
- ������                {Num6}
- �����                 {Num8}

* ����������� ��������� ������
  ��� ����������� �� ���������

��������       {Alt+}   {Alt-}
���������    {Shift+} {Shift-}


������ �����: 

- ���                   {Num7}
- ���                   {Num9}
- ���                   {Num2}

- ������ �����          {Num1}
- ������ ����           {Num3}
)
Gui 2: Font, s10, Lucida console
Gui, 2: +toolwindow +caption +border
Gui, 2: Add, Text,  , %GUI2Text%
Gui, 2: Add, Text, y+20 cBlue gahkcom, www.autohotkey.com
Gui, 2: Add, Text, y+10 cBlue gscinfo, www.script-coding.com
Gui, 2: Add, Button, y+15 w70 default, OK
Gui, 2: Add, Picture, icon1 x250 y350, %SystemRoot%\system32\main.cpl

Menu, Tray, NoStandard
Menu, Tray, Add, ������%a_tab%F9, vk78
Menu, Tray, Add, ���������%a_tab%F11, vk7a
Menu, Tray, Add
Menu, Tray, Add, �����%a_tab%F12, vk7b


vk67:: LButton    ; numpad7 ��������� ������� ����� ������ ����
vk69:: RButton    ; numpad9 ��������� ������� ������ ������ ����
vk62:: MButton    ; numpad2 ��������� ������� ������� ������ ����
vk61:: Click WheelUp    ; numpad1 ��������� ������� ������ �����
vk63:: Click WheelDown    ; numpad3 ��������� ������� ������ ����

vk65:: ; numpad 5 ��������� ����������� ���� ����
vk64:: ; numpad 4 ��������� ����������� ���� �����
vk66:: ; numpad 6 ��������� ����������� ���� ������
vk68:: ; numpad 8 ��������� ����������� ���� �����
    While GetKeyState(A_ThisHotkey, "P") || GetKeyState(A_PriorHotkey, "P")
    {
    k := a_index*s*N/40
    shift := N = 0 ? s : k

        if GetKeyState("vk65", "P")
        {
            if GetKeyState("vk64", "P")
                x := -shift, y := shift
            Else if GetKeyState("vk66", "P")
                x := y := shift
            Else
                x := 0, y := shift
        }
        Else if GetKeyState("vk64", "P")
        {
            if GetKeyState("vk65", "P")
                x := -shift, y := shift    
            Else if GetKeyState("vk68", "P")
                x := y := -shift
            Else
                x := -shift, y := 0
        }
        Else if GetKeyState("vk66", "P")
        {
            if GetKeyState("vk68", "P")
                x := shift, y := -shift
            Else if GetKeyState("vk62", "P")
                x := y := shift
            Else
                x := shift, y := 0
        }
        Else if GetKeyState("vk68", "P")
        {
            if GetKeyState("vk66", "P")
                x := shift, y := -shift    
            Else if GetKeyState("vk64", "P")
                x := y := -shift
            Else
                x := 0, y := -shift
        }
        MouseMove, x, y, 0, R
        Sleep, 20
    }
    Return


^vk6B:: ; Ctrl+ ��������� ��������� ----------------------
^vkBB::
IF flag11<>1
    {
    MouseGetPos, xpos, ypos
    GUI, Show, x %xpos% y %ypos% ; NA, cmspeed
    flag11=1
    }
IF N < 20
    {
    N := N+1
    GuiControl,, MyProgress1, %N%
    }
return

^vk6D:: ; Ctrl- ������� ��������� ----------------------
^vkBD::
IF flag12<>1
    {
    MouseGetPos, xpos, ypos
    GUI, Show,x %xpos% y %ypos% ; NA, cmspeed
    flag12=1
    }
IF N > 0
    {
    N := N-1
    GuiControl,, MyProgress1, %N%
    }
return

!vk6B:: ; Alt+ ��������� �������� ----------------------
!vkBB::
IF flag21<>1
    {
    MouseGetPos, xpos, ypos
    GUI, Show, x %xpos% y %ypos% ; NA, cmspeed
    flag1=21
    }
IF s < 20
    {
    s := s+1
    GuiControl,, MyProgress2, %s%
    }
return

!vk6D:: ; Alt- ������� �������� ----------------------
!vkBD::
IF flag22<>1
    {
    MouseGetPos, xpos, ypos
    GUI, Show,x %xpos% y %ypos% ; NA, cmspeed
    flag22=1
    }
IF s > 1
    {
    s := s-1
    GuiControl,, MyProgress2, %s%
    }
return

*vk6B up::
*vkBB up::
gui hide
flag11=0
flag21=0
return

*vk6D up::
*vkBD up::
gui hide
flag12=0
flag22=0
return

vk78::    ; F9 - help
Gui, 2: Show, Center h400 w300,������
return

vk7a::    ; F11 - suspend
Suspend
If A_IsSuspended = 1
    {
    Menu, Tray, Icon, %A_WinDir%\system32\shell32.dll, 220, 1
    menu, tray, rename, ���������%a_tab%F11, ��������%a_tab%F11
    }
Else
    {
    Menu, Tray, Icon, %A_WinDir%\system32\main.cpl, 1, 1
    menu, tray, rename, ��������%a_tab%F11, ���������%a_tab%F11
    }
return

vk7b::    ; F12 - exit
Suspend, Permit
ExitApp

2ButtonOK:
2GuiClose:
2GuiEscape:
Gui,2: cancel
return

ahkcom:
Run www.autohotkey.com
return

scinfo:
Run www.script-coding.com
return