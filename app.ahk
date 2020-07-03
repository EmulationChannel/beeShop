#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
Menu,TRAY,NoIcon

/*
Functions
*/

; ListBoxAdjustHSB, by TheGood
ListBoxAdjustHSB(hLB) { 
	
	;Declare variables (for clarity's sake)
	dwExtent := 0
	dwMaxExtent := 0
	hDCListBox := 0
	hFontOld := 0
	hFontNew := 0
	VarSetCapacity(lptm, 53)
	
	;Use GetDC to retrieve handle to the display context for the list box and store it in hDCListBox
	hDCListBox := DllCall("GetDC", "Uint", hLB)

	;Send the list box a WM_GETFONT message to retrieve the handle to the font that the list box is using, and store this handle in hFontNew
	SendMessage 49, 0, 0,, ahk_id %hLB%
	hFontNew := ErrorLevel

	;Use SelectObject to select the font into the display context. Retain the return value from the SelectObject call in hFontOld
	hFontOld := DllCall("SelectObject", "Uint", hDCListBox, "Uint", hFontNew)

	;Call GetTextMetrics to get additional information about the font being used (eg. to get tmAveCharWidth's value)
	DllCall("GetTextMetrics", "Uint", hDCListBox, "Uint", &lptm)
	tmAveCharWidth := NumGet(lptm, 20)

	;Get item count using LB_GETCOUNT
	SendMessage 395, 0, 0,, ahk_id %hLB%

	;Loop through the items
	Loop %ErrorLevel% {

		;Get list box item text
		s := GetListBoxItem(hLB, A_Index - 1)

		;For each string, the value of the extent to be used is calculated as follows:
		DllCall("GetTextExtentPoint32", "Uint", hDCListBox, "str", s, "int", StrLen(s), "int64P", nSize)
		dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth

		;Keep if it's the highest to date
		If (dwExtent > dwMaxExtent)
			dwMaxExtent := dwExtent
		
	}
	
	;After all the extents have been calculated, select the old font back into hDCListBox and then release it:
	DllCall("SelectObject", "Uint", hDCListBox, "Uint", hFontOld)
	DllCall("ReleaseDC", "Uint", hLB, "Uint", hDCListBox)
	
	;Adjust the horizontal bar using LB_SETHORIZONTALEXTENT
	SendMessage 404, dwMaxExtent, 0,, ahk_id %hLB%

}

GetListBoxItem(hLB, i) {
		
	;Get length of item. 394 = LB_GETTEXTLEN
	SendMessage 394, %i%, 0,, ahk_id %hLB%
	
	;Check for error
	If (ErrorLevel = 0xFFFFFFFF)
		Return ""
	
	;Prepare variable
	VarSetCapacity(sText, ErrorLevel, 0)
	
	;Retrieve item. 393 = LB_GETTEXT
	SendMessage 393, %i%, &sText,, ahk_id %hLB%
	
	;Check for error
	If (ErrorLevel = 0xFFFFFFFF)
		Return ""
	
	;Done
	Return sText

}

EnableGui() {
    GuiControl, Enable, Butt1
    GuiControl, Enable, Butt2
    GuiControl, Enable, Butt3
    GuiControl, Enable, Butt4
    GuiControl, Enable, GameList
    GuiControl, Enable, Search
}

DisableGui() {
    GuiControl, Disable, Butt1
    GuiControl, Disable, Butt2
    GuiControl, Disable, Butt3
    GuiControl, Disable, Butt4
    GuiControl, Disable, GameList
    GuiControl, Disable, Search
}

DownloadFile(UrlToFile, SaveFileAs, Overwrite := True, UseProgressBar := True, ExpectedFileSize := 0) {
	Gui, Show
	DisableGui()
    ;Check if the file already exists and if we must not overwrite it
    If (!Overwrite && FileExist(SaveFileAs))
        Return
    ;Check if the user wants a progressbar
    If (UseProgressBar) {
      ;Initialize the WinHttpRequest Object
      WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
      ;Download the headers
      WebRequest.Open("HEAD", UrlToFile)
      try {
      WebRequest.Send()
      } catch e {
      ExitApp
      }

        try {
            ;Store the header which holds the file size in a variable:
            FinalSize := WebRequest.GetResponseHeader("Content-Length")
        } catch e {
            ; Cannot get "Content-Length" header
            MsgBox % Cant get Content-Length header
        }

        LastSizeTick := 0
        LastSize := 0

        ; Enable progress bar updating if the system knows file size
        SetTimer, __UpdateProgressBar, 1500
    }

    ;Download the file
    UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
    ;Remove the timer and the progressbar because the download has finished
    If (UseProgressBar) {
        Progress, Off
        SetTimer, __UpdateProgressBar, Off
    }
    Return

    ;The label that updates the progressbar
    __UpdateProgressBar:
        ;Get the current filesize and tick
        CurrentSize := FileOpen(SaveFileAs, "r").Length ;FileGetSize wouldn't return reliable results
        CurrentSizeTick := A_TickCount

        ;Calculate the downloadspeed
        SpeedOrig  := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000))

        SpeedUnit  := "KB/s"
        Speed      := SpeedOrig

        if (Speed > 1024) {
            ; Convert to megabytes
            SpeedUnit := "MB/s"
            Speed := Round(Speed/1024, 2)
        }

        SpeedText := Speed . " " . SpeedUnit

        ;Save the current filesize and tick for the next time
        LastSizeTick := CurrentSizeTick
        LastSize := FileOpen(SaveFileAs, "r").Length

        if FinalSize = 0
        {
            PercentDone := 50
        } else {
            ;Calculate percent done
            PercentDone := Round(CurrentSize/FinalSize*100)
        }

        ;Update the ProgressBar
        GuiControl,, Progress,  %PercentDone%
		GuiControl,, SpeedGui2, %SpeedText%
    Return
}

