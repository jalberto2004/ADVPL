#INCLUDE "TOTVS.CH"
#INCLUDE "tbiconn.ch"

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Programa  | TRANSARQ | Autor | Jorge Alberto         | Data |05/04/2005 ||
||-------------------------------------------------------------------------||
|| Descricao | Transferencia de Arquivos entre o Terminal e o Servidor     ||
||-------------------------------------------------------------------------||
|| Sintaxe   | u_TRANSARQ()                                                ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |  														   ||
||-------------------------------------------------------------------------||
||  Uso      | Especifico                                                  ||
||-------------------------------------------------------------------------||
||                           ULTIMAS ALTERACOES                            ||
||-------------------------------------------------------------------------||
|| Programador |  Data  | Motivo da Alteracao                              ||
||-------------------------------------------------------------------------||
||             |        |                                                  ||
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/ 
User Function TRANSARQ()

	Local cUsuPer := ""
	Local oBtnT, oBtnSTT, oBtnS, oBtnSTS, oBtnCS, oBtnCL, oBtnEx, oBtnRe, oBtnSa, oBtnOp
	Local cBlockHead, bBlockHead
	Private cFiltroC, cFiltroD
	Private oFiltroC, oFiltroD
	Private oOk  	  := Loadbitmap(GetResources(), 'LBOK')
	Private oNo   	  := Loadbitmap(GetResources(), 'LBNO')
	Private aListC    := {}
	Private aListCBkp := {}
	Private aListD    := {}
	Private aListDBkp := {}
	Private cOrigem   := "C:\temp\"
	Private cDestino  := "\"
	Private oDlg,oList1,oList2
	Private cDirAtu  :=  Upper( Trim( CurDir() ) )

	If Type( "oMainWnd" ) == "U" // Se foi chamado pela tela inicial, crio uma tela aqui
		DEFINE MSDIALOG oMainWnd PIXEL FROM 0,0 TO 400,600
	Else
		cUsuPer := AllTrim( SuperGetMV( 'ES_PERTRAR',,'admin_administrador') )

		If ( Empty( cUsuPer ) .Or. ! ( AllTrim( Upper( UsrRetName( RetCodUsr() ) ) ) $ AllTrim( Upper( cUsuPer ) ) ) )
			MsgAlert( 'Usuário sem permissão de acesso a rotina !', 'Parâmetro ES_PERTRAR' )
			Return
		EndIf
	EndIf

	If Right(cDirAtu,1) $ "\/"
		cDirAtu := SubStr(cDirAtu,1, Len(cDirAtu) -1 )
		If Right(cDirAtu,1) $ "\/"
			cDirAtu := SubStr(cDirAtu,1, Len(cDirAtu) -1 )
		EndIf
	EndIf
	cDestino += cDirAtu + "\"



	AtuList( 3 )

	Define MsDialog oDlg From 000,000 To 530,1080 Title "Transferencia de Arquivos" Of oMainWnd Pixel

	oBtnT   := tButton():New(010,005,'Terminal' ,oDlg,{|| AtuOrig(1) },35,15,,,,.T.)
	oBtnSTT := tButton():New(010,045,'Selec. Todos' ,oDlg,{|| Selec(1) },35,15,,,,.T.)

	oBtnS   := tButton():New(010,295,'Servidor' ,oDlg,{|| AtuOrig(2) },35,15,,,,.T.)
	oBtnSTS := tButton():New(010,335,'Selec. Todos' ,oDlg,{|| Selec(2) },35,15,,,,.T.)

	cFiltroC := Space(30)
	@013,170 Say "Filtro:"  Size 20,10 OF oDlg PIXEL
	oFiltroC := TGet():New(012, 190,{|u| If(PCount()>0,cFiltroC:=u,cFiltroC) },oDlg,050,008,'',{|| Filtra( @aListC, cFiltroC, "C" ), oList1:SetFocus() },,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

	cFiltroD := Space(30)
	@013,460 Say "Filtro:"  Size 20,10 OF oDlg PIXEL
	oFiltroD := TGet():New(012, 480,{|u| If(PCount()>0,cFiltroD:=u,cFiltroD) },oDlg,050,008,'',{|| Filtra( @aListD, cFiltroD, "D" ), oList2:SetFocus() },,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

	@030,005 Say cOrigem  Size 190,10 OF oDlg PIXEL
	@030,295 Say cDestino Size 245,10 OF oDlg PIXEL

	@040,005 ListBox oList1 Fields HEADERS '  ','Arquivo','Tamanho','Data','Hora' Size 240,220 Pixel Of oDlg ;
	On dblClick(aListC := SDTroca2(oList1:nAt,aListC) , oList1:Refresh() )

	@040,295 ListBox oList2 Fields HEADERS '  ','Arquivo','Tamanho','Data','Hora' Size 240,220 Pixel Of oDlg ;
	On dblClick(aListD := SDTroca2(oList2:nAt,aListD) , oList2:Refresh() )

	oList1:SetArray(aListC)
	If Len( aListC ) > 0
		oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),DtoC(aListC[oList1:nAt,4]), aListC[oList1:nAt,5] } }
	EndIf
	oList1:bHeaderClick := {|u| OrdDados(oList1:ColPos,aListC,oList1) }
	oList1:Refresh()

	oList2:SetArray(aListD)
	If Len( aListD ) > 0
		oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),DtoC(aListD[oList2:nAt,4]), aListD[oList2:nAt,5] } }
	EndIf
	oList2:bHeaderClick := {|| OrdDados(oList2:ColPos,aListD,oList2) }
	oList2:Refresh()

	oBtnCS := tButton():New(040,253,' ---> ' ,oDlg,{|| AtuCopia(1)}   ,35,20,,,,.T.)
	oBtnCL := tButton():New(070,253,' <--- ' ,oDlg,{|| AtuCopia(2)}   ,35,20,,,,.T.)
	oBtnOp := tButton():New(150,253,'Abrir'  ,oDlg,{|| Abrir()}       ,35,20,,,,.T.)
	oBtnEx := tButton():New(180,253,'Excluir',oDlg,{|| Excluir() }    ,35,20,,,,.T.)
	oBtnRe := tButton():New(210,253,'Refresh',oDlg,{|| AtuTela() }    ,35,20,,,,.T.)
	oBtnSa := tButton():New(240,253,'Sair'   ,oDlg,{|| oDlg:End()}    ,35,20,,,,.T.)

	Activate MsDialog oDlg Centered

