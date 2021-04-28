#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} SuperQry
Montar uma tela para a digitação e execução de Comandos SQL ( Select, Update e Insert ).
Com opção de Exporta os resultados para Planilha Eletronica.
Possibilidade de exportar a consulta para o formato ADVPL que pode ser colado no código fonte.
@type function
@version 12.1.27
@author Jorge Alberto
@since 07/09/2020
/*/
User Function SuperQry()

    Local cSQL := ""
    Local cLine := ""
    Local cLogErro := ""
    Local cTipo := "Original"
    Local aTipos := {"Titulo","Original"}
    Local nHdl := 0
    Local oPanelResultado
    Local oPanelQuery
    Local oDlg
    Local oFont := TFont():New( "Arial",0,-14,,.F.,0,,700,.F.,.F.,,,,,, )
    Local oMGSql
    Local oMenu

    Private oPanelMsg
    Private oGridResult
    Private cArqUser := "super"+RetCodUsr()+".qry"

    If File( cArqUser )
        nHdl := FT_FUse( cArqUser )
        If nHdl = -1
            Alert( "Erro na abertura do arquivo ")
        Else
            FT_FGoTop()
            While !FT_FEOF()
                cLine  := FT_FReadLn()
                cSQL += cLine + CRLF
                FT_FSKIP()
            End
            FT_FUSE()
        EndIf
    EndIf

	//**************************************************************
	// Calcula as 2 dimensões, onde cada uma terá seus objetos      
	//**************************************************************
	oSize := FwDefSize():New( .F. ) // Não terá barra com os botões
	oSize:AddObject( "SUPERIOR", 100, 10, .T., .T. )
	oSize:AddObject( "INFERIOR", 100, 90, .T., .T. )
	oSize:lProp := .F. // Proporcional
	oSize:Process() // Dispara os calculos

	//**************************************************************
	// Divide a Superior em 3                                      
	//**************************************************************
	oSizeSup := FwDefSize():New( .F. ) // Não terá barra com os botões
	oSizeSup:aWorkArea := oSize:GetNextCallArea( "SUPERIOR" )
	oSizeSup:AddObject( "OPCOES"  , 10, 100, .T., .T. )
	oSizeSup:AddObject( "CONSULTA", 80, 100, .T., .T. )
	oSizeSup:AddObject( "MENSAGEM", 10, 100, .T., .T. )
	oSizeSup:lLateral := .T. //Calculo em Lateral
	oSizeSup:lProp := .T.
	oSizeSup:Process()

	//**************************************************************
	// Monta Dialog                                                
    //**************************************************************
	oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],"Super Query Analyser",,,,nOr(WS_VISIBLE,WS_POPUP),,,,,.T.)

    //**************************************************************
    //Aqui está criando o Grupo onder serão colocados os Botões
    //**************************************************************
    oGgpOpcoes := TGroup():New(oSizeSup:GetDimension("OPCOES","LININI"),;
                                oSizeSup:GetDimension("OPCOES","COLINI"),;
                                oSizeSup:GetDimension("OPCOES","LINEND"),;
                                oSizeSup:GetDimension("OPCOES","COLEND"),'Opções',oDlg,,,.T.)

    //*********************************************************************************
    //Aqui está criando o Grupo onde será colocado o MultiGet para a digitação do SQL
    //*********************************************************************************
    oPanelQuery := TGroup():New(oSizeSup:GetDimension("CONSULTA","LININI"),;
                                oSizeSup:GetDimension("CONSULTA","COLINI"),;
                                oSizeSup:GetDimension("CONSULTA","LINEND"),;
                                oSizeSup:GetDimension("CONSULTA","COLEND"),'Comando SQL',oDlg,,,.T.)
    
    //****************************************************************************
    //Aqui está criando o Grupo onde será colocado o MultiGet para as Mensagens 
    //****************************************************************************
    oPanelMsg := TGroup():New( oSizeSup:GetDimension("MENSAGEM","LININI"),;
                                oSizeSup:GetDimension("MENSAGEM","COLINI"),;
                                oSizeSup:GetDimension("MENSAGEM","LINEND"),;
                                oSizeSup:GetDimension("MENSAGEM","COLEND"),'Mensagens',oDlg,,,.T.)

    //******************************************************************************
    //Aqui está criando o Grupo onde será colocado o browse dos dados apresentados
    //******************************************************************************
    oPanelResultado := TGroup():New(oSize:GetDimension("INFERIOR","LININI"),;
                                oSize:GetDimension("INFERIOR","COLINI"),;
                                oSize:GetDimension("INFERIOR","LINEND"),;
                                oSize:GetDimension("INFERIOR","COLEND"),"Resultado",oDlg,,,.T.)

    //***********************************************
    //Aqui está criando os Botões/Atalhos das ações
    //***********************************************
    SetKey( VK_F5, {|| MsgRun( "Executando a consulta...", "Aguarde",  {|| ExecSQL(oPanelResultado, cSQL, @cLogErro, cTipo, oMGSql:nPos ), oMGSql:SetFocus() } ) } )
    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+10,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    "Executar SQL (F5)",oGgpOpcoes,{|u| MsgRun( "Executando a consulta...", "Aguarde",  {|| ExecSQL(oPanelResultado, cSQL, @cLogErro, cTipo, oMGSql:nPos ), oMGSql:SetFocus() } ) },50,12,,,,.T.,,"",,,,.F. )

	TComboBox():New( oSizeSup:GetDimension("OPCOES","LININI")+30,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    {|u| If(PCount()>0,cTipo:=u,cTipo)},aTipos,040,010,oGgpOpcoes,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cTipo, "Coluna dos dados", 1 )

    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+50,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    "Gerar Excel",oGgpOpcoes,{|u| MsgRun( "Gerando arquivo...", "Aguarde",  {|| GeraExcel( cSQL, cLogErro, oMGSql:nPos ) } ) },35,12,,,,.T.,,"",,,,.F. )

    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+70,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    "Enviar Log",oGgpOpcoes,{|u| MsgRun( "Enviando arquivo...", "Aguarde",  {|| Mysend(cLogErro) } ) },35,12,,,,.T.,,"",,,,.F. )

    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+90,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    "Exp. p/ Fonte ADVPL",oGgpOpcoes,{|u| MsgRun( "Gerando cQuery...", "Aguarde",  {|| CQuery(cSQL, oMGSql:nPos) } ) },55,12,,,,.T.,,"",,,,.F. )

    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+120,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    "Fechar",oGgpOpcoes,{|u| oDlg:END() },35,12,,,,.T.,,"",,,,.F. )
    

    //******************************************************
    //Aqui está criando o MultiGet para a digitação do SQL
    //******************************************************
    oMGSql := tMultiget():new(oSizeSup:GetDimension("CONSULTA","LININI")+10/*Linha inicial*/,;
                    oSizeSup:GetDimension("CONSULTA","COLINI")+5/*Coluna inicial*/,;
                    {| u | if( pCount() > 0, cSQL := u, cSQL )},oPanelQuery,;
                    oSizeSup:GetDimension("CONSULTA","XSIZE")-10/*Largura*/,;
                    oSizeSup:GetDimension("CONSULTA","YSIZE")-15/*Altura*/,oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/,/*bValid*/,,,/*lNoBorder*/,.T./*lVScroll*/)

    oMenu := TMenu():New(0,0,0,0,.T.)
    oMenu:Add( TMenuItem():New(oMenu,"Opção",,,,{|| MsgInfo("Melhoria futura", "Super Query") },,,,,,,,,.T.) )
    oMGSql:SetPopup(oMenu)
    oMGSql:SetFocus()

    oDlg:Activate()

    SetKey( VK_F5 , NIL )

