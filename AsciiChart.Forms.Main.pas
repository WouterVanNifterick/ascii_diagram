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
    cbHorizontal : TCheckBox;
    cbVertical   : TCheckBox;
    rgChartType  : TRadioGroup;
    grpAxis      : TGroupBox;
    edAxisX      : TLabeledEdit;
    edAxisY      : TLabeledEdit;
    Panel4       : TPanel;
    rbSizeCustom : TRadioButton;
    rbSizeAuto   : TRadioButton;
    Splitter1    : TSplitter;
    edTitle: TLabeledEdit;
    rbSizeData   : TRadioButton;
    cbFillGaps   : TCheckBox;
    Splitter2    : TSplitter;
    StatusBar1   : TStatusBar;
    ComboBox1    : TComboBox;
    procedure memInputChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure memInputDblClick(Sender: TObject);
    procedure UpdateChart(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  strict private
    procedure DoAutoSize;
    procedure UpdateSizeControls;
  private
    procedure GuiCharsToChart;
    procedure ChartToGuiChars;
    procedure InitEdChar;
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
begin
  Chart := TChart.Create([],TSize.Create(80,24));
  InitEdChar;

  memInputChange(self);

  UpdateChart(self);
  ChartToGuiChars;

  GenerateSineData;
end;



procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Chart);
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
//    s := s + Format('%.3f' + sLineBreak, [sin(2 * 2 * pi * i / samples) * 5], fs);
    s := s + Format('%.2f' + sLineBreak, [i*1.0], fs);
  memInput.Text := s;
end;

procedure TfrmMain.InitEdChar;
var
  c: Char;
begin
  edChars.InsertRow('Line', Chart.Chars.DataSymbol, true);
  edChars.ItemProps['Line'].EditStyle := TEditStyle.esPickList;
  if edChars.ItemProps['Line'].PickList.Count > 0 then
    for c in '#@x|o*' do
      edChars.ItemProps['Line'].PickList.Add(c);
  edChars.InsertRow('VertMarker', Chart.Chars.VertMarker, true);
  edChars.InsertRow('HorzMarker', Chart.chars.HorzMarker, true);
  edChars.InsertRow('LeftLine', Chart.Chars.LeftLine, true);
  edChars.InsertRow('BottomLine', Chart.Chars.BottomLine, true);
  edChars.InsertRow('BottomLineCrossing', Chart.Chars.BottomLineCrossing, true);
end;

procedure TfrmMain.ChartToGuiChars;
begin
  edChars.Strings.BeginUpdate;

  edChars.Values['Line'              ] := Chart.Chars.DataSymbol;
  edChars.Values['VertMarker'        ] := Chart.Chars.VertMarker;
  edChars.Values['HorzMarker'        ] := Chart.chars.HorzMarker;
  edChars.Values['LeftLine'          ] := Chart.Chars.LeftLine;
  edChars.Values['BottomLine'        ] := Chart.Chars.BottomLine;
  edChars.Values['BottomLineCrossing'] := Chart.Chars.BottomLineCrossing;

  edChars.Strings.EndUpdate;

end;


procedure TfrmMain.GuiCharsToChart;
var
  v: string;
  chars:TChart.Tchars;
begin
  v := edChars.Values['Line'              ] + Chart.Chars.DataSymbol;         Chars.DataSymbol         := v[1];
  v := edChars.Values['VertMarker'        ] + Chart.Chars.VertMarker;         Chars.VertMarker         := v[1];
  v := edChars.Values['HorzMarker'        ] + Chart.Chars.HorzMarker;         Chars.HorzMarker         := v[1];
  v := edChars.Values['LeftLine'          ] + Chart.Chars.LeftLine;           Chars.LeftLine           := v[1];
  v := edChars.Values['BottomLine'        ] + Chart.Chars.BottomLine;         Chars.BottomLine         := v[1];
  v := edChars.Values['BottomLineCrossing'] + Chart.Chars.BottomLineCrossing; Chars.BottomLineCrossing := v[1];
  Chart.Chars := Chars;
