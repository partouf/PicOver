{
   Copyright 2010 Partouf

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
}
unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Menus, Jpeg;

type
  TfrmMain = class(TForm)
    popMain: TPopupMenu;
    trayMain: TTrayIcon;
    miBrowse: TMenuItem;
    miExit: TMenuItem;
    N1: TMenuItem;
    miLock: TMenuItem;
    miOnTop: TMenuItem;
    miSave: TMenuItem;
    N2: TMenuItem;
    miLoad: TMenuItem;
    tmrMain: TTimer;
    miMinimize: TMenuItem;
    procedure miBrowseClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miLockClick(Sender: TObject);
    procedure miOnTopClick(Sender: TObject);
    procedure miLoadClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure tmrMainTimer(Sender: TObject);
    procedure miMinimizeClick(Sender: TObject);
    procedure trayMainDblClick(Sender: TObject);
  private
    { Private declarations }
    FFilepath: string;
    FJPEG: TJPEGImage;

    FMoveLocked: boolean;

    FWindowDragMode: boolean;
    FLastDragPoint: TPoint;

    procedure LoadFile;
    function AskFile: string;

    procedure SaveSettings;
    procedure LoadSettings;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  IniFiles;

const
  c_inifile = 'PicOver.ini';


function TfrmMain.AskFile: string;
var
  dlgOpen: TOpenDialog;
begin
  Result := '';

  dlgOpen := TOpenDialog.Create( nil );
  try
    dlgOpen.Filter := 'JPEG Image (*.jpg,*.jpeg)|*.jpg;*.jpeg';

    if dlgOpen.Execute then
    begin
      Result := dlgOpen.FileName;
    end;
  finally
    dlgOpen.Free;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FJPEG := TJPEGImage.Create;
  FFilepath := '';
  FWindowDragMode := False;
  FMoveLocked := False;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FJPEG);
end;

procedure TfrmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and not FMoveLocked then
  begin
    GetCursorPos( FLastDragPoint );

    FWindowDragMode := True;
  end;
end;

procedure TfrmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  p2: TPoint;
begin
  if FWindowDragMode and not FMoveLocked then
  begin
    GetCursorPos( p2 );

    Self.Left := Self.Left + (p2.X - FLastDragPoint.X);
    Self.Top := Self.Top + (p2.Y - FLastDragPoint.Y);

    GetCursorPos( FLastDragPoint );
  end;
end;

procedure TfrmMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FWindowDragMode := False;
end;

procedure TfrmMain.FormPaint(Sender: TObject);
begin
  if Assigned(FJPEG) then
  begin
    frmMain.Canvas.Draw( 0, 0, FJPEG );
  end;
end;

procedure TfrmMain.miLoadClick(Sender: TObject);
begin
  LoadSettings;
end;

procedure TfrmMain.LoadFile;
begin
  try
    FJPEG.LoadFromFile( FFilepath );

    frmMain.ClientWidth   := FJPEG.Width;
    frmMain.ClientHeight  := FJPEG.Height;

    frmMain.Canvas.Draw( 0, 0, FJPEG );
  except
    on E: Exception do
    begin
      Application.Terminate;
    end;
  end;
end;

procedure TfrmMain.miBrowseClick(Sender: TObject);
begin
  FFilepath := AskFile;
  if FFilePath <> '' then
  begin
    LoadFile;
  end;
end;

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMain.miLockClick(Sender: TObject);
begin
  FMoveLocked := not FMoveLocked;

  miLock.Checked := FMoveLocked;
end;

procedure TfrmMain.miMinimizeClick(Sender: TObject);
begin
  try
    if Self.Visible then
    begin
      miMinimize.Caption := '&Restore';

      Self.Hide;
    end
    else
    begin
      miMinimize.Caption := 'Mi&nimize';

      Self.Show;
    end;
  except
    on E: Exception do
    begin
      //
    end;
  end;
end;

procedure TfrmMain.miOnTopClick(Sender: TObject);
begin
  miOnTop.Checked := not miOnTop.Checked;

  if miOnTop.Checked then
  begin
    SetWindowPos( Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE );
  end
  else
  begin
    SetWindowPos( Handle, HWND_NOTOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE );
  end;
end;

procedure TfrmMain.LoadSettings;
var
  ini: TIniFile;
begin
  if FileExists( ExtractFilePath(Application.ExeName) + c_inifile ) then
  begin
    ini := TIniFile.Create( ExtractFilePath(Application.ExeName) + c_inifile );
    try
      FFilepath := ini.ReadString( 'Main', 'File', FFilepath );

      LoadFile;

      Self.Left := ini.ReadInteger( 'Main', 'X', Self.Left );
      Self.Top := ini.ReadInteger( 'Main', 'Y', Self.Top );

      miOnTop.Checked := ini.ReadBool( 'Main', 'OnTop', miOnTop.Checked );
      miLock.Checked := ini.ReadBool( 'Main', 'Lock', miLock.Checked );

      FMoveLocked := miLock.Checked;

      if miOnTop.Checked then
      begin
        SetWindowPos( Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE );
      end
      else
      begin
        SetWindowPos( Handle, HWND_NOTOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE );
      end;
    finally
      ini.Free;
    end;
  end;
end;

procedure TfrmMain.miSaveClick(Sender: TObject);
begin
  SaveSettings;
end;

procedure TfrmMain.SaveSettings;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create( ExtractFilePath(Application.ExeName) + c_inifile );
  try
    ini.WriteString( 'Main', 'File', FFilepath );
    ini.WriteInteger( 'Main', 'X', Self.Left );
    ini.WriteInteger( 'Main', 'Y', Self.Top );

    ini.WriteBool( 'Main', 'OnTop', miOnTop.Checked );
    ini.WriteBool( 'Main', 'Lock', miLock.Checked );
  finally
    ini.Free;
  end;

  miLoad.Enabled := True;
end;

procedure TfrmMain.tmrMainTimer(Sender: TObject);
begin
  try
    tmrMain.Enabled := False;

    LoadSettings;

    if FileExists( ExtractFilePath(Application.ExeName) + c_inifile ) then
    begin
      miLoad.Enabled := True;
    end;

    trayMain.Visible := True;
  except
    on E: Exception do
    begin
      //
    end;
  end;
end;

procedure TfrmMain.trayMainDblClick(Sender: TObject);
begin
  miMinimize.Click;
end;

end.