Return


Static Function OrdDados( nCol, aLista, oLista )

	oLista:ColPos := nCol
	aSort( aLista,,,{ |x,y| x[nCol] < y[nCol] } )
	oLista:SetFocus()
	oLista:Refresh()

Return


Static Function AtuList( nTipo )

	Local nI, aListM, aListN

	If nTipo == 1 .Or. nTipo == 3
		aListC := {}
		aListM := Directory(cOrigem + "*.*")
		For nI := 1 To Len(aListM)
			aAdd( aListC , { .f. , aListM[nI,1], aListM[nI,2], aListM[nI,3], aListM[nI,4] } )
		Next
		aSort(aListC,,,{|X,Y| X[2] < Y[2] })
		aListCBkp := aClone( aListC )

	EndIf

	If nTipo == 2 .Or. nTipo == 3

		aListD := {}
		aListN := Directory( cDestino + "*.*")
		For nI := 1 To Len(aListN)
			aAdd( aListD , { .f. , aListN[nI,1], aListN[nI,2], aListN[nI,3], aListN[nI,4] } )
		Next
		aSort(aListD,,,{|X,Y| X[2] < Y[2] })
		aListDBkp := aClone( aListD )

	EndIf

Return


Static Function AtuOrig(nTipo)

	Local cOrgBkp  := cOrigem
	Local cDestBkp := cDestino

	If nTipo == 1
		cOrigem  := cGetFile("","Selecione o Destino ...",0,"",.F.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_OVERWRITEPROMPT)

		If Empty(cOrigem )
			cOrigem  := cOrgBkp
		Else
			AtuList(1) //Origem

			oList1:SetArray(aListC)
			If Len( aListC ) > 0
				oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),aListC[oList1:nAt,4], aListC[oList1:nAt,5] } }
			EndIf
			oList1:Refresh()

			oFiltroC:cText(Space(30))
			oFiltroC:Refresh()

		EndIf

	ElseIf nTipo == 2
		cDestino := cGetFile("","Selecione o Destino ...",0,"",.F.,GETF_RETDIRECTORY+GETF_OVERWRITEPROMPT, .T.)

		If Empty(cDestino)
			cDestino := cDestBkp
		Else
			AtuList(2) //Destino

			oList2:SetArray(aListD)
			If Len( aListD ) > 0
				oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),aListD[oList2:nAt,4], aListD[oList2:nAt,5] } }
			EndIf
			oList2:Refresh()

			oFiltroD:cText(Space(30))
			oFiltroD:Refresh()
		EndIf
	EndIf
	oDlg:Refresh()

