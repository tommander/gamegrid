unit ugamecommon;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, RegExpr;

type
  TMapDir = (mdLeft,mdBottom,mdRight,mdTop);
  TMapPos = object
    X: Int64;
    Y: Int64;

    function Make(AX,AY: Int64): TMapPos; static;
    procedure Create(AX,AY: Int64);
    procedure FromPoint(APoint: TPoint);
    function ToPoint(): TPoint;
    function ToStr(): string;
    procedure FromStr(AValue: string);
  end;
  TMapSize = object
    Width: QWord;
    Height: QWord;

    function Make(AWidth,AHeight: QWord): TMapSize; static;
    procedure Create(AWidth,AHeight: QWord);
    procedure FromPoint(APoint: TPoint);
    function ToPoint(): TPoint;
    function ToStr(): string;
    procedure FromStr(AValue: string);
  end;
  TMapRect = object
    Left: Int64;
    Right: Int64;
    Top: Int64;
    Bottom: Int64;
    private
      procedure SetWidth(AWidth: QWord);
      function GetWidth(): QWord;
      procedure SetHeight(AHeight: QWord);
      function GetHeight(): QWord;
    public
      property Width: QWord read GetWidth write SetWidth;
      property Height: QWord read GetHeight write SetHeight;

      function Make(): TMapRect; static;
      function Make(ALeft,ATop,ARight,ABottom: Int64): TMapRect; static;
      function Make(ALeftTop: TMapPos; AWidth,AHeight: QWord): TMapRect; static;
      function Make(ALeftTop: TMapPos; ASize: TMapSize): TMapRect;
      procedure Create();
      procedure Create(ALeft,ATop,ARight,ABottom: Int64);
      procedure Create(ALeftTop: TMapPos; AWidth,AHeight: QWord);
      procedure Create(ALeftTop: TMapPos; ASize: TMapSize);
      procedure FromRect(ARect: TRect);
      function ToRect(): TRect;
      function ToStr(): string;
      procedure FromStr(AValue: string);
      function Contains(APos: TMapPos): boolean;
      function Contains(ARect: TMapRect): boolean;
      function Overflow(ARect: TMapRect): boolean;
  end;

operator =(a,b: TMapPos): boolean;
operator =(a,b: TMapSize): boolean;
operator =(a,b: TMapRect): boolean;

function AppDir(AFile: string = ''): string;
function JoinPath(const AElems: array of string): string;
function MapDirToStr(ADir: TMapDir): string;

implementation

{ Global }

function AppDir(AFile: string = ''): string;
begin
  result := ExtractFilePath(ParamStr(0));
  if AFile <> '' then
  begin
    result := IncludeTrailingPathDelimiter(result)+AFile;
  end;
end;

function JoinPath(const AElems: array of string): string;
var i: integer;
begin
  result := '';
  if Length(AElems) = 0 then
  begin
    Exit;
  end;
  result := AElems[Low(AElems)];
  for i := Low(AElems)+1 to High(AElems) do
  begin
    result := result + DirectorySeparator + AElems[i];
  end;
end;

function MapDirToStr(ADir: TMapDir): string;
begin
  result := '';
  case ADir of
    mdLeft: result := 'L';
    mdBottom: result := 'B';
    mdRight: result := 'R';
    mdTop: result := 'T';
  end;
end;

{ TMapPos }

operator =(a,b: TMapPos): boolean;
begin
  result := (
    (a.X = b.X) and
    (a.Y = b.Y)
  );
end;

function TMapPos.Make(AX,AY: Int64): TMapPos; static;
begin
  result.Create(AX,AY);
end;

procedure TMapPos.Create(AX,AY: Int64);
begin
  X := AX;
  Y := AY;
end;

procedure TMapPos.FromPoint(APoint: TPoint);
begin
  X := APoint.X;
  Y := APoint.Y;
end;

function TMapPos.ToPoint(): TPoint;
begin
  result.Create(X,Y);
end;

function TMapPos.ToStr(): string;
begin
  result := '['+IntToStr(X)+';'+IntToStr(Y)+']';
end;

procedure TMapPos.FromStr(AValue: string);
var re: TRegExpr;
begin
  re := TRegExpr.Create('\[(\d+);(\d+)\]');
  try
    if re.Exec(AValue) then
    begin
      X := StrToInt64Def(re.Match[1], 0);
      Y := StrToInt64Def(re.Match[2], 0);
    end;
  finally
    re.Free;
  end;
end;

{ TMapSize }

operator =(a,b: TMapSize): boolean;
begin
  result := (
    (a.Width = b.Width) and
    (a.Height = b.Height)
  );
end;

function TMapSize.Make(AWidth,AHeight: QWord): TMapSize;
begin
  result.Create(AWidth, AHeight);
end;

