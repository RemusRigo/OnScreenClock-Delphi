//-------------------------------------------------------------------------------------------------
// On-Screen Clock
//    © 2026 Remus Rigo
//       v1.1.20260917
//-------------------------------------------------------------------------------------------------

unit WndMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Menus, ShellAPI, INIFiles, CommonWnd;

//-------------------------------------------------------------------------------------------------

type _ClockMode  = (cmDigital, cmAnalogue, cmAnalogueSkin, cmCfg);
type _ClockAlign = (caLeftTop, caLeftBottom, caRightTop, caRightBottom);

//-------------------------------------------------------------------------------------------------

const
   WM_ICONTRAY = WM_USER+1;
   _PI         = 3.141592653589793238462643383279;
   cfgFile     = 'SysClock.ini';

//-------------------------------------------------------------------------------------------------

type TfrmMain = class(TForm)
   tmrMain: TTimer;
   popTray: TPopupMenu;
   popTray_Digital: TMenuItem;
   popTray_Cfg: TMenuItem;
   popTray_Sep1: TMenuItem;
   popTray_Sep2: TMenuItem;
   popTray_Exit: TMenuItem;
   popTray_Analogue: TMenuItem;
    btnOk: TButton;
    pgCtrl: TPageControl;
    tsGeneral: TTabSheet;
    rgrpStart: TRadioGroup;
    rbtnDigital: TRadioButton;
    rbtnAnalogue: TRadioButton;
   procedure popTray_CfgClick(Sender: TObject);
   procedure popTray_AnalogueClick(Sender: TObject);
   procedure popTray_DigitalClick(Sender: TObject);
   procedure popTray_ExitClick(Sender: TObject);
   procedure popTrayPopup(Sender: TObject);
   procedure DrawTime;
   procedure tmrMainTimer(Sender: TObject);
   procedure FormPaint(Sender: TObject);
   procedure FormCreate(Sender: TObject);
   procedure FormClose(Sender: TObject; var Action: TCloseAction);
   procedure FormDestroy(Sender: TObject);
   procedure btnOkClick(Sender: TObject);
   private
      TrayIconData : TNotifyIconData;
      cm  : _ClockMode;
      ca  : _ClockAlign;
      lastMode : _ClockMode;
      widthS, widthM, widthH : Integer;
      colS, colM, colH       : TColor;
      OldH,  OldM            : Integer;
      OldSX, OldSY           : Integer;
      OldMX, OldMY           : Integer;
      OldHX, OldHY           : Integer;
      FirstDraw : Boolean;
      ini       : TINIFile;
      procedure ClearFrm;
      procedure ReSizeFrm;
      procedure RePosFrm;
      procedure ConstructFrm;
      procedure DrawNumbers;
      procedure LoadSettings;
      procedure SaveSettings;
   public
      procedure CreateWnd; override;
      procedure TrayMessage(var msg : TMessage); message WM_ICONTRAY;
   protected
      procedure CreateParams(var Params: TCreateParams); override;
end;

//-------------------------------------------------------------------------------------------------

var
  frmMain    : TfrmMain;
  // common
  tbHeight   : Integer;
  tbRect     : TRect;
  // Digital form components
  lblDigital : TLabel;

//-------------------------------------------------------------------------------------------------

implementation

{$R *.dfm}

//-------------------------------------------------------------------------------------------------
procedure TfrmMain.CreateWnd;
begin
   inherited;
   // window was (re)created – refresh handle-bound state
   SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOSIZE);
   if TrayIconData.cbSize<>0 then
   begin
      TrayIconData.Wnd:=Handle;
      Shell_NotifyIcon(NIM_MODIFY, @TrayIconData);
   end;
end;

//-------------------------------------------------------------------------------------------------
procedure TfrmMain.TrayMessage(var msg: TMessage);
begin
   case Msg.lParam of

      WM_LBUTTONDOWN:   //LeftClick
      begin
         popTray.Popup(Screen.Width, Screen.Height-GetTaskBarHeight);
      end;

      WM_RBUTTONDOWN:   //RightClick
      begin

      end;

      WM_MBUTTONDOWN:   //MiddleClick
      begin
