//-------------------------------------------------------------------------------------------------
// On-Screen Clock
//    © 2008 Remus Rigo
//       v1.0.20080218
//-------------------------------------------------------------------------------------------------

unit CommonWnd;

interface

//-------------------------------------------------------------------------------------------------

uses
   Windows, Dialogs, SysUtils;

//-------------------------------------------------------------------------------------------------

function GetTaskBarHeight : Integer;
function GetTaskBarWidth  : Integer;
function GetTaskBarRect   : TRect;

//-------------------------------------------------------------------------------------------------

implementation

//-------------------------------------------------------------------------------------------------

function GetTaskBarHeight : Integer;
var
   tbHwnd : HWND;
   tbRect : TRect;
begin
   tbHwnd:=FindWindow('Shell_TrayWnd', '');
   if tbHwnd=0 then
      Result:=0
   else
   begin
      GetWindowRect(tbHwnd, tbRect);
      Result:=tbRect.Bottom-tbRect.Top
   end;
end;

//-------------------------------------------------------------------------------------------------

function GetTaskBarWidth : Integer;
var
   tbHwnd : HWND;
   tbRect : TRect;
begin
   tbHwnd:=FindWindow('Shell_TrayWnd', '');
   if tbHwnd=0 then
      Result:=0
   else
   begin
      GetWindowRect(tbHwnd, tbRect);
      Result:=tbRect.Right-tbRect.Left
   end;
end;

//-------------------------------------------------------------------------------------------------

function GetTaskBarRect : TRect;
var
   hnd  : HWND;
begin
   hnd:=FindWindow('Shell_TrayWnd', '');
   GetWindowRect(hnd, Result);
end;

//-------------------------------------------------------------------------------------------------

end.