procedure TMapSize.Create(AWidth,AHeight: QWord);
begin
  Width := AWidth;
  Height := AHeight;
end;

procedure TMapSize.FromPoint(APoint: TPoint);
begin
  Width := APoint.X;
  Height := APoint.Y;
end;

function TMapSize.ToPoint(): TPoint;
begin
  result.Create(Width, Height);
end;

function TMapSize.ToStr(): string;
begin
  result := '['+UIntToStr(Width)+';'+UIntToStr(Height)+']';
end;

procedure TMapSize.FromStr(AValue: string);
var re: TRegExpr;
begin
  re := TRegExpr.Create('\[(\d+);(\d+)\]');
  try
    if re.Exec(AValue) then
    begin
      Width := StrToUInt64Def(re.Match[1], 0);
      Height := StrToUInt64Def(re.Match[2], 0);
    end;
  finally
    re.Free;
  end;
end;

{ TMapRect }

operator =(a,b: TMapRect): boolean;
begin
  result := (
    (a.Left = b.Left) and
    (a.Top = b.Top) and
    (a.Right = b.Right) and
    (a.Bottom = b.Bottom)
  );
end;

procedure TMapRect.SetWidth(AWidth: QWord);
begin
  Right := Left+AWidth-1;
end;

function TMapRect.GetWidth(): QWord;
begin
  if Right < Left then
  begin
    Exit(0);
  end;
  result := Right-Left+1;
end;

procedure TMapRect.SetHeight(AHeight: QWord);
begin
  Bottom := Top+AHeight-1;
end;

function TMapRect.GetHeight(): QWord;
begin
  if Bottom < Top then
  begin
    Exit(0);
  end;
  result := Bottom-Top+1;
end;

function TMapRect.Make(): TMapRect;
begin
  result.Create();
end;

function TMapRect.Make(ALeft,ATop,ARight,ABottom: Int64): TMapRect;
begin
  result.Create(ALeft,ATop,ARight,ABottom);
end;

function TMapRect.Make(ALeftTop: TMapPos; AWidth,AHeight: QWord): TMapRect;
begin
  result.Create(ALeftTop,AWidth,AHeight);
end;

function TMapRect.Make(ALeftTop: TMapPos; ASize: TMapSize): TMapRect;
begin
  result.Create(ALeftTop,ASize);
end;

procedure TMapRect.Create();
begin
  Create(0,0,0,0);
end;

procedure TMapRect.Create(ALeft,ATop,ARight,ABottom: Int64);
begin
  Left := ALeft;
  Top := ATop;
  Right := ARight;
  Bottom := ABottom;
end;

procedure TMapRect.Create(ALeftTop: TMapPos; AWidth,AHeight: QWord);
begin
  Left := ALeftTop.X;
  Top := ALeftTop.Y;
  SetWidth(AWidth);
  SetHeight(AHeight);
end;

procedure TMapRect.Create(ALeftTop: TMapPos; ASize: TMapSize);
begin
  Create(ALeftTop, ASize.Width, ASize.Height);
end;

procedure TMapRect.FromRect(ARect: TRect);
begin
  Left := ARect.Left;
  Top := ARect.Top;
  Right := ARect.Right;
  Bottom := ARect.Bottom;
end;

function TMapRect.ToRect(): TRect;
begin
  result.Create(Left, Top, Right, Bottom);
end;

function TMapRect.ToStr(): string;
begin
  result := '['+IntToStr(Left)+';'+IntToStr(Top)+';'+IntToStr(Right)+';'+IntToStr(Bottom)+']';
end;

procedure TMapRect.FromStr(AValue: string);
var re: TRegExpr;
begin
  re := TRegExpr.Create('\[(\d+);(\d+);(\d+);(\d+)\]');
  try
    if re.Exec(AValue) then
    begin
      Left := StrToInt64Def(re.Match[1], 0);
      Top := StrToInt64Def(re.Match[2], 0);
      Right := StrToInt64Def(re.Match[3], 0);
      Bottom := StrToInt64Def(re.Match[4], 0);
    end;
  finally
    re.Free;
  end;
end;

function TMapRect.Contains(APos: TMapPos): boolean;
begin
  result := (APos.X >= Left) and (APos.X <= Right) and (APos.Y >= Top) and (APos.Y <= Bottom);
end;

function TMapRect.Contains(ARect: TMapRect): boolean;
begin
  result := (not ((ARect.Left > Right) or (ARect.Right < Left) or (ARect.Top > Bottom) or (ARect.Bottom < Top)));;
end;

function TMapRect.Overflow(ARect: TMapRect): boolean;
begin
  result := ((ARect.Left < Left) or (ARect.Right > Right) or (ARect.Top < Top) or (ARect.Bottom > Bottom));
end;

end.