Return


/*/{Protheus.doc} CQuery
Função que coloca na área de memória da máquina, toda a consulta no formato cQuery para que fique fácil de colar no código fonte !
@type function
@version 12.1.25
@author Jorge Alberto
@since 23/04/2021
@param cSql, character, Comando SQL
@param nPosCursor, numeric, Posição do cursor na tela
/*/
Static Function CQuery( cSql, nPosCursor )

    Local cRet     := ""
    Local cTab     := ""
    Local cTxt     := ""
    Local cFirma   := FWCodEmp()
    Local aCposSel := {}
    Local lOk      := .F.
    Local nPos     := 0
    Local nPFil    := 0
    Local nPEsp    := 0
    Local nPAspIN  := 0
    Local nPAspFI  := 0
    Local nPPonto  := 0
    Local nPosFim  := 0

    If( Empty( cSql ) .Or. nPosCursor <= 0 .Or. !("SELECT" $ Upper( cSql ) ) )
        Return
    EndIf

    cRet += "Local cQuery  := ''" + CRLF
    cRet += "Local cAliTmp := GetNextAlias()" + CRLF + CRLF

    cSql := LimpaSql( cSql, nPosCursor )

    // Pega a estrutura do SQL para adicionar os campos Data e Numérico no TCSetField()
    If TCSQLEXEC( cSql ) == 0
        cTab := GetNextAlias()
        MPSysOpenQuery( cSql, cTab )
        aCposSel := (cTab)->(DBSTRUCT())
        (cTab)->( DbCloseArea() )
        cTab := ""
    Endif

    While !Empty( cSql )

        nPos := At( chr(10), cSql )
        If nPos > 0
            
            nPosFim := At( chr(13), cSql, nPos )
            If nPosFim > 0
                
                cTxt := SubStr( cSql, nPos+1, (nPosFim-nPos-1) )
                If !Empty( cTxt )

                    cTxt := Replace( cTxt, '"', "'" )

                    // Ajusta a Filial
                    nPFil := At( '_FILIAL', Upper(cTxt) )
                    If nPFil > 0 .And. nPFil < nPosFim
                        
                        cTab := ''
                        nPPonto := 0
                        nPEsp := 0

                        // Pega o espaço/parentese antes do Alias
                        For nPEsp := nPFil To nPos Step - 1
                            If SubStr( cTxt, nPEsp, 1 ) $ ' /('
                                Exit
                            EndIf
                            // Se tem ponto então tem ALIAS antes do nome do campo/coluna
                            If SubStr( cTxt, nPEsp, 1 ) == '.'
                                nPPonto := nPEsp
                            Endif
                        Next

                        If nPPonto > 0 .And. nPEsp > 0
                            cTab := SubStr( cTxt, nPEsp+1, (nPPonto-nPEsp-1) )
                            cTab := FWSX2Util():GetFile( cTab )
                        Endif

                        nPAspIN := At( "'", cTxt, nPFil ) // aspas simples após a posição da palavra '_FILIAL'
                        nPAspFI := At( "'", cTxt, nPAspIN+1 ) // aspas simpes que fecha a string da filial
                        
                        If( nPAspIN > 0 .And. nPAspFI > 0 .And. nPFil + 15 >= nPAspIN )
                            If Empty( cTab )
                                cTxt := Replace( cTxt, SubStr( cTxt, nPAspIN+1, (nPAspFI-nPAspIN-1) ), '" + xFilial( ?? ) + "' )
                            Else
                                cTxt := Replace( cTxt, SubStr( cTxt, nPAspIN+1, (nPAspFI-nPAspIN-1) ), '" + xFilial( "' + Left( cTab, 3 ) + '" ) + "' )
                            Endif
                        Endif
                    Endif

                    If ( At( '--', cTxt ) > 0 .Or. At( '/*', cTxt ) > 0 )
                        cRet += '//cQuery += "' + cTxt + ' "' + CRLF
                    Else
                        cRet += 'cQuery += "' + cTxt + ' "' + CRLF
                    EndIf
                EndIf

                // Retira o que já foi lido
                cSql := SubStr( cSql, nPosFim+1 )
            EndIf
        EndIf
        
        If nPos <= 0 .Or. nPosFim <= 0
            If Len( cSql ) > 0
                If At( cSql, cRet ) <= 0
                    cRet += 'cQuery += "' + cSql + '"' + CRLF
                Endif
                cSql := ''
            Endif
        Endif

        // Ajusta o nome da tabela
        nPos := At( cFirma+'0', cRet )
        If nPos > 0
            cTab := SubStr( cRet, nPos-3, 6 )
            cTab := FWSX2Util():GetFile( cTab )
            If !Empty( cTab )
                cRet := Replace( cRet, cTab, '" + RetSqlName( "' + Left(cTab,3) + '" ) + " ' )
            Endif
        Endif
    EndDo

    cRet +=  CRLF + 'DbUseArea(.T.,"TOPCONECT",TcGenQry(,,cQuery),cAliTmp,.F.,.F.)' + CRLF
    
    For nPos := 1 To Len( aCposSel )

        If AllTrim(aCposSel[ nPos, 1 ]) $ "R_E_C_N_O_/R_E_C_D_E_L_"
            Loop
        Endif

        If aCposSel[ nPos, 2 ] $ "D/N"
            lOk := .T.
        ElseIf aCposSel[ nPos, 3 ] == 8 // Campo pode ser Data mesmo vindo como C no DBSTRUCT()

            If FWSX3Util():GetFieldType( aCposSel[ nPos, 1 ] )  == "D"
                lOk := .T.
                aCposSel[ nPos, 2 ] := "D"
            EndIf
        EndIf

        If lOk
            cRet +=  'TCSetField( cAliTmp, "' + aCposSel[ nPos, 1 ] + '", "' + aCposSel[ nPos, 2 ] + '", ' + cValToChar(aCposSel[ nPos, 3 ]) + ', ' + cValToChar(aCposSel[ nPos, 4 ]) + ' )' + CRLF
            If aCposSel[ nPos, 2 ] == "N"
                cRet +=  '// c' + AllTrim( Replace( aCposSel[ nPos, 1 ], "_", "" ) ) + 'Picture := "' + AllTrim(X3Picture( aCposSel[ nPos, 1 ] )) + '"' + CRLF
            Endif
        Endif
        lOk := .F.
    Next

    cRet +=  'While (cAliTmp)->( !EOF() ) ' + CRLF+CRLF
    cRet +=  '   (cAliTmp)->( DbSkip() ) ' + CRLF
    cRet +=  'EndDo ' + CRLF
    cRet +=  '(cAliTmp)->( DbCloseArea() ) ' + CRLF

    CopytoClipboard( cRet )
    MsgInfo( "Comando copiado para a área de trabalho !!" +CRLF+CRLF+;
            "Antes de sair do Protheus, abra o código fonte e COLE no local desejado !!" )

