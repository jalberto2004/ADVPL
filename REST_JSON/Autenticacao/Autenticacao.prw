#include "RESTFUL.ch"
#include "TOTVS.ch"

/*/{Protheus.doc} TRIAuthWS
Consumo de Webservice de autenticação utilizado para integração.
@author Jorge Alberto
@since 08/11/2020
/*/
User Function TRIAuthWS()

    Local cDifTime := ""

    If Type( "cAPIToken" ) == "U"
        Public cAPIToken := ""
        Public cAPIVld   := Time()
    EndIf

    cDifTime := ElapTime( cAPIVld, Time() )

    // Se nao tem Token ou se passou de 23 horas, então solicita um NOVO token, pois a validade é de 24 horas para cada token.
    If ( Empty( cAPIToken ) .Or. Val( Left( cDifTime, 2 ) ) > 23 )
        cAPIToken := GetToken()
        cAPIVld   := Time()
    EndIf

Return( cAPIToken )

/*/{Protheus.doc} GetToken
Realizar a chamda da API para retornar o Token de acesso.
@author Jorge Alberto
@since 08/11/2020
/*/
Static Function GetToken()

    Local cParIP  := AllTrim(SuperGetMV("ES_AUTENIP", ," "))
    Local cParPT  := AllTrim(SuperGetMV("ES_AUTENPT", ," "))
    Local cUrl    := "http://" + cParIP + ":"+cParPT
    Local cUri    := "/login/"
    Local cUsr    := "usuario"
    Local cEmp    := "senha123"
    Local oRest   := FWRest():New(cUrl)
    Local aHeader := {}
    Local cResult := ""
    
    oRest:setPath(cUri+cEmp+":"+cUsr)

    If oRest:Post(aHeader)
        cResult := oRest:GetResult()
    Else
        cResult :=  oRest:GetLastError()
    EndIf
    
Return(cResult)
