#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

#DEFINE ERRORCODE_DEF	400
#DEFINE ERRORSRV_DEF	500

WSRESTFUL  WSCliente DESCRIPTION "API personalizada para inclusão e alteração de Clientes" SECURITY 'CRMA980' FORMAT APPLICATION_JSON

    WSMETHOD POST InclusaoCliente;
	DESCRIPTION 'Inclusão de Cliente';
	WSSYNTAX '/WSCliente/InclusaoCliente';
	PRODUCES APPLICATION_JSON

    WSMETHOD PUT AlteracaoCliente;
	DESCRIPTION 'Alteração de Cliente';
	WSSYNTAX '/WSCliente/AlteracaoCliente';
	PRODUCES APPLICATION_JSON

END WSRESTFUL


/*/
Método POST para a Inclusão do Cliente, utilizando jSonObject.
@author Jorge Alberto
@since 31/03/2021
@version 1.0
@example
Chamada via postman  http://localhost:8012/rest/WSCliente/InclusaoCliente
Se a chave 'Security' estiver habilitada deverá ser passado o usuário/senha ou token
Body 
{
    "code": "10541054",
    "storeId": "0001",
    "registerSituation": "2",
    "strategicCustomerType": "F",
    "entityType": "F",
    "shortName": "LETICIA",
    "name": "LETICIA",
    "governmentalInformation": [
        {
            "scope": "Federal",
            "id": "10541054",
            "name": "CPF"
        }
    ],
    "listOfCommunicationInformation": [
        {
            "diallingCode": "99",
            "phoneNumber": "98789878",
            "email": "cliente@empresa.com.br",
            "homePage": "07\/05\/1987",
            "faxNumber": "3"
        }
    ],
    "address": {
        "address": "nao encontrado",
        "mainAddress": true,
        "zipCode": "",
        "state": {
            "stateId": "EX",
            "stateDescription": "nao encontrado"
        },
        "complement": "nao encontrado",
        "district": "nao encontrado",
        "city": {
            "cityCode": "",
            "cityInternalId": "",
            "cityDescription": "Sao Paulo"
        }
    }
}
/*/
WSMETHOD POST InclusaoCliente WSRECEIVE WSRESTFUL WSCliente

    Local oJson
    Local lRet        := .T.
    Local cJson       := Self:GetContent()
    Local cDirLog     := "\LOGWS\"
    Local aAuto       := {}
    Local aLogAuto    := {}
    Local nX          := 0
    Local cJSONRet    := ""
    Local cErro       := ""
    Local cErroExec   := ""
    Local cArqLog     := ""

    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private oError		    := Nil
    Private bError		    := { |e| oError := e, Break(e) }
    Private bErrorBlock	    := ErrorBlock( bError )

    RpcSetEnv( "01", "0104",, "" , "FAT" , "IncluiCliente" , {"SA1"},,,, )

    BEGIN SEQUENCE

        IF .NOT. ExistDir(cDirLog)
            MakeDir(cDirLog)
        EndIF

        // define o tipo de retorno do método
        Self:SetContentType("application/json")

        If .NOT. Empty( cJson )
            cJson := Replace( cJson, "\", "" )
        EndIf

        oJson := JsonObject():New()
        cErro := oJson:FromJson(cJson)

        //Se tiver algum erro no Parse, encerra a execução
        IF .NOT. Empty(cErro)
            SetRestFault(ERRORSRV_DEF, EncodeUTF8( cErro ) )
            lRet := .F.
            Break
        EndIf

        CarregaDados( oJson, @cErro, @aAuto, .T. )

        If .NOT. Empty( cErro )
            lRet := .F.
            SetRestFault( ERRORCODE_DEF, cErro )
            Break
        EndIf

        lMsErroAuto := .F.

        MSExecAuto({|_x, _y| CRMA980(_x, _y)}, aAuto, 3) // Inclusao

        If lMsErroAuto

            cArqLog   := DtoS(Date()) + "_" + StrTran(Time(), ':', '')+".log"
            cErroExec := ""
            aLogAuto  := {}
            aLogAuto  := GetAutoGrLog()
            For nX := 1 To Len(aLogAuto)
                cErroExec += EncodeUTF8( aLogAuto[nX] )
            Next
            MemoWrite( cDirLog + cArqLog, cErroExec )
            SetRestFault(ERRORSRV_DEF, "Erro: " + cErroExec + CRLF + "JSON recebido: " + cJson )
            lRet := .F.

        Else
            lRet := .T.
            cJSONRet := '{"Sucesso":"Cliente incluído"}'
            Self:SetResponse( EncodeUTF8(cJSONRet) )
        EndIf

    RECOVER
		lRet := .F.
		ErrorBlock(bErrorBlock)
        If ValType( oError ) == "O"
            cErro := oError:Description
            MemoWrite( cDirLog + DtoS(Date()) + "_" + StrTran(Time(), ':', '')+".log", cErro + CRLF + "JSON recebido: " + cJson )
            SetRestFault(ERRORSRV_DEF, EncodeUTF8("Ocorreu uma falha interna do Servidor: ") + cErro + CRLF + "JSON recebido: " + cJson )
        EndIF
	END SEQUENCE

    RpcClearEnv()

Return( lRet )


/*/
Método PUT para a Alteração do Cliente, utilizando jSonObject.
@author Jorge Alberto
@since 31/03/2021
@version 1.0
@example
Chamada via postman  http://localhost:8012/rest/WSCliente/AlteracaoCliente
Se a chave 'Security' estiver habilitada deverá ser passado o usuário/senha ou token
Body 
{
    "code": "10541054",
    "storeId": "0001",
    "registerSituation": "2",
    "strategicCustomerType": "F",
    "entityType": "F",
    "shortName": "LETICIA",
    "name": "LETICIA",
    "governmentalInformation": [
        {
            "scope": "Federal",
            "id": "10541054",
            "name": "CPF"
        }
    ],
    "listOfCommunicationInformation": [
        {
            "diallingCode": "99",
            "phoneNumber": "98789878",
            "email": "cliente@empresa.com.br",
            "homePage": "07\/05\/1987",
            "faxNumber": "3"
        }
    ],
    "address": {
        "address": "nao encontrado",
        "mainAddress": true,
        "zipCode": "",
        "state": {
            "stateId": "EX",
            "stateDescription": "nao encontrado"
        },
        "complement": "nao encontrado",
        "district": "nao encontrado",
        "city": {
            "cityCode": "",
            "cityInternalId": "",
            "cityDescription": "Sao Paulo"
        }
    }
}
/*/
WSMETHOD PUT AlteracaoCliente WSRECEIVE WSRESTFUL WSCliente

    Local oJson
    Local lRet        := .T.
    Local cJson       := Self:GetContent()
    Local cDirLog     := "\LOGWS\"
    Local aAuto       := {}
    Local aLogAuto    := {}
    Local nX          := 0
    Local cJSONRet    := ""
    Local cErro       := ""
    Local cErroExec   := ""
    Local cArqLog     := ""

    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private oError		    := Nil
    Private bError		    := { |e| oError := e, Break(e) }
    Private bErrorBlock	    := ErrorBlock( bError )

    RpcSetEnv( "01", "0104",, "" , "FAT" , "AlteraCliente" , {"SA1"},,,, )

    BEGIN SEQUENCE

        //Se não existir o diretório de logs dentro da Protheus Data, será criado
        IF .NOT. ExistDir(cDirLog)
            MakeDir(cDirLog)
        EndIF

        // define o tipo de retorno do método
        Self:SetContentType("application/json")

        If .NOT. Empty( cJson )
            cJson := Replace( cJson, "\", "" )
        EndIf

        oJson := JsonObject():New()
        cErro := oJson:FromJson(cJson)

        //Se tiver algum erro no Parse, encerra a execução
        IF .NOT. Empty(cErro)
            SetRestFault(ERRORSRV_DEF, EncodeUTF8( cErro ) )
            lRet := .F.
            Break
        EndIf

        CarregaDados( oJson, @cErro, @aAuto, .F. )

        If .NOT. Empty( cErro )
            lRet := .F.
            SetRestFault( ERRORCODE_DEF, cErro )
            Break
        EndIf

        lMsErroAuto := .F.

        MSExecAuto({|_x, _y| CRMA980(_x, _y)}, aAuto, 4) // Alteração

        If lMsErroAuto

            cArqLog   := DtoS(Date()) + "_" + StrTran(Time(), ':', '')+".log"
            cErroExec := ""
            aLogAuto  := {}
            aLogAuto  := GetAutoGrLog()
            For nX := 1 To Len(aLogAuto)
                cErroExec += EncodeUTF8( aLogAuto[nX] )
            Next
            MemoWrite( cDirLog + cArqLog, cErroExec )
            SetRestFault(ERRORSRV_DEF, "Erro: " + cErroExec + CRLF + "JSON recebido: " + cJson )
            lRet := .F.

        Else
            lRet := .T.
            cJSONRet := '{"Sucesso":"Cliente alterado"}'
            Self:SetResponse( EncodeUTF8(cJSONRet) )
        EndIf

    RECOVER
		lRet := .F.
		ErrorBlock(bErrorBlock)
        If ValType( oError ) == "O"
            cErro := oError:Description
            MemoWrite( cDirLog + DtoS(Date()) + "_" + StrTran(Time(), ':', '')+".log", cErro + CRLF + "JSON recebido: " + cJson )
            SetRestFault(ERRORSRV_DEF, EncodeUTF8("Ocorreu uma falha interna do Servidor: ") + cErro + CRLF + "JSON recebido: " + cJson )
        EndIF
	END SEQUENCE

    RpcClearEnv()

Return( lRet )



/*/{Protheus.doc} CarregaDados
Função que irá carregar os dados e validar se tem algum campo não informado
@type function
@version 12.1.25
@author Jorge Alberto
@since 31/03/2021
@param oJson, object, JSON recebido
@param cErro, character, Texto com o erro
@param aAuto, array, Dados que serão enviados para o execauto
@param lInclusao, logical, .T. se for inclusão ou .F. se for alteração
/*/
Static Function CarregaDados( oJson, cErro, aAuto, lInclusao )

    Local cCodigo     := ""
    Local cLoja       := ""
    Local cNome       := ""
    Local cApelido    := ""
    Local cBairro     := ""
    Local cComple     := ""
    Local cCEP        := ""
    Local cEst        := ""
    Local cDescEst    := ""
    Local cCodMum     := ""
    Local cCidade     := ""
    Local cCPF        := ""
    Local cEnder      := ""
    Local cTipo       := ""
    Local cPesFJ      := ""
    Local cBloquea    := ""
    Local cDDD        := ""
    Local cCelular    := ""
    Local cEmail      := ""
    Local cOpcAlim    := ""
    Local aStrGovInfo := {}
    Local aStrCom     := {}
    Local dDtNasc     := CtoD('')
    Local lFound      := .F.

    BEGIN SEQUENCE

        cCodigo  := AllTrim( IIF(ValType(oJson:GetJsonObject('code'))=="C",oJson:GetJsonObject('code'),'') )
        cLoja    := AllTrim( IIF(ValType(oJson:GetJsonObject('storeId'))=="C",oJson:GetJsonObject('storeId'),'') )
        cNome    := AllTrim( DecodeUTF8( IIF(ValType(oJson:GetJsonObject('name'))=="C",oJson:GetJsonObject('name'),'') ) )
        cApelido := AllTrim( DecodeUTF8( IIF(ValType(oJson:GetJsonObject('shortName'))=="C",oJson:GetJsonObject('shortName'),'') ) )
        cBloquea := AllTrim( IIF(ValType(oJson:GetJsonObject('registerSituation'))=="C",oJson:GetJsonObject('registerSituation'),'2') )
        cTipo    := AllTrim( IIF(ValType(oJson:GetJsonObject('strategicCustomerType'))=="C",oJson:GetJsonObject('strategicCustomerType'),'F') )
        cPesFJ   := AllTrim( IIF(ValType(oJson:GetJsonObject('entityType'))=="C",oJson:GetJsonObject('entityType'),'F') )

        If ValType( oJson:GetJsonObject('governmentalInformation') ) == "O"
            aAdd( aStrGovInfo, oJson:GetJsonObject('governmentalInformation') )
        ElseIf ValType( oJson:GetJsonObject('governmentalInformation') ) == "A"
            aStrGovInfo := oJson:GetJsonObject('governmentalInformation')
		EndIf

        If ValType( oJson:GetJsonObject('listOfCommunicationInformation') ) == "O"
            aAdd( aStrCom, oJson:GetJsonObject('listOfCommunicationInformation') )
        ElseIf ValType( oJson:GetJsonObject('listOfCommunicationInformation') ) == "A"
            aStrCom := oJson:GetJsonObject('listOfCommunicationInformation')
		EndIf

        If Len( aStrGovInfo ) >= 1
            cCPF := AllTrim( IIF(ValType(aStrGovInfo[1]:GetJsonObject('id'))=="C",aStrGovInfo[1]:GetJsonObject('id'),'') )
        EndIF

        If Len( aStrCom ) >= 1
            cDDD     := AllTrim( IIF(ValType(aStrCom[1]:GetJsonObject('diallingCode'))=="C",aStrCom[1]:GetJsonObject('diallingCode'),'') )
            cCelular := AllTrim( IIF(ValType(aStrCom[1]:GetJsonObject('phoneNumber'))=="C",aStrCom[1]:GetJsonObject('phoneNumber'),'') )
            cEmail   := AllTrim( IIF(ValType(aStrCom[1]:GetJsonObject('email'))=="C",aStrCom[1]:GetJsonObject('email'),'') )
            cOpcAlim := AllTrim( IIF(ValType(aStrCom[1]:GetJsonObject('opcAlimentar'))=="C",aStrCom[1]:GetJsonObject('opcAlimentar'),'') )
            dDtNasc  := CtoD( Replace( AllTrim( IIF(ValType(aStrCom[1]:GetJsonObject('dtNasc'))=="C",aStrCom[1]:GetJsonObject('dtNasc'),'') ), "\", "") )
        EndIF

        cEnder  := AllTrim( DecodeUTF8( IIF(ValType(oJson:GetJsonObject('address'):GetJsonObject('address'))=="C",oJson:GetJsonObject('address'):GetJsonObject('address'),'') ) )
        cBairro := AllTrim( DecodeUTF8( IIF(ValType(oJson:GetJsonObject('address'):GetJsonObject('district'))=="C",oJson:GetJsonObject('address'):GetJsonObject('district'),'') ) )
        cComple := AllTrim( DecodeUTF8( IIF(ValType(oJson:GetJsonObject('address'):GetJsonObject('complement'))=="C",oJson:GetJsonObject('address'):GetJsonObject('complement'),'') ) )
        cCEP    := AllTrim( IIF(ValType(oJson:GetJsonObject('address'):GetJsonObject('zipCode'))=="C",oJson:GetJsonObject('address'):GetJsonObject('zipCode'),'') )
        
        cEst     := AllTrim( IIF(ValType(oJson:GetJsonObject('address'):GetJsonObject('state'):GetJsonObject('stateId'))=="C",oJson:GetJsonObject('address'):GetJsonObject('state'):GetJsonObject('stateId'),'') )
        cDescEst := AllTrim( DecodeUTF8( IIF(ValType(oJson:GetJsonObject('address'):GetJsonObject('state'):GetJsonObject('stateDescription'))=="C",oJson:GetJsonObject('address'):GetJsonObject('state'):GetJsonObject('stateDescription'),'') ) )

        cCodMum := AllTrim( IIF(ValType(oJson:GetJsonObject('address'):GetJsonObject('city'):GetJsonObject('cityCode'))=="C",oJson:GetJsonObject('address'):GetJsonObject('city'):GetJsonObject('cityCode'),'') )
        cCidade := AllTrim( DecodeUTF8( IIF(ValType(oJson:GetJsonObject('address'):GetJsonObject('city'):GetJsonObject('cityDescription'))=="C",oJson:GetJsonObject('address'):GetJsonObject('city'):GetJsonObject('cityDescription'),'') ) )

        If .NOT. Empty( cNome )
            cNome := AllTrim( Replace( cNome, "'", " " ) )
            cNome := AllTrim( Replace( cNome, '"', ' ' ) )
        EndIf

        If .NOT. Empty( cApelido )
            cApelido := AllTrim( Replace( cApelido, "'", " " ) )
            cApelido := AllTrim( Replace( cApelido, '"', ' ' ) )
        EndIf

        If Empty( cNome )
            cErro := EncodeUTF8("Obrigatório informar o Nome do Cliente.")
            Break
        EndIf

        If Empty( cApelido )
            cErro := EncodeUTF8("Obrigatório informar o Apelido do Cliente.")
            Break
        EndIf

        If Empty( cEnder )
            cErro := EncodeUTF8("Obrigatório informar o Endereço do Cliente.")
            Break
        EndIf

        If Empty( cCPF )
            cErro := EncodeUTF8("Obrigatório informar o CPF do Cliente.")
            Break
        ElseIf .NOT. CGC( cCPF,, .F. /*lHelp*/ )
            cErro := EncodeUTF8("Digito verificador do CPF " + cCPF + " incorreto.")
            Break
        EndIf

        If Empty( cEst )
            cErro := EncodeUTF8("Obrigatório informar UF/Estado do Cliente.")
            Break
        EndIf

        // If Empty( cCodMum )
        //     cErro := EncodeUTF8("Obrigatório informar o Código do Municipio do Cliente.")
        //     Break
        // EndIf

        If Empty( cCidade )
            cErro := EncodeUTF8("Obrigatório informar a Descrição do Municipio do Cliente.")
            Break
        EndIf

        // If Empty( cCEP )
        //     cErro := EncodeUTF8("Obrigatório informar o CEP do Cliente.")
        //     Break
        // EndIf

        // If Empty( cCelular )
        //     lRet := .F.
        //     cErro := EncodeUTF8("Obrigatório informar o Telefone Celular do Cliente.")
        //     Break
        // EndIf

        DbSelectArea("SA1")
        DbSetOrder(1)
        DbSeek( xFilial("SA1") + cCodigo + cLoja )
        lFound := Found()

        If( lFound .And. lInclusao )
            cErro := EncodeUTF8("Codigo e Loja informados já estão cadastrados.")
            Break
        ElseIf( .NOT. lFound .And. .NOT. lInclusao )
            cErro := EncodeUTF8("Codigo e Loja não localizados no cadastro.")
            Break
        EndIf

        aadd( aAuto, { "A1_COD"    	, cCodigo	, Nil})
        aadd( aAuto, { "A1_LOJA"   	, cLoja		, Nil})
        aadd( aAuto, { "A1_NOME"   	, cNome		, Nil})
        aadd( aAuto, { "A1_NREDUZ" 	, cApelido  , Nil})
        aadd( aAuto, { "A1_MSBLQL"	, cBloquea 	, Nil})
        aadd( aAuto, { "A1_TIPO"	, cTipo   	, Nil})
        aadd( aAuto, { "A1_PESSOA"	, cPesFJ   	, Nil})
        aadd( aAuto, { "A1_CGC"     , cCPF	    , Nil})
        aadd( aAuto, { "A1_DDD"     , cDDD	    , Nil})
        aadd( aAuto, { "A1_TEL"     , cCelular  , Nil})
        aadd( aAuto, { "A1_EMAIL"   , cEmail    , Nil})
        aadd( aAuto, { "A1_DTNASC"  , dDtNasc   , Nil})
        aadd( aAuto, { "A1_OPCALIM" , cOpcAlim  , Nil})
        If cEst <> "EX"
            aAdd( aAuto, { "A1_PAIS", "105"		, Nil})	// Brasil
        EndIf
        aAdd( aAuto, { "A1_EST"		, cEst 		, Nil})
        aAdd( aAuto, { "A1_ESTADO"	, cDescEst  , Nil})
        aAdd( aAuto, { "A1_COD_MUN"	, cCodMum	, Nil})
        aAdd( aAuto, { "A1_MUN"		, cCidade	, Nil})
        aAdd( aAuto, { "A1_END"		, cEnder    , Nil})
        aAdd( aAuto, { "A1_BAIRRO"  , cBairro   , Nil})
        aAdd( aAuto, { "A1_COMPLEM" , cComple   , Nil})
        aAdd( aAuto, { "A1_CEP"     , cCEP      , Nil})

    END SEQUENCE

Return