//         Application.Terminate
      end;
   end;
end;

procedure TfrmMain.CreateParams(var Params: TCreateParams);
begin
   inherited;
   //Params.ExStyle:=Params.ExStyle or WS_EX_TOOLWINDOW;
   Params.ExStyle:=(Params.ExStyle and not WS_EX_APPWINDOW) or WS_EX_TOOLWINDOW;
end;


//-------------------------------------------------------------------------------------------------

procedure TfrmMain.ClearFrm;
begin
   if tmrMain.Enabled then
      tmrMain.Enabled:=False;

   case lastMode of

      cmDigital:
      begin
         lblDigital.Free;
      end;

      cmCfg:
      begin
         pgCtrl.Hide;
         SaveSettings;
      end;
   end;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.ReSizeFrm;
begin
   case cm of
      cmDigital:
      begin
         frmMain.BorderWidth:=3;
         frmMain.BorderIcons:=[];
         frmMain.BorderStyle:=bsNone;
         frmMain.ClientHeight:=60;
         frmMain.ClientWidth:=190;
      end;

      cmAnalogue:
      begin
         frmMain.BorderWidth:=3;
         frmMain.BorderIcons:=[];
         frmMain.BorderStyle:=bsNone;
         frmMain.ClientHeight:=150;
         frmMain.ClientWidth:=150;
      end;

      cmCfg:
      begin
         frmMain.BorderWidth:=0;
         frmMain.BorderIcons:=[biSystemMenu];
         frmMain.BorderStyle:=bsSingle;
         frmMain.ClientHeight:=150;
         frmMain.ClientWidth:=225;
      end;
   end;
end;
//-------------------------------------------------------------------------------------------------

procedure TfrmMain.RePosFrm;
begin
   // get task bar size and pos
   tbRect:=GetTaskBarRect;
   tbHeight:=GetTaskBarHeight;
   // main form pos
   if cm=cmCfg then
      frmMain.Position:=poScreenCenter
   else
   begin
      frmMain.Position:=poDesigned;
   if tbRect.Top=-2 then
   begin
      if tbRect.Left=-1 then
      begin
         if tbRect.Bottom>tbRect.Right then // Left
         begin
         end
         else // Top
         begin
         end
      end
      else // Right
      begin
      end
   end
   else // Bottom
   begin
      case ca of
         caLeftTop:
         begin
         end;
         caLeftBottom:
         begin
         end;
         caRightTop:
         begin
         end;
         caRightBottom:
         begin
            frmMain.Left:=Screen.Width-frmMain.Width;
            frmMain.Top:=Screen.Height-frmMain.Height-GetTaskBarHeight;
         end;
      end;
   end;
   end;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.ConstructFrm;
begin
   case cm of

      cmDigital: // construct Digital form
      begin
         lblDigital:=TLabel.Create(frmMain);
         try
            lblDigital.Parent:=Self;
            lblDigital.Left:=0;
            lblDigital.Top:=0;
            lblDigital.Height:=30;
            lblDigital.Width:=30;
            lblDigital.Align:=alClient;
            lblDigital.Font.Color:=clLime;
            lblDigital.Font.Size:=32;
            lblDigital.Font.Name:='Arial';
            lblDigital.Alignment:=taCenter;
            lblDigital.Layout:=tlCenter;
            lblDigital.Transparent:=false;
            lblDigital.Color:=clBlack;
         except
            lblDigital.Free;
         end;
      end;

      cmAnalogue:
      begin
      end;

      cmCfg:  // construct Config form
      begin
         pgCtrl.Show;
         LoadSettings;
      end;
   end;

   if cm=cmCfg then
      tmrMain.Enabled:=False
   else
   begin
      tmrMain.Enabled:=True;
   end;

   ReSizeFrm;
   RePosFrm;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.DrawNumbers;
var
   fixCenterX : Integer;
   fixCenterY : Integer;
   x, y       : Integer;
   cx, cy     : Integer;
   r          : Integer;
   i          : Integer;
   a          : Integer; // angle
   s          : Integer; // step
