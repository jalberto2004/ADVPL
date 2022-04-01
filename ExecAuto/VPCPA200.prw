#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} VPCPA200
Visualizar ( MVC ) a Estrutura de Produto passado pelo parâmetro.
@type function
@version 12.1.27
@author Jorge Alberto
@since 31/03/2022
@param cProduto, character, Código do Produto
/*/
User Function VPCPA200(cProduto)

	Local oExecView

	If Empty( cProduto )
		Return
	EndIf

	DbSelectArea('SG1')
	DbSetOrder(1)	// G1_FILIAL+G1_COD+G1_COMP+G1_TRT
	Dbseek(xFilial('SG1') + cProduto)

	oExecView := FWViewExec():New()
	oExecView:setSource("PCPA200")
	oExecView:setOperation(MODEL_OPERATION_VIEW)
	oExecView:openView(.T.)

	FreeObj( oExecView )

Return
