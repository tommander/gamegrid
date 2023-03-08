unit ugamegrid;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, ExtCtrls, ComCtrls, Math, ugamecommon,
  GR32_Image, GR32, GR32_Layers, GR32_Png;

type
  TLayerCollectionAccess = class(TLayerCollection);

  TGameOnChangeMapSize = TNotifyEvent;
  TGameOnChangeViewport = TNotifyEvent;
  TGameOnLog = TNotifyEvent;
  TGameOnAfterLayerPaint = procedure(ALayer: TCustomLayer) of object;
  TGameOnObjectDataCreate = procedure(var AData: pointer; const ADef: string) of object;
  TGameOnObjectDataFree = procedure(var AData: pointer) of object;

  TGameTreeNodeData = class
    public
      var FFile: string;
      var FContent: string;
      constructor Create(const AFile, AContent: string);
      destructor Destroy(); override;
  end;

  TGameLayer = class(TBitmapLayer)
    private
      var FPos: TMapPos;
      var FSize: TMapSize;
      var FRect: TMapRect;
      var FData: pointer;
      var FOriginalBitmap: TBitmap32;
      procedure SetPos(AValue: TMapPos);
      procedure SetSize(AValue: TMapSize);
    public
      property Pos: TMapPos read FPos write SetPos;
      property Size: TMapSize read FSize write SetSize;
      property Rect: TMapRect read FRect;
      property Data: pointer read FData write FData;
      property OriginalBitmap: TBitmap32 read FOriginalBitmap write FOriginalBitmap;

      constructor Create(ALayerCollection: TLayerCollection); override;
      //destructor Destroy; override;
  end;

  TGameNeighbour = record
    Direction: TMapDir;
    Index: QWord;
    Layer: TGameLayer;
  end;
  TGameNeighbours = array of TGameNeighbour;

  TCustomGameGrid = class(TCustomImage32)
    private
//      var Image: TImage32;
      var FBitmapIndex: TStringList;
      var BitmapList: TBitmap32List;

      var FMapSize: TMapSize; //number of fields
      var FViewport: TMapRect; //lefttop field -> bottomright field
      var FLastViewport: TMapRect; //updatelayers() is using this
      var FLastImageSize: TMapSize; //and this too
      var FLog: string;
      var FFieldSelected: TMapPos;
      var FFieldCursor: TMapPos;
//      var FMap: array of array of integer;

      var FDirLayers: string;
      var FDirObjects: string;

      var FOnChangeMapSize: TGameOnChangeMapSize;
      var FOnChangeViewport: TGameOnChangeViewport;
      var FOnLog: TGameOnLog;
      var FOnAfterLayerPaint: TGameOnAfterLayerPaint;
      var FOnObjectDataCreate: TGameOnObjectDataCreate;
      var FOnObjectDataFree: TGameOnObjectDataFree;

      procedure SetMapSize(AValue: TMapSize);
      procedure SetViewport(AValue: TMapRect);
      procedure FixViewport(AForceChange: boolean = false);
      procedure SetFieldSelected(AValue: TMapPos);
      procedure SetFieldCursor(AValue: TMapPos);

      procedure SetDirLayers(AValue: string);
      procedure SetDirObjects(AValue: string);

      procedure DoOnChangeMapSize();
      procedure DoOnChangeViewport();
      procedure DoOnLog();
      procedure DoAfterLayerPaint(ALayer: TCustomLayer);
      procedure DoObjectDataCreate(var AData: pointer; const ADef: string);
      procedure DoObjectDataFree(var AData: pointer);

      procedure AddToLog(const AText: string);
    public
      property MapSize: TMapSize read FMapSize write SetMapSize;
      property Viewport: TMapRect read FViewport write SetViewport;
      property Log: string read FLog;
      property FieldSelected: TMapPos read FFieldSelected write SetFieldSelected;
      property FieldCursor: TMapPos read FFieldCursor write SetFieldCursor;

      property DirLayers: string read FDirLayers write SetDirLayers;
      property DirObjects: string read FDirObjects write SetDirObjects;

      property OnChangeMapSize: TGameOnChangeMapSize read FOnChangeMapSize write FOnChangeMapSize;
      property OnChangeViewport: TGameOnChangeViewport read FOnChangeViewport write FOnChangeViewport;
      property OnLog: TGameOnLog read FOnLog write FOnLog;
      property OnAfterLayerPaint: TGameOnAfterLayerPaint read FOnAfterLayerPaint write FOnAfterLayerPaint;
      property OnObjectDataCreate: TGameOnObjectDataCreate read FOnObjectDataCreate write FOnObjectDataCreate;
      property OnObjectDataFree: TGameOnObjectDataFree read FOnObjectDataFree write FOnObjectDataFree;

      constructor Create(AOwner: TComponent{; AImage: TImage32; ABitmapList: TBitmap32List}); override;
      destructor Destroy(); override;
