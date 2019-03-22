;not that i dont think the others are good, but I just rewrote it from scratch.
;
;Screen dimention is 1920 x 1080

; 3 basic elements
;	1 - need to move systematicly (or randomly) on the minЗадание А
;   2 - need to scan while moving.
;   3 - need to pickup what we find.

;problem with using an icon, or a picture search is that the object is rotating, its going to change, also the picture is 3d, it will be bigger/smaller all the time.

; my approach will be find the first color, if found, search for a second within a small area of the first, if found, look for a 3rd.

;Set our hotkeys first and make our functions at the end.
HotKeySet("{ESC}", "myExit")	;when pressing Escape, exit the program.

;set our variables.

;Screen Scanning area. this is an imaginary rectangle / square in the middle of the screen we will be scanning OnAutoItExitRegister

;$Screen1[0] = 423
;$Screen1[1] = 196

;$Screen2[0] = 1497
;$Screen2[1] = 946

MsgBox(0,"Calibration: Top Left Play Area","Place your Mouse at the TOP LEFT most portion of the screen that is CLEAR of any interface. Press SPACE when ready.")
$Screen1 = MouseGetPos()

MsgBox(0,"Calibration: Bottom Right Play Area","Place your Mouse at the BOTTOM RIGHT most portion of the screen that is CLEAR of any interface. Press SPACE when ready.")
$Screen2 = MouseGetPos()


;The mini map is in this area. again rectangle.
;$MiniMapX1 = 1560
;$MiniMapY1 = 818
;$MiniMapX2 = 1887
;$MiniMapY2 = 1015

MsgBox(0,"Calibration: Top Left MiniMap","Place your Mouse at the TOP LEFT most portion of the minimap. Press SPACE when ready.")
$MiniMap1 = MouseGetPos()

MsgBox(0,"Calibration: Bottom Right MiniMap","Place your Mouse at the BOTTOM RIGHT most portion of the minimap. Press SPACE when ready.")
$MiniMap2 = MouseGetPos()


;These will be the colors we are looking for.

$Endurium_color_1 = 0x57C1E3 ;light blueish color
$Endurium_color_2 = 0x378AD8 ;darker blueish color;

;didnt know what they were call, so Box1 is the bright one with the yellow orange color and blue aura.
$Box1_color_1 = 0xFFFFFF ;pure white
$Box1_color_2 = 0xFFDAAA ;dark orange color

$ShadeVariant = 20  ;this is how much the color can be "off" by. it give is the ability to allow lighter/darker colors.

$ColorSearchCounter = 0 ; use this to keep track of how many times we are clicking in an area.

$HuntCounter = 0;


;Head to the Top Left side of the minimap
MouseClick("left",$MiniMap1[0],$MiniMap1[1],1)
Sleep(10000) ;10 second delay to get to the top left....

$CurrentHuntPoint = $MiniMap1 ;using this to set our current hunting pointer.
;divide up the minimap into a grid of 20 by 20 steps.
$X_Steps = ($MiniMap2[0] - $MiniMap1[0]) / 5  ;
$Y_Steps = ($MiniMap2[1] - $MiniMap1[1]) / 5  ;

$Hunting = True;

;start an infinint loop
while(1)
   ;activate our window. I will be using chrome
   WinActivate("DarkOrbit")
   ;Created a function to do the pixel searches for us so we can just call the function
   SearchForColor($Endurium_color_1, $Endurium_color_2)
   SearchForColor($Box1_color_1,$Box1_color_2)
   Sleep(250)


   if $Hunting = True Then
	  $HuntCounter = $HuntCounter + 1
	  if $HuntCounter = 10 Then
		 $HuntCounter = 0
			if $CurrentHuntPoint[0] + $X_Steps > $MiniMap2[0] Then
			  if $CurrentHuntPoint[1] + $Y_Steps > $MiniMap2[1] Then
				 $CurrentHuntPoint = $MiniMap1 ;reset hunt position back to the top left side
			  Else
				 $CurrentHuntPoint[0] = $MiniMap1[0] ;set X back to 0
				 $CurrentHuntPoint[1] = $CurrentHuntPoint[1] + $Y_Steps ;increment Y by our steps.
			  EndIf
			Else
			   $CurrentHuntPoint[0] = $CurrentHuntPoint[0] + $X_Steps
			EndIf
		 MouseClick("left",$CurrentHuntPoint[0],$CurrentHuntPoint[1],'1')
	  EndIf
   EndIf
WEnd



func SearchForColor($col1, $col2)
   ;Scan our area first to see if theres anything here.
   ;look for first color NOTE this is a reverse search, bottom to top search.
	  $Found = PixelSearch($Screen1[0],$Screen1[1] , $Screen2[0], $Screen2[1], $col1,$ShadeVariant)
	  If Not @error Then
		 ;ok, we found the first color, lets look for the second within 32 pixels of that first one
			SetError(0) ;clear the error first so we can search again.
			$Found = PixelSearch($Found[0] - 32,$Found[1] - 32 , $Found[0] + 32, $Found[1] + 32, $col2, $ShadeVariant)
			If Not @error Then
			  ;We found the second color, lets look for the second within 32 pixels of that first one
			   MouseClick("left",$Found[0],$Found[1],1,1)
			   sleep(3000) ;wait 3 seconds while we move/search
			   SearchForColor($col1, $col2) ;recursive this function till we hit it.
			EndIf
		 EndIf

;ok, for some reason the search is only looking at TOP 1/2 of search area. Im adding a 2nd search (reverse) to do the bottom half
   ;Scan our area first to see if theres anything here.
   ;look for first color NOTE this is a reverse search, bottom to top search.
	  $Found = PixelSearch($Screen2[0],$Screen2[1] , $Screen1[0], $Screen1[1], $col1,$ShadeVariant)
	  If Not @error Then
		 ;ok, we found the first color, lets look for the second within 32 pixels of that first one
			SetError(0) ;clear the error first so we can search again.
			$Found = PixelSearch($Found[0] - 32,$Found[1] - 32 , $Found[0] + 32, $Found[1] + 32, $col2, $ShadeVariant)
			If Not @error Then
			  ;We found the second color, lets look for the second within 32 pixels of that first one
			   MouseClick("left",$Found[0],$Found[1],1,1)
			   sleep(3000) ;wait 3 seconds while we move/search
			   SearchForColor($col1, $col2) ;recursive this function till we hit it.
			EndIf
	  EndIf
EndFunc





func myExit()
   exit
EndFunc