Return(.T.)


Static Function Excluir()

	local nn,pp

	local aCopia := aClone(aListC)
	local cVar   := Lower(cOrigem)


	if !MsgYesNo("A operacao excluira todos os arquivos selecionados. Tanto no Terminal, quanto no Servidor. CONFIRMA?")
		oDlg:Refresh()
		return
	endif

	pp := 0
	for nn := 1 to len(aCopia)
		if aCopia[nn,1]
			FERASE(cVar + Lower(aCopia[nn,2]))
			pp++
		endif
	next nn

	aCopia := aClone(aListD)
	cVar  := Lower(cDestino)
	for nn := 1 to len(aCopia)
		if aCopia[nn,1]
			FERASE(cVar + Lower(aCopia[nn,2]))
			pp++
		endif
	next nn

	MsgAlert("Excluidos " + cValToChar(pp) + " arquivos.")

	AtuList(1) //Origem

	oList1:SetArray(aListC)
	If Len( aListC ) > 0
		oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),aListC[oList1:nAt,4], aListC[oList1:nAt,5] } }
	EndIf
	oList1:Refresh()

	AtuList(2)// Destino

	oList2:SetArray(aListD)
	If Len( aListD ) > 0
		oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),aListD[oList2:nAt,4], aListD[oList2:nAt,5] } }
	EndIf
	oList2:Refresh()

	oDlg:Refresh()

Return

Static Function AtuCopia(nTipo)

	Local cVar   := ""
	Local cVar3  := ""
	Local aCopia := {}

	If nTipo == 1    //Terminal para o Servidor
		aCopia := aClone(aListC)
		cVar   := Lower(cOrigem)
		cVar3  := Lower(cDestino)
	Else
		//Servidor para o Terminal
		aCopia := aClone(aListD)
		cVar  := Lower(cDestino)
		cVar3 := Lower(cOrigem)
	EndIf

	Processa({|| ContCopia( aCopia, cVar, cVar3, nTipo ) }, 'Copiando... Aguarde...','Aguarde...')

	AtuTela()

Return(.t.)