//      procedure Clear();
      function GetBitmapIndex(const AName: string): integer;
      function GetBitmap(const AName: string): TBitmap32;
      procedure LoadGraphics();
      procedure LoadObjects(ATV: TTreeView);

      function FieldSizeFloat(): TFloatPoint;
      function FieldBoundsFloat(AField: TMapPos): TFloatRect;
      function FieldBoundsFloat(AField: TMapPos; ASize: TMapSize): TFloatRect;
      procedure ScrollH(ADelta: int64);
      procedure ScrollV(ADelta: int64);
      procedure Zoom(AZoomIn: boolean);

      procedure UpdateLayer(ALayer: TCustomLayer);
      procedure UpdateLayers();
      function FieldToLayer(AField: TMapPos): TGameLayer;
      function FieldFromXY(AX,AY: integer): TMapPos;
      function LayerFromXY(AX,AY: integer): TCustomLayer;
      function LayerFromXY(AXY: TFloatPoint): TCustomLayer;
      function FieldToXY(AField: TMapPos): TFloatPoint;
      function LayerNeighbours(ALayer: TGameLayer): TGameNeighbours;
      function AreaFree(ARect: TMapRect; AExceptLayer: integer = -1): boolean;

      function AddObject(ABitmap: integer; APos: TMapPos; ASize: TMapSize; AData: pointer): integer;
      function AddObject(APos: TMapPos; const AObjectDef: string): integer;
      function MoveObject(ALayer: TGameLayer; ANewPos: TMapPos): integer;
      procedure RotateObject(ALayer: TGameLayer);
      function RemoveObject(ALayer: TGameLayer): integer;
  end;
  TGameGrid = class(TCustomGameGrid)
    published
      { From TImage32 }
      property Align;
      property Anchors;
      property AutoSize;
      property Bitmap;
      property BitmapAlign;
      property Color;
      property Constraints;
      property Cursor;
      property DragCursor;
      property DragMode;
      property ParentColor;
      property ParentShowHint;
      property PopupMenu;
      property RepaintMode;
      property Scale;
      property ScaleMode;
      property ShowHint;
      property TabOrder;
      property TabStop;
      property Visible;
      property OnBitmapResize;
      property OnClick;
      property OnChange;
      property OnContextPopup;
      property OnDblClick;
      property OnGDIOverlay;
      property OnDragDrop;
      property OnDragOver;
      property OnEndDrag;
      property OnInitStages;
      property OnKeyDown;
      property OnKeyPress;
      property OnKeyUp;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
      property OnMouseWheel;
      property OnMouseWheelDown;
      property OnMouseWheelUp;
      property OnMouseEnter;
      property OnMouseLeave;
      property OnPaintStage;
      property OnResize;
      property OnStartDrag;
      { Mine }
//      property MapSize;
//      property Viewport;
//      property Log;
//      property FieldSelected;
//      property FieldCursor;
      property OnChangeMapSize;
      property OnChangeViewport;
      property OnLog;
      property OnAfterLayerPaint;
  end;

implementation

constructor TGameTreeNodeData.Create(const AFile,AContent: string);
begin
  FFile := copy(AFile,1,Length(AFile));
  FContent := copy(AContent,1,Length(AContent));
end;

destructor TGameTreeNodeData.Destroy();
begin
  FFile := '';
  FContent := '';
  inherited Destroy();
end;

procedure TGameLayer.SetPos(AValue: TMapPos);
begin
  FPos := AValue;
  FRect.Create(FPos, FSize);
end;

procedure TGameLayer.SetSize(AValue: TMapSize);
begin
  FSize := AValue;
  FRect.Create(FPos, FSize);
end;

constructor TGameLayer.Create(ALayerCollection: TLayerCollection);
begin
  inherited Create(ALayerCollection);
  Size := TMapSize.Make(0,0);
  FData := nil;
  FOriginalBitmap := nil;
end;

//destructor TGameLayer.Destroy;
//begin
//  inherited Destroy();
//end;

{ Private }

