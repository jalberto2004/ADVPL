SELECT CASE C.CV8_FILIAL
     , CASE C.CV8_PROC 
     WHEN 'ATFA370        ' THEN 'ATFA370 - Contab. Off-Line'           WHEN 'CTBA170        ' THEN 'CTBA170 - Valida Plano Contas'     
     WHEN 'CTBA190        ' THEN 'CTBA190 - Recalculo Saldos'           WHEN 'CTBA215        ' THEN 'CTBA215 - Estorno Apuração Lucros/Perdas'
     WHEN 'CTBA280        ' THEN 'CTBA280 - Rateio Off-Line'            WHEN 'CTBA281        ' THEN 'CTBA281 - Rateio Off-Line Comb.'
     WHEN 'CTBA360        ' THEN 'CTBA360 - Saldos Compostos'           WHEN 'CTBANFE        ' THEN 'CTBANFE - Lancto Contab. Doc Entrada'
     WHEN 'CTBANFS        ' THEN 'CTBANFS - Lancto Contab. Doc Saida'   WHEN 'FA376GERA      ' THEN 'FA376GERA'
     WHEN 'FINA150        ' THEN 'FINA150 - Arquivo Cobrança'           WHEN 'FINA360        ' THEN 'FINA360 - Refaz Acumulados'
     WHEN 'FINA370        ' THEN 'FINA370 - Contab. Off-Line'           WHEN 'FINA401        ' THEN 'FINA401 - Gera dados p/ DIRF'
     WHEN 'FINA430        ' THEN 'FINA430 - Retorno Pagamentos'         WHEN 'FINA440        ' THEN 'FINA440 - Recalc. Comissoes Off-Line'
     WHEN 'MATA280        ' THEN 'MATA280 - Virada Saldos'              WHEN 'MATA300        ' THEN 'MATA300 - Saldo Atual'
     WHEN 'MATA330        ' THEN 'MATA330 - Custo Medio'                WHEN 'MATA331        ' THEN 'MATA331 - Contabilização Custo Medio'
     WHEN 'MATR460        ' THEN 'MATR460 - Rel. Regis. Inven. Mod7'    WHEN 'MATR470        ' THEN 'MATR470 - Rel. Kardex Mod 3'
     WHEN 'QIPUPDAT       ' THEN 'QIPUPDAT'
     ELSE C.CV8_PROC|| ' - Nao identificado'
     END PROCESSO
     , C.CV8_DATA
     , C.CV8_HORA
     , C.CV8_MSG MENSAGEM
     , C.CV8_USER USUARIO
     , C.CV8_DET DETALHES
FROM   PROTHEUS.CV8010 C
WHERE  C.D_E_L_E_T_ = ' '
AND    C.CV8_PROC = ''
AND    C.CV8_DATA >= ''
ORDER BY C.CV8_PROC, C.CV8_DATA, C.CV8_HORA
;
