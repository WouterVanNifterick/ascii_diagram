unit WvN.Math.Interpolate;

interface

type
  TInterpolationType=(IT_LINEAR, IT_COSINE);

function LinearInterpolate(mu:Double):Double;overload;{inline;}
function LinearInterpolate(y1,y2,mu:Double):Double;overload;{inline;}
function LinearInterpolate(x1,y1,x2,y2,x:Double):Double;overload;{inline;}

function CosineInterpolate(mu:Double):Double;overload;inline;
function CosineInterpolate(y1,y2,mu:Double):Double;overload;inline;
function CosineInterpolate(x1,y1,x2,y2,x:Double):Double;overload;inline;

function CubicInterpolate(y0,y1,y2,y3,mu:Double):Double;
function HermiteInterpolate(y0,y1,y2,y3, mu, tension, bias:Double):Double;
function Interpolate(y1,y2,mu:Double;InterpolationType:TInterpolationType):Double;


implementation

uses SysUtils;

function LinearInterpolate(mu:Double):Double;
begin
  Result := mu;
end;

function LinearInterpolate(y1,y2,mu:Double):Double;
begin
  Result := y1*(1-mu)+y2*mu;
end;

function LinearInterpolate(x1,y1,x2,y2,x:Double):Double;
var
  mu:Double;
begin
  if X1=X2 then
    Exit(y1);
  mu := (x-x1)/(x2-x1);
  Result := y1*(1-mu)+y2*mu;
end;

function CosineInterpolate(mu:Double):Double;
begin
   Result := -(0.5 + cos(mu*pi)/2);
end;

function CosineInterpolate(y1,y2,mu:Double):Double;
var
  mu2:Double;
begin
  mu2 := (1-cos(mu*PI))/2;
  Result := y1*(1-mu2)+y2*mu2;
end;

function CosineInterpolate(x1,y1,x2,y2,x:Double):Double;
var
  mu:Double;
begin
  mu := (x-x1)/(x2-x1);
  Result := CosineInterpolate(y1,y2,mu);
end;


function CubicInterpolate(y0,y1,y2,y3,mu:Double):Double;
var
  a0,a1,a2,a3,mu2:Double;
begin
   mu2 := mu*mu;
   a0  := y3 - y2 - y0 + y1;
   a1  := y0 - y1 - a0;
   a2  := y2 - y0;
   a3  := y1;

   Result := a0*mu*mu2+a1*mu2+a2*mu+a3;
end;

{
   Tension: 1 is high, 0 normal, -1 is low
   Bias: 0 is even,
         positive is towards first segment,
         negative towards the other
}
function HermiteInterpolate(y0,y1,y2,y3, mu, tension, bias:Double):Double;
var
  m0,m1,mu2,mu3,
  a0,a1,a2,a3:Double;
begin
	mu2 := mu * mu;
	mu3 := mu2 * mu;
   m0 :=      ((y1-y0)*(1+bias)*(1-tension)/2);
   m0 := m0 + ((y2-y1)*(1-bias)*(1-tension)/2);
   m1 :=      ((y2-y1)*(1+bias)*(1-tension)/2);
   m1 := m1 + ((y3-y2)*(1-bias)*(1-tension)/2);
   a0 :=  2*mu3 - 3*mu2 + 1;
   a1 :=    mu3 - 2*mu2 + mu;
   a2 :=    mu3 -   mu2;
   a3 := -2*mu3 + 3*mu2;

   Result := a0*y1+a1*m0+a2*m1+a3*y2;
end;

function Interpolate(y1,y2,mu:Double;InterpolationType:TInterpolationType):Double;
begin
  Result := 0;
  case InterpolationType of
    TInterpolationType.IT_LINEAR: Result := LinearInterpolate(y1,y2,mu);
    TInterpolationType.IT_COSINE: Result := CosineInterpolate(y1,y2,mu);
  end;
end;

end.