procedure TCustomGameGrid.SetMapSize(AValue: TMapSize);
begin
  if (AValue.Width < 1) or (AValue.Height < 1) or (FMapSize = AValue) then
  begin
    Exit;
  end;

  FMapSize := AValue;

  FixViewport(true);
  DoOnChangeMapSize();
end;

procedure TCustomGameGrid.SetViewport(AValue: TMapRect);
begin
  if (FViewport = AValue) then
  begin
    Exit;
  end;

  FViewport := AValue;
  FixViewport(true);
end;

procedure TCustomGameGrid.FixViewport(AForceChange: boolean = false);
var t: QWord;
    vpOriginal: TMapRect;
    mapRect: TMapRect;
begin
  vpOriginal := FViewport;
  mapRect.Create(TMapPos.Make(0,0), FMapSize);

  if FViewport.Width > FMapSize.Width then
  begin
    FViewport.Width:= FMapSize.Width;
  end
  else if FViewport.Width = 0 then
  begin
    FViewport.Width := 1;
  end;

  if FViewport.Height > FMapSize.Height then
  begin
    FViewport.Height:= FMapSize.Height;
  end
  else if FViewport.Height = 0 then
  begin
    FViewport.Height := 1;
  end;

  if FViewport.Left < 0 then
  begin
    t := FViewport.Width;
    FViewport.Left := 0;
    FViewport.Width := t;
  end
  else if FViewport.Left > FMapSize.Width-FViewport.Width then
  begin
    t := FViewport.Width;
    FViewport.Left := FMapSize.Width-FViewport.Width;
    FViewport.Width := t;
  end;

  if FViewport.Top < 0 then
  begin
    t := FViewport.Height;
    FViewport.Top := 0;
    FViewport.Height := t;
  end
  else if FViewport.Top > FMapSize.Height-FViewport.Height then
  begin
    t := FViewport.Height;
    FViewport.Top := FMapSize.Height-FViewport.Height;
    FViewport.Height := t;
  end;

  if AForceChange or (vpOriginal <> FViewport) then
  begin
    UpdateLayers();
    DoOnChangeViewport();
  end;
end;

procedure TCustomGameGrid.SetFieldSelected(AValue: TMapPos);
var old: TMapPos;
    oldLayer,newLayer: TCustomLayer;
begin
  if AValue = FFieldSelected then
  begin
    Exit;
  end;

  old := FFieldSelected;
  oldLayer := LayerFromXY(FieldToXY(old));
  FFieldSelected := AValue;
  newLayer := LayerFromXY(FieldToXY(FFieldSelected));

  if Assigned(oldLayer) and (oldLayer.Index >= 3) then
  begin
    UpdateLayer(oldLayer);
  end
  else if Layers.Count > 2 then
  begin
    UpdateLayer(Layers[2]);
  end;

  if Assigned(newLayer) and (newLayer.Index >= 3) then
  begin
    UpdateLayer(newLayer);
  end
  else if Layers.Count > 2 then
  begin
    UpdateLayer(Layers[2]);
  end;
end;

procedure TCustomGameGrid.SetFieldCursor(AValue: TMapPos);
var old: TMapPos;
    oldLayer,newLayer: TCustomLayer;
begin
  if AValue = FFieldCursor then
  begin
    Exit;
  end;

  old := FFieldCursor;
  oldLayer := LayerFromXY(FieldToXY(old));
  FFieldCursor := AValue;
  newLayer := LayerFromXY(FieldToXY(FFieldCursor));

  if Assigned(oldLayer) and (oldLayer.Index >= 3) then
  begin
    UpdateLayer(oldLayer);
  end
  else if Layers.Count > 1 then
  begin
    UpdateLayer(Layers[1]);
  end;

  if Assigned(newLayer) and (newLayer.Index >= 3) then
  begin
    UpdateLayer(newLayer);
  end
  else if Layers.Count > 1 then
  begin
    UpdateLayer(Layers[1]);
  end;
end;

procedure TCustomGameGrid.SetDirLayers(AValue: string);
var strDir: string;
begin
  if DirectorySeparator <> '/' then
  begin
    strDir := StringReplace(AValue, '/', DirectorySeparator, [rfReplaceAll]);
  end
  else
  begin
    strDir := AValue;
  end;
  if not DirectoryExists(strDir) then
  begin
    Exit;
  end;
  FDirLayers := strDir;
end;

