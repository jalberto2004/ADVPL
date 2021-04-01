#INCLUDE "TOTVS.ch"
#INCLUDE "TOPCONN.ch"

/*/{Protheus.doc} MYDFSB
Dialog full sem botões superiores de Cancelar e Confirmar.
Com espaço para botões na parte inferior da tela.
Com tecla de atalho e botão para filtro.
@type function
@version 12.1.27
@author Jorge Alberto
@since 01/04/2021
/*/
User Function MYDFSB()

    Local oSize
    Local nOpc := 0

    Private nQtdLinhas := 100
    Private oBrowse
    Private aDados  := {}

    SetKey( VK_F12, {|| IIF( Parametros(), MsgRun( "Carregando dados", "Aguarde...", {|| CarregaDados() } ), NIL ) } )

    oSize := FwDefSize():New( .F. )
    oSize:aMargins := { 3, 3, 3, 3 }
    // Configuração com o Grid na parte Superior e os botões na parte inferior
	oSize:AddObject( "PRINCIPAL", 100, 90, .T., .T. )
	oSize:AddObject( "OPCOES", 100, 10, .T., .T. )
    // Configuração com o Grid na parte Inferior e os botões na parte superior
	// oSize:AddObject( "OPCOES", 100, 10, .T., .T. )
	// oSize:AddObject( "PRINCIPAL", 100, 90, .T., .T. )
    oSize:lProp := .T.
	oSize:Process()
    
    oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T./*lPixel*/,,,,.T./*lTransparent*/ )

    TButton():New(  oSize:GetDimension("OPCOES","LININI"),;
                    oSize:GetDimension("OPCOES","COLINI"),;
                    "Sair",oDlg,{|| oDlg:End() },;
                    035,012,,,,.T.,,"",,,,.F. )
    
    TButton():New(  oSize:GetDimension("OPCOES","LININI"),;
                    oSize:GetDimension("OPCOES","COLINI") + 75,;
                    "Parâmetros",oDlg,{|u| IIF( Parametros(), MsgRun( "Carregando dados", "Aguarde...", {|| CarregaDados() } ), NIL ) },;
                    035,012,,,,.T.,,"",,,,.F. )
    
    oBrowse := TWBrowse():New(  oSize:GetDimension("PRINCIPAL","LININI"),;
                                oSize:GetDimension("PRINCIPAL","COLINI"),;
                                oSize:GetDimension("PRINCIPAL","XSIZE"),;
                                oSize:GetDimension("PRINCIPAL","YSIZE"),,,,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

    CarregaDados()

    oDlg:Activate()

    If nOpc == 1
        Processa()
    EndIf

    SetKey( VK_F12 , NIL )

Return

Static Function Parametros()

    Local aParamBox := {}
    Local aRet      := {}
    Local nQtde     := 100

    aAdd(aParamBox,{ 1, "Qtde de Linhas", nQtde,"","","","",80,.T.})

    If !ParamBox(aParamBox,"Parâmetros",@aRet,,,,,,,,.F.,.T. )
        Return(.F.)
    EndIf

    nQtdLinhas := aRet[1]

Return(.T.)

Static Function CarregaDados()

    Local nCont := 1

    aDados := {}

    For nCont := 1 To nQtdLinhas

        AADD( aDados, { StrZero( nCont, 6 ),;
                        "Cliente " + StrZero( nCont, 6 ),;
                        "Produto " + StrZero( nCont, 6 ),;
                        DtoC( dDataBase + nCont );
                        } )

    Next

    oBrowse:aHeaders  := {"Sequencial","Cliente","Produto","Data" }
    oBrowse:setArray( aDados )
    oBrowse:bLine := {||{ aDados[oBrowse:nAt,01],;
                        aDados[oBrowse:nAt,02],;
                        aDados[oBrowse:nAt,03],;
                        aDados[oBrowse:nAt,04] } }
    oBrowse:bLDblClick := {|| DblClique( oBrowse:nAt )}
    oBrowse:nAt := 1

Return


Static Function DblClique( nLin )

    MsgInfo( "Linha " + cValToChar( nLin ) )

Return


Static Function Processa()

    MsgInfo( "Feitooooo !" )
    
Return
