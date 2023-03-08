unit umainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Spin, Buttons, ugamegrid, GR32, GR32_Image, GR32_Layers,
  ugamecommon, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    RadioGroup1: TRadioGroup;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    tmrRepaint: TTimer;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image32_1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer);
    procedure Image32_1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure Image32_1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Image32_1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Image32_1Resize(Sender: TObject);
    procedure ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ScrollBar2Scroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure tmrRepaintTimer(Sender: TObject);
    procedure GGChangeMapSize(Sender: TObject);
    procedure GGChangeViewport(Sender: TObject);
    procedure GGLog(Sender: TObject);
    procedure GGAfterLayerPaint(ALayer: TCustomLayer);
    procedure TreeView1Deletion(Sender: TObject; Node: TTreeNode);
  private
    var gg: TGameGrid;
    var firstActivate: boolean;
    var layerToMove: TGameLayer;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  layerToMove := nil;
  firstActivate := true;

  gg := TGameGrid.Create(self);
  gg.Parent := Panel4;
  gg.Align := alClient;
  gg.BitmapAlign := baTopLeft;
  gg.RepaintMode := rmOptimizer;
  gg.ScaleMode := smNormal;

  gg.OnChangeMapSize := @GGChangeMapSize;
  gg.OnChangeViewport := @GGChangeViewport;
  gg.OnLog := @GGLog;
  gg.OnAfterLayerPaint := @GGAfterLayerPaint;

  gg.OnMouseMove := @Image32_1MouseMove;
  gg.OnMouseUp := @Image32_1MouseUp;
  gg.OnMouseWheelDown := @Image32_1MouseWheelDown;
  gg.OnMouseWheelUp := @Image32_1MouseWheelUp;
  gg.OnResize := @Image32_1Resize;

  gg.DirLayers := 'data/layers';
  gg.DirObjects := 'data/objects';

  gg.LoadGraphics();
  gg.LoadObjects(TreeView1);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
end;

procedure TForm1.Image32_1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer; Layer: TCustomLayer);
var fld: TMapPos;
    lidx: integer;
begin
  fld := gg.FieldFromXY(X,Y);
  lidx := -1;
  if Assigned(Layer) then
  begin
    lidx := Layer.Index;
  end;
  gg.FieldCursor := fld;
  Label1.Caption := Format('[%d;%d]=>[%d;%d;%d]', [X,Y,lidx,fld.X,fld.Y]);
end;

procedure TForm1.Image32_1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
//const arrObj: array[0..3] of string = ('wire','input','output','gate');

  procedure SetLayerInfo(TheLayer: TCustomLayer);
  var gn: TGameNeighbours;
      i: integer;
      s: string;
  begin
    Memo2.Lines.Clear;
    if not Assigned(TheLayer) then
    begin
      Memo2.Lines.Add('<nil>');
      Exit;
    end;
    if TheLayer is TGameLayer then
    begin
      Memo2.Lines.Add('Game Layer');
//      Memo2.Lines.Add('Pos: %s', [(TheLayer as TGameLayer).Pos.ToStr()]);
      Memo2.Lines.Add('Size: %s', [(TheLayer as TGameLayer).Size.ToStr()]);
      Memo2.Lines.Add('Rect: %s', [(TheLayer as TGameLayer).Rect.ToStr()]);
      Memo2.Lines.Add('Data: %p', [(TheLayer as TGameLayer).Data]);
      Memo2.Lines.Add('Neighbours:');
      gn := gg.LayerNeighbours(TheLayer as TGameLayer);
      for i := Low(gn) to High(gn) do
      begin
        s := '<nil>';
        if Assigned(gn[i].Layer) then
        begin
          s := gn[i].Layer.Rect.ToStr();
        end;
        Memo2.Lines.Add('  %d: %s%d %s', [i, MapDirToStr(gn[i].Direction), gn[i].Index, s]);
      end;
      Exit;
    end;
  end;

  procedure UpdateFieldSelected();
  begin
    if Assigned(Layer) and (Layer is TGameLayer) then
    begin
      gg.FieldSelected := (Layer as TGameLayer).Pos;
    end
    else
    begin
      gg.FieldSelected := gg.FieldFromXY(X,Y);
    end;
  end;

begin
  UpdateFieldSelected();

  case RadioGroup1.ItemIndex of
    1: //Move
    begin
      if not Assigned(layerToMove) then
      begin
        if Layer is TGameLayer then
        begin
          layerToMove := (Layer as TGameLayer);
        end;
      end
      else
      begin
        gg.MoveObject(layerToMove, gg.FieldFromXY(X,Y));
        layerToMove := nil;
      end;
    end;
    2: //Rotate
    begin
      layerToMove := nil;
      if Layer is TGameLayer then
      begin
        gg.RotateObject(Layer as TGameLayer);
      end;
    end;
    3: //Delete
    begin
      layerToMove := nil;
      if Layer is TGameLayer then
      begin
        gg.RemoveObject(Layer as TGameLayer);
      end;
    end;
    4: //Add
    begin
      layerToMove := nil;
      if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) then
      begin
        if gg.AddObject(gg.FieldFromXY(X,Y), TGameTreeNodeData(TreeView1.Selected.Data).FContent) = -1 then
        begin
          showmessage('Cannot');
        end;
      end;
    end;
    else //Select
    begin
      layerToMove := nil;
      SetLayerInfo(Layer);
    end;
  end;
end;

