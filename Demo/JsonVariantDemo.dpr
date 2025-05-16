program JsonVariantDemo;

uses
{$IFDEF USE_FASTMM5}
  FastMM5,
{$ENDIF}
  Vcl.Forms,
  JsonVariantDemoMain in 'JsonVariantDemoMain.pas' {frmJVDemo},
  JsonVariant in '..\JsonVariant.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmJVDemo, frmJVDemo);
  Application.Run;
end.
