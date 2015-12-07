{ -----------------------------------------------------------------------------
  Marquee.pas             Copyright © 1998-2001 by DithoSoft Software Solutions
  Version 2.7                                           http://www.dithosoft.de
  -----------------------------------------------------------------------------
  TMarquee scrolls text of (theoretically) unlimited length. You can choose
  between 3 different styles (scrolling, blinking, bouncing) and you may select
  the number of pixels and the scroll delay factor in milliseconds.
  -----------------------------------------------------------------------------
  Version history:

  1.00    - first release
  2.00    - Faster drawing
          - Multiline text possible
          - Added AutoSizeHeight property
          - Added property editor for the ScrollText property added
          - Added component editor for the TMarquee component
  2.10    - Bugfixes
          - Code rewriting
          - No multiline text anymore...
          - Changed property editor for the ScrollText property so you can now
            load text
          - The component can now handle VERY long text as well
          - Added StripControlCodes property to automatically replace chars
            < #32 by #32
          - Added OnClick, OnDblClick and OnResize events
  2.2a    - Fixed bug: two independend marquees scrolled the same text
          - Fixed bug: removing the last marquee from a form resulted in an
            access violation
  2.2b    - Fixed bug: drawing routines didn't correctly clear the drawing area
  2.2c	  - Fixed bug: drawing routines didn't work at all anymore...
  2.2d	  - Fixed bug: drawing didn't work alright under Win98
  2.3     - Rewritten component to finally fix the drawing problems under
            multiple OSs
  2.3a    - Added OnMouseMove, OnMouseDown, OnMouseUp event handlers
  2.4     - Updated the ssBounce mode to now work properly
          - Added CurrentOutput property
  2.4a    - Modified NewControlCode property to allow #0 as well
          - Fixed Access Violation when activating during FormCreate
          - Fixed problem arising from passing empty strings to ScrollText
          - Added documentation for each method
  2.5     - Checked for Delphi 5 compatibility
  2.5a    - Improved for Delphi 5 compatibility
  2.6     - On request: new flag Continuous
            Fixed bug in DoBounce, where the bouncing text left the control
            Fixed bug in DoBlink and DoBounce, where long text wasn't displayed
            Reformatted source code
  2.7     - Delphi 6 compatibility, additional inherited properties
  -----------------------------------------------------------------------------
  Property Description
           property Active
             Starts or stops the marquee

           property AutoCenter
             Automatically centers the text vertically if AutoSizeHeight is
             disabled

           property AutoSizeHeight
             Automatically adapts the height of the marquee to the height of
             the current text

           property Continuous
             Determines whether the text is scrolled continuously or if a new
             run starty only after the text has scrolled entirely through.

           property CurrentOutput
             Retrieve the text currently scrolling/blinking/bouncing

           property NewControlCode
             Defines the character that automatically replaces control codes

           property ScrollAmount
             Number of Pixels to jump (min. 1/max. 20)

           property ScrollDelay
             The bigger the slower (min. 1/max. MaxInt)

           property ScrollStyle
             Style of the marquee (Scrolling right to left, blink or bounce)

           property ScrollText
             Text to scroll

           property StripControlCodes
             If set, all characters < #32 are replaced by a defined character
  ---------------------------------------------------------------------------- }
unit Marquee;

