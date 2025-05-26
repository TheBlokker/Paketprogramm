program Paket;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  ABOUT in 'ABOUT.pas' {AboutBox},
  SetupContact in 'SetupContact.pas' {Form2},
  FrameContactOption in 'FrameContactOption.pas' {Frame1: TFrame},
  Startup in 'Startup.pas' {Form3},
  vCardParser in 'vCardParser.pas',
  Worker in 'Worker.pas',
  FrameContactCustome in 'FrameContactCustome.pas' {Frame2: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