procedure TCustomGameGrid.SetDirObjects(AValue: string);
var strDir: string;
begin
  if DirectorySeparator <> '/' then
  begin
    strDir := StringReplace(AValue, '/', DirectorySeparator, [rfReplaceAll]);
  end
  else
  begin
    strDir := AValue;
  end;
  if not DirectoryExists(strDir) then
  begin
    Exit;
  end;
  FDirObjects := strDir;
end;

procedure TCustomGameGrid.DoOnChangeMapSize();
begin
  if Assigned(FOnChangeMapSize) then
  begin
    FOnChangeMapSize(self);
  end;
end;

procedure TCustomGameGrid.DoOnChangeViewport();
begin
  if Assigned(FOnChangeViewport) then
  begin
    FOnChangeViewport(self);
  end;
end;

procedure TCustomGameGrid.DoOnLog();
begin
  if Assigned(FOnLog) then
  begin
    FOnLog(self);
  end;
end;

procedure TCustomGameGrid.DoAfterLayerPaint(ALayer: TCustomLayer);
begin
  if Assigned(FOnAfterLayerPaint) then
  begin
    FOnAfterLayerPaint(ALayer);
  end;
end;

procedure TCustomGameGrid.DoObjectDataCreate(var AData: pointer; const ADef: string);
begin
  if Assigned(FOnObjectDataCreate) then
  begin
    FOnObjectDataCreate(AData, ADef);
  end;
end;

procedure TCustomGameGrid.DoObjectDataFree(var AData: pointer);
begin
  if Assigned(FOnObjectDataFree) then
  begin
    FOnObjectDataFree(AData);
  end;
end;

procedure TCustomGameGrid.UpdateLayer(ALayer: TCustomLayer);
var lT: TCustomLayer;
    lB: TBitmapLayer;
    lG: TGameLayer;
    x,y: integer;
    bds: TFloatRect;
begin
  if not Assigned(ALayer) then
  begin
    Exit;
  end;

  if (ALayer.Index = 0) and (ALayer is TBitmapLayer) then
  begin
    lB := (ALayer as TBitmapLayer);
    lB.Visible := true;
    lB.Bitmap.BeginUpdate;
    try
      lB.Location := FloatRect(0,0,Width,Height);
      lB.Bitmap.SetSize(Width,Height);
      lB.Bitmap.Clear(Color32(200,200,200));
      for x := FViewport.Left to FViewport.Right do
      begin
        for y := FViewport.Top to FViewport.Bottom do
        begin
          if ((x+y) mod 2) <> 0 then
          begin
            continue;
          end;
          bds := FieldBoundsFloat(TMapPos.Make(x,y));
          lB.Bitmap.FillRect(
            Round(bds.Left),
            Round(bds.Top),
            Round(bds.Right),
            Round(bds.Bottom),
            Color32(220,220,220)
          );
        end;
      end;
    finally
      lB.Bitmap.EndUpdate;
    end;
  end
  else if (ALayer.Index = 1) and (ALayer is TBitmapLayer) then
  begin
    lB := (ALayer as TBitmapLayer);
    lT := LayerFromXY(FieldToXY(FFieldCursor));
    lB.Visible := (Assigned(lT) and (not (lT is TGameLayer)));
    if lB.Visible then
    begin
      lB.Bitmap.BeginUpdate;
      try
        lB.Location := FieldBoundsFloat(FFieldCursor);
        lB.Bitmap.SetSize(Round(lB.Location.Right-lB.Location.Left+1),Round(lB.Location.Bottom-lB.Location.Top+1));
        lB.Bitmap.DrawMode := dmBlend;
        lB.Bitmap.Clear(Color32(200,0,0,128));
      finally
        lB.Bitmap.EndUpdate;
      end;
    end;
  end
  else if ALayer.Index = 2 then
  begin
    lB := (ALayer as TBitmapLayer);
    lT := LayerFromXY(FieldToXY(FFieldSelected));
    lB.Visible := (Assigned(lT) and (not (lT is TGameLayer)));
    if lB.Visible then
    begin
      lB.Bitmap.BeginUpdate;
      try
        lB.Location := FieldBoundsFloat(FFieldSelected);
        lB.Bitmap.SetSize(Round(lB.Location.Right-lB.Location.Left+1),Round(lB.Location.Bottom-lB.Location.Top+1));
        lB.Bitmap.DrawMode := dmBlend;
        lB.Bitmap.Clear(Color32(0,0,200,128));
      finally
        lB.Bitmap.EndUpdate;
      end;
    end;
  end
  else if (ALayer.Index >= 3) and (ALayer is TGameLayer) then
  begin
    lG := (ALayer as TGameLayer);
    lG.Visible := Viewport.Contains(lG.Pos);
    if lG.Visible then
    begin
      lG.Bitmap.BeginUpdate;
      try
        lG.Location := FieldBoundsFloat(lG.Pos, lG.Size);
        lG.Bitmap.SetSize(Round(lG.Location.Right-lG.Location.Left+1),Round(lG.Location.Bottom-lG.Location.Top+1));
        lG.Bitmap.DrawMode := dmBlend;
        lG.Bitmap.FillRectS(lG.Bitmap.BoundsRect, Color32(clBtnFace));
        if Assigned(lG.OriginalBitmap) then
        begin
          lG.OriginalBitmap.DrawTo(lG.Bitmap, lG.Bitmap.BoundsRect);
        end;
        DoAfterLayerPaint(lG);
        if lG.Rect.Contains(FFieldCursor) then
        begin
          lG.Bitmap.FillRectTS(lG.Bitmap.BoundsRect, Color32(200,0,0,128));
        end
        else if lG.Rect.Contains(FFieldSelected) then
        begin
          lG.Bitmap.FillRectTS(lG.Bitmap.BoundsRect, Color32(0,0,200,128));
        end;
      finally
        lG.Bitmap.EndUpdate;
      end;
    end;
  end;
