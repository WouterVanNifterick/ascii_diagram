unit AsciiChart.Chart;

interface

uses
  SysUtils,
  Types;

type
/// <summary>
/// ScaleMode
///  <ul>
///  <li>Screen: maximize the size of the chart based on the form size</li>
///  <li>Data  : scale the chart based on the number of data items and its ranges</li>
///  <li>Custom: let the user set the width+height via the GUI</li>
///  </ul>
/// </summary>
  TScaleMode = (Screen,Data,Custom);

  TData = array of double;

  TChartType = (Line,Point,Bar);

  TSerie=record
    ChartType:TChartType;
    minV,maxV,vRange:double;
    FData:TData;
    AxisX:string;
    AxisY:string;
    procedure SetData(const Value: TData);
    property Data:TData read FData write SetData;
  end;

  TChart=class
  public type
    Tchars=record
      DataSymbol,
      VertMarker,
      HorzMarker,
      LeftLine,
      BottomLine,
      BottomLineCrossing:char;
    end;
  strict private type
    TJustify=(left,right,center);
  strict private var
    IsDirty   : Boolean;
    FChars    : TChars;
    FSize     : TSize;
    FMaxC     : TSize;
    FMargins  : TRect;
    ChartArea : TRect;
    Canvas    : array of array of char;
    FTitle    : string;
    FFillGaps  : boolean;

    FShowHorizontalMarkers: Boolean;
    FShowVerticalMarkers  : Boolean;
    procedure TextAt(x,y:integer;txt:string;justify:tjustify=center;merge:boolean=false);
    procedure Render;
    procedure Clear;
    procedure FillRect(r:TRect;c:Char);
    procedure SetSize(const Value: TSize);
    procedure SetData(const Value: TData);
    procedure SetShowVerticalMarkers(const Value: Boolean);
    procedure SetShowHorizontalMarkers(const Value: Boolean);
    procedure SetAxisX(const Value: string);
    procedure SetAxisY(const Value: string);
    procedure SetMargins(const Value: TRect);
    procedure RecalcChartArea;
    procedure DrawLines;
    procedure DrawPoints;
    procedure DrawBars;
    procedure ShowBottomAxis;
    procedure SetTitle(const Value: string);
    procedure ShowLeftAxis;
    procedure SetFillGaps(const Value: Boolean);
  public
    FSerie:TSerie;
    constructor Create(aData:TData;sz:TSize);
    procedure SetChars(const Value: TChars);
    function ToString:string; reintroduce;
    property Size:TSize read FSize write SetSize;
    property Data:TData read FSerie.Fdata write SetData;
    property ShowHorizontalMarkers:Boolean read FShowHorizontalMarkers write SetShowHorizontalMarkers;
    property ShowVerticalMarkers:Boolean read FShowVerticalMarkers write SetShowVerticalMarkers;
    property Chars:TChars read FChars write SetChars;
    property AxisX:string read FSerie.AxisX write SetAxisX;
    property AxisY:string read FSerie.AxisY write SetAxisY;
    property Margins:TRect read FMargins write SetMargins;
    property Title:string read FTitle write SetTitle;
    property FillGaps:Boolean read FFillGaps write SetFillGaps;
  end;

implementation

uses Math, WvN.Math.Interpolate;

procedure TChart.Clear;
begin
  FillRect(Rect(0,0,fMaxC.cx,fMaxC.cy),' ');
end;

constructor TChart.Create(aData:TData;sz:TSize);
begin
  FMaxC := Default(TSize);
  FMargins.left       := 5;
  FMargins.Top        := 2;
  FMargins.Bottom     := 2;
  FMargins.right      := 0;
  Size                := sz;
  FSerie.ChartType    := Point;
  Data                := aData;
  ShowVerticalMarkers := true;
  FFillGaps           := false;
{
  FSerie.DataSymbol         := '█';
  FChars.LeftLine           := '|';
  FChars.HorzMarker         := '─'; //╌ ┈
  FChars.VertMarker         := '|'; // ┊
  FChars.BottomLine         := '━';
  FChars.BottomLineCrossing := '┻';
}

  FChars.DataSymbol         := '#'; // █░
  FChars.LeftLine           := '|';
  FChars.HorzMarker         := '-';
  FChars.VertMarker         := ':';
  FChars.BottomLine         := '=';
  FChars.BottomLineCrossing := '+';
  IsDirty                   := true;

