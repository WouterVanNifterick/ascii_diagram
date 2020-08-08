program AsciiDiagram;

uses
  FastMM4,
  Vcl.Forms,
  AsciiDiagram.Forms.Main in 'AsciiDiagram.Forms.Main.pas' {frmMain},
  AsciiDiagram.Chart in 'AsciiDiagram.Chart.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
