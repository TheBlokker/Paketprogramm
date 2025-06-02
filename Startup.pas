unit Startup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls;

type
  TForm3 = class(TForm)
    Label1: TLabel;
    Image1: TImage;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses ABOUT, Main;

procedure TForm3.Button1Click(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm3.Button3Click(Sender: TObject);
begin
  Form1.Show;
end;

end.