/*
GUI
*/

Menu, tray, Icon , assets/icon.ico, 1, 1
Gui, 1:New,,beeShop
Gui, Add, Pic, x20 y4 vImg, assets\bee.tif
Gui, Add, Text, x343 y29 w200 cFFFFFF vStatus, Status: Idle
Gui, Add, Text, x343 y45 cFFFFFF vDatabase, Database: 3DSAll
Gui, Add, Text, x343 y61 cFFFFFF vSpeedGui, Speed:
Gui, Add, Text, x379 y61 w200 cFFFFFF vSpeedGui2, -
Gui, Add, ListBox, x20 y120 w293 h250 vGameList hwndGameList +HScroll
ListBoxAdjustHSB("GameList")
Gui, Add, Button, x323 y120 w107 h30 vButt1, Bump
Gui, Add, Button, x323 y160 w107 h30 vButt2, Settings
Gui, Add, Button, x323 y200 w107 h30 vButt3, Upload
Gui, Add, Edit, x323 y240 w107 h25 vSearch,
; Gui, Add, Button, x223 y240 w107 h30 vButt4, Settings
Gui, Add, Progress,x323 y327 w107 h30 vProgress cffda30, 0
Gui, Color, 333e40
Gui, Show, w450 h370, BeeShop

if (FileExist("assets/db.csv")) {
    FileRead, games, assets\db.csv
    GuiControl, Text, Database, Database: Local
    Sort, games
} else {
    MsgBox, 0, beeShop - Error, Database is missing.`n(assets/db.csv)
    ExitApp
}
games := StrSplit(games, "`n") 

Loop, % games.MaxIndex()
{
	game := games[A_Index]
	game := StrSplit(game, ",") 
    ; game[2] url
    GuiControl,, GameList, % game[1]
}
GuiControl,, Img, assets\bee2.tif
return
ButtonUpload:
DisableGui()
Goto, FTPUpload
return

ButtonBump:
Gui, Submit, NoHide

if (GameList = "") {
    MsgBox, 0, beeShop - Error, No game was selected.
} else if (FileExist("ip.txt")) {
    GuiControl, Text, Status,  Status: Downloading
    Loop, % games.MaxIndex()
    {
        game := games[A_Index]
        game := StrSplit(game, ",") 
        ; game[2] url
        If (game[1] = GameList) {
            DownloadFile(game[2], GameList . ".cia")
            GameName := GameList . ".cia"
            GuiControl,, Progress,  0
            EnableGui()
            GuiControl,, SpeedGui2, -
            Sleep, 100
            GuiControl,, Progress,  25
            break
        }
    }
Goto, FTPUpload
} else {
    MsgBox, 0, beeShop - Error, IP is not configured.
}
return

FTPUpload:
if (GameName != "") {
if FileExist(GameName) {
    if FileExist("ip.txt") {
       FileRead, IpPort, ip.txt
       IpPort := "ftp://" . Ip
       ;MsgBox % IpPort
       GuiControl,, Progress,  100
       GuiControl, Text, Status,  Status: Uploading
       FileAppend, 
       RunWait, serve.exe "%GameName%",,hide
       GuiControl,, Progress,  0
       GuiControl, Text, Status,  Status: Idle
       EnableGui()
       GameName := ""
    } else {
        MsgBox, 0, beeShop - Error, IP is not configured.
        EnableGui()
        GameName := ""
    }
    } else {
    MsgBox, 0, beeShop - Error, Game has not been found.
    EnableGui()
    GameName := ""
    }
} else {
    FileSelectFile, GameName, 1,, beeShop - Select the game, CIAs (*.cia)
    if (GameName != "") {
        Goto, FTPUpload
    } else {
        EnableGui()
    }
}
return


; Settings
; Work In Progress
ButtonSettings:
Gui, Settings:New,,Settings
Menu, tray, Icon , assets/icon.ico, 1, 1
Gui, Add, Text,cFFFFFF, IP:
if FileExist("ip.txt") {
    FileRead, ReadIp, ip.txt
}
Gui, Add, Edit, vIp w220, %ReadIp%
Gui, Add, Button, w220, Save
Gui, Color, 333e40
Gui, Show,,Settings
return

SettingsButtonSave:
Gui, Settings:Submit
if (Ip == "") {
    MsgBox, 0, beeShop - Error, Please set a valid IP.
    Gui, Show,,Settings
} else if (Ip != ReadIp) {
    FileDelete, ip.txt
    FileAppend, %Ip%, ip.txt
}
return


Enter::
Send, {Enter}
Gui,1:Submit,NoHide
GuiControl, ChooseString, GameList, %Search%
return

GuiClose:
ExitApp
