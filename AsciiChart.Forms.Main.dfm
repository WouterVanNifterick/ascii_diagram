object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'ASCII Chart Generator'
  ClientHeight = 710
  ClientWidth = 1420
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = UpdateChart
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 1167
    Top = 0
    Width = 4
    Height = 710
    Align = alRight
    ResizeStyle = rsUpdate
    ExplicitLeft = 1069
    ExplicitHeight = 809
  end
  object memInput: TMemo
    Left = 0
    Top = 0
    Width = 65
    Height = 710
    Align = alLeft
    TabOrder = 0
    OnChange = memInputChange
    OnDblClick = memInputDblClick
  end
  object memChart: TMemo
    Left = 65
    Top = 0
    Width = 1102
    Height = 710
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    WordWrap = False
  end
  object pnlRight: TScrollBox
    Left = 1171
    Top = 0
    Width = 249
    Height = 710
    Align = alRight
    TabOrder = 2
    object grpCharacters: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 247
      Width = 239
      Height = 167
      Align = alTop
      Caption = 'Characters'
      TabOrder = 0
      ExplicitTop = 243
      object edChars: TValueListEditor
        Left = 2
        Top = 15
        Width = 235
        Height = 150
        Align = alClient
        TabOrder = 0
        OnStringsChange = UpdateChart
        ColWidths = (
          91
          138)
        RowHeights = (
          18
          18)
      end
    end
    object grpSize: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 239
      Height = 126
      Align = alTop
      Caption = 'Size'
      TabOrder = 1
      object pnlWidth: TPanel
        Left = 2
        Top = 49
        Width = 235
        Height = 35
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblWidth: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 28
          Height = 29
          Align = alLeft
          Caption = 'Width'
          Enabled = False
          Layout = tlCenter
          ExplicitHeight = 13
        end
        object tbWidth: TTrackBar
          AlignWithMargins = True
          Left = 37
          Top = 3
          Width = 195
          Height = 29
          Align = alClient
          Enabled = False
          Max = 99999
          Min = 5
          ParentShowHint = False
          Frequency = 10
          Position = 80
          ShowHint = False
          ShowSelRange = False
          TabOrder = 0
          TickStyle = tsNone
          OnChange = UpdateChart
        end
      end
      object pnlHeight: TPanel
        Left = 2
        Top = 84
        Width = 235
        Height = 35
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object lblHeight: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 31
          Height = 29
          Align = alLeft
          Caption = 'Height'
          Enabled = False
          Layout = tlCenter
          ExplicitHeight = 13
        end
        object tbHeight: TTrackBar
          AlignWithMargins = True
          Left = 40
          Top = 3
          Width = 192
          Height = 29
          Align = alClient
          Enabled = False
          Max = 100
          Min = 5
          ParentShowHint = False
          Frequency = 10
          Position = 24
          ShowHint = False
          ShowSelRange = False
          TabOrder = 0
          TickStyle = tsNone
          OnChange = UpdateChart
        end
      end
      object Panel4: TPanel
        Left = 2
        Top = 15
        Width = 235
        Height = 34
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object rbSizeCustom: TRadioButton
          AlignWithMargins = True
          Left = 147
          Top = 3
          Width = 62
          Height = 28
          Align = alLeft
          Caption = 'Custom'
          TabOrder = 0
          OnClick = UpdateChart
        end
        object rbSizeAuto: TRadioButton
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 70
          Height = 28
          Align = alLeft
          Caption = 'Screen'
          Checked = True
          TabOrder = 1
          TabStop = True
          OnClick = UpdateChart
        end
        object rbSizeData: TRadioButton
          AlignWithMargins = True
          Left = 79
          Top = 3
          Width = 62
          Height = 28
          Align = alLeft
          Caption = 'Data'
          TabOrder = 2
          OnClick = UpdateChart
        end
      end
    end
    object grpMarkers: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 188
      Width = 239
      Height = 53
      Align = alTop
      Caption = 'Marker Lines'
      TabOrder = 2
      object cbHorizontal: TCheckBox
        AlignWithMargins = True
        Left = 7
        Top = 18
        Width = 78
        Height = 30
        Margins.Left = 5
        Align = alLeft
        Caption = 'Horizontal'
        TabOrder = 0
        OnClick = UpdateChart
        ExplicitHeight = 26
      end
      object cbVertical: TCheckBox
        AlignWithMargins = True
        Left = 91
        Top = 18
        Width = 62
        Height = 30
        Align = alLeft
        Caption = 'Vertical'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = UpdateChart
        ExplicitHeight = 78
      end
      object cbFillGaps: TCheckBox
        AlignWithMargins = True
        Left = 159
        Top = 18
        Width = 78
        Height = 30
        Align = alLeft
        Caption = 'Fill Gaps'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = UpdateChart
        ExplicitLeft = 203
        ExplicitTop = 20
        ExplicitHeight = 78
      end
    end
    object rgChartType: TRadioGroup
      AlignWithMargins = True
      Left = 3
      Top = 132
      Width = 239
      Height = 50
      Margins.Top = 0
      Align = alTop
      Caption = 'Chart Type'
      Columns = 3
      ItemIndex = 1
      Items.Strings = (
        'Line'
        'Point'
        'Bar')
      TabOrder = 3
      OnClick = UpdateChart
    end
    object grpAxis: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 420
      Width = 239
      Height = 117
      Align = alTop
      Caption = 'Axis'
      TabOrder = 4
      ExplicitTop = 476
      DesignSize = (
        239
        117)
      object edAxisX: TLabeledEdit
        Left = 40
        Top = 24
        Width = 185
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        EditLabel.Width = 6
        EditLabel.Height = 13
        EditLabel.Caption = 'X'
        LabelPosition = lpLeft
        TabOrder = 0
        OnChange = UpdateChart
      end
      object edAxisY: TLabeledEdit
        Left = 40
        Top = 51
        Width = 185
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        EditLabel.Width = 6
        EditLabel.Height = 13
        EditLabel.Caption = 'Y'
        LabelPosition = lpLeft
        TabOrder = 1
        OnChange = UpdateChart
      end
      object LabeledEdit1: TLabeledEdit
        Left = 40
        Top = 78
        Width = 185
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        EditLabel.Width = 20
        EditLabel.Height = 13
        EditLabel.Caption = 'Title'
        LabelPosition = lpLeft
        TabOrder = 2
        OnChange = UpdateChart
      end
    end
  end
end
