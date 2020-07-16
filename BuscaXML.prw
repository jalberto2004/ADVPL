/*/{Protheus.doc} BuscaXML
Consultar e baixar o arquivo XML da NFE.
@type function
@author Jorge Alberto
@since 10/03/2020
@param cDir, character, Diretório para geração do XML
@param cChave, character, Chave do XML
@return character, Texto do nome do arquivo
/*/
Static Function BuscaXML( lManual, cDir, cChave )

	Local nHndERP := AdvConnection()
	Local cServer := "99.99.99.99"
	Local cBanco  := "ORACLE/PROTHEUS_PRODUCAO"
	Local cSql    := ""
	Local cArq    := ""
    Local cChNFE  := GetNextAlias()
	Local nPorta  := 5487
	Local nConTSS := 0
	
	// Abre a conexão com o TSS da filial
	nConTSS := TCLINK( AllTrim( cBanco ), AllTrim( cServer ), nPorta )
	
	If nConTSS < 0
		IIf( lManual, Alert('Não foi possivel conectar no servidor do TSS !'), NIL )
	Else
	
		TCSetConn( nConTSS )
	
		cSql := "SELECT UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(XML_SIG,2000,0001)) AS XML1, "
		cSql += 	   "UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(XML_SIG,2000,2001)) AS XML2, "
		cSql +=  	   "UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(XML_SIG,2000,4001)) AS XML3, "
		cSql +=  	   "UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(XML_SIG,2000,6001)) AS XML4 "
		cSql +=   "FROM SPED050 "  
	    cSql +=  "WHERE DOC_CHV = '" + cChave + "'"
		  
		DbUseArea( .T., "TOPCONN", TcGenQry( Nil, Nil, cSql ), cChNFE, .F., .F. )
		(cChNFE)->( DbGoTop() )

        If (cChNFE)->( !EOF() )
        
            cArq := cChave + ".xml"

            // Grava no servidor o xml da Nota.
		    Memowrit( cDir + cArq, Alltrim( (cChNFE)->XML1 ) + Alltrim( (cChNFE)->XML2 ) + Alltrim( (cChNFE)->XML3 ) + Alltrim( (cChNFE)->XML4 ) )
        EndIf
		(cChNFE)->( DbCloseArea() )
		
		// Fecha a conexão com o TSS
		TCUnlink( nConTSS )
	EndIf

	// Volta para a conexao com o ERP
	TCSetConn( nHndERP )

Return( cDir + cArq )