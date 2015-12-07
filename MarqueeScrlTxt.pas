{ -----------------------------------------------------------------------------
  MarqueeScrlTxt.pas      Copyright © 1998-2001 by DithoSoft Software Solutions
  Version 2.7                                           http://www.dithosoft.de
  -----------------------------------------------------------------------------
  Property editor dialog for the TMarquee component
  ---------------------------------------------------------------------------- }
unit MarqueeScrlTxt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TScrollTextDlg = class(TForm)
    Frame: TBevel;
    ScrollText: TEdit;
    ScrollTextLabel: TLabel;
    LoadBtn: TButton;
    StripControlCodes: TCheckBox;
    OKButton: TButton;
    CancelButton: TButton;
    OpenDialog: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
  end;

var
  ScrollTextDlg: TScrollTextDlg;

implementation

{$R *.DFM}

procedure TScrollTextDlg.FormShow(Sender: TObject);
begin
  { Focus the input line when showing the dialog }
  ScrollText.SetFocus;
end;

procedure TScrollTextDlg.LoadBtnClick(Sender: TObject);
var
  TextList: TStringList;
begin
  { Show the "File open" dialog }
  if OpenDialog.Execute then begin
    { Create a string list that holds the entire file contents }
    TextList := TStringList.Create;
    try
      { Load the text and convert it to a single line }
      TextList.LoadFromFile(OpenDialog.FileName);
      ScrollText.Text := TextList.Text;
    finally
      TextList.Free;
    end;
  end;
end;

end.
