#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} TstQrCode
Geração de QRCode.
Consulte a documentação abaixo para mais detalhes:
https://tdn.totvs.com.br/display/public/PROT/FwQrCode
https://tdn.totvs.com/display/public/PROT/FWMsPrinter
@type function
@version 
@author Jorge Alberto
@since 16/07/2020
/*/
User Function TstQrCode()

    Local oDlg
    Local cCodigo := "http://www.totvs.com.br" + Space(60)
    Private oQrCode
    
    oDlg := MSDialog():New( 0,0,400,800,"Exemplo de uso da classe FwQrCode",,,.F.,,,,,,.T.,,,.T. )

    //Cria o objeto FwQrCode
    oQrCode := FwQrCode():New({25,25,200,200},oDlg,cCodigo)

    TGet():New( 025, 150, {|u|IIF(Pcount()>0,cCodigo:=u,cCodigo)},oDlg,200, 010, "!@",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCodigo" )

    TButton():New( 045,150,"Gerar",oDlg,{|| MsgRun("Gerando QRCode...","Aguarde",{|| MyRefresh(cCodigo)}) },30,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    TButton():New( 075,150,"Imprimir",oDlg,{|| PrtQRCode(cCodigo) },30,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    TButton():New( 105,150,"Fechar",oDlg,{|| oDlg:End() },30,20,,,.F.,.T.,.F.,,.F.,,,.F. )

    oDlg:Activate(,,,.T.)

Return


/*/{Protheus.doc} MyRefresh
Atualiza o objeto
@type function
@version 
@author Jorge Alberto
@since 16/07/2020
@param cNewCod, character, endereço web que será atualizado
/*/
Static Function MyRefresh(cNewCod)
    oQrCode:SetCodeBar(cNewCod)
    oQrCode:Refresh()
Return


/*/{Protheus.doc} PrtQRCode
Gera um PDF com o QRCode
@type function
@version 
@author Jorge Alberto
@since 16/07/2020
@param cCodigo, character, endereço web que será transformado em QRCode e gerado em pdf
/*/
Static Function PrtQRCode(cCodigo)
 
	Local oPrinter
	 
	oPrinter := FWMSPrinter():New("QRCode"/*Titulo arquivo*/,6,.F.,,.T.,,,,,.F.)
	oPrinter:Setup()
	oPrinter:setDevice(IMP_PDF)
	oPrinter:cPathPDF :="C:\"
	 
	oPrinter:QRCode(150,150,cCodigo, 100)
	 
	oPrinter:EndPage()
	oPrinter:Preview()
	
	FreeObj(oPrinter)
	oPrinter := Nil
 
Return
