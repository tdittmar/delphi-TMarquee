{ -----------------------------------------------------------------------------
  MarqueeReg.pas          Copyright © 1998-2001 by DithoSoft Software Solutions
  Version 2.7                                           http://www.dithosoft.de
  -----------------------------------------------------------------------------
  This unit registers the component and property editors for TMarquee. It must
  be added separately to designtime packages. It may not be added to a runtime
  package!
  ---------------------------------------------------------------------------- }
unit MarqueeReg;

interface

uses {$IFDEF VER140}DesignIntf, DesignEditors, VCLEditors{$ELSE}DsgnIntf{$ENDIF};

type
  { TMarqueeEditor }
  TMarqueeEditor = class(TComponentEditor)
  public
    function  GetVerbCount: Integer; override;
    function  GetVerb(Index: Integer): String; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

  { TScrollTextProperty }
  TScrollTextProperty = class(TStringProperty)
  public
    function  GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

procedure Register;

implementation

uses Forms, Controls, Classes, MarqueeVersion, MarqueeScrlTxt, Marquee;

procedure Register;
begin
  RegisterComponents('Freeware', [TMarquee]);
  RegisterComponentEditor(TMarquee,TMarqueeEditor);
  RegisterPropertyEditor(TypeInfo(String),TMarquee,'ScrollText',TScrollTextProperty);

  {$IFDEF VER130}
  RegisterPropertiesInCategory(TVisualCategory,TMarquee,
                               ['AutoCenter','AutoSizeHeight','BorderStyle',
                                'ScrollText']);
  RegisterPropertiesInCategory(TInputCategory,TMarquee,
                               ['Active','Continuous']);
  RegisterPropertiesInCategory(TMiscellaneousCategory,TMarquee,
                               ['NewControlCode','StripControlCodes',
                                'ScrollAmount','ScrollStyle','ScrollDelay']);
  RegisterPropertiesInCategory(TLocalizableCategory,TMarquee,
                               ['ScrollText']);
  {$ENDIF}
end;

////////////////////////////////////////////////////////////////////////////////

{
  We want to display 2 new menu items in the component's context menu, so we
  have to return 2 here.
}
function TMarqueeEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

{
  Delphi wants to know the captions of the 2 new menu items, so we return them
  depending on the index.
}
function TMarqueeEditor.GetVerb(Index: Integer): String;
begin
  { Return the caption of the new menu items }
  if Index = 0 then Result := 'About TMarquee...';
  if Index = 1 then Result := 'Change ScrollText...';
end;

{
  Someone has selected one of the menu items in the context menu, so we perform
  some action depending on the index.
}
procedure TMarqueeEditor.ExecuteVerb(Index: Integer);
var
  MarqueeVersionDlg: TMarqueeVersionDlg;
  ScrollTextDlg    : TScrollTextDlg;
begin
  { Show the version dialog }
  if Index = 0 then begin
    MarqueeVersionDlg := TMarqueeVersionDlg.Create(Application);
    try
      MarqueeVersionDlg.ShowModal;
    finally
      MarqueeVersionDlg.Free;
    end;
  end;

  { Show the property dialog }
  if Index = 1 then begin
    ScrollTextDlg := TScrollTextDlg.Create(Application);
    try
      { Initialize captions and controls }
      ScrollTextDlg.Caption := TMarquee(Component).Name+'.ScrollText';
      ScrollTextDlg.StripControlCodes.Checked := TMarquee(Component).StripControlCodes;
      ScrollTextDlg.ScrollText.Text := TMarquee(Component).ScrollText;

      { When the dialog was OKed... }
      if ScrollTextDlg.ShowModal = mrOK then begin
        { Get the new values and tell the Designer that the properties were modified }
        TMarquee(Component).StripControlCodes := ScrollTextDlg.StripControlCodes.Checked;
        TMarquee(Component).ScrollText := ScrollTextDlg.ScrollText.Text;
        Designer.Modified;
      end;
    finally
      ScrollTextDlg.Free;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

{
  Our new property editor allows to open a dialog for the property, so we
  return [paDialog] here.
}
function TScrollTextProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

{
  Someone clicked the ellipsis in the Object Inspector. What we do is:
    * we create the dialog
    * we get the name of the component and the property and set the caption
    * we get the current ScrollText and initialize the edit line
    * we check the checkbox in the dialog if currently control codes are to be
      stripped from the text

  After the dialog was closed successfully, we
    * set the new ScrollText
    * set the StripControlCodes property True/False depending on the state of
      the checkmark
}
procedure TScrollTextProperty.Edit;
var
  ScrollTextDlg : TScrollTextDlg;
begin
  ScrollTextDlg := TScrollTextDlg.Create(Application);
  try
    { Initialize caption and controls }
    ScrollTextDlg.Caption := TComponent(GetComponent(0)).Name+'.'+GetPropInfo.Name;
    ScrollTextDlg.StripControlCodes.Checked := TMarquee(GetComponent(0)).StripControlCodes;
    ScrollTextDlg.ScrollText.Text := GetValue;

    { When the dialog was OKed... }
    if ScrollTextDlg.ShowModal = mrOK then begin
      { ...get the new values }
      TMarquee(GetComponent(0)).StripControlCodes := ScrollTextDlg.StripControlCodes.Checked;
      SetValue(ScrollTextDlg.ScrollText.Text);
    end;
  finally
    ScrollTextDlg.Free;
  end;
end;

end.
