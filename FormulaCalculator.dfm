object Form1: TForm1
  Left = 192
  Top = 125
  Width = 1308
  Height = 676
  Caption = 'Calculator'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object helpText: TLabel
    Left = 336
    Top = 168
    Width = 617
    Height = 105
    Alignment = taCenter
    AutoSize = False
    Caption = 'helpText '
    Color = 16776176
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -29
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    WordWrap = True
  end
  object textEdit: TEdit
    Left = 336
    Top = 312
    Width = 617
    Height = 45
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    Text = #49688#49885#51012' '#51077#47141#54616#49464#50836'!'
  end
  object resultBtn: TBitBtn
    Left = 504
    Top = 392
    Width = 305
    Height = 81
    Caption = #44228#49328#54616#44592
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -48
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = resultBtnClick
  end
end
