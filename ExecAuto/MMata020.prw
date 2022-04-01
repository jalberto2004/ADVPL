#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} MMata020
Função para inclusão de Fornecedor via ExecAuto em MVC.
@type function
@version 12.1.33
@author Jorge Alberto
@since 01/04/2022
@param aDados, array, Dados do Fornecedor
/*/
User Function MMata020(aDados)

    Local nI        := 0
    Local nOpc      := 0
    Local lContinua := .F.
    Local aLog      := {}
    Local oModel 

	For nI := 1 to Len(aDados)

		//      1;       2;         3;      4;         5;         6;      7;          8;      9;     10;
		//A2_LOJA; A2_NOME; A2_NREDUZ; A2_END; A2_NR_END; A2_BAIRRO; A2_EST; A2_COD_MUN; A2_MUN; A2_CEP;		
		//     11;     12;     13;     14;       15;         16;        17;        18;         19;         20; 
		//A2_TIPO; A2_CGC; A2_DDD; A2_TEL; A2_BANCO; A2_AGENCIA; A2_NUMCON; A2_TIPCTA; A2_TPESSOA; A2_CODPAIS; 		
		//        21;        22;       23;        24;      25;       26;       27;         28;       29;        30
		//A2_CALCIRF; A2_MINIRF; A2_INSCR; A2_INSCRM; A2_PAIS; A2_EMAIL; A2_SETOR; A2_COMPLEM; A2_HPAGE;A2_CELULAR
		//          31
		// [REC ou CAD]
		
		nOpc := IIF(Alltrim(aDados[nI,31]) == "C" ,3,4) // 3 Inclusao ; 4 Alteracao
		
		lContinua := nOpc == 3
		dbSelectArea("SA2")
		SA2->(dbSetOrder(3)) // A2_FILIAL + A2_CGC
		If SA2->(dbSeek(xFilial("SA2") + Alltrim(aDados[nI,12])))
			If nOpc == 4
				lContinua := .T.
			Else
				aAdd(aLog," - CNPJ/CPF ["+ Alltrim(aDados[nI,12]) +"] nao foi cadastrado pois já existe no sistema com o código ["+SA2->A2_COD+"] e loja ["+SA2->A2_LOJA+"].")
			EndIf 
		EndIf
		
		// Funcao que cria ou altera o fornecedor
		oModel := Nil					
		oModel := FWLoadModel('MATA020')							
		oModel:SetOperation(nOpc)
		oModel:Activate()						
					
		If nOpc == 4
			oModel:SetValue('SA2MASTER','A2_COD'  ,SA2->A2_COD)
			oModel:SetValue('SA2MASTER','A2_LOJA' ,SA2->A2_LOJA)
		Else
			oModel:SetValue('SA2MASTER','A2_COD' , GETSXENUM("SA2","A2_COD"))
			oModel:SetValue('SA2MASTER','A2_LOJA' ,aDados[nI,1])	
		EndIf		
		oModel:SetValue('SA2MASTER','A2_NOME' , Alltrim(aDados[nI,2]))
		oModel:SetValue('SA2MASTER','A2_NREDUZ' ,Alltrim(aDados[nI,3]))
		oModel:SetValue('SA2MASTER','A2_END' ,Alltrim(aDados[nI,4]))
		oModel:SetValue('SA2MASTER','A2_NR_END' ,Alltrim(aDados[nI,5]))
		oModel:SetValue('SA2MASTER','A2_BAIRRO' ,Alltrim(aDados[nI,6]))
		oModel:SetValue('SA2MASTER','A2_EST' ,Alltrim(aDados[nI,7]))
		oModel:SetValue('SA2MASTER','A2_COD_MUN',Alltrim(aDados[nI,8]))		
		//oModel:SetValue('SA2MASTER','A2_MUN' ,Alltrim(aDados[nI,9]))
		oModel:SetValue('SA2MASTER','A2_CEP' ,StrTRan(Alltrim(aDados[nI,10]),"-",""))
		oModel:SetValue('SA2MASTER','A2_TIPO' ,Alltrim(aDados[nI,11]))				
		oModel:SetValue('SA2MASTER','A2_CGC' ,Alltrim(aDados[nI,12]))
		oModel:SetValue('SA2MASTER','A2_DDD' ,Alltrim(aDados[nI,13]))
		oModel:SetValue('SA2MASTER','A2_TEL' ,Alltrim(aDados[nI,14]))
		oModel:SetValue('SA2MASTER','A2_BANCO' ,Alltrim(aDados[nI,15]))
		oModel:SetValue('SA2MASTER','A2_AGENCIA' ,Alltrim(aDados[nI,16]))
		oModel:SetValue('SA2MASTER','A2_NUMCON' ,Alltrim(aDados[nI,17]))
		oModel:SetValue('SA2MASTER','A2_TIPCTA' ,Alltrim(aDados[nI,18]))
		oModel:SetValue('SA2MASTER','A2_TPESSOA' ,Alltrim(aDados[nI,19]))
		oModel:SetValue('SA2MASTER','A2_CODPAIS' ,Alltrim(aDados[nI,20]))
		oModel:SetValue('SA2MASTER','A2_CALCIRF' ,Alltrim(aDados[nI,21]))
		oModel:SetValue('SA2MASTER','A2_MINIRF' ,Alltrim(aDados[nI,22]))
		oModel:SetValue('SA2MASTER','A2_INSCR' , Alltrim(aDados[nI,23]))
		oModel:SetValue('SA2MASTER','A2_INSCRM' ,Alltrim(aDados[nI,24]))
		oModel:SetValue('SA2MASTER','A2_PAIS' ,  Alltrim(aDados[nI,25]))
		oModel:SetValue('SA2MASTER','A2_EMAIL' , Alltrim(aDados[nI,26]))
		oModel:SetValue('SA2MASTER','A2_SETOR' , Alltrim(aDados[nI,27]))
		oModel:SetValue('SA2MASTER','A2_COMPLEM' ,Alltrim(aDados[nI,28]))
		oModel:SetValue('SA2MASTER','A2_HPAGE' ,Alltrim(aDados[nI,29]))
		oModel:SetValue('SA2MASTER','A2_CELULAR' ,Alltrim(aDados[nI,30]))
		
		// Validacao dos campos informados				
		If oModel:VldData()

			// Efetiva gravacao
		    oModel:CommitData()
			aAdd(aLog," - CNPJ/CPF ["+ Alltrim(aDados[nI,12]) +"] foi cadastrado com sucesso.")

		Else
			aErro := oModel:GetErrorMessage()
		     
		    //Monta o Texto que será mostrado na tela
		    AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
		    AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
		    AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
		    AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
		    AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
		    AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
		    AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
		    AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
		    AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')
		
		    VarInfo("Erro",oModel:GetErrorMessage()[6])
		    aAdd(aLog," - CNPJ/CPF ["+ Alltrim(aDados[nI,12]) +"] erro no importação: ["+Alltrim(oModel:GetErrorMessage()[6])+"].")
		Endif
		
		oModel:DeActivate()		
		oModel:Destroy()
        FreeObj( oModel )
			
	Next nI

Return
