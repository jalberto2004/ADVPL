#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} MMata061
Rotina que chama o ExecAuto MVC da rotina MATA061 - Cadastro de Produto X Fornecedor.
@type function
@version 12.1.33
@author Jorge Alberto
@since 31/03/2022
/*/
User Function MMata061()

    Local cMensagem   := ""
    Local cNomeAjus   := ""
    Local cCmpoCodRef := Space( Len( SA5->A5_CODPRF ) )
	Local cFilSA2     := xFilial("SA2")
	Local cFilSA5     := xFilial("SA5")
	Local cFilSB1     := xFilial("SB1")
    Local aErro       := {}
    Local oModel
    Local oFont
    Local oDlgErro

    DbSelectArea("SA5")
    DBSetOrder(1)

    DbSelectArea("SB1")
    DBSetOrder(1)

    If SA5->( DbSeek( cFilSA5 + "FOR001" + "01" + "PROD000001" ) )
        cMensagem += "Ja esta cadastrado o Produto PROD000001 para o fornecedor FOR001" + CRLF
    Else

        If .NOT. SB1->( DbSeek( cFilSB1 + "PROD000001" ) )
            cMensagem += "Produto PROD000001 nao cadastrado" + CRLF
        Else

            If SB1->B1_MSBLQL == '1'
                cMensagem += "Produto PROD000001 está Bloqueado para uso" + CRLF
            Else

                oModel := FWLoadModel('MATA061')

                oModel:SetOperation(MODEL_OPERATION_INSERT)
                oModel:Activate()

                cNomeAjus := SubStr( SB1->B1_DESC, 1, TamSX3("A5_NOMPROD")[1] )
                
                //Cabeçalho
                oModel:SetValue('MdFieldSA5','A5_PRODUTO', "PROD000001" )
                oModel:SetValue('MdFieldSA5','A5_NOMPROD', cNomeAjus )

                cNomeAjus := SubStr( Posicione("SA2",1,cFilSA2 + "FOR001" + "01","SA2->A2_NOME"), 1, TamSX3("A5_NOMEFOR")[1] )

                //Grid
                oModel:GetModel( 'MdGridSA5'):AddLine()
                oModel:SetValue( 'MdGridSA5','A5_CODPRF' , cCmpoCodRef )
                oModel:SetValue( 'MdGridSA5','A5_FORNECE', "FOR001"    )
                oModel:SetValue( 'MdGridSA5','A5_LOJA'   , "01"        )
                oModel:SetValue( 'MdGridSA5','A5_NOMEFOR', cNomeAjus   )
                oModel:SetValue( 'MdGridSA5','A5_CODTAB' , "TBPR01"    )

                If oModel:VldData()

                    oModel:CommitData()
                    cMensagem += "Produto PROD000001 foi cadastrado para o fornecedor FOR001" + CRLF

                Else
                    aErro := oModel:GetErrorMessage()

                    cMensagem += "ERRO NA INCLUSAO DO PRODUTO X FORNECEDOR!" +CRLF

                    If Len( aErro ) > 0
                        cMensagem += "Produto PROD000001" +CRLF
                        cMensagem += aErro[MODEL_MSGERR_IDFORM]+": "+;
                                    aErro[MODEL_MSGERR_IDFIELD]+": "+;
                                    aErro[MODEL_MSGERR_IDFORMERR]+": "+;
                                    aErro[MODEL_MSGERR_IDFIELDERR]+": "+;
                                    aErro[MODEL_MSGERR_ID]+" "+;
                                    aErro[MODEL_MSGERR_MESSAGE]+" / "+aErro[MODEL_MSGERR_SOLUCTION] + CRLF
                    EndIf
                EndIf

                oModel:DeActivate()
                oModel:Destroy()
                FreeObj(oModel)

            EndIf
        EndIf
    EndIf

    oFont := TFont():New( "Tahoma",0,-12,,.F.,0,,700,.F.,.F.,,,,,, )
    oDlgErro := MSDialog():New( 092,232,395,789,"Mensagens sobre a atualização Produto x Fornecedor",,,.F.,,,,,,.T.,,,.T. )
        tMultiget():new(008,008,{| u | if( pCount() > 0, cMensagem := u, cMensagem )},oDlgErro,256/*nLargura*/,084/*nAltura*/,oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/)
        TButton():New( 112,108,"Voltar",oDlgErro,{||oDlgErro:END()},037,012,,,,.T.,,"",,,,.F. )
    oDlgErro:Activate(,,,.T.)

    FreeObj(oFont)
    FreeObj(oDlgErro)

Return