end;

procedure TCustomGameGrid.UpdateLayers();
var i: integer;
begin
  // Background grid
  if Layers.Count = 0 then
  begin
    UpdateLayer(Layers.Add(TBitmapLayer));
  end
  else
  begin
    UpdateLayer(Layers[0]);
  end;

  // Background cursor
  if Layers.Count = 1 then
  begin
    UpdateLayer(Layers.Add(TBitmapLayer));
  end
  else
  begin
    UpdateLayer(Layers[1]);
  end;

  // Background selection
  if Layers.Count = 2 then
  begin
    UpdateLayer(Layers.Add(TBitmapLayer));
  end
  else
  begin
    UpdateLayer(Layers[2]);
  end;

  // Objects
  if Layers.Count > 3 then
  begin
    for i := 3 to Layers.Count-1 do
    begin
      UpdateLayer(Layers[i]);
    end;
  end;
end;

function TCustomGameGrid.FieldSizeFloat(): TFloatPoint;
begin
  result := FloatPoint(Width/Viewport.Width, Height/Viewport.Height);
end;

function TCustomGameGrid.FieldBoundsFloat(AField: TMapPos): TFloatRect;
begin
  result := FieldBoundsFloat(AField, TMapSize.Make(1,1));
end;

function TCustomGameGrid.FieldBoundsFloat(AField: TMapPos; ASize: TMapSize): TFloatRect;
var fs: TFloatPoint;
begin
  fs := FieldSizeFloat();
  result := FloatRect(
    (AField.X-Viewport.Left)*fs.X,
    (AField.Y-Viewport.Top)*fs.Y,
    (AField.X-Viewport.Left+ASize.Width)*fs.X,
    (AField.Y-Viewport.Top+ASize.Height)*fs.Y
  );
end;

procedure TCustomGameGrid.ScrollH(ADelta: int64);
var newVP: TMapRect;
begin
  newVP.Create(TMapPos.Make(FViewport.Left+ADelta, FViewport.Top), FViewport.Width, FViewport.Height);
  if (newVP.Left < 0) then
  begin
    newVp.Left := 0;
    newVp.Width := FViewport.Width;
  end;
  if (newVP.Left > FMapSize.Width-FViewport.Width) then
  begin
    newVp.Left := FMapSize.Width-FViewport.Width;
    newVp.Width := FViewport.Width;
  end;
  Viewport := newVP;
end;

procedure TCustomGameGrid.ScrollV(ADelta: int64);
var newVP: TMapRect;
begin
  newVP.Create(TMapPos.Make(FViewport.Left, FViewport.Top+ADelta), FViewport.Width, FViewport.Height);
  if (newVP.Top < 0) then
  begin
    newVp.Top := 0;
    newVp.Height := FViewport.Height;
  end;
  if (newVP.Top > FMapSize.Height-FViewport.Height) then
  begin
    newVp.Top := FMapSize.Height-FViewport.Height;
    newVp.Height := FViewport.Height;
  end;
  Viewport := newVP;
end;

