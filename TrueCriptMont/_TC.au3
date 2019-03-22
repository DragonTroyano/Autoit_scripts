;V0.1.2A
#include-Once

;Gets or sets the path of the TrueCrypt executable (only needed if truecrypt is installed to a different path)
Func _TC_Path($sPath = "")
    Static $sTCPath = @ProgramFilesDir & "\TrueCrypt\TrueCrypt.exe"
    Switch $sPath
        Case ""
            Return $sTCPath
        Case Else
            $sTCPath = $sPath
    EndSwitch
EndFunc   ;==>_TC_Path

;Mounts a TrueCrypt volume
;@Error=1: $sVol does not exist or is a directory
;@Error=2: $cLetter was not valid (must be in the format "E" not "E:" or "E:\")
;Return 1:Success
;Return 0:Failure
Func _TC_Mount($sVol, $cLetter, $sPassword = "")
    If Not FileExists($sVol) Then Return SetError(1, 0, 0)
    If StringInStr(FileGetAttrib($sVol), "D") Then Return SetError(1, 0, 0)

    If StringLen($cLetter) <> 1 Then Return SetError(2, 0, 0)
    If Not StringIsAlpha($cLetter) Then Return SetError(2, 0, 0)

    Switch $sPassword
        Case ""
            Return Not RunWait('"' & _TC_Path() & '" /q /v "' & $sVol & '" /l' & $cLetter)
        Case Else
            Return Not RunWait('"' & _TC_Path() & '" /q /s /p "' & $sPassword & '" /v "' & $sVol & '" /l' & $cLetter)
    EndSwitch
EndFunc   ;==>_TC_Mount

;Unmounts a TrueCrypt Volume
;@Error=1: $cLetter was not valid (must be in the format "E" not "E:" or "E:\")
;@Error=2: $iForce was not valid (must be 0 or "1)
;Return 1:Success
;Return 0:Failure
Func _TC_UnMount($cLetter, $iForce = 0)
    If StringLen($cLetter) <> 1 Then Return SetError(1, 0, 0)
    If Not StringIsAlpha($cLetter) Then Return SetError(1, 0, 0)
    If Not ($iForce = 0 Or $iForce = 1) Then Return SetError(2, 0, 0)

    Switch $iForce
        Case 1
            Return Not RunWait('"' & _TC_Path() & '" /s /q  /f /d' & $cLetter)
        Case 0
            Return Not RunWait('"' & _TC_Path() & '" /s /q /d' & $cLetter)
    EndSwitch
EndFunc   ;==>_TC_UnMount