Static Function ContCopia(aCopia,cVar,cVar3,nTipo)

	Local nI
	Local cVar2 := ""
	Local cIncProc := ""
	Local lSucess := .F.
	Local nAcopia := Len(aCopia)
	Local aFiles := {}
	Local nJ := 0
	Local nK := 0
	Local nN := 0
	Local cMsg2 := "* TRANSARQ *"

	cMsg2	+= iif(nTipo <> 2,"TERMINAL => SERVIDOR","SERVIDOR => TERMINAL")
	cMsg2	:= Substr(cMsg2 + " " + REPLICATE("*",80), 1, 80)

	For nI:=1 to nAcopia
		If aCopia[nI,1]
			aadd(aFiles,{ nI , alltrim(upper(aCopia[nI,2])), " "} )
			nJ++
		EndIf
	Next
	nN := LEN(aFiles)
	/*
	cMsg1	:= (" ")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= cMsg2
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" Computador=[" + cRemoteComputer + "]")
	cMsg1	+= (" IP=[" + cRemoteip + "]")
	cMsg1	+= (" Thread=[" + cThread + "]")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" Origem =[" + alltrim(cVar) + "]")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" Destino=[" + alltrim(cVar3) + "]")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" Inicio da Copia em [" + dtoc(date()) + " " + time() + "].")
	If nJ >= 1
		cMsg1	+= ( " Copiar " + alltrim(str(nj,10,0)) + iif(nJ <= 1, " arquivo selecionado"," arquivos selecionados") +".")
	Else
		cMsg1	+= (" ? ")
	Endif
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" Arquivos:")
	For nI:=1 To nN
		cMsg1	+= IIF(nI==1," "," ; ") + ALLTRIM(aFiles[nI,2])
	Next
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= ("******************************************************************************")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" ")
	cMsg1	+= chr(13)+chr(10)
	//Conout(cMsg1)
	*/
	ProcRegua( naCopia )

	For nI := 1 To naCopia

		cVar2 := Lower(aCopia[nI,2])   //Nome do Arquivo a ser copiado.

		cIncProc := If( aCopia[nI,1] , 'Copiando arquivo: ' + Trim(cVar2) , "" )
		IncProc( cIncProc )

		If aCopia[nI,1] //Esta marcado, entao copia

			If nTipo == 2  //  Servidor para Remote
				lSucess := CpyS2T( cVar + cVar2 , cVar3 , .T. )
			Else   //  Remote para Sevidor
				lSucess := CpyT2S( cVar + cVar2 , cVar3 , .T. )
			EndIf
			If lSucess
				nN	:= ascan(aFiles,{|aVal| aVal[1] == nI})
				aFiles[nN,3] := "*"
				nK++
			Else
				MsgInfo( "Não foi possível copiar o arquivo " + AllTrim(cVar2) + " pois ele está em uso !", "Arquivo em uso" )
			Endif
		EndIf
	Next
	/*
	cMsg1	:= (" ")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= cMsg2
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" Computador=[" + cRemoteComputer + "]")
	cMsg1	+= (" IP=[" + cRemoteip + "]")
	cMsg1	+= (" Thread=[" + cThread + "]")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" Origem=[" + alltrim(cVar) + "]")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" Destino=[" + alltrim(cVar3) + "]")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" Termino da Copia em [" + dtoc(date()) + " " + time() + " Hr].")
	cMsg1	+= chr(13)+chr(10)
	If nK == 1
		cMsg1	+= (" Foi copiado 1 arquivo")
	ElseIf nK > 1
		cMsg1	+= (" Foram copiados " + alltrim(str(nK,10,0) ) + " arquivos " )
	Else
		cMsg1	+= (" Nenhum arquivo foi copiado")
	Endif

	If nJ == 1
		cMsg1	+= (" de 1 arquivo selecionado." )
	ElseIf nJ > 1
		cMsg1	+= (" de " + alltrim( str(nj,10,0) )  + " arquivos selecionados")
	Else
		cMsg1	+= (".")
	Endif

	cMsg1	+= chr(13)+chr(10)

	If nK == 1
		cMsg1	+= (" Arquivo copiado:")
	ElseIf nK > 1
		cMsg1	+= (" Arquivos copiados:")
	Else
		cMsg1	+= ("?")
		cMsg1	+= chr(13)+chr(10)
	Endif

	If nK >= 1
		For nI:=1 to nJ
			If aFiles[nI,3] <> " "
				cMsg1	+= ( iif(nI=1," "," ; ") + upper(alltrim(aFiles[nI,2])) )
			Endif
		Next
		cMsg1	+= chr(13)+chr(10)
	Endif

	If nJ >= 1 .and. nJ <> nK
		If (nJ - nk) == 1
			cMsg1	+= (" 1 Arquivo nao copiado:")
		Else
			cMsg1	+= (" " + alltrim(str((nJ - nk),10,0)) + " Arquivos nao copiados:")
		Endif
		For nI:=1 to nJ
			If aFiles[nI,3] == " "
				cMsg1	+= ( iif(nI=1," "," ; ") + upper(alltrim(aFiles[nI,2])) )
			EndIf
		Next
		cMsg1	+= chr(13)+chr(10)

	Endif
	cMsg1	+= ("******************************************************************************")
	cMsg1	+= chr(13)+chr(10)
	cMsg1	+= (" ")
	cMsg1	+= chr(13)+chr(10)

	//Conout(cMsg1)
	*/
