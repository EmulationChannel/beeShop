#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
Menu,TRAY,NoIcon
/*

External Libraries

*/

DownloadFile(UrlToFile, SaveFileAs, Overwrite := True, UseProgressBar := True, ExpectedFileSize := 0) {
	Gui, Show
	GuiControl, Disable, Butt1
	GuiControl, Disable, Butt2
    GuiControl, Disable, Butt3
	GuiControl, Disable, GameList
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
Gui, Add, Pic, x20 y4 vImg, assets\bee.tif
Gui, Add, Text, x243 y29 w200 cFFFFFF vStatus, Status: Idle
Gui, Add, Text, x243 y45 cFFFFFF, Database: 3DSAll
Gui, Add, Text, x243 y61 cFFFFFF vSpeedGui, Speed:
Gui, Add, Text, x279 y61 w200 cFFFFFF vSpeedGui2, -
Gui, Add, ListBox, x20 y120 w193 h250 vGameList
Gui, Add, Button, x223 y120 w107 h30 vButt1, Bump
Gui, Add, Button, x223 y160 w107 h30 vButt2, IP Config
Gui, Add, Button, x223 y200 w107 h30 vButt3, Fix Upload
Gui, Add, Progress,x223 y327 w107 h30 vProgress cffda30, 0
Gui, Color, 333e40
Gui, Show, w350 h370, BeeShop

whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", "https://3dsall.com/db.txt", true)
whr.Send()
whr.WaitForResponse()
games := whr.ResponseText
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

ButtonIPConfig:
if FileExist("ip.txt") {
	Run, ip.txt
} else {
	FileAppend, IP:Port, ip.txt
	Run, ip.txt
}
return

ButtonFixUpload:
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
            DownloadFile(game[2], "game.cia")
            GuiControl,, Progress,  0
            GuiControl, Enable, Butt1
            GuiControl, Enable, Butt2
            GuiControl, Enable, Butt3
            GuiControl, Enable, GameList
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
if FileExist("game.cia") {
    if FileExist("ip.txt") {
       FileRead, IpPort, ip.txt
       IpPort := "ftp://" . IpPort
       GuiControl,, Progress,  100
       GuiControl, Text, Status,  Status: Uploading
       RunWait, curl -T "%A_WorkingDir%\game.cia" %IpPort%,, hide
       GuiControl,, Progress,  0
       GuiControl, Text, Status,  Status: Idle
    } else {
        MsgBox, 0, beeShop - Error, IP is not configured.
    }
    } else {
    MsgBox, 0, beeShop - Error, game.cia has not been found
    }
return

GuiClose:
ExitApp
