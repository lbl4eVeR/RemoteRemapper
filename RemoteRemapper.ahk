SetTitleMatchMode 1
#SingleInstance, Force
#Persistent

VarSetCapacity(RemoteRemapperIcon16, 1536 << !!A_IsUnicode)
RemoteRemapperIcon16 := "AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB8fHzYfICDYICAg/yIiIv8mJibQKSopKgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAhISHNIyMj/yYmJv4qKir+Li4u/zQzM70AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIyMj8SgnKP8vLy//NzU1/0E9Pv9JREXhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACcnJ/UvLi7/OjY3/0VAQf9STU7/W1hW5wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAtLS35OTY2/0lDRP9VUFD/YVxd/29qau4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOzo6/klERf9YU1T/Y19g/3NvcP+Ef3/zAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAElJSf5BQUH/Pz8//0BAQP9BQkL/SkpL9gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBQUH+RERE/1dXV/9WVlb/RkZG/0lJSf0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARUVF/k5OTv9JSUn/R0dH/1BQUP9GRkb+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE5OTv5QUVH/U1NT/1NTUv9SU1P/UlBR/gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABIQ0P+T0tK/1ZUVv9UUVT/TEZH/0ZCQ/oAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOzg4/j46Of9MS1T/SEhR/zQyMv8xMTH0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC0sLPosLCz/Kysq/ygpKP8mJyf/JSUl8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkJST1JCQk/yQkJP8jIyP/ISEh/yAgIPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHx8fzx0dHv8hIR//ISAe/xwcHf8cHBzDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABwcHDMcHBzQGxwc/xsbHP4cHBzJGhoaLAAAAAAAAAAAAAAAAAAAAAAAAAAA+B8AAPgfAAD4HwAA+B8AAPgfAAD4HwAA+B8AAPgfAAD4HwAA+B8AAPgfAAD4HwAA+B8AAPgfAAD4HwAA+B8AAA=="

Menu, Tray, noStandard
Menu, Tray, Icon, % "HICON:*" . EmbeddedIcon(RemoteRemapperIcon16)
Menu, Tray, Tip, Fernbedienungshelfer
If !( A_IsCompiled ) {
Menu, Tray, add, Edit This Script, edit_script
Menu, Tray, add ; adds a separator line
}
Menu, Tray, add, Reload , tray_reload
Menu, Tray, add, Pause , tray_pause
Menu, Tray, add ; adds a separator line
Menu, Tray, add, Exit , exit

Browser_Home::
	If FileExist(A_AppData "\Mozilla\Firefox\Profiles\stream\") {
			For process In ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process Where Name = 'firefox.exe'") {
			If (process.CommandLine ~= "i)-no-remote -p stream") {
				WinActivate, % "ahk_pid " process.processID
				Sleep,100
				Send ^{Browser_Home}
				Return
				}
			}
			Run, "Firefox" -no-remote -p stream
			ChangeFirefoxIcon()
			Return
	}
	If ProcessExist("brave.exe") {
		WinActivate, ahk_exe brave.exe
		Sleep,100
		Send ^{Browser_Home}
		Return
	} Else {
		Try {
			Run, "Brave"
		} Catch e {
			Try
				Run, "Firefox" -new-tab "https://startseite.tiiny.site"
			Catch e
				Return
			ChangeFirefoxIcon()
		}
	}
Return

/*

Enter::
	If (WinActive("ahk_exe brave.exe") and MousePosControl("Chrome_RenderWidgetHostHWND1")) or WinActiveFullscreen("Brave")
		Send {Space}
	Else
		Send {Enter}
Return

*/

Left::
	If WinActive("ahk_exe vlc.exe")
		Send {+P}
	Else
		Send {Left}
Return

Right::
	If (WinActive("ahk_exe brave.exe") and MousePosControl("Chrome_RenderWidgetHostHWND1")) or WinActiveFullscreen("Brave")
		If (WinActive("Netflix") and MousePosControl("Chrome_RenderWidgetHostHWND1")) or WinActiveFullscreen("Netflix")
			Send s
	Send {Right}
Return

AppsKey::
	If (WinActive("ahk_exe brave.exe") and MousePosControl("Chrome_RenderWidgetHostHWND1")) or WinActiveFullscreen("Brave")
		Send {f}
	Else
		Send {RButton}
Return

edit_script:
	Run, "Notepad" "%A_ScriptName%"
Return

tray_reload:
	Reload
	Sleep 1000
	MsgBox, 4, , The script could not be reloaded and will need to be manually restarted. Would you like Exit?
	IfMsgBox, Yes, ExitApp
Return

tray_pause:
	If (a_isPaused = 1) {
		Pause off
		Menu, Tray, unCheck, Pause
	} Else {
		Menu, Tray, check, Pause
		Pause on
	}
Return

exit:
ExitApp

RegRead, SystemUsesLightTheme, % "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", % "SystemUsesLightTheme"
If ( !SystemUsesLightTheme ) {
	uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
	SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
	FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
	DllCall(SetPreferredAppMode, "int", 1) ; Dark
	DllCall(FlushMenuThemes)
}

EmbeddedIcon(B64) {
	If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0) {
	   Return False
	}
	VarSetCapacity(Dec, DecLen, 0)
	If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0) {
	   Return False
	}
	hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
	pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
	DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
	DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
	DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
	hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
	VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
	DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
	DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
	DllCall("Gdiplus.dll\GdipCreateHICONFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
	DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
	DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
	DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
	DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
Return hBitmap
}

ProcessExist(Name) {
	Process,Exist,%Name%
	Return Errorlevel
}

MousePosControl(ControlInput) {
	MouseGetPos,,,id,control
Return (ControlInput = control) ? true : false
}

WinActiveFullscreen(winTitle) {
	winID := WinExist( winTitle )
	If ( !winID )
		Return false
	WinGet style, Style, ahk_id %WinID%
	WinGetPos ,,,winW,winH, %winTitle%
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}

ChangeFirefoxIcon() {
	If FileExist(A_ScriptDir "\firefoxstream.ico") {
		WinWait Mozilla Firefox
		hIcon := DllCall("LoadImage", uint, 0, str, A_ScriptDir "\firefoxstream.ico", uint, 1, uint, 0, uint, 0, uint, uint 0x10)
		hWnd := WinExist(Mozilla Firefox)
		SendMessage, WM_SETICON:=0x80, ICON_SMALL:=0, hIcon,, ahk_id %hWnd% ; Set the window's small icon
		SendMessage, WM_SETICON:=0x80, ICON_BIG:=1, hIcon,, ahk_id %hWnd%   ; Set the window's big icon
		SendMessage, WM_SETICON:=0x80, ICON_SMALL2:=2, hIcon,, ahk_id %hWnd%    ; Set the window's small icon
	}
}