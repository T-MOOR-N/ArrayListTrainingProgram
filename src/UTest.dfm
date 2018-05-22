object FormTest: TFormTest
  Left = 0
  Top = 0
  Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1087#1088#1072#1074#1080#1083#1100#1085#1099#1081' '#1086#1090#1074#1077#1090
  ClientHeight = 280
  ClientWidth = 405
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 224
    Width = 405
    Height = 56
    Align = alBottom
    TabOrder = 0
    object Button1: TButton
      Left = 96
      Top = 16
      Width = 217
      Height = 25
      Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object ListBoxAnswer: TListBox
    Left = 0
    Top = 0
    Width = 405
    Height = 224
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
end