procedure TForm1.Image32_1MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if Shift = [ssCtrl] then
  begin
    gg.Zoom(false);
  end
  else if Shift = [ssShift] then
  begin
    gg.ScrollH(1);
    ScrollBar1.Position := ScrollBar1.Position + 1;
  end
  else if Shift = [] then
  begin
    gg.ScrollV(1);
    ScrollBar2.Position := ScrollBar2.Position + 1;
  end;
end;

procedure TForm1.Image32_1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if Shift = [ssCtrl] then
  begin
    gg.Zoom(true);
  end
  else if Shift = [ssShift] then
  begin
    gg.ScrollH(-1);
    ScrollBar1.Position := ScrollBar1.Position - 1;
  end
  else if Shift = [] then
  begin
    gg.ScrollV(-1);
    ScrollBar2.Position := ScrollBar2.Position - 1;
  end;
end;

procedure TForm1.Image32_1Resize(Sender: TObject);
begin
  tmrRepaint.Enabled := false;
  tmrRepaint.Enabled := true;
end;

procedure TForm1.ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  gg.ScrollH(ScrollPos-ScrollBar1.Position);
end;

procedure TForm1.ScrollBar2Scroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  gg.ScrollV(ScrollPos-ScrollBar2.Position);
end;

procedure TForm1.tmrRepaintTimer(Sender: TObject);
begin
  gg.UpdateLayers;
  tmrRepaint.Enabled := false;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  gg.Invalidate;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  gg.MapSize := TMapSize.Make(SpinEdit1.Value, SpinEdit2.Value);
end;

procedure TForm1.Button3Click(Sender: TObject);
var vp: TMapRect;
begin
  vp := gg.Viewport;
  vp.Width := SpinEdit3.Value;
  vp.Height := SpinEdit4.Value;
  gg.Viewport := vp;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  if not firstActivate then
  begin
    Exit;
  end;
  firstActivate := false;
  gg.MapSize := TMapSize.Make(3,2);
  gg.Viewport := TMapRect.Make(TMapPos.Make(0,0),3,2);
end;

procedure TForm1.GGChangeMapSize(Sender: TObject);
begin
  SpinEdit1.Value := gg.MapSize.Width;
  SpinEdit2.Value := gg.MapSize.Height;
end;

procedure TForm1.GGChangeViewport(Sender: TObject);
begin
  SpinEdit3.Value := gg.Viewport.Width;
  SpinEdit4.Value := gg.Viewport.Height;
  ScrollBar1.Max := gg.MapSize.Width-gg.Viewport.Width;
  ScrollBar2.Max := gg.MapSize.Height-gg.Viewport.Height;
end;

procedure TForm1.GGLog(Sender: TObject);
begin
  Memo1.Lines.Text := gg.Log;
end;

procedure TForm1.GGAfterLayerPaint(ALayer: TCustomLayer);

  function RelativeRect(ARect: TFloatRect): TRect;
  begin
    result.Left := Round(ARect.Left - (ALayer as TGameLayer).Location.Left);
    result.Right := Round(ARect.Right - (ALayer as TGameLayer).Location.Left);
    result.Top := Round(ARect.Top - (ALayer as TGameLayer).Location.Top);
    result.Bottom := Round(ARect.Bottom - (ALayer as TGameLayer).Location.Top);
  end;

var b: TBitmap32;
    i: integer;
    rct: TRect;
begin
  if not (ALayer is TGameLayer) then
  begin
    Exit;
  end;

  (ALayer as TGameLayer).Bitmap.BeginUpdate;
  try
      // Left pins
      b := gg.GetBitmap('pinL');
      for i := (ALayer as TGameLayer).Rect.Top to (ALayer as TGameLayer).Rect.Bottom do
      begin
        rct := RelativeRect(gg.FieldBoundsFloat(
          TMapPos.Make((ALayer as TGameLayer).Rect.Left, i),
          TMapSize.Make(1,1)
        ));
        b.DrawTo((ALayer as TGameLayer).Bitmap, rct);
      end;

      // Bottom pins
      b := gg.GetBitmap('pinB');
      for i := (ALayer as TGameLayer).Rect.Left to (ALayer as TGameLayer).Rect.Right do
      begin
        rct := RelativeRect(gg.FieldBoundsFloat(
          TMapPos.Make(i, (ALayer as TGameLayer).Rect.Bottom),
          TMapSize.Make(1,1)
        ));
        b.DrawTo((ALayer as TGameLayer).Bitmap, rct);
      end;

      // Right pins
      b := gg.GetBitmap('pinR');
      for i := (ALayer as TGameLayer).Rect.Bottom downto (ALayer as TGameLayer).Rect.Top do
      begin
        rct := RelativeRect(gg.FieldBoundsFloat(
          TMapPos.Make((ALayer as TGameLayer).Rect.Right, i),
          TMapSize.Make(1,1)
        ));
        b.DrawTo((ALayer as TGameLayer).Bitmap, rct);
      end;

      // Top pins
      b := gg.GetBitmap('pinT');
      for i := (ALayer as TGameLayer).Rect.Right downto (ALayer as TGameLayer).Rect.Left do
      begin
        rct := RelativeRect(gg.FieldBoundsFloat(
          TMapPos.Make(i, (ALayer as TGameLayer).Rect.Top),
          TMapSize.Make(1,1)
        ));
        b.DrawTo((ALayer as TGameLayer).Bitmap, rct);
      end;
  finally
    (ALayer as TGameLayer).Bitmap.EndUpdate;
  end;
end;

procedure TForm1.TreeView1Deletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
  begin
    TGameTreeNodeData(Node.Data).Free;
    Node.Data := nil;
  end;
end;

end.