{$DEFINE DELPHI5OR6}
{$IFNDEF VER130}
  {$IFNDEF VER140}
    {$UNDEF DELPHI5OR6}
  {$ENDIF}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  { TMarqueeStyle }
  TScrollStyle  = (ssScroll, ssBlink, ssBounce);

  { TScrollDelay }
  TScrollDelay  = 1..MaxInt;

  { TScrollAmount }
  TScrollAmount = 1..20;

  { TMarquee }
  TMarquee = class(TCustomControl)
  private
    { Property variables }
    FActive            : Boolean;
    FAutoCenter        : Boolean;
    FAutoSizeHeight    : Boolean;
    FBorderStyle       : TBorderStyle;
    FContinuous        : Boolean;
    FNewControlCode    : Char;
    FScrollAmount      : TScrollAmount;
    FScrollDelay       : TScrollDelay;
    FScrollStyle       : TScrollStyle;
    FScrollText        : String;
    FStripControlCodes : Boolean;
    FOnResize          : TNotifyEvent;

    { Internal Timer }
    FTimer             : TTimer;

    { Internal Bitmap to which we draw offscreen }
    FMemoryBitmap      : TBitmap;

    { Internal Flags }
    FProcessingTimer   : Boolean;
    FUpdatingHeight    : Boolean;

    { Internal variables for the scrolling routines }
    FScrollScreenPos   : LongInt;
    FScrollCurrentChar : Integer;
    FScrollPartString  : String;
    FBlinkState        : Boolean;
    FBlinkText         : String;
    FBounceDirection   : Integer;
    FBounceScreenPos   : Integer;
    FBouncePartString  : String;
    FBounceCurrentChar : Integer;

    { Property access methods }
    procedure   SetActive(Value: Boolean);
    procedure   SetAutoCenter(Value: Boolean);
    procedure   SetAutoSizeHeight(Value: Boolean);
    procedure   SetBorderStyle(Value: TBorderStyle);
    procedure   SetContinuous(Value: Boolean);
    procedure   SetNewControlCode(Value: Char);
    procedure   SetScrollAmount(Value: TScrollAmount);
    procedure   SetScrollDelay(Value: TScrollDelay);
    procedure   SetScrollStyle(Value: TScrollStyle);
    procedure   SetScrollText(Value: String);
    procedure   SetStripControlCodes(Value: Boolean);
    function    GetCurrentOutput: String;

    { Drawing routines }
    procedure   DoScroll(Restart: Boolean);
    procedure   DoBlink(Restart: Boolean);
    procedure   DoBounce(Restart: Boolean);

    { Utility methods }
    function    TextWidth(const AText: String): Integer;
    function    TextHeight(const AText: String): Integer;
    procedure   RecalcControlSize;
    procedure   RedrawControl;
    function    ReplaceControlCodes(const AText: String): String;

    { Message handlers }
    procedure   CMColorChanged(var Msg: TMessage); message CM_COLORCHANGED;
    procedure   CMCtl3DChanged(var Msg: TMessage); message CM_CTL3DCHANGED;
    procedure   CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure   CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure   CMVisibleChanged(var Msg: TMessage); message CM_VISIBLECHANGED;
    procedure   WMWindowPosChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
  protected
    { Marquee processing }
    procedure   MarqueeStep(Sender: TObject);
    procedure   UpdateMarquee(FullRestart, FullRepaint: Boolean);
  protected
    { Overridden component methods }
    procedure   CreateParams(var Params: TCreateParams); override;
    procedure   Paint; override;
  public
    { Public interface }
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  published
    { Properties }
    property    Active: Boolean read FActive write SetActive;
    {$IFDEF DELPHI5OR6}property Anchors;{$ENDIF}
    property    AutoCenter: Boolean read FAutoCenter write SetAutoCenter;
    property    AutoSizeHeight: Boolean read FAutoSizeHeight write SetAutoSizeHeight;
    property    BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle;
    {$IFDEF DELPHI5OR6}property Constraints;{$ENDIF}
    property    Continuous: Boolean read FContinuous write SetContinuous;
    property    Color;
    property    Ctl3D;
    property    CurrentOutput: String read GetCurrentOutput;
    property    DragCursor;
    {$IFDEF DELPHI5OR6}property DragKind;{$ENDIF}
    property    DragMode;
    property    Enabled;
    property    Font;
    property    Hint;
    property    NewControlCode: Char read FNewControlCode write SetNewControlCode;
    property    ParentColor;
    property    ParentCtl3D;
    property    ParentFont;
    property    ParentShowHint;
    property    ScrollAmount: TScrollAmount read FScrollAmount write SetScrollAmount;
    property    ScrollDelay: TScrollDelay read FScrollDelay write SetScrollDelay;
    property    ScrollStyle: TScrollStyle read FScrollStyle write SetScrollStyle;
    property    ScrollText: String read FScrollText write SetScrollText;
    property    ShowHint;
    property    StripControlCodes: Boolean read FStripControlCodes write SetStripControlCodes;

    property    OnClick;
    property    OnDblClick;
    property    OnMouseDown;
    property    OnMouseMove;
    property    OnMouseUp;
    property    OnResize: TNotifyEvent read FOnResize write FOnResize;
  end;

implementation

const
  BorderStyles        : Array[TBorderStyle] of DWORD = (0, WS_BORDER);
  SDefaultMarqueeText = '+++ Marquee 2.7 ';

////////////////////////////////////////////////////////////////////////////////