end;

type TDataType = (dtRaw, dtFloat, dtHex, dtHex2);

procedure TfrmMain.memInputChange(Sender: TObject);
var
  a:TData;s,t:string;
  v:double; vi, vo:Int64;
  fs:TFormatSettings;
  I: Integer;
  DataType:TDataType;
  IsOdd : Boolean;
begin
  fs.DecimalSeparator := '.';


  DataType := dtFloat;

  a := [];
  s := memInput.Text;

  if s.StartsWith('hex2') then
  begin
    DataType := dtHex2;
    s := s.Substring(4);
  end
  else
  if s.StartsWith('hex') then
  begin
    DataType := dtHex;
    s := s.Substring(3);
  end;

  if s.StartsWith('raw') then
  begin
    DataType := dtRaw;
    for I := 3 to length(s) do
       a := a + [ord(s[I])];
  end
  else
  begin
    s := s.Replace(',',sLineBreak);
    s := s.Replace( #9,sLineBreak);
    s := s.Replace(' ',sLineBreak);
    s := s.Replace('(','');
    s := s.Replace(')','');
    s := s.Replace(';','');
    s := s.Replace(sLineBreak+sLineBreak,sLineBreak);
    s := s.Replace(sLineBreak+sLineBreak,sLineBreak);
    s := s.Replace(sLineBreak+sLineBreak,sLineBreak);

    IsOdd := True;

    for s in s.Split([sLineBreak]) do
    begin
      t := trim(s);
      IsOdd := not IsOdd;
      if DataType in [dtHex, dtHex2] then
        if not t.StartsWith('$') then
          t := '$'+t;

      if t.StartsWith('$') then
      begin
        if TryStrToInt64(t,vi) then
        begin
          if DataType = dtHex then
            a := a+[vi];

          if DataType = dtHex2 then
          begin
            if IsOdd then
              a := a+[vi]
            else
            begin
              vo  := trunc(a[high(a)]) shl 8;
              a[high(a)] := vo + vi
            end;
          end;
        end;
      end
      else
        if TryStrToFloat(t,v,fs) then
          a := a+[v];
    end;
  end;

  Chart.Data := a;
  UpdateChart(Sender);
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
  Chart.Title                 := edTitle.Text;

  GuiCharsToChart;

  memChart.Text := Chart.ToString;

  StatusBar1.Panels[1].Text := Format('Data points:%d', [Length(Chart.FSerie.FData)]);
end;

procedure TfrmMain.UpdateSizeControls;
var
  mode: TScaleMode;
  h:integer;
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

        h := round(Ceil(abs(Chart.FSerie.minV))+ceil(abs(Chart.FSerie.maxV)));
        if h>40 then
        h := (length(Chart.Data) div 3);
        h := h + Chart.Margins.Top + Chart.Margins.Bottom;
        tbHeight.Position := h;
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


procedure TfrmMain.ComboBox1Change(Sender: TObject);
var
  Chars:TChart.Tchars;
begin
  case Combobox1.ItemIndex of
    1: begin
         Chars.DataSymbol         := '#'; // █░
         Chars.LeftLine           := '|';
         Chars.HorzMarker         := '-';
         Chars.VertMarker         := ':';
         Chars.BottomLine         := '=';
         Chars.BottomLineCrossing := '+';
         Chart.Chars := Chars;
       end;
    2: begin
         Chars.DataSymbol         := '█';
         Chars.LeftLine           := '│';
         Chars.HorzMarker         := '─'; //╌ ┈
         Chars.VertMarker         := '│'; // ┊ ┼

         Chars.BottomLine         := '─';
         Chars.BottomLineCrossing := '┴';
         Chart.Chars := Chars;
       end;
  end;

  self.edChars.Visible := ComboBox1.ItemIndex=0;
  if edChars.Visible then
    grpCharacters.Height := 180
  else
    grpCharacters.Height := 45;

  ChartToGuiChars;

  UpdateChart(Sender);
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
