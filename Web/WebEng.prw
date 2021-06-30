#INCLUDE "TOTVS.CH"
 
/*/{Protheus.doc} WebEng
Exemplo de abertura de página WEB ou estática com TWebEngine()
@type function
@version 12.1.25
@author Jorge Alberto
@since 30/06/2021
/*/
User Function WebEng()

    Local aParamBox := {}
    Local aRet := {}
    
    aAdd( aParamBox,{3,"Tipo de página", 1,{"WEB","HTML Local"},50,"",.T.} )

    If !ParamBox( aParamBox, "exemplo", @aRet )
        Return
    EndIf
    
    If aRet[1] == 1
        WEB()
    Else
        HTML()
    EndIf
Return


/*/{Protheus.doc} WEB
Página HTML da Web
@type function
@version 12.1.25
@author Jorge Alberto
@since 30/06/2021
/*/
Static Function WEB()

    Local aSize       := {}
    Local aObjects    := {} 
    Local aInfo       := {}
    Local aPosObj     := {}
    Local nPort       := 0
    Local cUrl        := "https://www.totvs.com/"
    Local oModal
    Local oWebEngine 

    Private oWebChannel := TWebChannel():New()

    aSize := MsAdvSize()
    AAdd( aObjects, { 100, 100, .T., .T. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
    aPosObj := MsObjSize( aInfo, aObjects,.T.)
    
    oModal := MSDialog():New(aSize[7],0,aSize[6],aSize[5], "Página Web",,,,,,,,,.T./*lPixel*/)
    
        nPort := oWebChannel::connect()
        oWebEngine := TWebEngine():New(oModal, 0, 0, 100, 100,/*cUrl*/, nPort)
        
        oWebEngine:bLoadFinished := {|self,url| conout("Fim do carregamento da pagina " + url) }
        oWebEngine:navigate(cUrl)
        
        oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

    oModal:Activate()
 
Return


/*/{Protheus.doc} HTML
Página HTML local
@type function
@version 12.1.25
@author Jorge Alberto
@since 30/06/2021
/*/
Static Function HTML()

    Local aSize       := {}
    Local aObjects    := {}
    Local aInfo       := {}
    Local aPosObj     := {}
    Local nPort       := 0
    Local cHtml       := "\web\AppletWeb.html"
    Local oModal
    Local oWebEngine 

    Private oWebChannel := TWebChannel():New()
    
    aSize := MsAdvSize()
    AAdd( aObjects, { 100, 100, .T., .T. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
    aPosObj := MsObjSize( aInfo, aObjects,.T.)
    
    oModal := MSDialog():New(aSize[7],0,aSize[6],aSize[5], "Página Local",,,,,,,,,.T./*lPixel*/)
    
        nPort := oWebChannel::connect()
        oWebEngine := TWebEngine():New(oModal, 0, 0, 100, 100,/*cUrl*/, nPort)
      
        oWebEngine:SetHtml( MemoRead( cHtml ) )
        
        oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

    oModal:Activate()
 
Return