begin
   fixCenterX:=frmMain.Canvas.Font.Size div 2;
   fixCenterY:=frmMain.Canvas.Font.Height div 2;
   cx:=frmMain.ClientHeight div 2;
   cy:=frmMain.ClientWidth div 2;
   r:=(frmMain.ClientHeight div 2) - (Canvas.Font.Size*2);

   a:=30;
   s:=12;

   for i:=1 to s do
   begin
      X:=cx+Round(R*Sin(a*i*_PI/180));
      Y:=cy-Round(R*Cos(a*i*_PI/180));
      Canvas.TextOut(x-fixCenterX, y+fixCenterY, IntToStr(i));
   end;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.DrawTime;
var
   wndSize   : Integer;
   DateTime  : TDateTime;
   Xo, Yo, Xs, Ys, Xm, Ym, Xh, Yh, H, M, S, Rs, Rm, Rh : Integer;
begin
//   Canvas.MoveTo(0, frmMain.ClientHeight div 2);
//   Canvas.LineTo(frmMain.ClientHeight, frmMain.ClientHeight div 2);
//   Canvas.MoveTo(frmMain.ClientWidth div 2, 0);
//   Canvas.LineTo(frmMain.ClientWidth div 2, frmMain.ClientWidth);
   // Get current time
   DateTime:=Time;

   // Display time in form title
   Caption:=' '+FormatDateTime('hh:nn:ss AM/PM',DateTime);

   wndSize:=frmMain.ClientHeight div 2;
   // Set center point
   Xo:=wndSize;
   Yo:=wndSize;

   // Clock radius
   Rs:=Round(wndSize div 2 + 20);
   Rm:=Round(wndSize div 3 + 10);
   Rh:=Round(wndSize div 4 + 5);

   H:=StrToInt(Copy(FormatDateTime('hh AM/PM',DateTime),1,2));
   M:=StrToInt(FormatDateTime('nn',DateTime));
   S:=StrToInt(FormatDateTime('ss',DateTime));

   // Set coordinates for seconds
   Xs:=Xo+Round(Rs*Sin(S*6*Pi/180));
   Ys:=Yo-Round(Rs*Cos(S*6*Pi/180));

   // Set coordinates for minutes
   Xm:=Xo+Round(Rm*Sin(M*6*Pi/180));
   Ym:=Yo-Round(Rm*Cos(M*6*Pi/180));

   // Set coordinates for hours }
   Xh:=Xo+Round(Rh*Sin((H*30+M/2)*Pi/180));
   Yh:=Yo-Round(Rh*Cos((H*30+M/2)*Pi/180));

   { Erase previous line for seconds }
   if not FirstDraw then
   begin
      Canvas.Pen.Color:=colS;
      Canvas.Pen.Width:=widthS;
      Canvas.MoveTo(Xo,Yo);
      Canvas.LineTo(OldSX,OldSY);
   end
   else
      Canvas.Pen.Mode:=pmNotXor;

   // Draw seconds line
   Canvas.Pen.Color:=colS;
   Canvas.Pen.Width:=widthS;
   Canvas.MoveTo(Xo,Yo);
   Canvas.LineTo(Xs,Ys);
   OldSX:=Xs;
   OldSY:=Ys;

   if FirstDraw then
   begin
      // Draw minutes line
      Canvas.Pen.Color:=colM;
      Canvas.Pen.Width:=widthM;
      Canvas.MoveTo(Xo,Yo);
      Canvas.LineTo(Xm,Ym);
      OldMX:=Xm;
      OldMY:=Ym;

      // Draw hour line
      Canvas.Pen.Color:=colH;
      Canvas.Pen.Width:=widthH;
      Canvas.MoveTo(Xo,Yo);
      Canvas.LineTo(Xh,Yh);
      OldHX:=Xh;
      OldHY:=Yh;
   end;

  // Refresh minute new position
  if (OldMX<>Xm) or (OldMY<>Ym) then
  begin
    // Erase previous one
    Canvas.Pen.Color:=colM;
    Canvas.Pen.Width:=widthM;
    Canvas.MoveTo(Xo,Yo);
    Canvas.LineTo(OldMX,OldMY);

    // Draw new line
    Canvas.MoveTo(Xo,Yo);
    Canvas.LineTo(Xm,Ym);
    OldMX:=Xm;
    OldMY:=Ym;
  end;

   // Refresh hour new position
   if (OldHX<>Xh) or (OldHY<>Yh) then
   begin
      // Erase previous one
      Canvas.Pen.Color:=colH;
      Canvas.Pen.Width:=widthH;
      Canvas.MoveTo(Xo,Yo);
      Canvas.LineTo(OldHX,OldHY);

      // Draw new line
      Canvas.MoveTo(Xo,Yo);
      Canvas.LineTo(Xh,Yh);
      OldHX:=Xh;
      OldHY:=Yh;
   end;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.tmrMainTimer(Sender: TObject);