procedure TCustomGameGrid.Zoom(AZoomIn: boolean);
var newVP: TMapRect;
begin
  newVP := Viewport;
  if AZoomIn then
  begin
    if (newVP.Width > 1) and (newVP.Height > 1) then
    begin
      newVP.Width := newVP.Width-1;
      newVP.Height := newVP.Height-1;
    end;
  end
  else
  begin
    if (newVP.Width < FMapSize.Width) and (newVP.Height < FMapSize.Height) then
    begin
      newVP.Width := newVP.Width+1;
      newVP.Height := newVP.Height+1;
    end;
  end;
  Viewport := newVP;
end;

function TCustomGameGrid.LayerNeighbours(ALayer: TGameLayer): TGameNeighbours;
var i: integer;
    posNeighbour: TMapPos;
    ptNeighbour: TFloatPoint;
    l: TCustomLayer;
begin
  SetLength(result, 2*(ALayer.Size.Width+ALayer.Size.Height));
  for i := Low(result) to High(result) do
  begin
    posNeighbour.Create(0,0);
    if (i < ALayer.Size.Height) then
    begin
      result[i].Direction := mdLeft;
      result[i].Index := i;
      posNeighbour.Create(ALayer.FRect.Left-1, ALayer.FRect.Top-i);
    end
    else if (i < (ALayer.Size.Height+ALayer.Size.Width)) then
    begin
      result[i].Direction := mdBottom;
      result[i].Index := i-ALayer.Size.Height;
      posNeighbour.Create(ALayer.FRect.Left+result[i].Index, ALayer.FRect.Bottom+1);
    end
    else if (i < (ALayer.Size.Height+ALayer.Size.Width+ALayer.Size.Height)) then
    begin
      result[i].Direction := mdRight;
      result[i].Index := i-ALayer.Size.Height-ALayer.Size.Width;
      posNeighbour.Create(ALayer.FRect.Right+1, ALayer.FRect.Bottom-result[i].Index);
    end
    else
    begin
      result[i].Direction := mdTop;
      result[i].Index := i-ALayer.Size.Height-ALayer.Size.Width-ALayer.Size.Height;
      posNeighbour.Create(ALayer.FRect.Right-result[i].Index, ALayer.FRect.Top-1);
    end;
    result[i].Layer := nil;
    if Layers.MouseEvents then
    begin
      ptNeighbour := FieldToXY(posNeighbour);
      l := LayerFromXY(ptNeighbour);
      if l is TGameLayer then
      begin
        result[i].Layer := (l as TGameLayer);
      end;
    end;

  end;
end;

procedure TCustomGameGrid.RotateObject(ALayer: TGameLayer);
var mapRect: TMapRect;
begin
  if not Assigned(ALayer) then
  begin
    Exit;
  end;

  if not AreaFree(TMapRect.Make(ALayer.Pos, ALayer.Size.Height, ALayer.Size.Width), ALayer.Index) then
  begin
    Exit;
  end;

  mapRect.Create(TMapPos.Make(0,0), FMapSize.Width, FMapSize.Height);
  if mapRect.Overflow(TMapRect.Make(ALayer.Pos, ALayer.Size.Height, ALayer.Size.Width)) then
  begin
    Exit;
  end;

  ALayer.Size := TMapSize.Make(ALayer.Size.Height, ALayer.Size.Width);
  UpdateLayer(ALayer);
end;

function TCustomGameGrid.AreaFree(ARect: TMapRect; AExceptLayer: integer = -1): boolean;
var x,y: integer;
    xy: TFloatPoint;
    l: TCustomLayer;
begin
  result := false;

  for x := ARect.Left to ARect.Right do
  begin
    for y := ARect.Top to ARect.Bottom do
    begin
      xy := FieldToXY(TMapPos.Make(x,y));
      l := LayerFromXY(xy);
      if (l is TGameLayer) and (l.Index <> AExceptLayer) then
      begin
        Exit(false);
      end;
    end;
  end;

  result := true;
end;

function TCustomGameGrid.FieldToLayer(AField: TMapPos): TGameLayer;
var l: TCustomLayer;
begin
  result := nil;
  l := LayerFromXY(FieldToXY(AField));
  if l is TGameLayer then
  begin
    result := (l as TGameLayer);
  end;
end;

function TCustomGameGrid.FieldFromXY(AX,AY: integer): TMapPos;
var fs: TFloatPoint;
begin
  fs := FieldSizeFloat();
  result.Create(
    FViewport.Left + Math.Floor(AX / fs.X),
    FViewport.Top + Math.Floor(AY / fs.Y)
  );
end;