{
  In the component's constructor we only initialize the properties. Some
  inherited properties are also to be set. Also, we create the timer and the
  offline bitmap here. They are available as long as the object lives.
}
constructor TMarquee.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { Set inherited property defaults }
  ControlStyle       := [csCaptureMouse,csClickEvents,csOpaque,csDoubleClicks,
                         csReflector];
  ParentColor        := False;
  Color              := clWhite;
  Height             := 21;
  Width              := 217;

  { Set new properties }
  FActive            := False;
  FAutoCenter        := True;
  FAutoSizeHeight    := False;
  FBorderStyle       := bsSingle;
  FContinuous        := False;
  FNewControlCode    := #32;
  FScrollAmount      := 1;
  FScrollDelay       := 50;
  FScrollStyle       := ssScroll;
  FScrollText        := SDefaultMarqueeText;
  FStripControlCodes := True;
  FOnResize          := nil;

  { Initialize internal flags }
  FProcessingTimer   := False;
  FUpdatingHeight    := False;

  { Initialize internal timer }
  FTimer             := TTimer.Create(Self);
  FTimer.Enabled     := False;
  FTimer.Interval    := FScrollDelay;
  FTimer.OnTimer     := MarqueeStep;
  FTimer.Tag         := 0;

  { Initialize internal bitmap }
  FMemoryBitmap      := TBitmap.Create;

  { Initialize other variables }
  FScrollScreenPos   := 0;
  FScrollCurrentChar := 1;
  FScrollPartString  := '';
  FBlinkState        := False;
  FBlinkText         := '';
  FBounceDirection   := 0;
  FBounceScreenPos   := 0;
  FBouncePartString  := '';
end;

{
  In the component's destructor we only need to free the timer and the bitmap.
  To make sure that no unwanted timer events occur anymore, we disable it and
  remove the OnTimer-Eventhandler before freeing. This may be unnecessary, but
  who knows?
}
destructor TMarquee.Destroy;
begin
  { Destroy internal timer }
  FTimer.Enabled := False;
  FTimer.OnTimer := nil;
  FTimer.Free;

  { Destroy internal bitmap }
  FMemoryBitmap.Free;

  inherited Destroy;
end;

////////////////////////////////////////////////////////////////////////////////

{
  The CreateParams method is responsible for the borders. Depending on Ctl3D
  and BorderStyle, we create a framed component with sunken edge.
}
procedure TMarquee.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  { Set a 3D border depending on Ctl3D and border style }
  if NewStyleControls and Ctl3D and (BorderStyle = bsSingle) then
    Params.ExStyle := Params.ExStyle or WS_EX_CLIENTEDGE
  else
    Params.Style := Params.Style or BorderStyles[FBorderStyle];
end;

{
  The Paint method does the basic painting. Unless any scrolling is active, the
  method clears the background and draws the current ScrollText. Please note
  that this method does nothing when the timer is active!
}
procedure TMarquee.Paint;
var
  i: Integer;
  s: String;
  y: Integer;
begin
  inherited;

  { When inactive, just draw the (beginning of the) text to the canvas }
  if not FTimer.Enabled then
  begin
    Canvas.Brush.Color := Color;

    { Find a part of the text that is long enough to be fully displayed. }
    i := 1;
    s := '';

    while (TextWidth(s) < ClientWidth) and (i <= Length(FScrollText)) do
    begin
      s := s+FScrollText[i];
      Inc(i);
    end;

    { Calc the vertically centered position }
    y := 0;
    if FAutoCenter then
      y := (ClientHeight-TextHeight(s)) div 2;

    { And draw the text }
    Canvas.FillRect(ClientRect);
    Canvas.TextOut(0,y,s);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

{
  The MarqueeStep method is important: it responds to the timer events. When a
  timer event occurs, the flag FProcessingTimer is set to make sure that one
  drawing process will be terminated successfully before initiating another.
  The Tag property of the timer indicates whether the marquee is to be
  restarted. Is is set in the Activate property handler. When restarting
  (Tag = 0), UpdateMarquee is called with all redraw flags to on, in any other
  case, "normal" drawing is done (i.e. the next step).
}
procedure TMarquee.MarqueeStep(Sender: TObject);
begin
  if not FProcessingTimer then
  begin
    FProcessingTimer := True;
    try
      if FTimer.Tag = 0 then
      begin
        UpdateMarquee(True,True);
        FTimer.Tag := 1;
      end else
        UpdateMarquee(False,False);
    finally
      FProcessingTimer := False;
    end;
  end;
end;

