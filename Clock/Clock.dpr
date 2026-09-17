//-------------------------------------------------------------------------------------------------
// On-Screen Clock
//    © 2026 Remus Rigo
//       v1.1.20260917
//-------------------------------------------------------------------------------------------------

program Clock;

uses
  Forms,
  WndMain in 'Wnd\WndMain.pas' {frmMain},
  CommonWnd in 'Lib\CommonWnd.pas';

{$R *.res}

begin
   Application.Initialize;
   Application.Title:='Clock';
   Application.MainFormOnTaskbar:=True;
   Application.ShowMainForm:=True;
   Application.CreateForm(TfrmMain, frmMain);
   Application.Run;
end.
