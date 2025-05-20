object frmJVDemo: TfrmJVDemo
  Left = 0
  Top = 0
  Margins.Left = 5
  Margins.Top = 5
  Margins.Right = 5
  Margins.Bottom = 5
  Caption = 'JSON Variant Demo'
  ClientHeight = 1187
  ClientWidth = 1816
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 144
  TextHeight = 25
  object pnlButtons: TPanel
    Left = 1268
    Top = 0
    Width = 548
    Height = 1187
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      548
      1187)
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
      Top = 1128
      Width = 529
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
      Top = 420
      Width = 529
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Ownership considerations'
      TabOrder = 9
      OnClick = btnOwnershipClick
    end
    object btnCase: TButton
      Left = 10
      Top = 492
      Width = 529
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Case Sensitivity'
      TabOrder = 10
      OnClick = btnCaseClick
    end
    object btnConflicts: TButton
      Left = 10
      Top = 564
      Width = 529
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'JSON Key/Name vs Function conflict'
      TabOrder = 11
      OnClick = btnConflictsClick
    end
    object btnDateTime: TButton
      Left = 10
      Top = 636
      Width = 529
      Height = 38
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'JSON Date/Time considerations'
      TabOrder = 12
      OnClick = btnDateTimeClick
    end
  end
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 1268
    Height = 1187
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object splitLog: TSplitter
      Left = 0
      Top = 763
      Width = 1268
      Height = 5
      Cursor = crVSplit
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alBottom
      MinSize = 45
      ExplicitLeft = 1665
      ExplicitTop = 0
      ExplicitWidth = 630
    end
    object pnlJSON: TPanel
      Left = 0
      Top = 0
      Width = 1268
      Height = 763
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        1268
        763)
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
        Left = 3
        Top = 43
        Width = 1255
        Height = 713
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
      Top = 768
      Width = 1268
      Height = 419
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        1268
        419)
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
        Left = 1225
        Top = 9
        Width = 35
        Height = 33
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
        ExplicitLeft = 509
      end
      object memLog: TMemo
        Left = 8
        Top = 43
        Width = 1250
        Height = 369
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
