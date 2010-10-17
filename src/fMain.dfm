object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsNone
  Caption = 'PicOver'
  ClientHeight = 200
  ClientWidth = 320
  Color = clBlack
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object popMain: TPopupMenu
    Left = 32
    Top = 96
    object miBrowse: TMenuItem
      Caption = '&Browse'
      OnClick = miBrowseClick
    end
    object miLock: TMenuItem
      Caption = 'Lo&ck'
      OnClick = miLockClick
    end
    object miOnTop: TMenuItem
      Caption = '&OnTop'
      OnClick = miOnTopClick
    end
    object miMinimize: TMenuItem
      Caption = 'Mi&nimize'
      OnClick = miMinimizeClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miLoad: TMenuItem
      Caption = '&Load profile'
      Enabled = False
      OnClick = miLoadClick
    end
    object miSave: TMenuItem
      Caption = '&Save profile'
      OnClick = miSaveClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miExit: TMenuItem
      Caption = 'E&xit'
      OnClick = miExitClick
    end
  end
  object trayMain: TTrayIcon
    PopupMenu = popMain
    OnDblClick = trayMainDblClick
    Left = 32
    Top = 40
  end
  object tmrMain: TTimer
    Interval = 100
    OnTimer = tmrMainTimer
    Left = 144
    Top = 88
  end
end
