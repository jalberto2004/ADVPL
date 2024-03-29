SELECT USR.USR_ID, USR.USR_CODIGO, USR.USR_NOME, CASE USR.USR_MSBLQL WHEN '1' THEN 'Sim' ELSE 'N�o' END BLOQUEADO, USR.USR_EMAIL
	 , RTRIM(MMENU.M_MODULE)+' - '+USRMNU.USR_CODMOD AS MODULO, PAI.N_DESC AS MENU
     , CASE WHEN RTRIM(MFUNC.F_FUNCTION) IS NULL THEN RTRIM(PAI.N_DESC)+' > > > '+RTRIM(FILHO.N_DESC) ELSE RTRIM(FILHO.N_DESC) + ' ( ' + RTRIM(MFUNC.F_FUNCTION) + ' )' END OPCAO
	 , MMENU.M_NAME AS ARQ_MENU, MMENU.M_ARQMENU AS CAMINHO
	 , USRMNU.USR_ARQMENU
	 , MITEM.*
FROM SYS_USR USR ( NOLOCK )
INNER JOIN SYS_USR_MODULE USRMNU ( NOLOCK ) ON ( USR.USR_ID = USRMNU.USR_ID AND USRMNU.D_E_L_E_T_ = ' ' AND USRMNU.USR_ACESSO = 'T' /*com acesso ao M�dulo*/ )
INNER JOIN MPMENU_MENU MMENU ( NOLOCK ) ON ( USRMNU.USR_ARQMENU = MMENU.M_ID AND MMENU.D_E_L_E_T_ = ' ' AND MMENU.M_NAME NOT LIKE '#' /*n�o � backup*/ )
INNER JOIN MPMENU_ITEM MITEM ( NOLOCK ) ON ( MMENU.M_ID = MITEM.I_ID_MENU AND MITEM.D_E_L_E_T_ = ' ' )
INNER JOIN MPMENU_I18N PAI ( NOLOCK ) ON ( MITEM.I_FATHER = PAI.N_PAREN_ID AND PAI.D_E_L_E_T_ = ' ' AND PAI.N_LANG = '1' AND PAI.N_PAREN_TP <> '1')
INNER JOIN MPMENU_I18N FILHO ( NOLOCK ) ON ( MITEM.I_ID = FILHO.N_PAREN_ID AND FILHO.D_E_L_E_T_ = ' ' AND FILHO.N_LANG = '1' AND FILHO.N_PAREN_TP <> '1' )
LEFT OUTER JOIN MPMENU_FUNCTION ( NOLOCK ) MFUNC ON ( MITEM.I_ID_FUNC = MFUNC.F_ID AND MFUNC.D_E_L_E_T_ = ' ' )
WHERE USR.D_E_L_E_T_ = ' '
AND UPPER( USR.USR_CODIGO ) LIKE ( 'JORGE%' )
AND UPPER( MFUNC.F_FUNCTION ) LIKE ( 'MATA%' )
AND TRIM( MMENU.M_NAME ) = 'SIGAFATPERSONALIZADO'
AND UPPER( MMENU.M_NAME ) = 'SIGAFAT'
ORDER BY USR.USR_CODIGO, MMENU.M_MODULE,  MITEM.I_ORDER