; MagFeedAutomator by @Takarias
; Version 1.0 - August 24th, 2021
; This script is only designed and confirmed to work on Ephinea. I will not provide support specific to other servers.

#SingleInstance Force

; Initializing variables so it doesn't yell at me.
FeedItem := ""
FeedItemNum := 0
FeedQuant := 0
IsFirstCycle := 1

; Prevent PSO from gobbling our inputs
SetKeyDelay, 250, 100

; I need this here to skip the second part of queryUser()
Goto, TestForPSO

; Set some controls, just in case
^e::ExitApp ; In case of emergency, break glass
^r::Reload ; Restart script - this loads the script anew. Primarily for testing
^s::Goto, TestForPSO ; Start the thing, because I want the hotkeys to work

; Setting up a few functions to refer back to
queryUser()
{
	Gui, New, AlwaysOnTop -MaximizeBox -MinimizeBox
	Gui, Add, Text, , Feed Item
	Gui, Add, ListBox, r11 vFeedItem, Monomate|Dimate|Trimate|Monofluid|Difluid|Trifluid|Sol Atomizer|Moon Atomizer|Star Atomizer|Antidote|Antiparalysis
	Gui, Add, Text, , Feed Quantity
	Gui, Add, Edit
	Gui, Add, UpDown, vFeedQuant Range0-1000, 0
	Gui, Add, Button, gSaveFeed, Begin Feed
	Gui, Show
}
; I don't understand why this needs to be done here, but it sure seems to.
SaveFeed:
Gui, Submit
if (FeedItem = "" || FeedQuant = 0)
{
	MsgBox, Please select an item and quantity.
	queryUser()
	return
}
feedItemToNum(FeedItem, FeedItemNum)
Goto, BeginFeed
return

; As a courtesy, we open a dialogue box to tell the user to stop touching shit.
; After 5 seconds, the dialogue box closes and we activate the PSO window.
; This 5-second timer allows the user to go AFK, and the message hopefully makes this clear.
focusPSO(PSOPID, FeedQuant)
{
	; Single-use var for progress display.
	FeedCyclesRemaining := Ceil(FeedQuant/3)
	MsgBox, 0x2000, , Feed is about to begin! HANDS OFF THE COMPUTER UNTIL THE CURRENT FEED CYCLE IS COMPLETE.`n`nIf you are AFK`, this dialogue box will time out in a few seconds and the feed will commence without you.`n`nThere are %FeedCyclesRemaining% feed cycles still to go., 5
	if WinExist("Ephinea: Phantasy Star Online Blue Burst")
		WinActivate
	else
		MsgBox, Something broke and I don't know what yet. Please click PSO`, then clear this dialogue.
	return
}

; Convert selected FeedItem into a number, used to loop number of inputs dynamically
feedItemToNum(ByRef FeedItem, ByRef FeedItemNum)
{
	if (FeedItem = "Monomate"){
		FeedItemNum := 0
	} else if (FeedItem = "Dimate"){
		FeedItemNum := 1
	} else if (FeedItem = "Trimate"){
		FeedItemNum := 2
	} else if (FeedItem = "Monofluid"){
		FeedItemNum := 3
	} else if (FeedItem = "Difluid"){
		FeedItemNum := 4
	} else if (FeedItem = "Trifluid"){
		FeedItemNum := 5
	} else if (FeedItem = "Sol Atomizer"){
		FeedItemNum := 9
	} else if (FeedItem = "Moon Atomizer"){
		FeedItemNum := 10
	} else if (FeedItem = "Star Atomizer"){
		FeedItemNum := 11
	} else if (FeedItem = "Antidote"){
		FeedItemNum := 12
	} else if (FeedItem = "Antiparalysis"){
		FeedItemNum := 13
	} else {
		; This should never appear. But if it does, ask the user what the resulting dialogue bos reads.
		MsgBox, 0x30, , How the fuck did you break this?`n`nFeedItem: %FeedItem%`nFeedItemNum: %FeedItemNum%`nFeedQuant: %FeedQuant%
	}
	return
}

