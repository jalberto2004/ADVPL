#include "RESTFUL.ch"
#include "TOTVS.ch"

/*/{Protheus.doc} TRIContaWS
Consumo de Webservice de Clientes utilizado para integração com Post na API.
@author Jorge Alberto
@since 08/11/2020
/*/
User Function TRICliWS( aParam, lAuto )

    Local cResult   := ""
    Local lResult   := .F.
    Local xToJson
    Local cBody     := ""

    private aHeader := {}
    private cParIP  := AllTrim(SuperGetMV("ES_AUTENIP", ," "))
    private cParPT  := AllTrim(SuperGetMV("ES_AUTENPT", ," ")) 
    private cUrl    := "http://" + cParIP + ":"+cParPT
    private cUri    := "/v2/write/"
    Private cTbl    := "pessoas"
    private oRest   := FWRest():New(cUrl)
    private oJson   := JsonObject():New()

    oRest:setPath(cUri+cTbl)
    
    xToJson := oJson:fromJson( u_TRIAuthWS() ) 
    If ValType(xToJson) == "C" //se a variável estiver populada com caractere, a conversão para JSON gerou um erro
        MsgInfo("Erro ao Autenticar no servidor SoftMovel.", "Integração")
    Else
        
        aAdd(aHeader, "Authorization: Bearer "+oJson:getJsonObject("token"))
        oJson   := JsonObject():New()
        
        // Carrega os dados objeto do Json conforme o que foi passado por parâmetro
        montaBody(aParam)
        cBody := oJson:toJson()

        oRest:SetPostParam( cBody )
        
        // Faz a chamada do Post da API
        If oRest:Post(aHeader)
            cResult := oRest:GetResult()
            lResult:= .T.
        Else
        
            // Com o erro, devemos retornar o resultado do erro para detalhar o problema
            oJson:= JsonObject():new()
            oJson:fromJson(oRest:cResult)
            If !Empty(oRest:cResult )
                cResult := "Erro na integração (pessoas): " + cValToChar(oJson:getJsonObject("status")) + " - " +oEMToAnsi(oJson:getJsonObject("message"))
            else
                cRestult := "Erro na integração. Contate o Administrador."
            EndIf
            
            If !lAuto
                MsgInfo(cResult, "Integração")
            EndIf
            lResult:= .F.
            MemoWrite("c:\temp\tricliwsbody.txt", cBody)
            MemoWrite("c:\temp\tricliwsbody-erro.txt", cResult)
        EndIf
        
    EndIf

return(lResult)


/*/{Protheus.doc} montaBody
Preenche o objeto Json com os dados que estao no array
@author Jorge Alberto
@since 08/11/2020
/*/
Static Function montaBody(aDados)

    oJson["id"]                 := aDados[01]
    oJson["cod_lancamento"]     := aDados[02]
    oJson["user_insercao"]      := aDados[03]
    oJson["user_modificacao"]   := aDados[04]
    oJson["flg_ativo"]          := aDados[05]
    oJson["des_pessoa"]         := aDados[06]
    oJson["des_cidade_fat"]     := aDados[07]
    oJson["cod_cep_fat"]        := aDados[08]
    oJson["cod_transportador"]  := aDados[09]
    oJson["nro_telefone"]       := aDados[10]
    oJson["flg_pessoa"]         := aDados[11]
    oJson["des_rota"]           := aDados[12]
    oJson["obs_observacao"]     := aDados[13]
    oJson["flg_status"]         := aDados[14]
    oJson["vlr_transp_fixo"]    := aDados[15]
    
Return()
