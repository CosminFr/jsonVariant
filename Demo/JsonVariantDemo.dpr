program JsonVariantDemo;

uses
{$IFDEF USE_FASTMM5}
  FastMM5,
{$ENDIF}
  Vcl.Forms,
{$IFDEF USE_LOGGER}
  ZenLogger,
{$ENDIF}
  JsonVariantDemoMain in 'JsonVariantDemoMain.pas' {frmJVDemo},
  JsonVariant in '..\JsonVariant.pas';

{$R *.res}

begin
  Application.Initialize;
{$IFDEF USE_LOGGER}
  InitializeLogger();
  Log.LogLevel := LL_TRACE;
{$ENDIF}
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmJVDemo, frmJVDemo);
  Application.Run;
end.
