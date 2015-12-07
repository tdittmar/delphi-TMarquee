{ -----------------------------------------------------------------------------
  MarqueeVersion.pas      Copyright © 1998-2001 by DithoSoft Software Solutions
  Version 2.7                                           http://www.dithosoft.de
  -----------------------------------------------------------------------------
  About dialog for the TMarquee component
  ---------------------------------------------------------------------------- }
unit MarqueeVersion;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TMarqueeVersionDlg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
    Button1: TButton;
    Image1: TImage;
    Label4: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MarqueeVersionDlg: TMarqueeVersionDlg;

implementation

{$R *.DFM}

end.