buyStuff(FeedItemNum, FeedQuant)
{
	; Don't ask me why, but we need to state this again, and only in this function.
	SetKeyDelay, 250, 100
	; Enter store
	Send, {Enter}
	Send, {Enter}
	; Move down to chosen item
	Loop, %FeedItemNum%
	{
		Send, {Down}
	}
	; Initiate purchase
	Send, {Enter}
	; Select correct quantity - We do not waste our user's money!
	if (FeedQuant > 2) {
		Send, {Up}
		Send, {Up}
	} else if (FeedQuant = 2) {
		Send, {Up}
	}
	; Confirm quantity
	Send, {Enter}
	; Actually buy
	Send, {Enter}
	; Leave store
	Send, {Backspace}
	Send, {Backspace}
	Send, {Backspace}
	return
}

feedStuff(ByRef FeedQuant)
{
	; Feed the correct number of times
	Loop % Min(FeedQuant, 3) {
		Send, {F4}
		Send, {Enter}
		Send, {Enter}
		Send, {Enter}
		Send, {F4}
		; Decrement remaining feed count
		FeedQuant := --FeedQuant
		}
	return
}

; We begin the actual script.
; First, we check to see if PSO is running.
TestForPSO:
Process, Exist, psobb.exe
; The "Process, Exists" command sets the value of ErrorLevel to the process ID, if there is a match.
If (ErrorLevel = 0) ; ErrorLevel will != 0 if process is found.
{
	; In the event PSO is not currently running, inform the user about it.
	MsgBox, 5, , PSO is not currently running.`n`nPlease open PSO and confirm that all items are removed from your inventory except the Mag you intend to feed and enough Meseta to complete the current feed schedule`, then position yourself in front of the Tools `(Items`) shop.
	IfMsgBox Retry
		; GoTo is a sin, but I think it's the cleanest way to do this.
		Goto TestForPSO
	else
		Exit
} else {
	; If PSO is curently running, we confirm the user is ready to begin.
	MsgBox, Please confirm that all items are removed from your inventory except the Mag you intend to feed and enough Meseta to complete the current feed schedule`, AND you have set your function keyes to menu instead of shortcut`, AND you are positioned in front of the Tools `(Items`) shop BEFORE pressing `'Okay`' on this dialogue box.
	; The user has now confirmed they're ready to go, and while I could set up a whole 'machine vision' thing to test that, sometimes you just have to trust the user.
	queryUser()
	return
}
BeginFeed:
; Now that the user has set everything up, we are finally ready to begin the feed!
; By which I really mean it's time to wait, so we should tell the user that, but only on the first cycle.
if (IsFirstcycle = 1) {
	MsgBox, , , Thanks for all that! Since you can only feed a Mag once every 3.5 minutes`, now we have a lot of waiting to do. You're free to step away or use your computer - anything that doesn't cause PSO to crash anyway. I'll be back to take over for a few seconds each time we need to feed your Mag., 10
	IsFirstCycle := --IsFirstCycle
	Goto, LoopPoint
	return
} else {
	Goto, LoopPoint
	return
}
LoopPoint:
; With that last explanation out of the way, we're in to the actual utility.
; We do actually need to do some sleeping, though. 210 seconds of it every cycle.
Sleep, 205000
; After waiting, we need to get the user to surrender control to us. Mwahahaha!
; This will prompt them to stop touching things and will return focus to PSO so we can do the feeding.
focusPSO(PSOPID, FeedQuant)
; Now that we have control, we need to buy stuff with the creatively-named
buyStuff(FeedItemNum, FeedQuant)
; With our items purchased, we feed them to the Mag.
feedStuff(FeedQuant)
; Great! Now we check to see if there's more feeding that needs to be done.
if (FeedQuant > 0) {
	; If there is, we just loop through this process again.
	Goto, LoopPoint
	return
} else if (FeedQuant < 1) {
	; If there's not, we thank the user and tell them we're done.
	MsgBox, , , Your feed is finally completed! Thanks for using this tool. If you would like to start a new feed`, please restart the tool.
	Exit
}