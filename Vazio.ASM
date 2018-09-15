;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2016                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*			    PISCA-PISCA                            *
;*               SUANNY FABYNE DA SILVA VIEIRA                     *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		FLAG ;VARIAVEL Q SERÁ UTILIZADA PARA AUXILIAR NA INTERRUPÇAO
		CONTDELAY ;VARIAVEL AUXILIAR PARA FAZER DELAY DE MEIO SEGUNDO
		;NOVAS VARIÁVEIS

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;     GP0 COMO PISCA ALERTA (1 LIGA O PISCA ALERTA, 0 P/ DESLIGA)
;     GP1, (1 PARA PISCAR O LED DA ESQUERDA, 0 P/ DESLIGAR )
;     GP2, (1 PARA PISCAR O LED DA DIREITA, 0 P/ DESLIGAR )
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;   GP4 REPRESENTA O LED DA ESQUERDA E GP5 O DA DIREITA (1 LIGA O LED, 0 DESLIGA)
; 

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÁ ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES
	MOVLW B'000' 
	MOVWF FLAG ;INICALIZAÇAO DE FLAG COMO 000, O BIT MENOS SIGNIFICATIVO CORRESPONDE A GP0 (PISCAALERTA), O DO MEIO GP1 (ESQUERDA) E O MAIS SIGNIGICATIVO GP2 (DIREITA)
	BTFSC GPIO, GP0 ; SE O GP0, QUE ACIONA O PISCA ALERTA, FOR 1, SERÁ SETADA A FLAG QUE CORRESPONDE A MESMA
	GOTO PISCAALERTA
	BTFSC GPIO, GP1 ; SE O GP1, QUE ACIONA O LED ESQUERDO, FOR 1, SERÁ SETADA A FLAG QUE CORRESPONDE A MESMA
	GOTO PISCAGP4
	BTFSC GPIO, GP2 ; SE O GP2, QUE ACIONA O LED DIREITO, FOR 1, SERÁ SETADA A FLAG QUE CORRESPONDE A MESMA
	GOTO PISCAGP5 
	GOTO SAI_INT ;SE TIVER INTERRUPÇAO, MAS NEM GP0, GP1 OU GP2 TIVER EM 2, SAI DA INTERRUPÇAO COM FLAG ZERADA
PISCAALERTA
	MOVLW B'001' ;SETA O BIT DA FLAG CORRESPONDENTE AO GP0 ACESO (PISCA ALERTA)
	MOVWF FLAG
	GOTO SAI_INT
PISCAGP4
	MOVLW B'010' ;SETA O BIT DA FLAG CORRESPONDENTE AO GP1 ACESO (ESQUERDA)
	MOVWF FLAG
	GOTO SAI_INT
PISCAGP5
	MOVLW B'100' ;SETA O BIT DA FLAG CORRESPONDENTE AO GP2 ACESO (DIREITA)
	MOVWF FLAG
	GOTO SAI_INT

	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	BCF INTCON, 0 ;SETA O BIT 0 DO INTCON, PARA NAO FICARMOS SEMPRE EM LOOP NA INTERRUPÇAO, SEM SAIR
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

DELAYPISCA ;SUBROTINA REFERENTE AO DISPLAY
	MOVLW .8 ;TIMER0 CONTARÁ DE 10 ATÉ 256 8 VEZES, PARA OCORRER O DELAY DESEJADO DE MEIO SEGUNDO
	MOVWF CONTDELAY
	BCF INTCON, T0IF 
	MOVLW .10 ;INICIA COM 10, POIS (256-10)x256x8 = 500ms 
	MOVWF TMR0
TIMER
	BTFSS INTCON, T0IF
	GOTO TIMER
	GOTO CONTADOR