end;


procedure TChart.FillRect(r: TRect; c: Char);
var x,y:integer;
begin
  for y := r.Top to r.Bottom do
    for x := r.Left to r.Right do
      Canvas[y,x] := c;
end;

function MergeChars(c1,c2:char):char;
begin
  if c1=c2 then Exit(c1);
  if (c1=' ') then exit(c2);
  if (c2=' ') then exit(c1);

  if CharInSet(c1, ['a'..'z','0'..'9']) then exit(c1);
  if CharInSet(c2, ['a'..'z','0'..'9']) then exit(c2);

  if (c1='▄') and (c2='█') then Exit('█');
  if (c1='▀') and (c2='█') then Exit('█');
  if (c2='▄') and (c1='█') then Exit('█');
  if (c2='▀') and (c1='█') then Exit('█');

  if CharInSet(c1, ['▄','▀','█']) then Exit(c1);
  if CharInSet(c2, ['▄','▀','█']) then Exit(c1);

  if (c1=':') and (c2='=') then Exit('=');
  if (c2=':') and (c1='=') then Exit('=');

  if (c1=':') and (c2='-') then Exit('+');
  if (c2=':') and (c1='-') then Exit('+');

  if (c1='─') and (c2='|') then Exit('┼');
  if (c2='─') and (c1='|') then Exit('┼');

  if (c1='━') and (c2='|') then Exit('┴');
  if (c2='━') and (c1='|') then Exit('┴');

  if (c1='-') and (c2='|') then Exit('+');

  Exit(c2);
end;


procedure TChart.TextAt(x,y:integer;txt:string;justify:tjustify=center;merge:boolean=false);
var n,nX,o:integer;
begin
  case justify of
    left   : o := 0;
    right  : o := -length(txt);
    center : o := -(length(txt) div 2);
    else     o := 0;
  end;

  if y<0 then
    Exit;

  if y>=Size.cy then
    Exit;

  if Merge then
  for n := Low(txt) to High(txt) do
  begin
    nX := x+n;
    if nX<FMaxC.cx-FMargins.Right then
      Canvas[y,o+nX] := MergeChars(Canvas[y,o+nX], txt[n]);
  end
  else
    for n := Low(txt) to High(txt) do
    begin
      nX := x+n;
      if nX<FMaxC.cx-FMargins.Right then
        Canvas[y,o+nX] := txt[n];
    end;
end;

function TChart.ToString: string;
var s:string;x,y:integer;c:char;
begin
  Render;
  s := '';
  for y := 0 to FMaxC.cy do
  begin
    for x := 0 to FMaxC.cx do
    begin
      c := Canvas[y,x];
      if c=#0 then
        c := ' ';
      s := s + c;
    end;
    s := s + sLineBreak;
  end;
  Result := s;
end;

procedure TChart.ShowLeftAxis;
var
  i      : Integer;
  fs     : TFormatSettings;
  ds,s   : string;
  digits : integer;
  v      : double;
begin
  fs.DecimalSeparator := '.';

  if FSerie.vRange <     0.01 then Digits := 6 else
  if FSerie.vRange <     0.1  then Digits := 5 else
  if FSerie.vRange <     1    then Digits := 4 else
  if FSerie.vRange <    10    then Digits := 3 else
  if FSerie.vRange <   100    then Digits := 2 else
  if FSerie.vRange <  1000    then Digits := 1 else
  if FSerie.vRange < 10000    then Digits := 0;

  ds := digits.ToString;

  // left labels
  for I := 0 to ChartArea.Height do
  begin
    v := FSerie.minV + (I / ChartArea.Height) * FSerie.vRange;
    if sameValue(v,round(v)) then
      s := Format('%0.0f', [v],fs)
    else
      s := Format('%0.'+ds+'f', [v],fs);

    TextAt(FMargins.Left, (FMaxC.cy - FMargins.Bottom) - I - 1, s, right,true);
  end;