Return




/*/{Protheus.doc} ExecSQL
Executar os comandos digitados
@type function
@version 12.1.27
@author Jorge Alberto
@since 01/04/2021
@param oPanelResultado, object, Painel com o resultado
@param cSql, character, Comando Sql que está na "tela"
@param cLogErro, character, Variável com o erro na execução
@param cTipo, character, Qual é o Título que deverá ser gerado
@param nPosCursor, numeric, Posição do cursos no momento da execução do comando Sql
/*/
Static Function ExecSQL(oPanelResultado, cSql, cLogErro, cTipo, nPosCursor )

    Local nQueryRet := 0 
    Local nX := 0
    Local nHdl := 0
    Local oFont := TFont():New( "Tahoma",0,-14,,.F.,0,,700,.F.,.F.,,,,,, )
    Local cTRB := ""
    Local cSqlDigit := cSql
    Local cErro := ""
    Local cCampo := ""
    Local cMensagem := ""
    Local cComandoSQL := UPPER( cSql )
    Local aHeaderEx := {}
    Local aColsEx := {}
    Local aFieldFill := {}
    Local aStru := {}
    Local aSQL := {}
    Local oMGMensagem

    If( Empty( cSql ) .Or. nPosCursor <= 0 )
        Return
    EndIf

    cSql := LimpaSql( cSql, nPosCursor )

    //*************************************************
    //Aqui está criando o MultiGet para as Mensagens 
    //*************************************************
    oMGMensagem := tMultiget():new(oSizeSup:GetDimension("MENSAGEM","LININI")+10/*Linha inicial*/,;
                oSizeSup:GetDimension("MENSAGEM","COLINI")+05/*Coluna inicial*/,;
                {| u | if( pCount() > 0, cMensagem := u, cMensagem )},oPanelMsg,;
                oSizeSup:GetDimension("MENSAGEM","XSIZE")-10/*Largura*/,;
                oSizeSup:GetDimension("MENSAGEM","YSIZE")-15/*Altura*/,oFont,,,,,.T./*lPixel*/,,,,,,.T./*lReadOnly*/,/*bValid*/,,,.T./*lNoBorder*/,.T./*lVScroll*/)

    If ( 'INSERT ' $ cComandoSQL .OR. 'UPDATE ' $ cComandoSQL .OR. ' INTO ' $ cComandoSQL )

        aSQL:= StrTokArr( strtran(cSql,CRLF," "), "#" ) // troca o ENTER por ESPAÇO para compatibilizar  e depois divide por instruções
        Processa({|| cErro := RunSql(aSQL)}," Processando Intruções SQL...")

        oMGMensagem:AppendText( "Comando executado " + IIF( Empty( cErro ), "sem", "com" ) + " erro !" )

        //********************************************************
        //Aqui está criando o MultiGet com OU sem erro do gerado
        //********************************************************
        tMultiget():new(oSize:GetDimension("INFERIOR","LININI")+10,; //nTop
                        oSize:GetDimension("INFERIOR","COLINI")+05,; //nLeft
                        {| u | if( pCount() > 0, cErro := u, cErro )},oPanelResultado,;
                        oSize:GetDimension("INFERIOR","XSIZE")-10,;//nLargura
                        oSize:GetDimension("INFERIOR","YSIZE")-15,;//nAltura
                        oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/)
    
    ElseIf 'SELECT ' $ cComandoSQL

        If TCSQLEXEC(cSql) < 0
            cErro := TCSQLError()
            //********************************************************
            //Aqui está criando o MultiGet com o erro do SQL gerado
            //********************************************************
            tMultiget():new(oSize:GetDimension("INFERIOR","LININI")+10,; //nTop
                            oSize:GetDimension("INFERIOR","COLINI")+05,; //nLeft
                            {| u | if( pCount() > 0, cErro := u, cErro )},oPanelResultado,;
                            oSize:GetDimension("INFERIOR","XSIZE")-10,;//nLargura
                            oSize:GetDimension("INFERIOR","YSIZE")-15,;//nAltura
                            oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/)
            cLogErro := cErro
            oMGMensagem:AppendText( "" )
        Else
            cLogErro := ""
            cTRB := GetNextAlias()

            // Função padrão que executa a consulta e carrega na tabela cTRB
            MPSysOpenQuery( cSql, cTRB )
            aStru := (cTRB)->(DBSTRUCT())

            For nX := 1 to Len(aStru)
                cCampo := aStru[nX][1]

                If cTipo == "Titulo"
                    cTitulo := AllTrim(FWX3Titulo(cCampo) )
                    If Empty(cTitulo)
                        cTitulo := cCampo
                    Endif
                Else
                    cTitulo := cCampo
                EndIf

                Aadd(aHeaderEx,{ cTitulo, cCampo, "", aStru[nX][3], aStru[nX][4], ".T.", ".T.", aStru[nX][2] , "", "", "", ""} )
            Next nX

            // Se não tem dados, cria uma linha vazia
            If (cTRB)->( EOF() )
                Aadd(aColsEx, Array( Len(aStru) ) )
            Else
                // Faz a Leitura dos dados
                While  !(cTRB)->(EOF())

                    For nX := 1 to Len(aStru)
                        cCampo := aStru[nX][1]
                        Aadd(aFieldFill,  &('(cTRB)->' + cCampo ))
                    Next nX
                    Aadd(aFieldFill, .F.) //Delete
                    
                    Aadd(aColsEx, aFieldFill)
                    aFieldFill := {}
                    nQueryRet++

                    (cTRB)->(DBSkip())
                Enddo
            EndIf
            (cTRB)->( DbCloseArea() )
            oMGMensagem:AppendText( "Consulta retornou " + cValToChar( nQueryRet ) + " registros." )

            //******************************************************
            //Aqui está criando o Grid com os resultados
            //******************************************************
            oGridResult := MsNewGetDados():New( oSize:GetDimension("INFERIOR","LININI")+10,; //nTop
                                                oSize:GetDimension("INFERIOR","COLINI")+05,; //nLeft
                                                oSize:GetDimension("INFERIOR","LINEND")-05,; //nBottom
                                                oSize:GetDimension("INFERIOR","COLEND")-05,; //nRight
                                                0,;	     		                            //nStyle // GD_INSERT+GD_DELETE+GD_UPDATE
                                                "AllwaysTrue()",;							//cLinhaOk
                                                ,;											//cTudoOk
                                                "",;										//cIniCpos
                                                ,;											//aAlter
                                                ,;											//nFreeze
                                                99,;										//nMax
                                                ,;											//cFieldOK
                                                ,;											//cSuperDel
                                                ,;											//cDelOk
                                                oPanelResultado,;					        //oWnd
                                                aHeaderEx,;								    //aHeader
                                                aColsEx)									//aCols
            oGridResult:nAt := 1
            oGridResult:oBrowse:nAt := 1
            oGridResult:Refresh()

        EndIf

    Else
        oMGMensagem:AppendText( "Comando não permitido !" )
    EndIf

    nHdl := 0
    nHdl := FCreate( cArqUser )
    
    If nHdl = -1
        Alert( " Erro na criação do arquivo " )
    Else
        FWrite( nHdl, cSqlDigit + CRLF)
        FClose( nHdl )
    EndIf