CONTADOR
	BCF INTCON, T0IF
	MOVLW .10
	MOVWF TMR0
	DECFSZ CONTDELAY ;REPETE A CONTAGEM DO TIMER0 8 VEZES, E APÓS ISSO, RETORNA
	GOTO TIMER
	RETURN
	

	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000111' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS) GP0, GP1 E GP2 COMO ENTRADA
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000111' ;USANDO ESCALA DE 256, E ALTERANDO O BIT 7 PARA DESABILITAR O GPIO PULL-UPS
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10001000'  ;SETA BIT 7 PARA HABILITAR ITERRUPÇOES, E BIT 3 PARA HABILITAR INTERRUPÇAO DO GPIO
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00000111' ;SETA BIT 0, 1 E 2 PARA OCORRER A INTERRUPÇAO AO MUDAR PORTAS GPO, GP1 E GP2
	MOVWF	IOC
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW B'000'
	MOVWF FLAG
	MOVLW .8
	MOVWF CONTDELAY
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN ;MODELO FEITO E TESTANDO EM PULL-DOWN
	BTFSC FLAG, 0 ;CONFERE SE O BIT 0 DA FLAG QUE CORRESPONDE AO GP0 EM 1 (OU PISCA ALERTA) ESTA DESLIGADO
	GOTO PISCAALERTAMAIN ;SE TIVER LIGADO, VAI PARA O PISCA ALERTA
	BTFSC FLAG, 1 ;CONFERE SE O BIT 1 DA FLAG QUE CORRESPONDE AO GP1 EM 1 (OU ESQUERDA) ESTA DESLIGADO
	GOTO PISCAGP4MAIN
	BTFSC FLAG, 2 ;CONFERE SE O BIT 2 DA FLAG QUE CORRESPONDE AO GP2 EM 1 (OU ESQUERDA) ESTA DESLIGADO
	GOTO PISCAGP5MAIN
	GOTO MAIN ;SE NENHUM BIT DA FLAG ESTIVER SETADO, OU SEJA, GP0 GP1 E GP1 TODOS EM 0. CONTINUA EM LOOP NO MAIN
PISCAALERTAMAIN	
	BSF GPIO, GP4 ;SETA AS PORTAS GP4 E GP5, CORRESPONDENTES AOS LEDS, PARA PISCAR OS LEDS COM FREQUENCIA DE 1 SEGUNDO
	BSF GPIO, GP5
	CALL DELAYPISCA ;DELAY DE MEIO SEGUNDO
	BCF GPIO, GP4
	BCF GPIO, GP5
	CALL DELAYPISCA 
	BTFSS FLAG,0 ;QUANDO VOLTAR DA INTERRUPÇAO, PRECISA DESSA CHECAGEM PARA CONFERIR SE A PORTA CORRESPONDENTE AO PISCAALERTA AINDA ESTÁ EM 1
	GOTO MAIN  ;SE A INTERRUPÇAO GERADA FEZ SAIR DO PISCAALERTA, ENTAO SAI DESSA LABEL E VOLTA PRO MAIN
	GOTO PISCAALERTAMAIN
PISCAGP4MAIN
	BSF GPIO, GP4
	CALL DELAYPISCA
	BCF GPIO, GP4
	CALL DELAYPISCA
	BTFSS FLAG,1 ;QUANDO VOLTAR DA INTERRUPÇAO, PRECISA DESSA CHECAGEM PARA CONFERIR SE A PORTA CORRESPONDENTE AO ESQUERDA AINDA ESTÁ EM 1
	GOTO MAIN ;SE A INTERRUPÇAO GERADA FEZ MUDAR A CHAVE QUE ATIVA O ESQUERDA, ENTAO VOLTA PRO MAIN
	GOTO PISCAGP4MAIN
PISCAGP5MAIN
	BSF GPIO, GP5
	CALL DELAYPISCA
	BCF GPIO, GP5
	CALL DELAYPISCA
	BTFSS FLAG,2 ;QUANDO VOLTAR DA INTERRUPÇAO, PRECISA DESSA CHECAGEM PARA CONFERIR SE A PORTA CORRESPONDENTE AO DIREITA AINDA ESTÁ EM 1
	GOTO MAIN ;SE A INTERRUPÇAO GERADA FEZ MUDAR A CHAVE QUE ATIVA O ESQUERDA, ENTAO VOLTA PRO MAIN
	GOTO PISCAGP5MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END