end;

procedure TChart.ShowBottomAxis;
var
  x,i,j,binSize,pvX: Integer;
begin
  // bottom line
  for x := 1 + FMargins.Left to FMaxC.cx - FMargins.Right do
    Canvas[FMaxC.cy - FMargins.Bottom, x] := FChars.BottomLine;

  binSize := Length(FSerie.Data) div Max(1,Size.cx div 20);
  binSize := max(binsize, 1);
  if binSize > 100000 then   binSize := 100000 else
  if binSize >  10000 then   binSize :=  10000 else
  if binSize >   1000 then   binSize :=   1000 else
  if binSize >    100 then   binSize :=    100 else
  if binSize >     10 then   binSize :=     10 else
  if binSize >      5 then   binSize :=      5 else
  if binSize >      2 then   binSize :=      2 else
                             binSize :=      1;
  // paint bottom axis, with labels
  for I := Low(FSerie.FData) to High(FSerie.FData) do
  begin
    pvX := Round(((I - 0) / length(FSerie.FData)) * ChartArea.Width);
    if (I mod binSize) = 0 then
    begin
      // draw places where marker lines cross bottom line
      TextAt(pvX + FMargins.Left + 1, FMaxC.cy - FMargins.Bottom, FChars.BottomLineCrossing, TJustify.left, false);
      // draw vertical marker lines
      if ShowVerticalMarkers then
        for j := FMargins.Top-1 to FMaxC.cy - FMargins.Bottom  do
          TextAt(pvX + FMargins.Left + 1, j, FChars.VertMarker, TJustify.left, true);
      // bottom labels
      TextAt(pvX + FMargins.Left + 1, FMaxC.cy - FMargins.Bottom + 1, IntTostr(I),TJustify.left,false);
    end;
  end;

  // axis name
  TextAt( ChartArea.CenterPoint.X, ChartArea.Bottom+2, FSerie.AxisX, center ,false);
end;

procedure TChart.DrawBars;
var
  v,v1,v2: Double;
  i,j,k,l,x1,x2:integer;
  Y,pvX,pvY,pvY1,pvY2: Double;
begin
  if FFillGaps then
        for I := Self.ChartArea.Left to self.ChartArea.Right do
        begin
          l := length(FSerie.FData);
          if l=0 then
            exit;

          pvX := I;

          x1 := i-self.ChartArea.Left;
          x1 := round((x1 / self.ChartArea.Width)*l);
          v1 := FSerie.FData[ x1 ];
          pvY1 := (((v1 - FSerie.minV) / FSerie.vRange) * ChartArea.Height);

          x2 := i-self.ChartArea.Left+1;
          x2 := round((x2 / self.ChartArea.Width)*l);
          if x2>=l then
            exit;
          v2 := FSerie.FData[ x2 ];
          pvY2 := (((v2 - FSerie.minV) / FSerie.vRange) * ChartArea.Height);

          Y := Interpolate(pvY1,pvY2,0.5,tinterpolationType.IT_LINEAR);

          j := (FMaxC.cy - FMargins.Bottom) - round(Y) - 1;
          if Y - trunc(Y) > 0.5 then
            TextAt(round(pvX) + FMargins.Left - 3, j, '▄' {FSerie.DataSymbol},TJustify.left,false)
          else
            TextAt(round(pvX) + FMargins.Left - 3, j, '█' {FSerie.DataSymbol},TJustify.left,false);

          for k := J+1  to (FMaxC.cy - FMargins.Bottom) - 1 do
            TextAt(round(pvX) + FMargins.Left - 3, k, Chars.DataSymbol,TJustify.left,false);

        end
  else
        for i := Low(FSerie.FData) to High(FSerie.FData) do
        begin
          v := FSerie.FData[i];
          pvX := (((i - 0) / length(FSerie.FData)) * ChartArea.Width);
          pvY := (((v - FSerie.minV) / FSerie.vRange) * ChartArea.Height);
          j := (FMaxC.cy - FMargins.Bottom) - round(pvY) - 1;
          if pvY - trunc(pvY) > 0.5 then
            TextAt(round(pvX) + FMargins.Left + 1, j, '▄' {FSerie.DataSymbol},TJustify.left,true)
          else
            TextAt(round(pvX) + FMargins.Left + 1, j, '█' {FSerie.DataSymbol},TJustify.left,true);


          for k := J+1  to (FMaxC.cy - FMargins.Bottom) - 1 do
            TextAt(round(pvX) + FMargins.Left + 1, k, Chars.DataSymbol,TJustify.left,false);
        end;
