object FormMain: TFormMain
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = #1058#1088#1077#1085#1072#1078#1077#1088#1085#1072#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1072
  ClientHeight = 718
  ClientWidth = 1018
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1018
    Height = 718
    Align = alClient
    Color = clMenu
    ParentBackground = False
    TabOrder = 0
    object Label4: TLabel
      Left = 8
      Top = 113
      Width = 76
      Height = 19
      Caption = #1057#1090#1088#1091#1082#1090#1091#1088#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 316
      Top = 113
      Width = 99
      Height = 19
      Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Panel2: TPanel
      Left = 316
      Top = 8
      Width = 685
      Height = 99
      TabOrder = 2
      object Label1: TLabel
        Left = 8
        Top = 0
        Width = 524
        Height = 34
        Caption = 
          #1055#1088#1086#1075#1088#1072#1084#1084#1072' '#1086#1073#1091#1095#1072#1077#1090' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1085#1080#1102' '#1083#1080#1085#1077#1081#1085#1099#1093' '#1089#1087#1080#1089#1082#1086#1074#1099#1093' '#1089#1090#1088#1091#1082#1090#1091#1088' '#1076#1072#1085#1085 +
          #1099#1093', '#1088#1077#1072#1083#1080#1079#1091#1077#1084#1099#1093' '#1085#1072' '#1086#1089#1085#1086#1074#1077' '#1084#1072#1089#1089#1080#1074#1072' '#1074' '#1076#1074#1091#1093' '#1089#1083#1077#1076#1091#1102#1097#1080#1093' '#1074#1072#1088#1080#1072#1085#1090#1072#1093':'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial Rounded MT Bold'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object Label2: TLabel
        Left = 8
        Top = 40
        Width = 498
        Height = 34
        Caption = 
          '1) '#1053#1077#1091#1087#1086#1088#1103#1076#1086#1095#1077#1085#1085#1099#1081' '#1089#1087#1080#1089#1086#1082' '#1089' '#1074#1086#1079#1084#1086#1078#1085#1086#1089#1090#1100#1102' '#1076#1086#1073#1072#1074#1083#1077#1085#1080#1103' '#1074' '#1083#1102#1073#1086#1077' '#1079#1072#1076#1072 +
          #1085#1085#1086#1077' '#1084#1077#1089#1090#1086' '#1085#1072' '#1086#1089#1085#1086#1074#1077' '#1089#1076#1074#1080#1075#1086#1074#1099#1093' '#1086#1087#1077#1088#1072#1094#1080#1081
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial Rounded MT Bold'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object Label3: TLabel
        Left = 8
        Top = 73
        Width = 467
        Height = 17
        Caption = 
          '2) '#1059#1087#1086#1088#1103#1076#1086#1095#1077#1085#1085#1099#1081' '#1089#1087#1080#1089#1086#1082' '#1085#1072' '#1086#1089#1085#1086#1074#1077' '#1086#1095#1077#1088#1077#1076#1080' '#1089' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1085#1080#1077#1084' '#1087#1088#1080#1086#1088 +
          #1080#1090#1077#1090#1086#1074' '#1101#1083#1077#1084#1077#1085#1090#1086#1074
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial Rounded MT Bold'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
    end
    object MyStringGrid: TStringGrid
      AlignWithMargins = True
      Left = 8
      Top = 166
      Width = 289
      Height = 329
      Color = clWhite
      ColCount = 6
      DefaultColWidth = 44
      FixedColor = clWhite
      FixedCols = 0
      RowCount = 6
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      GridLineWidth = 3
      Options = [goVertLine, goHorzLine]
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      OnDrawCell = MyStringGridDrawCell
      ColWidths = (
        44
        44
        44
        44
        44
        44)
      RowHeights = (
        24
        24
        24
        24
        24
        24)
    end
    object ComboBoxStructure: TComboBox
      Left = 8
      Top = 25
      Width = 289
      Height = 27
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 1
      Text = #1053#1077#1091#1087#1086#1088#1103#1076#1086#1095#1077#1085#1085#1099#1081' '#1089#1087#1080#1089#1086#1082
      OnChange = ComboBoxStructureChange
      Items.Strings = (
        #1053#1077#1091#1087#1086#1088#1103#1076#1086#1095#1077#1085#1085#1099#1081' '#1089#1087#1080#1089#1086#1082
        #1059#1087#1086#1088#1103#1076#1086#1095#1077#1085#1085#1099#1081' '#1089#1087#1080#1089#1086#1082)
    end
    object Panel3: TPanel
      Left = 8
      Top = 501
      Width = 289
      Height = 153
      TabOrder = 3
      object ButtonAddAfter: TButton
        Left = 17
        Top = 82
        Width = 112
        Height = 25
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1086#1089#1083#1077
        Enabled = False
        TabOrder = 0
        OnClick = ButtonAddAfterClick
      end
      object ButtonAddFirst: TButton
        Left = 17
        Top = 20
        Width = 112
        Height = 25
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1077#1088#1074#1099#1081
        TabOrder = 1
        OnClick = ButtonAddFirstClick
      end
      object ButtonAddBefore: TButton
        Left = 17
        Top = 51
        Width = 112
        Height = 25
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1077#1088#1077#1076
        Enabled = False
        TabOrder = 2
        OnClick = ButtonAddBeforeClick
      end
      object ButtonDelete: TButton
        Left = 17
        Top = 113
        Width = 112
        Height = 25
        Caption = #1059#1076#1072#1083#1080#1090#1100
        Enabled = False
        TabOrder = 3
        OnClick = ButtonDeleteClick
      end
      object ButtonNext: TBitBtn
        Left = 159
        Top = 113
        Width = 112
        Height = 25
        Caption = '>>'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Kind = bkYes
        NumGlyphs = 2
        ParentFont = False
        TabOrder = 4
        OnClick = ButtonNextClick
      end
      object ButtonClean: TButton
        Left = 159
        Top = 20
        Width = 112
        Height = 25
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100
        Enabled = False
        TabOrder = 5
        OnClick = ButtonCleanClick
      end
      object ButtonAdd: TButton
        Left = 159
        Top = 82
        Width = 112
        Height = 25
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100
        TabOrder = 6
        OnClick = ButtonAddClick
      end
    end
    object ComboBoxMode: TComboBox
      Left = 8
      Top = 69
      Width = 289
      Height = 27
      Style = csDropDownList
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 4
      Text = #1044#1077#1084#1086#1085#1089#1090#1088#1072#1094#1080#1103
      OnChange = ComboBoxModeChange
      Items.Strings = (
        #1044#1077#1084#1086#1085#1089#1090#1088#1072#1094#1080#1103
        #1058#1077#1089#1090#1080#1088#1086#1074#1072#1085#1080#1077)
    end
    object StringGrid2: TStringGrid
      Left = 8
      Top = 138
      Width = 289
      Height = 32
      ColCount = 6
      DefaultColWidth = 44
      Enabled = False
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      GridLineWidth = 3
      ParentFont = False
      TabOrder = 5
      ColWidths = (
        44
        44
        44
        44
        44
        44)
      RowHeights = (
        24)
    end
    object ListBox: TListBox
      Left = 316
      Top = 138
      Width = 685
      Height = 516
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
    end
  end
end
