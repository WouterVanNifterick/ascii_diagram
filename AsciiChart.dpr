program AsciiChart;

uses
  FastMM4,
  Vcl.Forms,
  AsciiChart.Forms.Main in 'AsciiChart.Forms.Main.pas' {frmMain},
  AsciiChart.Chart in 'AsciiChart.Chart.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
