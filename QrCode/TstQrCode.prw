#INCLUDE "PROTHEUS.CH"

/*
Consulte:
https://tdn.totvs.com.br/display/public/PROT/FwQrCode
*/
User Function TstQrCode()

    Local oDLG := Nil
    Local cCodigo := "http://www.totvs.com.br" + Space(60)
    Private oQrCode

    //Cria a Dialog
    DEFINE MSDIALOG oDlg TITLE "RDMAKE para teste da classe FwQrCode" FROM 0,0 TO 400,800 PIXEL

    //Cria o objeto FwQrCode
    oQrCode := FwQrCode():New({25,25,200,200},oDlg,cCodigo)

    //Get com o codigo exibido
    @25,150 GET oGet VAR cCodigo OF oDlg SIZE 200,10 PIXEL

    //Botao Gerar
    @45,150 BUTTON "Gerar" SIZE 30,20 PIXEL OF oDlg ACTION MsgRun("Gerando QRCode","Aguarde",{|| MyRefresh(cCodigo)}) PIXEL

    //Exibe a Dialog em Video
    ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function MyRefresh(cNewCod)

    oQrCode:SetCodeBar(cNewCod)
    oQrCode:Refresh()

Return