Return


Static Function AtuTela()

	AtuList(1) //Origem

	oList1:SetArray(aListC)
	If Len( aListC ) > 0
		oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),aListC[oList1:nAt,4], aListC[oList1:nAt,5] } }
	EndIf
	oList1:Refresh()

	Filtra( aListC, cFiltroC, "C" )


	AtuList(2) //Destino

	oList2:SetArray(aListD)
	If Len( aListD ) > 0
		oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),aListD[oList2:nAt,4], aListD[oList2:nAt,5] } }
	EndIf
	oList2:Refresh()

	Filtra( aListD, cFiltroD, "D" )

	oDlg:Refresh()

Return()


Static Function Selec(nTipo)

	If nTipo == 1
		aListC := SDTroca(aListC)
		oList1:Refresh()
	Else
		aListD := SDTroca(aListD)
		oList2:Refresh()
	EndIf
	oDlg:Refresh()

Return


Static Function SDTroca(aVetor)

	Local nI
	For nI := 1 To Len(aVetor)
		aVetor[nI,1] := !aVetor[nI,1]
	Next
Return(aVetor)


Static Function SDTroca2(nIt,aVetor)

	If Len( aVetor ) > 0
		aVetor[nIt,1] := !aVetor[nIt,1]
	EndIf

Return(aVetor)


Static Function Filtra( aDados, cFiltro, cTipo )

	Local nI, aNewDados
	Default cTipo := "C"

	aNewDados := {}

	If "C" $ cTipo

		AtuList( 1 ) // Chama a rotina para ler os arquivos do último diretório informado.
		If !Empty( cFiltro )

			For nI := 1 To Len( aDados )
				// Filtra o que o usuário digitou na tela com o que está no array aDados que é o que está na tela
				If Upper( AllTrim( cFiltro ) ) $ Upper( AllTrim( aDados[ nI, 2 ] ) )
					AADD( aNewDados, { aDados[nI,1], aDados[nI,2], Transform(aDados[nI,3],"999,999,999,999"), aDados[nI,4], aDados[nI,5] } )
				EndIf
			Next

			aListC := {}
			aListC := aClone( aNewDados )
		EndIf

		oList1:nAt := 1
		oList1:SetArray(aListC)
		If Len( aListC ) > 0
			oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),aListC[oList1:nAt,4], aListC[oList1:nAt,5] } }
		EndIf
		oList1:Refresh()
		oDlg:Refresh()

	EndIf

	If "D" $ cTipo

		AtuList( 2 ) // Chama a rotina para ler os arquivos do último diretório informado.
		If !Empty( cFiltro )

			For nI := 1 To Len( aDados )
				// Filtra o que o usuário digitou na tela com o que está no array aDados que é o que está na tela
				If Upper( AllTrim( cFiltro ) ) $ Upper( AllTrim( aDados[ nI, 2 ] ) )
					AADD( aNewDados, { aDados[nI,1], aDados[nI,2], Transform(aDados[nI,3],"999,999,999,999"), aDados[nI,4], aDados[nI,5] } )
				EndIf
			Next

			aListD := {}
			aListD := aClone( aNewDados )
		EndIf

		oList2:nAt := 1
		oList2:SetArray(aListD)
		If Len( aListD ) > 0
			oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),aListD[oList2:nAt,4], aListD[oList2:nAt,5] } }
		EndIf
		oList2:Refresh()
		oDlg:Refresh()

	EndIf

Return



Static Function Abrir()

	Local nMarcado := 0
	Local nI := 0

	For nI := 1 To Len( aListC )
		If aListC[ nI, 1]
			nMarcado := nMarcado + 1
			ShellExecute( "open", cOrigem + AllTrim( aListC[nI,2] ), "/open", "", 1 )
			aListC[ nI, 1] := !aListC[ nI, 1] // Inverte a seleção do arquivo aberto.
		EndIf
	Next

	If nMarcado == 0
		MsgInfo( "No TERMINAL não foi marcado nenhum arquivo para que possa ser aberto." )
	EndIf

Return
