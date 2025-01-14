Class KFGUI_Button extends KFGUI_Clickable;

var() Canvas.CanvasIcon OverlayTexture;
var() string ButtonText,GamepadButtonName;
var() color TextColor;
var() Canvas.FontRenderInfo TextFontInfo;
var() byte FontScale,ExtravDir;
var bool bIsHighlighted;

function DrawMenu()
{
    Owner.CurrentStyle.RenderButton(Self);
}

function bool GetUsingGamepad()
{
    return Owner.bUsingGamepad && GamepadButtonName != "";
}

function HandleMouseClick( bool bRight )
{
    if( bRight )
        OnClickRight(Self);
    else OnClickLeft(Self);
}

Delegate OnClickLeft( KFGUI_Button Sender );
Delegate OnClickRight( KFGUI_Button Sender );

defaultproperties
{
    ButtonText="Button!"
    TextColor=(R=0,G=0,B=0,A=255)
    TextFontInfo=(bClipText=true,bEnableShadow=true)
    FontScale=1
}