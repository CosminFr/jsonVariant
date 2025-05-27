object frmJVDemo: TfrmJVDemo
  Left = 0
  Top = 0
  Margins.Left = 5
  Margins.Top = 5
  Margins.Right = 5
  Margins.Bottom = 5
  Caption = 'JSON Variant Demo'
  ClientHeight = 960
  ClientWidth = 1634
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 144
  TextHeight = 25
  object pnlButtons: TPanel
    Left = 1087
    Top = 0
    Width = 547
    Height = 960
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      547
      960)
    object btnCreateJsonObject: TButton
      Left = 10
      Top = 42
      Width = 250
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'Create JSON Object'
      TabOrder = 0
      OnClick = btnCreateJsonObjectClick
    end
    object btnCreateJsonList: TButton
      Left = 288
      Top = 42
      Width = 250
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'Create JSON List'
      TabOrder = 1
      OnClick = btnCreateJsonListClick
    end
    object btnUpdateJsonObject: TButton
      Left = 10
      Top = 120
      Width = 250
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'Update JSON Object'
      TabOrder = 2
      OnClick = btnUpdateJsonObjectClick
    end
    object btnUpdateJsonList: TButton
      Left = 288
      Top = 120
      Width = 250
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'Update JSON List'
      TabOrder = 3
      OnClick = btnUpdateJsonListClick
    end
    object btnParseJsonObject: TButton
      Left = 10
      Top = 276
      Width = 250
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'Parse JSON Object'
      TabOrder = 4
      OnClick = btnParseJsonObjectClick
    end
    object btnParseJsonList: TButton
      Left = 288
      Top = 276
      Width = 250
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'Parse JSON List'
      TabOrder = 5
      OnClick = btnParseJsonListClick
    end
    object btnValidateJsonObject: TButton
      Left = 10
      Top = 204
      Width = 250
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'Validate JSON Object'
      TabOrder = 6
      OnClick = btnValidateJsonObjectClick
    end
    object btnValidateJsonList: TButton
      Left = 288
      Top = 204
      Width = 250
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'Validate JSON List'
      TabOrder = 7
      OnClick = btnValidateJsonListClick
    end
    object btnClose: TButton
      Left = 10
      Top = 902
      Width = 528
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      ModalResult = 8
      TabOrder = 8
      OnClick = btnCloseClick
    end
    object btnOwnership: TButton
      Left = 10
      Top = 381
      Width = 528
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Ownership considerations'
      TabOrder = 9
      OnClick = btnOwnershipClick
    end
    object btnCase: TButton
      Left = 10
      Top = 453
      Width = 528
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Case Sensitivity'
      TabOrder = 10
      OnClick = btnCaseClick
    end
    object btnConflicts: TButton
      Left = 10
      Top = 525
      Width = 528
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akTop, akRight]
      Caption = 'JSON Key/Name vs Function conflict'
      TabOrder = 11
      OnClick = btnConflictsClick
    end
    object btnDateTime: TButton
      Left = 10
      Top = 597
      Width = 528
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akTop, akRight]
      Caption = 'JSON Date/Time considerations'
      TabOrder = 12
      OnClick = btnDateTimeClick
    end
    object gbPath: TGroupBox
      Left = 10
      Top = 661
      Width = 531
      Height = 73
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akTop, akRight]
      Caption = 'JSON Path'
      TabOrder = 13
      OnEnter = cbPathEnter
      DesignSize = (
        531
        73)
      object cbPath: TComboBox
        Left = 5
        Top = 25
        Width = 376
        Height = 33
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = '$..author'
        OnEnter = cbPathEnter
        Items.Strings = (
          '$..author'
          '$..book[*].title'
          'store.book[2]'
          '*.book[-1]'
          '$.store..price'
          '$..book..price'
          '["store"]["book"][1]')
      end
      object btnPath: TButton
        Left = 384
        Top = 23
        Width = 142
        Height = 38
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Anchors = [akTop, akRight]
        Caption = 'Search ...'
        TabOrder = 1
        OnClick = btnPathClick
      end
    end
  end
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 1087
    Height = 960
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object splitLog: TSplitter
      Left = 0
      Top = 537
      Width = 1087
      Height = 5
      Cursor = crVSplit
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alBottom
      MinSize = 46
      ExplicitTop = 473
      ExplicitWidth = 691
    end
    object pnlJSON: TPanel
      Left = 0
      Top = 0
      Width = 1087
      Height = 537
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        1087
        537)
      object lblJSON: TLabel
        Left = 8
        Top = 8
        Width = 43
        Height = 25
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Caption = 'JSON'
      end
      object memJson: TMemo
        Left = 4
        Top = 43
        Width = 1072
        Height = 487
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          'Instructions to use:'
          
            '* Check code for different usage examples. Make changes to bette' +
            'r suit your own JSON template.'
          
            '* Use "Create" buttons to initialize a demo JSON (and override t' +
            'hese instructions).'
          
            '* "Update" buttons showcase different edit options & modifies JS' +
            'ON value'
          
            '* Validate & Parse should not change the input, sending all outp' +
            'uts to the log.'
          '')
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object pnlLog: TPanel
      Left = 0
      Top = 542
      Width = 1087
      Height = 418
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        1087
        418)
      object lblLog: TLabel
        Left = 8
        Top = 8
        Width = 30
        Height = 25
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Caption = 'Log'
      end
      object btnRealignLog: TSpeedButton
        Left = 1044
        Top = 10
        Width = 35
        Height = 32
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Anchors = [akTop, akRight]
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          1800000000000003000000000000000000000000000000000000D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D300000000000000000003030303030300000006
          0606D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3000000
          0000000000000000001010100C0C0C131313D4D4D4D3D3D3D3D3D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D3000000000000000000000000000000D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3000000
          000000000000000000000000000000D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D30000001D1D1DD3D3D300000000000000000000
          0000D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3000000
          191919D3D3D3D3D3D3000000000000000000000000D3D3D3D3D3D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D30000001A1A1AD3D3D3D3D3D3D3D3D300000000
          0000000000000000D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3CCCCCC
          D2D2D2D3D3D3D3D3D3D3D3D3D3D3D3000000000000000000000000D3D3D3D3D3
          D3D3D3D3D4D4D4D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3
          D3D3000000000000000000000000D3D3D3D3D3D3131313060606D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D30000000000000000000000
          00D3D3D30B0B0B000000D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3000000000000000000000000000000030303D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D30000000000
          00000000000000000000D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D3D3000000000000000000000000D3D3D3D3D3D3
          D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D2D2D21A1A1A1818181C1C1C0000
          00000000000000000000D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3
          D3D3CCCCCC000000000000000000000000000000000000000000}
        OnClick = btnRealignLogClick
        ExplicitLeft = 648
      end
      object memLog: TMemo
        Left = 8
        Top = 43
        Width = 1068
        Height = 368
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
end