Return


/*/{Protheus.doc} RunSql
Função que efetivamente irá executar o Insert ou Update digitado
@type function
@version 12.1.27
@author Jorge Alberto
@since 01/04/2021
@param aSQL, array, Comandos a serem executados
@return character, Erro na execução do comando SQL
/*/
Static Function RunSql( aSQL )

    Local nX := 0
    Local nLenSQL := Len( aSql )
    Local cSqlEx := ""
    Local cErro := ""

    ProcRegua( nLenSQL )

    For nX:= 1 To nLenSQL
        IncProc("Processando Instrução " + alltrim(STR(nX)) + ' de ' + alltrim( STR( nLenSQL ) ) )

        cSqlEx := aSQL[nX]

        If TCSQLEXEC(cSqlEx) < 0
            lErro := .T.
            cErro += TCSQLError() + CRLF
        EndIf

    Next nX

Return( cErro )


/*/{Protheus.doc} LimpaSql
Pegar somente o comando SQL que deve ser executado
@type function
@version 12.1.27
@author Jorge Alberto
@since 01/04/2021
@param cSql, character, Comando SQL
@param nPosCursor, numeric, Posição do cursor no momento da chamada da execução
@return character, Comando SQL que será executado, ou seja, o que estive entre ;
/*/
Static Function LimpaSql( cSql, nPosCursor )

    Local nPosIni := 0
    Local nPosFim := 0

    // Localiza o ; apos a posição do cursor
    nPosFim := At( ";", cSql, nPosCursor )

    If nPosFim > 0

        // Pega todo o texto desde o inicio ate o ; apos a posição do cursor
        cSql := SubStr( cSql, 1, nPosFim-1 )

        // Pega a posicao do ULTIMO ; sendo que pode não existir
        nPosIni := RAt( ";", cSql ) + 1

    // Se não tem o ; apos o cursor, pega o ultimo ; localizado
    Else
        nPosIni := RAt( ";", cSql ) + 1
    EndIf

    If nPosIni > 0
        // Pega somente o que deve ser executado
        cSql := SubStr( cSql, nPosIni )
    EndIf

