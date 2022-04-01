#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} MMata010
Rotina que chama o ExecAuto MVC da rotina MATA010 - Cadastro de Produto.
Se for incluído corretamente, também será incluido o Complemento do Produto MATA180.
@type function
@version 12.1.33
@author Jorge Alberto
@since 31/03/2022
/*/
User Function MMata010()

    Local aNovoProd := {}

    CriaProd( aNovoProd )

Return


/*/{Protheus.doc} CriaProd
Inclusão do Produto
@type function
@version 12.1.33
@author Jorge Alberto
@since 31/03/2022
@param aNovoProd, array, Dados de um ou mais produtos
@return logical, .T. se incluiu o produto ou .F. caso contrario
/*/
Static Function CriaProd( aNovoProd )

    Local lOk       := .T.
    Local nReg      := 0
    Local aErro     := {}
    Local cErro     := ""
    Local cProd     := ""
    Local cMensagem := ""
    Local oModel
    Local oFont
    Local oDlgErro

    For nReg := 1 To Len( aNovoProd )

        If cProd <> aNovoProd[ nReg, 2]

            oModel := FwLoadModel("MATA010")
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            /*
            Para atualizar alguma informação do Produto já cadastrado basta seguir os dois passos abaixo:
            1. Estar posicionado no Produto ( SB1 );
            2. Setar a Operação como MODEL_OPERATION_UPDATE.
            */
            oModel:Activate()
            oModel:SetValue( "SB1MASTER", "B1_COD"     ,aNovoProd[ nReg, 2] )
            oModel:SetValue( "SB1MASTER", "B1_DESC"    ,aNovoProd[ nReg, 3] )
            oModel:SetValue( "SB1MASTER", "B1_ESPECIF" ,aNovoProd[ nReg, 3] )
            oModel:SetValue( "SB1MASTER", "B1_TIPO"    ,aNovoProd[ nReg, 5] )
            oModel:SetValue( "SB1MASTER", "B1_UM"      ,aNovoProd[ nReg, 6] )
            oModel:SetValue( "SB1MASTER", "B1_LOCPAD"  ,aNovoProd[ nReg, 7] )
            oModel:SetValue( "SB1MASTER", "B1_CONTA"   ,aNovoProd[ nReg, 8] )
            oModel:SetValue( "SB1MASTER", "B1_ITEMCC"  ,aNovoProd[ nReg, 9] )
            oModel:SetValue( "SB1MASTER", "B1_CLVL"    ,aNovoProd[ nReg,10] )
            oModel:SetValue( "SB1MASTER", "B1_NATUREZ" ,aNovoProd[ nReg,11] )
            oModel:SetValue( "SB1MASTER", "B1_POSIPI"  ,aNovoProd[ nReg,12] )
            oModel:SetValue( "SB1MASTER", "B1_ORIGEM"  ,aNovoProd[ nReg,13] )
            oModel:SetValue( "SB1MASTER", "B1_GRTRIB"  ,aNovoProd[ nReg,14] )
            oModel:SetValue( "SB1MASTER", "B1_GARANT"  ,aNovoProd[ nReg,15] )
            oModel:SetValue( "SB1MASTER", "B1_GRUPO"   ,aNovoProd[ nReg,16] )
            oModel:SetValue( "SB1MASTER", "B1_CODREV"  ,"001"               )
            oModel:SetValue( "SB1MASTER", "B1_MSBLQL"  ,"2"                 ) // Produto Desbloqueado

            If oModel:VldData()
                oModel:CommitData()
                cMensagem += 'Produto ' + AllTrim(aNovoProd[ nReg, 2]) + ' incluído com sucesso !' +CRLF

                oModel:DeActivate()
                oModel:Destroy()
                FreeObj( oModel )
                
                // MVC da rotina de Complemento de Produto
                oModel := FwLoadModel("MATA180")
                oModel:SetOperation(MODEL_OPERATION_INSERT)
                oModel:Activate()
                oModel:SetValue("SB5MASTER","B5_COD"    ,aNovoProd[ nReg, 2] )
                oModel:SetValue("SB5MASTER","B5_CEME"   ,aNovoProd[ nReg, 3] )

                If oModel:VldData()
                    oModel:CommitData()
                    cMensagem += 'Complemento do Produto incluído com sucesso ("SB5") !' +CRLF
                Else
                    aErro := oModel:GetErrorMessage()

                    cErro := aErro[MODEL_MSGERR_IDFORM]+": "+;
                            aErro[MODEL_MSGERR_IDFIELD]+": "+;
                            aErro[MODEL_MSGERR_IDFORMERR]+": "+;
                            aErro[MODEL_MSGERR_IDFIELDERR]+": "+;
                            aErro[MODEL_MSGERR_ID]+" "+;
                            aErro[MODEL_MSGERR_MESSAGE]+" / "+aErro[MODEL_MSGERR_SOLUCTION]

                    cMensagem += 'Erro ao incluir complemento do Produto na SB5: ' + cErro +CRLF
                EndIf
            Else
                aErro := oModel:GetErrorMessage()

                cErro := aErro[MODEL_MSGERR_IDFORM]+": "+;
                        aErro[MODEL_MSGERR_IDFIELD]+": "+;
                        aErro[MODEL_MSGERR_IDFORMERR]+": "+;
                        aErro[MODEL_MSGERR_IDFIELDERR]+": "+;
                        aErro[MODEL_MSGERR_ID]+" "+;
                        aErro[MODEL_MSGERR_MESSAGE]+" / "+aErro[MODEL_MSGERR_SOLUCTION]

                cMensagem += 'Erro na Inclusão do Produto ' + AllTrim(aNovoProd[ nReg, 2]) + ': ' + cErro +CRLF
                lOk := .F.
            EndIf       

            oModel:DeActivate()
            oModel:Destroy()
            FreeObj( oModel )
                    
            cProd := aNovoProd[ nReg, 2] 
        EndIf

    Next

    oFont := TFont():New( "Tahoma",0,-12,,.F.,0,,700,.F.,.F.,,,,,, )
    oDlgErro := MSDialog():New( 092,232,395,789,"Mensagens sobre a atualização Produto x Fornecedor",,,.F.,,,,,,.T.,,,.T. )
        tMultiget():new(008,008,{| u | if( pCount() > 0, cMensagem := u, cMensagem )},oDlgErro,256/*nLargura*/,084/*nAltura*/,oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/)
        TButton():New( 112,108,"Voltar",oDlgErro,{||oDlgErro:END()},037,012,,,,.T.,,"",,,,.F. )
    oDlgErro:Activate(,,,.T.)

    FreeObj(oFont)
    FreeObj(oDlgErro)

Return( lOk )
