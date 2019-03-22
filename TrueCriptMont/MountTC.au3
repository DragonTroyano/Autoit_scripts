#AutoIt3Wrapper_icon=lock.ico
#include "_TC.au3"


$result=True
_TC_Path("D:\LiberKey\Apps\TrueCrypt\App\TrueCrypt\TrueCrypt.exe")
if DriveStatus("W:\")<> "INVALID" Then ;Check if we're already mounted
    $result=True
else
    $result =_TC_Mount("M:\www-server.iso","W")
EndIf

If $result = True Then

    $PID = ProcessExists("dropbox.exe") ; Will return the PID or 0 if the process isn't found.
	ConsoleWrite('PID is:     ' & $PID & @CRLF) ;> написали об этом в консоли
    If not $PID Then
        $result= Run ("C:\Program Files (x86)\Dropbox\Client\Dropbox.exe")
		ConsoleWrite('Run DropBox:     ' & $PID & @CRLF) ;> написали об этом в консоли
        if not $result then MsgBox(0,"Dropbox Error", "Could not load DropBox",5)
    EndIf

    ;Restart indexing service so we pick up the TrueCrypt partition
    $result = RunWait(@ComSpec & " /c " & 'sc stop wsearch', "", @SW_HIDE)
    Sleep(3000)
    $result = RunWait(@ComSpec & " /c " & 'sc start wsearch"', "", @SW_HIDE)

    ;$result = Run(@ComSpec & " /c " & "C:\users\user1\Documents\Scripts\Restart Windows Search Indexing Task.lnk")

Else
   MsgBox(0,"Mount Cancelled","Secure Partition has not been mounted.",1)
EndIf