Return( cSql )


/*/{Protheus.doc} GeraExcel
Gerar um arquivo com os dados localizados e também com o comando SQL executado.
Sendo que irá gerar esse arquivo no formato .XLS quando tiver o Excel instalado, OU então cria um arquivo .CSV
@type function
@version 12.1.27
@author Jorge Alberto
@since 01/04/2021
@param cSql, character, Comando Sql
@param cLogErro, character, Log com o erro
@param nPosCursor, numeric, Posição do cursor no momento da chamada da rotina
/*/
Static Function GeraExcel( cSql, cLogErro, nPosCursor )

    Local nX, nY
    Local nHdr := 0
    Local nModo //Modo do Tipo do Campo| 1 = Modo Texto ou data | 2 = Valor sem R$ | 3 = Valor com R$
    Local aHeader := {}
    Local aCols:= {}
    Local aLinha
    Local aArea := {}
    Local cAba01
    Local cTitTabela01
    Local cAba02
    Local cTmp := ""
    Local cTitTabela02
    Local X_TIPO := 8
    Local X_TITULO := 1
    Local oFWMsExcel
    Local oExcel
    Local cTime := ""
    Local cArquivo := ""

    If !Empty( cLogErro )
        MsgInfo( "Não é possível gerar o excel com erro !")
        Return
    EndIf

    cSql := LimpaSql( cSql, nPosCursor )

    aHeader  := oGridResult:aHeader
    aCols    := oGridResult:aCols
    aArea    := GetArea()
    cTime    := time()
    cArquivo := GetTempPath()+'superqry-temp-' + SUBSTR(cTime,1,2) + "H" + SUBSTR(cTime,4,2) + '.xml'
    
    If ApOleClient("MSExcel")

        //Criando o objeto que irá gerar o conteúdo do Excel
        oFWMsExcel := FWMSExcel():New()
        oFWMsExcel:SetTitleBold(.T.) //Título Negrito

        //Aba 01 - Dados
        cAba01 := "Dados"
        cTitTabela01 := 'Dados da Consulta'
        oFWMsExcel:AddworkSheet(cAba01) //Não utilizar número junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
        oFWMsExcel:AddTable(cAba01,cTitTabela01)
        //Criando Colunas
        For nX := 1 to Len(aHeader)
            DO CASE
            CASE  aHeader[nx,X_TIPO] $ 'C'
                nModo := 1 //1 = Modo Texto
            CASE  aHeader[nx,X_TIPO] $ 'D'
                nModo := 1
            CASE  aHeader[nx,X_TIPO] $ 'N'
                nModo := 2 //2 = Valor sem R$ | 3 = Valor com R$
            OTHERWISE
                nModo := 1
            END CASE
            oFWMsExcel:AddColumn(cAba01,cTitTabela01,aHeader[nx,X_TITULO],nModo)
        Next nX
        //Criando as Linhas

        For nX := 1 to Len(aCols)
            aLinha := {}
            For nY := 1 to LEN(aCols[nX])
                AADD(aLinha, aCols[nX][nY])
            Next nY
            oFWMsExcel:AddRow(cAba01,cTitTabela01,aLinha)
        Next nX


        //Aba 02 - Sql
        cAba02 := "SQL"
        cTitTabela02 := 'Consulta SQL'

        oFWMsExcel:AddworkSheet(cAba02)
        //Criando a Tabela
        oFWMsExcel:AddTable(cAba02,cTitTabela02)
        oFWMsExcel:AddColumn(cAba02,cTitTabela02,"Consulta",1)

        //Criando as Linhas... Enquanto não for fim da query
        oFWMsExcel:AddRow(cAba02,cTitTabela02,{cSql})

        //Ativando o arquivo e gerando o xml
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cArquivo)

        //Abrindo o excel e abrindo o arquivo xml
        oExcel := MsExcel():New()       //Abre uma nova conexão com Excel
        oExcel:WorkBooks:Open(cArquivo) //Abre uma planilha
        oExcel:SetVisible(.T.)          //Visualiza a planilha
        oExcel:Destroy()                //Encerra o processo do gerenciador de tarefas
    
    Else// Não tem Excel instalado
        
        // Pega o nome do arquivo, mas sem a extensão XML para usar o CSV
        cArquivo := Left( cArquivo, Len(cArquivo)-3 ) + "csv"

        nHdr := FCreate( cArquivo )
        If nHdr <= 0
            MsgInfo( 'Não foi possível criar o arquivo "' + cArquivo + '"'+CRLF+'Verifique se o arquivo está em uso.')
        Else
            // Carrega o Cabeçalho das colunas
            For nX := 1 to Len(aHeader)
                cTmp += cValToChar( aHeader[ nX, 1 ] ) + ";"
            Next nX
            FWrite( nHdr, cTmp + CRLF )

            // Carrega os dados para gerar cada Linha
            For nX := 1 to Len(aCols)
            
                cTmp := ""
                For nY := 1 to LEN(aCols[nX])-1
                    cTmp += cValToChar( aCols[ nX, nY ] ) + ";"
                Next nY
                FWrite( nHdr, cTmp + CRLF )
            
            Next nX

            // No final gera uma linha com o SQL executado 
            fWrite( nHdr, strtran(cSql,CRLF," ") + CRLF)

            FClose( nHdr )
            ShellExecute("open", cArquivo, "", GetTempPath(), 1)
        EndIf
    EndIf

    RestArea(aArea)