{
  UpdateMarquee prepares the bitmap. If a full repaint is requested, the size,
  color, font etc. of the bitmap are set and everything is cleared. Then,
  depending on the ScrollStyle, the drawing methods are called. Here the
  FullRestart parameter is important: if True, the draing methods will restart
  the marquee all over.
}
procedure TMarquee.UpdateMarquee(FullRestart,FullRepaint: Boolean);
begin
  { On full repaint, resize and clear the bitmap }
  if FullRepaint then
  begin
    Canvas.Brush.Color               := Color;
    Canvas.FillRect(ClientRect);

    FMemoryBitmap.Height             := TextHeight(FScrollText);
    FMemoryBitmap.Width              := ClientWidth;
    FMemoryBitmap.Canvas.Brush.Color := Color;
    FMemoryBitmap.Canvas.FillRect(ClientRect);
    SetBkMode(FMemoryBitmap.Canvas.Handle,TRANSPARENT);
  end;

  { Paint the marquee depending on the scroll style }
  case ScrollStyle of
    ssScroll: DoScroll(FullRestart);
    ssBlink : DoBlink(FullRestart);
    ssBounce: DoBounce(FullRestart);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

{
  CMColorChanged responds to the CM_COLORCHANGED message sent by Delphi when
  the Color property has changed. What we do here is to repaint the area
  "behind" the bitmap, so we don't get nasty stripes above and below.
}
procedure TMarquee.CMColorChanged(var Msg: TMessage);
begin
  inherited;

  { Redraw the background if the control is active }
  if not (csLoading in ComponentState) and Assigned(FTimer) and Assigned(Canvas) then
  begin
    if FTimer.Enabled then
    begin
      Canvas.Brush.Color := Color;
      Canvas.FillRect(ClientRect);
    end;
  end;
end;

{
  CMCtl3DChanged responds to the CM_CTL3DCHANGED message sent by Delphi when
  the Ctl3D property has changed. We recreate the window only if necessary to
  avoid too much action if there is no border at all.
}
procedure TMarquee.CMCtl3DChanged(var Msg: TMessage);
begin
  { Do nothing when destroying the component }
  if (csDestroying in ComponentState) then
    exit;

  { Recreate window if border is to be 3D }
  if NewStyleControls and (FBorderStyle = bsSingle) then
    RecreateWnd;

  inherited;
end;

