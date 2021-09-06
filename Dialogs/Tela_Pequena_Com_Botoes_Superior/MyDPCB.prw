#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} MyDPCB
Dialog com uso do MsNewGetDados pequeno.
@type function
@version 12.1.25
@author Jorge Alberto
@since 06/09/2021
/*/
User Function MyDPCB()

    Local oDlg
    Local lConf     := .F.
    Local cSuperDel := ""
    Local cDelOk    := "AllwaysFalse"
    Local cFieldOk  := "AllwaysTrue"
    Local aAltera   := {'Recurso'}
    Local aBotoes   := {}
    Local aOperac   := {}
    Local aMyHeader := {}

    Private oBrwOper

    aOperac := CarregaDados()
    
    Aadd(aMyHeader, {'Operação' , 'Operac' , '', 02, 00, '', , 'C' })
    Aadd(aMyHeader, {'Recurso'  , 'Recurso', '', 06, 00, 'ExistCPO("SH1")', , 'C', 'SH1' })
    Aadd(aMyHeader, {'Descrição', 'DescRec', '', 30, 00, '', , 'C' })

    oDlg := MSDialog():New(092,232,366,694,"Exemplo de MsNewGetDados de tamanho pequeno",,,,,CLR_BLACK,CLR_WHITE,,,.T./*lPixel*/,,,,.F./*lTransparent*/ )
        oBrwOper := MsNewGetDados():New(036/*nTop*/,005/*nLeft*/,125/*nBottom*/,220/*nRight*/, GD_UPDATE,'U_DPCBLi','U_DPCBOK','',aAltera,0,999,cFieldOk,cSuperDel,cDelOk,oDlg,aMyHeader,aOperac )
    oDlg:Activate(,,,,EnchoiceBar(oDlg,{||lConf:=.T.,oDlg:End() },{||oDlg:End() },,aBotoes))

    If lConf
        Processa()
    EndIf

Return


/*/{Protheus.doc} CarregaDados
Carregar os dados
@type function
@version 12.1.25
@author Jorge Alberto
@since 06/09/2021
@return array, Dados que serão apresentados na tela
/*/
Static Function CarregaDados()

    Local aOperac := {}
    Local nI      := 0

    For nI := 1 To 10
        If nI == 3 .Or. nI == 8 
            AADD( aOperac, { "01", Space(6)        , "Descrição " + StrZero( nI, 6 ), .F. } )
        Else
            AADD( aOperac, { "01", StrZero( nI, 6 ), "Descrição " + StrZero( nI, 6 ), .F. } )
        EndIf
    Next

Return( aOperac )


/*/{Protheus.doc} DPCBLi
Validação da Linha
@type function
@version 12.1.25
@author Jorge Alberto
@since 06/09/2021
@return logical, .T. se a linha estiver correta ou .F. caso contrário
/*/
User Function DPCBLi()

    Local lOk  := .T.

    If Empty( oBrwOper:aCols[ oBrwOper:nAt, 2 ] )
        lOk := .F.
        MsgAlert( "Linha sem Recurso informado !" )
    EndIf

Return(lOk)


/*/{Protheus.doc} DPCBOK
Função executada para validar o contexto geral da MsNewGetDados (todo aCols).
@type function
@version 12.1.25
@author Jorge Alberto
@since 06/09/2021
@return logical, .T. se tudo estiver correto ou .F. caso contrário
/*/
User Function DPCBOK()

    Local lOk  := .T.

    MsgInfo( "Validação geral" )

Return(lOk)


/*/{Protheus.doc} Processa
Executa o processamento da rotina
@type function
@version 12.1.25
@author Jorge Alberto
@since 06/09/2021
/*/
Static Function Processa()

    MsgInfo( "Feitooooo !" )
    
Return
