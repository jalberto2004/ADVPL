#Include "TOTVS.ch"

/*/{Protheus.doc} EXECFUNC
Montar uma tela para que seja executada uma Função de Usuário ou padrão
@type function
@version 12.1.27
@author Jorge Alberto
@since 30/03/2021
/*/
User Function EXECFUNC()

    Local cString := Space(150)
    Local oGet1
    Local oDlg

    DEFINE MSDIALOG oDlg TITLE "Executar Programas" FROM C(178),C(181) TO C(323),C(543) PIXEL

    @ C(032),C(005) Say "Nome do programa/função a ser executado" Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlg

    @ C(042),C(005) MsGet oGet1 Var cString Size C(171),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

    @ C(056),C(052) Button "Executar" Size C(037),C(012) PIXEL OF oDlg ACTION( { ExecutaStr( Alltrim(cString) ), oGet1:refresh() } )
    @ C(056),C(091) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

    ACTIVATE MSDIALOG oDlg CENTERED

Return


/*/{Protheus.doc} ExecutaStr
Validar o texto e executar 
@type function
@version 12.1.27
@author Jorge Alberto
@since 30/03/2021
@param cString, character, função que será executada
/*/
Static Function ExecutaStr(cString)

    If Empty( cString )
        MsgAlert("Comando a ser executado não informado. Verifique!")
        Return
    Endif

    If ( At( "(", cString ) <= 0 .And. At( ")", cString ) <= 0 ) // Não tem os parenteses
        cString := cString + "()"
    EndIf

    // Retira os espacos em qualquer lugar.
    cString := StrTran( cString, " ", "" )

    If FindFunction(cString)
        &cString
    Else
        MsgAlert( "Função não existe no RPO !")
    EndIf

    cString := Space(100)

Return
