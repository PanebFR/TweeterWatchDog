#NoEnv
#Persistent
SetWorkingDir %A_ScriptDir%

;You need to use something to generate RSS based on Twitter, like this one : https://www.labnol.org/internet/twitter-rss-feed/28149/
;The URL provides with this script in var RssTwitter should be looking for #AutoHotKey.
;Please tried it out! :) 

RssTwitter := "https://script.google.com/macros/s/AKfycbzjst7qEt785uOklbnGFqYk8adF87twnEPHjFhDL4Fw_IPu2yhu/exec?834685062180384769"
NewTwitterFile := "lastRSS.txt"
OldTwitterFile := "olderRSS.txt"
 
GoSub checkMyTweet
SetTimer, checkMyTweet, 120000
Return
 
checkMyTweet:
IfNotExist, %OldTwitterFile%
	{
		UrlDownloadToFile, %RssTwitter%, %OldTwitterFile%
		Return
	}
UrlDownloadToFile, %RssTwitter%, %NewTwitterFile%
NewTwitterArray := Object()
OldTwitterArray := Object()
NewTwitterContentArray := Object()
 
FileRead, myFile, %A_ScriptDir%\%NewTwitterFile%
pos := 0
While, pos := RegExMatch(myFile, "<pubDate.*?</pubDate>", entree, pos + 1)
{
  NewTwitterArray[ A_Index ] := entree
}
pos:=0
While, pos := RegExMatch(myFile, "/a>.*?]]", entree, pos + 1)
{
	  StringTrimRight, entree, entree, 2
	  StringTrimLeft, entree, entree, 3
      NewTwitterContentArray[ A_Index ] := entree
}
 

FileRead, myFile, %A_ScriptDir%\%OldTwitterFile%
pos := 0
While, pos := RegExMatch(myFile, "<pubDate.*?</pubDate>", entree, pos + 1)
{
  OldTwitterArray[ A_Index ] := entree
}
 
dateToDisplay := Object ()
tweetToDisplay := Object()
ArrayCountTray := 0
If(NewTwitterArray[1] == OldTwitterArray[1])
{
	;Return ; Please uncomment if you don't want the tray tip "no new tweet"
	TrayTip , Tweeter RSS-AHK-Feed, No new tweet from our birds :(, 10	
}
Else
{
	ArrayCountNew := NewTwitterArray._MaxIndex() 
	ArrayCountOld := OldTwitterArray._MaxIndex()
 
 
	Loop %ArrayCountNew%
	{	
		saveIndex := A_Index
		store := 1
		Loop %ArrayCountOld%
		{
			If(OldTwitterArray[A_Index] == NewTwitterArray [saveIndex]){
				store := 0
			}
 
		}
		If(store == 1){
			ArrayCountTray := ArrayCountTray+1
			dateToDisplay%ArrayCountTray% := NewTwitterArray [saveIndex]
			tweetToDisplay%ArrayCountTray% := saveIndex
		}
 
 
	}
}
 
Loop %ArrayCountTray%
{
	element := dateToDisplay%A_Index%
	StringTrimLeft, element, element, 9
	StringTrimRight, element, element, 10
	tmp := tweetToDisplay%A_Index%
	tweet := NewTwitterContentArray[tmp]
	TrayTip , Tweeter RSS-AHK-Feed, New tweet : %tweet% !, 10
	Sleep 10000
}
 
FileDelete, %A_ScriptDir%\%OldTwitterFile%
FileMove, %A_ScriptDir%\%NewTwitterFile%, %A_ScriptDir%\%OldTwitterFile%
Return
