; Функция поиска нужного класса в интернете эксплорере



$sClassName = 'button-pro form-actions_yes' ; название класса который на который необходимо кликнуть
$oLinks = _IEGetObjByClass ($oIE, $sClassName)
_IEAction($oLinks, "click")

   Func _IEGetObjByClass(ByRef $o_object, $s_Class, $i_index = 0)
    If Not IsObj($o_object) Then
        __IEErrorNotify("Error", "_IEGetObjByClass", "$_IEStatus_InvalidDataType")
        SetError($_IEStatus_InvalidDataType, 1)
        Return 0
    EndIf
    ;
    If Not __IEIsObjType($o_object, "browserdom") Then
        __IEErrorNotify("Error", "_IEGetObjByClass", "$_IEStatus_InvalidObjectType")
        SetError($_IEStatus_InvalidObjectType, 1)
        Return 0
    EndIf
    ;
    Local $i_found = 0
    ;
    $o_tags = _IETagNameAllGetCollection($o_object)
    For $o_tag In $o_tags
        If String($o_tag.className) = $s_Class Then
            If ($i_found = $i_index) Then
                SetError($_IEStatus_Success)
                Return $o_tag
            Else
                $i_found += 1
            EndIf
        EndIf
    Next
    __IEErrorNotify("Warning", "_IEGetObjByClass", "$_IEStatus_NoMatch", $s_Class)
    SetError($_IEStatus_NoMatch, 2)
    Return 0
 EndFunc