Return


/*/{Protheus.doc} Mysend
Enviar o erro por e-mail 
@type function
@version 12.1.27
@author Jorge Alberto
@since 01/04/2021
@param cTxt, character, Texto com o erro
/*/
Static Function Mysend( cTxt )
    Local lEnvia := .F.
    Static oDlgLog
    Static oButton1
    Static oButton2
    Static oGet1
    Static cGet1 := ""
    Static oSay

    If Empty( cTxt )
        MsgInfo( "Não tem erro para enviar log !")
        Return
    EndIf

    cGet1 := PadR( AllTrim( UsrRetMail( RetCodUsr() ) ), 200 )

    DEFINE MSDIALOG oDlgLog TITLE "Envio de Log" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

    @ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlgLog PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
    @ 016, 015 SAY oSay PROMPT "Por favor, entre com seu email ABAIXO:" SIZE 100, 007 OF oDlgLog PICTURE "@!" COLORS 0, 12632256 PIXEL

    @ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlgLog ACTION {||lEnvia := .T.,oDlgLog:End()} PIXEL
    @ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlgLog ACTION oDlgLog:End()  PIXEL

    ACTIVATE MSDIALOG oDlgLog CENTERED

    If lEnvia
        CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

            If !lResult
                MsgBox('Erro no Envio')
                Return()
            EndIf

            cAccount := GETMV("MV_RELACNT")

            SEND MAIL FROM cAccount;
                TO cGet1;
                SUBJECT "Executar Query";
                BODY cTxt

        DISCONNECT SMTP SERVER

        MsgInfo("Email Enviado com Sucesso!")
    EndIf

Return