{
  CMEnabledChanged responds to the CM_ENABLEDCHANGED message sent by Delphi
  when the Enabled property has changed. The timer will be suspended here if
  the marquee is active, but the control is not (when the control is inactive,
  we don't want to do any scolling, do we?).
}
procedure TMarquee.CMEnabledChanged(var Msg: TMessage);
begin
  { Do nothing when destroying the component }
  if (csDestroying in ComponentState) then
    exit;

  { Activate/Deactivate the timer depending on the Enabled property }
  if not (csLoading in ComponentState) then
    FTimer.Enabled := Active and Enabled;

  inherited;
end;

{
  CMFontChanged responds to ... guess what? Well, what we do here is to assign
  the new font to the control's and the offline bitmap's canvas. After that, we
  recalc the control size in case the AutoSizeHeight property is True, and then
  we redraw to display the changes.
}
procedure TMarquee.CMFontChanged(var Msg: TMessage);
begin
  { Do nothing when destroying the component }
  if (csDestroying in ComponentState) then
    exit;

  { Assign the new font to the canvas and recalc the height of the control }
  Canvas.Font.Assign(Font);
  FMemoryBitmap.Canvas.Font.Assign(Font);
  if FAutoSizeHeight then
    RecalcControlSize;
  RedrawControl;

  inherited;
end;

{
  CMVisibleChanged does about the same as the CMEnabledChanged method, but for
  the visible property.
}
procedure TMarquee.CMVisibleChanged(var Msg: TMessage);
begin
  inherited;

  { Exit if destroying the component }
  if (csDestroying in ComponentState) then
    exit;

  { Activate/Deactivate the timer if the control is visible/invisible }
  if Visible then
    FTimer.Enabled := Active and Enabled
  else
    FTimer.Enabled := False;
end;

{
  WMWindowPosChanged responds to a Windows message for a change! It is used to
  make sure that the component does not get larger than the automatically
  assigned height (if AutoSizeHeight property is True). Please don't remove the
  FUpdatingHeight flag, because otherwise you get a never ending recursion of
  resize messages!
}
procedure TMarquee.WMWindowPosChanged(var Msg: TWMWindowPosChanged);
begin
  inherited;

  { Go on if not currently updating or destroying the component }
  if not FUpdatingHeight and not (csDestroying in ComponentState) then
  begin
    FUpdatingHeight := True;
    try
      if FAutoSizeHeight then
        RecalcControlSize;

      RedrawControl;

      if not (csDestroying in ComponentState) and Assigned(FOnResize) then
        FOnResize(Self);
    finally
      FUpdatingHeight := False;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

{
  The TextWidth method finds out the width of the given string in the device
  context of the Canvas. It's only a little helper...
}
function TMarquee.TextWidth(const AText: String): Integer;
var
  ASize: TSize;
begin
  { Get the width of the given string for the specified DC }
  GetTextExtentPoint32(Canvas.Handle,PChar(AText),Length(AText),ASize);
  Result := ASize.cx;
end;

{
  The TextHeight method finds out the height of the given string in the device
  context of the Canvas. It's only a little helper...
}
function TMarquee.TextHeight(const AText: String): Integer;
var
  ASize: TSize;
begin
  { Get the width of the given string for the specified DC }
  GetTextExtentPoint32(Canvas.Handle,PChar(AText),Length(AText),ASize);
  Result := ASize.cy;
end;

{
  The ReplaceControlCodes method is responsible for stripping control codes
  from the given string. If the FNewControlCode property contains #0, we just
  continue with the next character!
}
function TMarquee.ReplaceControlCodes(const AText: String): String;
var
  i: Integer;
begin
  Result := '';

  for i := 1 to Length(AText) do
  begin
    if Ord(AText[i]) < 32 then
    begin
      if FNewControlCode <> #0 then
        Result := Result+FNewControlCode
      else
        Result := Result+#32;
    end
    else
      Result := Result+AText[i];
  end;
end;

{
  RecalcControlSize resizes the height of the control depending on the height
  of ScrollText. If there is no text to be scrolled, we use 'X' to calc the
  height, so we don't get a "one pixel" control.
}
procedure TMarquee.RecalcControlSize;
var
  h: Integer;
begin
  { Calc the control's height  }
  if FScrollText = '' then
    h := TextHeight('Xg')+2
  else
    h := TextHeight(FScrollText)+2;

  ClientHeight := h;
end;

{
  RedrawControl redraws the control depending on the state of the timer. When
  the control is active, the current DrawXXXXX method is called, otherwise Paint.
}
procedure TMarquee.RedrawControl;
begin
  { Redraw depending on the current state }
  if FTimer.Enabled then
    UpdateMarquee(False,True)
  else
    Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

{
  OK, now for the harder part. The DoScroll method is responsible for doing the
  right to left scrolling of the text, when the ScrollStyle is set to ssScroll.
  Actually it is not too difficult to understand what it does. When initializing,
  it clears the canvas and resets some internal variables to defaults. Then it
  decreases the current position of the text within the offline bitmap. If there
  is room for a new character, it adds this character to a partial string, draws
  it and paints the bitmap to the Canvas. With the next timer event, it starts
  all over. As soon as the left position of the text within the offline bitmap
  is much smaller than 0, it deletes enough characters from the beginning of the
  partial string to just keep the position < 0. This way, we can scroll very
  long text, as only the visible part of the string actually needs to be drawn.
}
procedure TMarquee.DoScroll(Restart: Boolean);
var
  ARect : TRect;
  OutY  : Integer;
begin
  { Set colors }
  Canvas.Brush.Color := Color;
  FMemoryBitmap.Canvas.Brush.Color := Color;

  { When restarting, set default values }
  if Restart then
  begin
    Canvas.FillRect(ClientRect);
    FScrollScreenPos   := ClientWidth;
    FScrollCurrentChar := 1;
    FScrollPartString  := '';
  end;

  try
    { Clear the bitmap }
    ARect := Rect(0,0,FMemoryBitmap.Width,FMemoryBitmap.Height);
    FMemoryBitmap.Canvas.FillRect(ARect);

    { Continue only if there is text to scroll }
    if Length(FScrollText) > 0 then
    begin
      { Decrease the current output position }
      Dec(FScrollScreenPos,FScrollAmount);

      { If there is text in the PartString and the output position is < 0
        remove just enough characters at the beginning of the PartString to
        keep the output position <= 0. }
      if (FScrollScreenPos < 0) and (Length(FScrollPartString) > 0) then
      begin
        while (Length(FScrollPartString) > 0) and
              (FScrollScreenPos+TextWidth(FScrollPartString[1]) <= 0) do
        begin
          Inc(FScrollScreenPos,TextWidth(FScrollPartString[1]));
          Delete(FScrollPartString,1,1);
        end;
      end;

      { If we are scrolling continuously, or if we haven't filled in the entire
        text yet, we add enough characters at the end of the string to just
        exceed the width of the control }
      if FContinuous or (FScrollCurrentChar <= Length(FScrollText)) then
      begin
        while FScrollScreenPos+TextWidth(FScrollPartString) < ClientWidth do
        begin
          FScrollPartString := FScrollPartString+FScrollText[FScrollCurrentChar];
          Inc(FScrollCurrentChar);

          if FScrollCurrentChar > Length(FScrollText) then
          begin
            if FContinuous then
              FScrollCurrentChar := 1
            else
              break;
          end;
        end;
      end;

      { If we're not scrolling continuously and all the text has been filled in,
        we wait until all the text has moved through the control and then we
        restart the marquee. }
      if not FContinuous and (FScrollCurrentChar > Length(FScrollText)) then
        if Length(FScrollPartString) = 0 then
          UpdateMarquee(True,False);

      { Output the Text to the memory bitmap }
      TextOut(FMemoryBitmap.Canvas.Handle,FScrollScreenPos,0,PChar(FScrollPartString),Length(FScrollPartString));

      { Now draw the memory bitmap }
      OutY := 0;
      if FAutoCenter then
        OutY := (ClientHeight-FMemoryBitmap.Height) div 2;
      BitBlt(Canvas.Handle,0,OutY,ClientWidth,FMemoryBitmap.Height,FMemoryBitmap.Canvas.Handle,0,0,SRCCOPY);
    end;
  except
    asm
      nop;
    end;
  end;
end;

{
  DoBlink is more straight forward than DoScroll. Again, the initialization
  takes part when the Restart parameter is True. Then it clears the bitmap and
  finds the number of characters that can be displayed in the control.
  Depending on the state, it draws, or draws not, the text -> it blinks the text.
}
procedure TMarquee.DoBlink(Restart: Boolean);
var
  ARect       : TRect;
  xPos,OutY   : Integer;
begin
  { Set colors }
  Canvas.Brush.Color := Color;
  FMemoryBitmap.Canvas.Brush.Color := Color;

  { When restarting, initialize all }
  if Restart then
  begin
    Canvas.FillRect(ClientRect);
    FBlinkState := False;
    FBlinkText := FScrollText;
    while (TextWidth(FBlinkText) > ClientWidth) or (TextWidth(FBlinkText) < 0) do
      Delete(FBlinkText,Length(FBlinkText),1);
  end;

  try
    { Clear the bitmap }
    ARect := Rect(0,0,FMemoryBitmap.Width,FMemoryBitmap.Height);
    FMemoryBitmap.Canvas.FillRect(ARect);


    { Exit if there is no text to scroll }
    if Length(FBlinkText) > 0 then
    begin
      { Calc a horizontally centered position }
      XPos := (ClientWidth-TextWidth(FBlinkText)) div 2;

      { Output the Text }
      FBlinkState := not FBlinkState;
      if FBlinkState then
        TextOut(FMemoryBitmap.Canvas.Handle,XPos,0,PChar(FBlinkText),Length(FBlinkText));

      { Now draw the memory bitmap }
      OutY := 0;
      if FAutoCenter then
        OutY := (ClientHeight-FMemoryBitmap.Height) div 2;
      BitBlt(Canvas.Handle,0,OutY,ClientWidth,FMemoryBitmap.Height,FMemoryBitmap.Canvas.Handle,0,0,SRCCOPY);
    end;
  except
    asm
      nop;
    end;
  end;
end;

{
  The DoBounce method is the most complicated scrolling method. Again,
  initialization. After that it decides, whether the entire text fits the
  control. In that case, it does a simple bounce algorithm (scroll right to
  left, when touching the left border, it toggles a flag and does the same
  backwards until it touches the right border and so on). If the text does not
  fit the control entirely, it gets more complicated. If is a lot like DoScroll:
  it decreases the current output position. Then it removes the leading
  characters which don't fit the control anymore. Then it adds characters as
  long as there are any left. Then it waits until the text was entirely
  displayed. Then it toggles the flag and does the entire algorithm backwards
  (i.e. removes from the right, adds to the left until no more is to be added,
  waits, toggles).
}
procedure TMarquee.DoBounce(Restart: Boolean);
var
  ARect  : TRect;
  OutY   : Integer;
begin
  { Set colors }
  Canvas.Brush.Color := Color;
  FMemoryBitmap.Canvas.Brush.Color := Color;

  { When restarting, set default values }
  if Restart then
  begin
    Canvas.FillRect(ClientRect);
    FBounceScreenPos   := ClientWidth;
    FBounceCurrentChar := 1;
    FBouncePartString  := '';
    FBounceDirection   := 1;
  end;

  try
    { Clear the bitmap }
    ARect := Rect(0,0,FMemoryBitmap.Width,FMemoryBitmap.Height);
    FMemoryBitmap.Canvas.FillRect(ARect);

    { Exit if there is no text to scroll }
    if Length(FScrollText) > 0 then
    begin
      { Do a simple bounce if the entire text is shorter than the control is wide }
      if (TextWidth(FScrollText) > 0) and (TextWidth(FScrollText) < ClientWidth) then
      begin
        FBouncePartString := FScrollText;
        if FBounceDirection = 1 then
        begin
          Dec(FBounceScreenPos,FScrollAmount);
          if FBounceScreenPos <= 0 then
          begin
            FBounceScreenPos := 0;
            FBounceDirection := -1;
          end;
        end
        else if FBounceDirection = -1 then
        begin
          Inc(FBounceScreenPos,FScrollAmount);
          if FBounceScreenPos+TextWidth(FBouncePartString) >= ClientWidth then
          begin
            FBounceScreenPos := ClientWidth-TextWidth(FBouncePartString);
            FBounceDirection := 1;
          end;
        end;
      end

      { Do the more complicated bounce when the text is longer than the control is wide }
      else
      begin
        if FBounceDirection = 1 then
        begin
          Dec(FBounceScreenPos,FScrollAmount);

          { Remove leading characters if they are out of rect }
          if FBounceScreenPos < 0 then
            while (FBounceScreenPos+TextWidth(FBouncePartString[1]) < 0) do
            begin
              Inc(FBounceScreenPos,TextWidth(FBouncePartString[1]));
              Delete(FBouncePartString,1,1);
            end;

          { Add trailing characters if they should be visible }
          while FBounceScreenPos+TextWidth(FBouncePartString) < ClientWidth do
          begin
            if (FBounceCurrentChar > Length(FScrollText)) then
            begin
              if (FBounceScreenPos+TextWidth(FBouncePartString) <= ClientWidth) then
              begin
                FBounceDirection   := -1;
                FBounceCurrentChar := Length(FScrollText)-Length(FBouncePartString);
                break;
              end;
            end
            else
            begin
              FBouncePartString := FBouncePartString+FScrollText[FBounceCurrentChar];
              Inc(FBounceCurrentChar);
            end;
          end;
        end
        else if FBounceDirection = -1 then
        begin
          Inc(FBounceScreenPos,FScrollAmount);

          { Remove trailing characters if they are out of rect }
          while FBounceScreenPos+TextWidth(FBouncePartString)-TextWidth(FBouncePartString[Length(FBouncePartString)]) > ClientWidth do
            Delete(FBouncePartString,Length(FBouncePartString),1);

          { Insert leading characters if they should be visible }
          while FBounceScreenPos > 0 do
          begin
            if FBounceCurrentChar < 1 then
            begin
              if (FBounceScreenPos >= 0) then
              begin
                FBounceDirection    := 1;
                FBounceCurrentChar  := Length(FBouncePartString)+1;
                break;
              end;
            end
            else
            begin
              FBouncePartString := FScrollText[FBounceCurrentChar]+FBouncePartString;
              Dec(FBounceScreenPos,TextWidth(FScrollText[FBounceCurrentChar]));
              Dec(FBounceCurrentChar);
            end;
          end;
        end;
      end;

      { Output the Text to the memory bitmap }
      TextOut(FMemoryBitmap.Canvas.Handle,FBounceScreenPos,0,PChar(FBouncePartString),Length(FBouncePartString));

      { Now draw the memory bitmap }
      OutY := 0;
      if FAutoCenter then
        OutY := (ClientHeight-FMemoryBitmap.Height) div 2;
      BitBlt(Canvas.Handle,0,OutY,ClientWidth,FMemoryBitmap.Height,FMemoryBitmap.Canvas.Handle,0,0,SRCCOPY);
    end;
  except
    asm
      nop;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

{
  SetActive sets the Active property, but only enables the timer when the
  control is visible and enabled.
}
procedure TMarquee.SetActive(Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    if not FActive then
      FTimer.Tag := 0;

    if FActive and Enabled and (Length(FScrollText) > 0) then
      FTimer.Enabled := True
    else
    begin
      FTimer.Enabled := False;
      RedrawControl;
    end;
  end;
end;

{
  SetAutoCenter sets the AutoCenter property and redraws the control.
}
procedure TMarquee.SetAutoCenter(Value: Boolean);
begin
  if FAutoCenter <> Value then
  begin
    FAutoCenter := Value;
    RedrawControl;
  end;
end;

{
  SetAutoSizeHeight sets the AutoSizeHeight property. If it is True, the new
  size for the control is calc'ed and set.
}
procedure TMarquee.SetAutoSizeHeight(Value: Boolean);
begin
  if FAutoSizeHeight <> Value then
  begin
    FAutoSizeHeight := Value;
    RecalcControlSize;
  end;
end;

{
  SetBorderStyle sets the BorderStyle property and recreates the control to
  display the new border.
}
procedure TMarquee.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

{
  SetContinuous set the Continuous property to determine whether the text
  scrolls continuously or not.
}
procedure TMarquee.SetContinuous(Value: Boolean);
begin
  if FContinuous <> Value then
  begin
    FContinuous := Value;
    UpdateMarquee(True,True);
  end;
end;

{
  SetNewControlCode sets the NewControlCode property. It makes sure that only
  values > #32 or = #0 can be used to replace control codes. Otherwise, the
  entire thing wouldn't make sense...
}
procedure TMarquee.SetNewControlCode(Value: Char);
begin
  if FNewControlCode <> Value then
  begin
    if (Ord(Value) < 32) and (Value <> '') then
    begin
      MessageDlg('You cannot enter characters which are control codes themselves!',mtError,[mbOK],0);
      exit;
    end;
    FNewControlCode := Value;
  end;
end;

{
  SetScrollAmount sets the ScrollAmount property.
}
procedure TMarquee.SetScrollAmount(Value: TScrollAmount);
begin
  if FScrollAmount <> Value then
    FScrollAmount := Value;
end;

{
  SetScrollDelay sets the ScrollDelay property and at the same time adjusts the
  timer interval.
}
procedure TMarquee.SetScrollDelay(Value: TScrollDelay);
begin
  if FScrollDelay <> Value then
  begin
    FScrollDelay := Value;
    FTimer.Interval := Value;
  end;
end;

{
  SetScrollStyle sets the ScrollStyle property and restarts the marquee if
  needed.
}
procedure TMarquee.SetScrollStyle(Value: TScrollStyle);
begin
  if FScrollStyle <> Value then
  begin
    FScrollStyle := Value;

    if FTimer.Enabled then
    begin
      FTimer.Enabled := False;
      UpdateMarquee(True,False);
      FTimer.Enabled := True;
    end;
  end;
end;

{
  SetScrollText sets the ScrollText property. It also reinitializes the marquee
  when the text is changed.
}
procedure TMarquee.SetScrollText(Value: String);
var
  OldActive: Boolean;
begin
  if FScrollText <> Value then
  begin
    OldActive := FActive;
    SetActive(False);

    FScrollText := Value;
    if FStripControlCodes then
      FScrollText := ReplaceControlCodes(FScrollText);

    if FAutoSizeHeight then
      RecalcControlSize;

    SetActive(OldActive);
  end;
end;

{
  SetStripControlCodes sets the StripControlCodes property and automatically
  replaces control codes when enabled.
}
procedure TMarquee.SetStripControlCodes(Value: Boolean);
begin
  if FStripControlCodes <> Value then
  begin
    FStripControlCodes := Value;

    if FStripControlCodes then
      FScrollText := ReplaceControlCodes(FScrollText);
      
    RedrawControl;
  end;
end;

{
  GetCurrentOutput retrieves the momentarily visible partial string depending
  on the ScrollStyle. DoubleBuffered
}
function TMarquee.GetCurrentOutput: String;
begin
  Result := '';
  if FTimer.Enabled then
  begin
    case FScrollStyle of
      ssScroll: Result := FScrollPartString;
      ssBlink : Result := FBlinkText;
      ssBounce: Result := FBouncePartString;
    end;
  end;
end;

end.
