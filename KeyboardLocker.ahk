;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; THE KEYBOARD LOCKER                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This script will disable the keyboard when the user       ;
; presses Ctrl+Alt+L. The keyboard is reenabled if the user ;
; types in the string "unlock".                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Originally written by Lexikos:                            ;
;  http://www.autohotkey.com/forum/post-147849.html#147849  ;
; Modifications by Trevor Bekolay for the How-To Geek       ;
;  http://www.howtogeek.com/                                ;
; Edited by Andrew Wong for personal use (no tray message)  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
FileInstall, Enabled.ico, Enabled.ico, 0
FileInstall, Disabled.ico, Disabled.ico, 0
Init()

  ;;;;;;;;;;;;;;;;;;;;;;;START PERSONAL;;;;;;;;;;;;;;;;;;;;;;;;
null: ;Menu items with no action
Return

titlehandle:
  TitleWindow()
Return

TitleWindow() {
    global blocked
    str = Keyboard Locker`n`nOriginally written by Lexikos`nModifications by Trevor Bekolay for the How-To Geek`nEdited by Andrew Wong for personal use`n`n
    If (blocked) {
        MsgBox 0,Keyboard Locker,%str%Current Status: Locked`nTo unlock, type "unlock"
    } Else {
        MsgBox 0,Keyboard Locker,%str%Current Status: Unlocked`nTo lock, press Ctrl+Alt+L
      }
  }

locktoggle:
  BlockKeyboard()
Return
;;;;;;;;;;;;;;;;;;;;;;;END PERSONAL;;;;;;;;;;;;;;;;;;;;;;;;;;

Exit:
  ExitApp
Return

; This can only execute if the keyboard is NOT blocked,
; so it can't be used to unblock the keyboard.
^!l::
  KeyWait, Ctrl ; don't block Ctrl key-up
  KeyWait, Alt  ; or Alt key-up
  KeyWait, l    ; or l-up
  BlockKeyboard()
Return

Init()
  {
    global blocked = 0
    Menu, Tray, Icon, Enabled.ico
    Menu, Tray, NoStandard
    Menu, Tray, Tip, Keyboard Locker
    Menu, Tray, Add, Keyboard Locker, titlehandle
    Menu, Tray, Add
    Menu, Tray, Add, Status: Unlocked, null
    Menu, Tray, Disable, Status: Unlocked
    Menu, Tray, Add, Press Ctrl+Alt+L to lock, locktoggle
    Menu, Tray, Add
    Menu, Tray, Add, Exit, Exit
  }

BlockKeyboard(block=-1) ; -1, true or false.
  {
    global blocked
    static hHook = 0, cb = 0

    If !cb ; register callback once only.
        cb := RegisterCallback("BlockKeyboard_HookProc")

    If (block = -1) ; Toggle
        block := (hHook=0)

    If ((hHook!=0) = (block!=0)) ; alReady (un)blocked, no action necessary.
        Return

    If (block) {
        Menu, Tray, Icon, Disabled.ico ; Change tray icon
        Menu, Tray, Rename, Status: Unlocked, Status: Locked
        Menu, Tray, Rename, Press Ctrl+Alt+L to lock, Type "unlock" to unlock
        hHook := DllCall("SetWindowsHookEx"
                , "int", 13  ; WH_KEYBOARD_LL
                , "uint", cb ; lpfn (callback)
                , "uint", 0  ; hMod (NULL)
                , "uint", 0) ; dwThreadId (all threads)
        blocked = 1
      }
    Else {

        Menu, Tray, Icon, Enabled.ico ; Change tray icon
        Menu, Tray, Rename, Status: Locked, Status: Unlocked
        Menu, Tray, Rename,  Type "Unlock" to Unlock, Press Ctrl+Alt+L to lock
        DllCall("UnhookWindowsHookEx", "uint", hHook)
        hHook = 0
        blocked = 0
      }
  }

BlockKeyboard_HookProc(nCode, wParam, lParam)
  {
    static Count = 0

    ; Unlock keyboard if "unlock" typed in
    If (NumGet(lParam+8) & 0x80) { ; key up
        If (Count = 0 && NumGet(lParam+4) = 0x16) {        ; 'u'
            Count = 1
        } Else If (Count = 1 && NumGet(lParam+4) = 0x31) { ; 'n'
            Count = 2
        } Else If (Count = 2 && NumGet(lParam+4) = 0x26) { ; 'l'
            Count = 3
        } Else If (Count = 3 && NumGet(lParam+4) = 0x18) { ; 'o'
            Count = 4
        } Else If (Count = 4 && NumGet(lParam+4) = 0x2E) { ; 'c'
            Count = 5
        } Else If (Count = 5 && NumGet(lParam+4) = 0x25) { ; 'k'
            Count = 0
            BlockKeyboard(false)
        } Else {
            Count = 0
          }
      }

    Return 1
  }
