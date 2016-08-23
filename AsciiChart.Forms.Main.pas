unit AsciiChart.Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.ValEdit, Vcl.ShareContract, AsciiChart.Chart;

type
  // █▀░▄


  TfrmMain = class(TForm)
    memInput     : TMemo;
    memChart     : TMemo;
    pnlRight     : TScrollBox;
    grpCharacters: TGroupBox;
    edChars      : TValueListEditor;
    grpSize      : TGroupBox;
    pnlWidth     : TPanel;
    lblWidth     : TLabel;
    tbWidth      : TTrackBar;
    pnlHeight    : TPanel;
    lblHeight    : TLabel;
    tbHeight     : TTrackBar;
    grpMarkers   : TGroupBox;
    cbHorizontal: TCheckBox;
    cbVertical: TCheckBox;
    rgChartType  : TRadioGroup;
    grpAxis      : TGroupBox;
    edAxisX      : TLabeledEdit;
    edAxisY      : TLabeledEdit;
    Panel4       : TPanel;
    rbSizeCustom : TRadioButton;
    rbSizeAuto   : TRadioButton;
    Splitter1    : TSplitter;
    LabeledEdit1 : TLabeledEdit;
    rbSizeData   : TRadioButton;
    cbFillGaps: TCheckBox;
    procedure memInputChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpdateChart(Sender: TObject);
    procedure memInputDblClick(Sender: TObject);
  strict private
    procedure DoAutoSize;
    procedure UpdateSizeControls;
    procedure UpdateChars;
  public
    Chart: TChart;
    procedure GenerateSineData;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses Math;


procedure TfrmMain.FormCreate(Sender: TObject);
var c:char;
begin
  Chart := TChart.Create([],TSize.Create(80,24));
  memInputChange(self);
  UpdateChart(self);
  edChars.InsertRow('Line', Chart.FSerie.DataSymbol,true);
  edChars.ItemProps['Line'].EditStyle  :=  TEditStyle.esPickList;
  for c in '#x|o*▋' do
    edChars.ItemProps['Line'].PickList.Add(c);

  edChars.InsertRow('VertMarker'        ,Chart.Chars.VertMarker,true);
  edChars.InsertRow('HorzMarker'        ,Chart.chars.HorzMarker,true);
  edChars.InsertRow('LeftLine'          ,Chart.Chars.LeftLine,true);
  edChars.InsertRow('BottomLine'        ,Chart.Chars.BottomLine,true);
  edChars.InsertRow('BottomLineCrossing',Chart.Chars.BottomLineCrossing,true);

  GenerateSineData;
end;



procedure TfrmMain.GenerateSineData;
var
  s: string;
  fs: TFormatSettings;
  i: Integer;
const
  samples = 128;
begin
  memInput.Clear;
  s := '';
  fs.DecimalSeparator := '.';
  for I := 0 to samples - 1 do
    s := s + Format('%.3f' + sLineBreak, [sin(2 * 2 * pi * i / samples) * 5], fs);
  memInput.Text := s;
end;

procedure TfrmMain.memInputChange(Sender: TObject);
var
  a:TData;s,t:string;
  v:double;
  fs:TFormatSettings;
begin
  fs.DecimalSeparator := '.';

  a := [];
  s := memInput.Text;
  s := s.Replace(',',sLineBreak);
  s := s.Replace(#9,'');
  s := s.Replace(' ','');
  s := s.Replace('(','');
  s := s.Replace(')','');
  s := s.Replace(';','');
  s := s.Replace(sLineBreak+sLineBreak,sLineBreak);
  s := s.Replace(sLineBreak+sLineBreak,sLineBreak);
  s := s.Replace(sLineBreak+sLineBreak,sLineBreak);

  for s in s.Split([sLineBreak]) do
  begin
    t := trim(s);
    if TryStrToFloat(t,v,fs) then
      a := a+[v];
  end;
  Chart.Data := a;
  memChart.Text := Chart.ToString;
end;

procedure TfrmMain.memInputDblClick(Sender: TObject);
begin
  GenerateSineData;
end;



procedure TfrmMain.UpdateChart(Sender: TObject);
begin
  UpdateSizeControls;

  Chart.Size                  := Size.Create(tbWidth.Position, tbHeight.Position);
  Chart.ShowHorizontalMarkers := cbHorizontal.Checked;
  Chart.ShowVerticalMarkers   := cbVertical.Checked;
  Chart.FillGaps              := cbFillGaps.Checked;
  Chart.FSerie.ChartType      := TChartType(rgChartType.ItemIndex);
  Chart.AxisX                 := edAxisX.Text;
  Chart.AxisY                 := edAxisY.Text;

  UpdateChars;

  memChart.Text := Chart.ToString;
end;

procedure TfrmMain.UpdateChars;
var
  v: string;
  Chars: TChart.Tchars;
begin
  if edChars.RowCount<>7 then
    Exit;

  v := edChars.Values['Line']               + Chart.FSerie.DataSymbol        ; Chart.FSerie.DataSymbol  := v[1];
  v := edChars.Values['VertMarker']         + Chart.Chars.VertMarker         ; Chars.VertMarker         := v[1];
  v := edChars.Values['HorzMarker']         + Chart.Chars.HorzMarker         ; Chars.HorzMarker         := v[1];
  v := edChars.Values['LeftLine']           + Chart.Chars.LeftLine           ; Chars.LeftLine           := v[1];
  v := edChars.Values['BottomLine']         + Chart.Chars.BottomLine         ; Chars.BottomLine         := v[1];
  v := edChars.Values['BottomLineCrossing'] + Chart.Chars.BottomLineCrossing ; Chars.BottomLineCrossing := v[1];
  Chart.SetChars(Chars);
end;

procedure TfrmMain.UpdateSizeControls;
var
  mode: TScaleMode;
begin
  mode := Custom;

  if rbSizeAuto.Checked   then mode := Screen;
  if rbSizeData.Checked   then mode := Data;
  if rbSizeCustom.Checked then mode := Custom;

  pnlWidth.Visible  := mode = custom;
  pnlHeight.Visible := mode = custom;
  lblWidth.Enabled  := mode = custom;
  lblHeight.Enabled := mode = custom;
  tbWidth.Enabled   := mode = custom;
  tbHeight.Enabled  := mode = custom;


  case mode of
    Screen:
      begin
        DoAutoSize;
        tbWidth.Max    := tbWidth.Position * 2;
        tbHeight.Max   := tbHeight.Position * 2;
        grpSize.Height := 53;
      end;
    Data:
      begin
        tbWidth.Max       := 300;
        tbHeight.Max      := 100;
        tbWidth.Position  := length(Chart.Data) + Chart.Margins.Left + Chart.Margins.Right;
        tbHeight.Position := (length(Chart.Data) div 3) + Chart.Margins.Top + Chart.Margins.Bottom;
        grpSize.Height    := 53;
      end;
    Custom:
      begin
        tbWidth.Max    := 300;
        tbHeight.Max   := 100;
        grpSize.Height := 126;
      end;
  end;

  lblWidth .Caption := Format('Width: %d',[tbWidth.Position]);
  lblHeight.Caption := Format('Height: %d',[tbHeight.Position]);

end;

procedure TfrmMain.DoAutoSize;
var
  b: TBitmap;
  c: TCanvas;
begin
  b := TBitmap.Create;
  try
    c := b.Canvas;
    c.Font.Assign(memChart.Font);
    tbWidth.Position  := memChart.Width  div c.TextWidth ('w');
    tbHeight.Position := memChart.Height div c.TextHeight('w');
  finally
    b.Free;
  end;
end;

end.