end;

procedure TChart.DrawPoints;
var
  v1,v2,pvX,pvY1,pvY2,Y:double;
  l,x1,x2,i,j:integer;
begin
  if FFillGaps then
            for I := Self.ChartArea.Left to self.ChartArea.Right do
            begin
              l := length(FSerie.FData);
              if l=0 then
                exit;

              pvX := I;

              x1 := i-self.ChartArea.Left;
              x1 := round((x1 / self.ChartArea.Width)*l);
              v1 := FSerie.FData[ x1 ];
              pvY1 := (((v1 - FSerie.minV) / FSerie.vRange) * ChartArea.Height);

              x2 := i-self.ChartArea.Left+1;
              x2 := round((x2 / self.ChartArea.Width)*l);
              if x2>=l then
                exit;
              v2 := FSerie.FData[ x2 ];
              pvY2 := (((v2 - FSerie.minV) / FSerie.vRange) * ChartArea.Height);

              Y := Interpolate(pvY1,pvY2,0.5,tinterpolationType.IT_LINEAR);

              j := (FMaxC.cy - FMargins.Bottom) - round(Y) - 1;
              if Y - trunc(Y) > 0.5 then
                TextAt(round(pvX) + FMargins.Left-1 , j, '▄' {FSerie.DataSymbol},TJustify.left,false)
              else
                TextAt(round(pvX) + FMargins.Left-1 , j, '▀' {FSerie.DataSymbol},TJustify.left,false)

            end
  else

            for i := Low(FSerie.FData) to High(FSerie.FData) do
            begin
              v1 := FSerie.FData[i];
              pvX := (((i - 0) / length(FSerie.FData)) * ChartArea.Width);
              pvY1 := (((v1 - FSerie.minV) / FSerie.vRange) * ChartArea.Height);

              j := (FMaxC.cy - FMargins.Bottom) - round(pvY1) - 1;
              if pvY1 - trunc(pvY1) > 0.5 then
                TextAt(round(pvX) + FMargins.Left + 1, j, '▄' {FSerie.DataSymbol},TJustify.left,false)
              else
                TextAt(round(pvX) + FMargins.Left + 1, j, '▀' {FSerie.DataSymbol},TJustify.left,false)
          //    TextAt(round(pvX) + FMargins.Left + 1, (FMaxC.cy - FMargins.Bottom) - round(pvY) - 1, FSerie.DataSymbol);
            end;
end;

procedure TChart.DrawLines;
var
  v1,v2: Double;
  i,d1,dx,dy,pX1,pY1,pX2,pY2,jX,jY: Integer;
  d: Double;
  c: Char;
begin
  for I := Low(FSerie.FData) to High(FSerie.FData) do
  begin
    if I < High(FSerie.FData) then
    begin
      v1 := FSerie.FData[I];
      pX1 := Round(((I - 0) / length(FSerie.FData)) * ChartArea.Width);
      pY1 := Round(((v1 - FSerie.minV) / FSerie.vRange) * ChartArea.Height);
      v2 := FSerie.FData[I + 1];
      pX2 := Round(((I + 1 - 0) / length(FSerie.FData)) * ChartArea.Width);
      pY2 := Round(((v2 - FSerie.minV) / FSerie.vRange) * ChartArea.Height);
      dx := px1 - px2;
      dy := pY1 - pY2;
      d := sqrt(sqr(dx) + sqr(dy));
      if d > 0.5 then
        for d1 := 0 to round(d) do
        begin
          jx := round(Interpolate(px1, px2, d1 / round(d), IT_LINEAR));
          jy := round(Interpolate(py1, py2, d1 / round(d), IT_LINEAR));
          c := Chars.DataSymbol;
          TextAt(jX + FMargins.Left + 1, (FMaxC.cy - FMargins.Bottom) - jY - 1, c,TJustify.left,true);
        end;
    end;
  end;