function TCustomGameGrid.LayerFromXY(AX,AY: integer): TCustomLayer;
begin
  result := TLayerCollectionAccess(Layers).MouseUp(mbLeft, [], AX, AY);
end;

function TCustomGameGrid.LayerFromXY(AXY: TFloatPoint): TCustomLayer;
begin
  result := LayerFromXY(Round(AXY.X), Round(AXY.Y));
end;

function TCustomGameGrid.FieldToXY(AField: TMapPos): TFloatPoint;
var fs: TFloatPoint;
begin
  fs := FieldSizeFloat();
  result := FloatPoint(
    ((AField.X - FViewport.Left) * fs.X) + (fs.X / 2),
    ((AField.Y - FViewport.Top) * fs.Y) + (fs.Y / 2)
  );
end;

procedure TCustomGameGrid.AddToLog(const AText: string);
begin
  FLog := FLog + AText + #13#10;
  DoOnLog();
end;

{ Public }

constructor TCustomGameGrid.Create(AOwner: TComponent{; AImage: TImage32; ABitmapList: TBitmap32List});
begin
  inherited Create(AOwner);

//  Image := AImage;
  FBitmapIndex := TStringList.Create;
  BitmapList := TBitmap32List.Create(self);// ABitmapList;
  MapSize := TMapSize.Make(0,0);
  Viewport := TMapRect.Make();
  FLastViewport := TMapRect.Make();
  FLastImageSize := TMapSize.Make(0,0);
  FLog := '';
  FieldSelected := TMapPos.Make(-1,-1);
  FieldCursor := TMapPos.Make(-1,-1);
  FDirLayers := '';
  FDirObjects := '';

  OnChangeMapSize := nil;
  OnChangeViewport := nil;
  OnLog := nil;
  OnAfterLayerPaint := nil;
  OnObjectDataCreate := nil;
  OnObjectDataFree := nil;
end;

destructor TCustomGameGrid.Destroy;
begin
  if Assigned(FBitmapIndex) then
  begin
    FreeAndNil(FBitmapIndex);
  end;
  inherited Destroy;
end;

function TCustomGameGrid.GetBitmapIndex(const AName: string): integer;
var i: integer;
begin
  result := -1;
  i := FBitmapIndex.IndexOfName(AName);
  if (i < 0) or (i >= FBitmapIndex.Count) then
  begin
    Exit;
  end;
  result := StrToIntDef(FBitmapIndex.ValueFromIndex[i], -1);
end;

function TCustomGameGrid.GetBitmap(const AName: string): TBitmap32;
var i: integer;
begin
  result := nil;
  i := GetBitmapIndex(AName);
  if (i < 0) or (i >= BitmapList.Bitmaps.Count) then
  begin
    Exit;
  end;
  result := BitmapList.Bitmap[i];
end;

procedure TCustomGameGrid.LoadGraphics();
var sr: TSearchRec;
    bmp: TBitmap32Item;
    s: string;
begin
  BitmapList.Bitmaps.BeginUpdate;
  try
    BitmapList.Bitmaps.Clear;

    if not DirectoryExists(AppDir(FDirLayers)) then
    begin
      Exit;
    end;

    {$IFDEF Unix}
    if FindFirst(AppDir(JoinPath([FDirLayers,'*.png'])), 0, sr) <> -1 then
    {$ELSE Unix}
    if FindFirst(AppDir(JoinPath([FDirLayers,'*.png'])), 0, sr) = 0 then
    {$ENDIF}
    begin
      try
        repeat
          bmp := BitmapList.Bitmaps.Add;
          bmp.Bitmap.DrawMode:=dmBlend;
          LoadBitmap32FromPNG(bmp.Bitmap, AppDir(JoinPath([FDirLayers,sr.Name])));
          s := LowerCase(StringReplace(ChangeFileExt(sr.Name, ''), FBitmapIndex.NameValueSeparator, '', [rfReplaceAll]));
          FBitmapIndex.AddPair(s,IntToStr(bmp.Index));
        until
          FindNext(sr) <> 0;
      finally
        FindClose(sr);
      end;
    end;
  finally
    BitmapList.Bitmaps.EndUpdate;
  end;
end;

procedure TCustomGameGrid.LoadObjects(ATV: TTreeView);
var sr: TSearchRec;
    tn: TTreeNode;
    sl: TStringList;
