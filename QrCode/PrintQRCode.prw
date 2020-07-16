#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

// https://tdn.totvs.com/display/public/PROT/FWMsPrinter
User Function PrintQRCode()
 
	Local oPrinter
	 
	//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01"
	 
	oPrinter := FWMSPrinter():New('teste',6,.F.,,.T.,,,,,.F.)
	oPrinter:Setup()
	oPrinter:setDevice(IMP_PDF)
	oPrinter:cPathPDF :="C:\temp\"
	 
	oPrinter:QRCode(150,150,"QR Code gerado com sucesso", 100)
	 
	oPrinter:EndPage()
	oPrinter:Preview()
	
	FreeObj(oPrinter)
	oPrinter := Nil
	 
	//RESET ENVIRONMENT
 
Return