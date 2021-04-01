#INCLUDE "TOTVS.ch"
#INCLUDE "TOPCONN.ch"

/*/{Protheus.doc} MYDFCB
Dialog full com bot�es superiores de Cancelar e Confirmar.
Com tecla de atalho para filtro.
Com bot�es no aba "Outras A��es".
Com op��o para marcar uma ou mais linhas.
@type function
@version 12.1.27
@author Jorge Alberto
@since 30/03/2021
/*/
User Function MYDFCB()

    Local oSize     
    Local aBotoes   := {;
                        { "", {|| MsgInfo("Bot�o 1", "Informa��o") }, "Bot�o 1", "Bot�o 1" },;
                        { "", {|| MsgAlert("Bot�o 2", "Alerta") }, "Bot�o 2", "Bot�o 2" };
                        }
    Local nOpcA     := 0

    Private nQtdLinhas := 100
    Private oBrowse
    Private aDados  := {}

    SetKey( VK_F12, {|| IIF( Parametros(), MsgRun( "Carregando dados", "Aguarde...", {|| CarregaDados() } ), NIL ) } )

    oSize := FwDefSize():New( .T. )
	oSize:AddObject( "GERAL", 100, 100, .T., .T. )
	oSize:Process()
    
    oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T./*lPixel*/,,,,.T./*lTransparent*/ )

    oBrowse := TWBrowse():New(  oSize:GetDimension("GERAL","LININI"),;
                                oSize:GetDimension("GERAL","COLINI"),;
                                oSize:GetDimension("GERAL","XSIZE"),;
                                oSize:GetDimension("GERAL","YSIZE"),,,,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

    CarregaDados()

    oDlg:Activate(,,,,EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End() },{||oDlg:End() },,aBotoes))

    If nOpcA == 1
        Processa()
    EndIf

    SetKey( VK_F12 , NIL )

Return

Static Function Parametros()

    Local aParamBox := {}
    Local aRet      := {}
    Local nQtde     := 100

    aAdd(aParamBox,{ 1, "Qtde de Linhas", nQtde,"","","","",80,.T.})

    If !ParamBox(aParamBox,"Par�metros",@aRet,,,,,,,,.F.,.T. )
        Return(.F.)
    EndIf

    nQtdLinhas := aRet[1]

Return(.T.)

Static Function CarregaDados()

    Local oOk   := LoadBitMap(GetResources(), "LBOK")
	Local oNo   := LoadBitMap(GetResources(), "LBNO")
    Local nCont := 1

    aDados := {}

    For nCont := 1 To nQtdLinhas

        AADD( aDados, { .F.,;
                        StrZero( nCont, 6 ),;
                        "Cliente " + StrZero( nCont, 6 ),;
                        "Produto " + StrZero( nCont, 6 ),;
                        DtoC( dDataBase + nCont );
                         } )

    Next

    oBrowse:aHeaders  := {"","Sequencial","Cliente","Produto","Data" }
    oBrowse:setArray( aDados )
    oBrowse:bLine := {||{If(aDados[oBrowse:nAt,01],oOK,oNO),;
								aDados[oBrowse:nAt,02],;
								aDados[oBrowse:nAt,03],;
								aDados[oBrowse:nAt,04],;
								aDados[oBrowse:nAt,05] } }
    oBrowse:bLDblClick := {|| SelLine( oBrowse:nAt )}
    oBrowse:nAt := 1

Return

Static Function SelLine( nLin )

    aDados[ nLin, 1 ] := !aDados[ nLin, 1 ]
    MsgInfo( "Linha " + cValToChar( nLin ) )

Return

Static Function Processa()

    MsgInfo( "Feitooooo !" )
    
Return