end;

procedure TChart.RecalcChartArea;
var r:TRect;
begin
  r := Rect(0,0,fMaxC.cx,fMaxC.cy);
  r.Left   := r.Left  + FMargins.Left;
  r.Top    := r.Top   + FMargins.Top;
  r.Right  := r.Right - FMargins.Right;
  r.Bottom := r.Bottom - FMargins.Bottom;

  if r.Height=0 then
    r.Height := 1;

  ChartArea := r;
end;

procedure TChart.Render;
var
  r:TRect; i,j:integer;
begin
  if not IsDirty then
    Exit;

  Clear;

  r := ChartArea;
  r.Left := r.Left+1;
  r.Top := r.Top-1;
  r.Right := r.Right-1;
  if ShowHorizontalMarkers then
    for i := r.Top to r.Bottom do
    begin
      if Odd(I) then
        for j := r.Left to r.Right do
          TextAt(j,i,Chars.HorzMarker,left,true);
    end;

  ShowBottomAxis;
  ShowLeftAxis;

  // horz caption
  TextAt( 0 , 0, FSerie.AxisY, Left );

  // paint data points
  case FSerie.ChartType of
    Line  : DrawLines;
    Point : DrawPoints;
    Bar   : DrawBars;
  end;

  // Title
  if FTitle<>'' then
    TextAt( ChartArea.CenterPoint.X, ChartArea.Top-2, '[ '+FTitle+' ]', center ,true );

  IsDirty := False;
end;


procedure TSerie.SetData(const Value: TData);
begin
  FData := Value;
  if length(FData)=0 then
  begin
    minV := 0;
    maxV := 0;
    vRange := 1;
    Exit;
  end;

  minV := MinValue(FData);
  maxV := MaxValue(FData);
  vRange:=maxV-minV;
//  VRange := Ceil((vRange)/10)*10;

  if vRange=0 then
    vRange := 1;
end;

procedure TChart.SetAxisX(const Value: string);
begin
  FSerie.AxisX := Value;
  IsDirty := True;
end;

procedure TChart.SetAxisY(const Value: string);
begin
  FSerie.AxisY := Value;
  IsDirty := True;
end;

procedure TChart.SetChars(const Value: TChars);
begin
  FChars := Value;
  IsDirty := True;
end;

procedure TChart.SetData(const Value: TData);
begin
  FSerie.data := Value;
  IsDirty := True;
end;

procedure TChart.SetFillGaps(const Value: Boolean);
begin
  FFillGaps := Value;
  IsDirty := True;
end;

procedure TChart.SetMargins(const Value: TRect);
begin
  FMargins := Value;
  RecalcChartArea;
  IsDirty := True;
end;

procedure TChart.SetSize(const Value: TSize);
begin
  FSize := Value;
  FMaxC.cx := FSize.cx-1;
  FMaxC.cy := FSize.cy-1;

  RecalcChartArea;

  SetLength(Canvas,FSize.cy,FSize.cx);
  IsDirty := True;
end;

procedure TChart.SetTitle(const Value: string);
begin
  FTitle := Value;
  IsDirty := True;
end;

procedure TChart.SetShowHorizontalMarkers(const Value: Boolean);
begin
  FShowHorizontalMarkers := Value;
  IsDirty := True;
end;

procedure TChart.SetShowVerticalMarkers(const Value: Boolean);
begin
  FShowVerticalMarkers := Value;
  IsDirty := True;
end;

end.
