program gamegrid;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, umainform, ugamegrid, ugamecommon
  { you can add units after this },
  SysUtils;

{$R *.res}

begin
  {$IF declared(UseHeapTrace)}
  if UseHeapTrace then
  begin
    if FileExists('gamegrid.heaptrc') then
    begin
      DeleteFile('gamegrid.heaptrc');
    end;
    GlobalSkipIfNoLeaks := False;
    SetHeapTraceOutput('gamegrid.heaptrc');
  end;
  {$ENDIF}
  Randomize;
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