begin
   case cm of

      cmDigital:
      begin
         lblDigital.Caption:=TimeToStr(now);
      end;

      cmAnalogue:
      begin
         DrawTime;
      end;

   end;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.FormPaint(Sender: TObject);
begin
   case cm of

      cmAnalogue:
      begin
         DrawNumbers;
         FirstDraw:=True;
         DrawTime;
         FirstDraw:=False;
      end;

   end;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.LoadSettings;
begin
   if ini.ReadString('General', 'Start', 'Digital')='Digital' then
      rbtnDigital.Checked
   else
      rbtnAnalogue.Checked;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.SaveSettings;
begin
   if rbtnDigital.Checked then
      ini.WriteString('General', 'Start', 'Digital')
   else
      ini.WriteString('General', 'Start', 'Analogue')
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   ini.Free;
   Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//   Action:=caNone;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.FormCreate(Sender: TObject);
begin
   BorderIcons:=[];
   BorderStyle:=bsNone;
   SetWindowLongPtr(Handle, GWL_EXSTYLE, GetWindowLongPtr(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);

   ini:=TINIFile.Create(GetCurrentDir+'\'+cfgFile);
   cm:=cmDigital;
   ca:=caRightBottom;
   lastMode:=cm;
   pgCtrl.Hide;
   ConstructFrm;

   TrayIconData.cbSize:=SizeOf(TrayIconData);
   TrayIconData.Wnd:=Handle;
   TrayIconData.uID:=0;
   TrayIconData.uFlags:=NIF_MESSAGE + NIF_ICON + NIF_TIP;
   TrayIconData.uCallbackMessage:=WM_ICONTRAY;
   TrayIconData.hIcon:=Application.Icon.Handle;
   StrPCopy(TrayIconData.szTip, Application.Title);
   Shell_NotifyIcon(NIM_ADD, @TrayIconData);

   // Always on top
   //SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE OR SWP_NOACTIVATE OR SWP_NOSIZE);
   //SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOMOVE OR SWP_NOACTIVATE OR SWP_NOSIZE OR SWP_FRAMECHANGED);
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.popTrayPopup(Sender: TObject);
begin
   tmrMain.Enabled:=False;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.popTray_DigitalClick(Sender: TObject);
begin
   lastMode:=cm;
   cm:=cmDigital;
   ClearFrm;
   ConstructFrm;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.popTray_AnalogueClick(Sender: TObject);
begin
   lastMode:=cm;
   cm:=cmAnalogue;
   ClearFrm;
   ConstructFrm;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.popTray_CfgClick(Sender: TObject);
begin
   lastMode:=cm;
   cm:=cmCfg;
   ClearFrm;
   ConstructFrm;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.popTray_ExitClick(Sender: TObject);
begin
   Application.Terminate;
end;

//-------------------------------------------------------------------------------------------------

procedure TfrmMain.btnOkClick(Sender: TObject);
begin
   cm:=lastMode;
   lastMode:=cmCfg;
   ClearFrm;
   lastMode:=cm;
   ConstructFrm;
end;

end.