begin
  ATV.BeginUpdate;
  sl := TStringList.Create;
  try
    ATV.Items.Clear;

    if not DirectoryExists(AppDir(FDirObjects)) then
    begin
      Exit;
    end;

    {$IFDEF Unix}
    if FindFirst(AppDir(JoinPath([FDirObjects,'*.obj'])), 0, sr) <> -1 then
    {$ELSE Unix}
    if FindFirst(AppDir(JoinPath([FDirObjects,'*.obj'])), 0, sr) = 0 then
    {$ENDIF}
    begin
      try
        repeat
          tn := ATV.Items.Add(nil, ChangeFileExt(sr.Name, ''));
          sl.LoadFromFile(AppDir(JoinPath([FDirObjects,sr.Name])));
          tn.Data := TGameTreeNodeData.Create(AppDir(JoinPath([FDirObjects,sr.Name])), sl.Text);
          sl.Clear;
        until
          FindNext(sr) <> 0;
      finally
        FindClose(sr);
      end;
    end;
  finally
    sl.Free;
    ATV.EndUpdate;
  end;
end;

{procedure TCustomGameGrid.Clear;
begin
end;}

function TCustomGameGrid.AddObject(ABitmap: integer; APos: TMapPos; ASize: TMapSize; AData: pointer): integer;
var layer: TCustomLayer;
    rct,mapRect: TMapRect;
begin
  result := -1;

  // Check for a layer that has the same position
  rct.Create(APos,ASize);
  if not AreaFree(rct) then
  begin
    Exit;
  end;

  // Check that the object fits into the map
  mapRect.Create(TMapPos.Make(0,0), FMapSize.Width, FMapSize.Height);
  if mapRect.Overflow(rct) then
  begin
    Exit;
  end;

  // Try to add a new layer
  layer := Layers.Add(TGameLayer);
  if not (layer is TGameLayer) then
  begin
    Exit;
  end;

  // All good, we just set properties
  result := 0;
  (layer as TGameLayer).Visible := true;
  (layer as TGameLayer).Pos := Apos;
  (layer as TGameLayer).Size := ASize;
  (layer as TGameLayer).Data := AData;
  if (ABitmap >= 0) and (ABitmap < BitmapList.Bitmaps.Count) then
  begin
    (layer as TGameLayer).OriginalBitmap := BitmapList.Bitmap[ABitmap];
  end;

  UpdateLayer(layer);
end;

function TCustomGameGrid.AddObject(APos: TMapPos; const AObjectDef: string): integer;
var strBitmap,strData: string;
    ms: TMapSize;
    d: pointer;
    intS,intP: integer;
begin
  //bitmapa^15;25^neconeconeco
  //12345678901234567890123456
  //len=26
  //-
  //s=1 p=8 l=p-s=7
  //x[1,7]='bitmapa'
  //-
  //s=9 p=14 l=p-s=5
  //x[9;5]='15;25'
  //-
  //s=15 l=len-s+1=26-15+1=12
  //x[15;12]='neconeconeco'


  strBitmap := '';
  strData := '';
  ms.Create(0,0);
  d := nil;

  intS := 1;
  intP := Pos(#10,AObjectDef,intS);
  if intP = 0 then
  begin
    Exit;
  end;
  if intP > intS then
  begin
    strBitmap := copy(AObjectDef, intS, intP-intS);
  end;

  intS := intP+1;
  intP := Pos(#10,AObjectDef,intS);
  if intP = 0 then
  begin
    Exit;
  end;
  if intP > intS then
  begin
    ms.FromStr(copy(AObjectDef, intS, intP-intS));
  end;

  intS := intP+1;
  intP := Length(AObjectDef)+1;
  if intP > intS then
  begin
    DoObjectDataCreate(d, copy(AObjectDef, intS, intP-intS));
  end;

  result := AddObject(GetBitmapIndex(strBitmap), APos, ms, d);
end;

function TCustomGameGrid.MoveObject(ALayer: TGameLayer; ANewPos: TMapPos): integer;
var newRect: TMapRect;
begin
  result := -1;
  if ALayer.Index < 3 then
  begin
    Exit;
  end;
  newRect.Create(ANewPos, ALayer.Size);
  if not AreaFree(newRect, ALayer.Index) then
  begin
    Exit;
  end;
  ALayer.Pos := ANewPos;
  UpdateLayer(ALayer);
end;

function TCustomGameGrid.RemoveObject(ALayer: TGameLayer): integer;
begin
  result := -1;
  if ALayer.Index < 3 then
  begin
    Exit;
  end;
  Layers.Delete(ALayer.Index);
end;

end.

