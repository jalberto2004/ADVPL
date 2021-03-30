#INCLUDE "TOTVS.ch"
#INCLUDE "TOPCONN.ch"

/*/{Protheus.doc} MYDFCB
Dialog full com botões superiores de Cancelar e Confirmar.
Com tecla de atalho para filtro.
Com botões no aba "Outras Ações".
Com opção para marcar uma ou mais linhas.
@type function
@version 12.1.27
@author Jorge Alberto
@since 30/03/2021
/*/
User Function MYDFCB()

    Local oSize     
    Local aBotoes   := {;
                        { "", {|| MsgInfo("Botão 1", "Informação") }, "Botão 1", "Botão 1" },;
                        { "", {|| MsgAlert("Botão 2", "Alerta") }, "Botão 2", "Botão 2" };
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

    If !ParamBox(aParamBox,"Parâmetros",@aRet,,,,,,,,.F.,.T. )
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
                        "Data " + DtoC( dDataBase + nCont );
                         } )

    Next

    oBrowse:aHeaders  := {"","Cliente","Produto","Data" }
    oBrowse:setArray( aDados )
    oBrowse:bLine := {||{If(aDados[oBrowse:nAt,01],oOK,oNO),;
								aDados[oBrowse:nAt,02],;
								aDados[oBrowse:nAt,03],;
								aDados[oBrowse:nAt,04] } }
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
