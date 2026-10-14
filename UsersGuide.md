# OnScreen Clock: User's Guide



## Downloads & Runtimes

Download the latest release from the [Releases page](https://github.com/RemusRigo/OnScreenClock-Delphi/releases).

|Folder|Architecture|Required Runtime|
|-|-|-|
|`x64`|64-bit|none (native Windows app)|
|`x86`|32-bit|none (native Windows app)|

> On 64-bit Windows, use **x64**.



## Install

OnScreen Clock is portable: there is no installer.

1. Copy `Clock.exe` to a folder where you have write access, for example `D:\My Apps\OnScreen Clock\`.
2. Double-click `Clock.exe`. The clock appears in the bottom-right corner of the screen, above the taskbar,
   and a clock icon appears in the system tray.
3. Optional: to start it with Windows, press **Win+R**, type `shell:startup`, and put a shortcut to `Clock.exe` in that folder.
   Set the shortcut's **Start in** folder to the folder of `Clock.exe`, so the settings are found.

> If Windows blocks the file ("Windows protected your PC"), right-click `Clock.exe` →
> **Properties** → check **Unblock** → **OK**, then try again.



## Usage

Click the tray icon to open the menu:

|Menu|Description|
|-|-|
|**Digital**|Show the digital clock|
|**Analogue**|Show the analogue clock|
|**Config**|Choose which clock is shown at **Start** (Digital or Analogue), then click **Ok**|
|**Exit**|Close the clock|

The **Config** choice is saved in `SysClock.ini`, in the folder the clock was started from.

> The clock is placed above the taskbar when the taskbar is at the bottom of the screen.



## Uninstall

1. Click the tray icon → **Exit**.
2. Delete the shortcut from `shell:startup` (if you created one) and the folder with `Clock.exe` and `SysClock.ini`.
