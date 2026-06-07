jmp main

; Variáveis 

; Endereço das palavras e palavras 
palavra0: string "livro"
palavra1: string "pisca"

; Banco de palavras 
palavras: var #2
    static palavras + #0, #palavra0
    static palavras + #1, #palavra1
  
; Palavra digitada

Resultado: var #6
    static Resultado + #0, #0
    static Resultado + #1, #0
    static Resultado + #2, #0
    static Resultado + #3, #0
    static Resultado + #4, #0
    static Resultado + #5, #0


pontResultado: var #1

FlagIguais: var #5

restart: var #1

main:
    loadn r1, #tela4Linha0      ;Endereco onde comeca a primeira linha do cenario
    loadn r2, #30720       ;cor cinza
    call ImprimeTela

    loadn r2, #0                ;inicializa o contador com 0 

    Loopmenu:
        inchar r4
        loadn r1, #13           ;tecla enter
        
        inc r2                  ;faz a soma aleatória para dar o rand

        cmp r4, r1
        jne Loopmenu

        loadn r5, #2           ;limita o valor para ficar entre 0 e 1
        mod r3, r2, r5

        loadn r0, #palavras
        add r0, r0, r3
        loadi r1, r0        ; pega endereço da palavra
        
        store restart, r1 ; tive que criar essa variável para fazer o restart funcionar e não alterar a lógica do código
        
    
    Restart:    
        call ApagaTela  

        load r7, restart ; guarda em r7 o endereço da palavra (NÃO USAR O R7)
        
        loadn r0, #444      ; posição na tela
        loadn r3, #0 ; vai funcionar meio que como um contador para o jogo
        loadn r4, #40 ; para ir para a linha de baixo
        
        Loopmain:
            call Zera
        
            mov r5, r0 ; deixa o endereço da primeira palavra a ser printada na tela "usável" na função jogo
            
            call Jogo
            
            ; Imprime o Resultado

            loadn r1, #Resultado
            ; r0 já tem o endereço da primeira letra      
            loadn r2, #0         ; cor

            call ImprimeStr
            
            call Ganha ; função para ver se a pessoa ganhou o jogo
            
            add r0, r0, r4 ; atualiza o endereço da primeira letra para ir na linha debaixo  
            
            inc r3
            
            loadn r1, #5 ; critério de parada
            cmp r1, r3
            jne Loopmain
            
            call Fracassou
        
        
;--------------------------------------------
;          ZERA PONTEIROS E FLAGS
;-------------------------------------------- 
Zera:
    push r0
    push r1
    push r2
    push r3
    
        loadn r0, #0 
        store pontResultado, r0
        
        loadn r1, #0 ; contador
        loadn r2, #5 ; critério de parada
        loadn r3, #FlagIguais ; endereço da primeira FlagIguais
        
        LoopFlag:
            storei r3, r0
            
            inc r3
            inc r1
            
            cmp r1, r2
            jne LoopFlag
            
    pop r3
    pop r2
    pop r1    
    pop r0
    
    rts
;--------------------------------------------
;                  JOGO
;--------------------------------------------
Jogo:
    push r0
    push r1
    push r2
    push r6

        loadn r6, #0 ; NÃO MEXER NO R6

        LoopJogo:
            ; r0 == letra que a pessoa digitar
            inchar r0 ; esperar a pessoa digitar
            mov r1, r5 ; copia o enderço da primeira letra a ser digitada e impressa no 
            add r1, r1, r6 ; avança para imprimir a letra no lado 
            outchar r0, r1
            
            loadn r1, #255 ; A pessoa não escreveu nada
            cmp r1, r0
            jeq LoopJogo
        
        call Compara

        inc r6

        loadn r1, #5 ; critério de parada
        cmp r6, r1
        jne LoopJogo


    pop r6
    pop r2
    pop r1
    pop r0
    rts

;--------------------------------------------
;                Compara
;--------------------------------------------
Compara:
    ; r0 tem a letra digitada
    ; r7 tem o endereço 0 da nossa palavra
    ; r6 posição da minha letra digitada
    push r1
    push r2
    push r3
    push r4
    push r5

    loadn r3, #0
            
    LoopCompara:
        mov r2, r7 ; r2 tem o endereço da primeira letra da palavra-alvo para a gente poder ir mudando
        add r2, r2, r3 ; atualiza o endereço

        loadi r1, r2   ; r1 tem a primeira letra da
        cmp r1, r0 ; se a letra digitada for uma das letras da palavra-alvo, então
        jeq Continua 
        
        inc r3 ; atualiza o ponteiro

        loadn r5, #5 ; critério de parada para o loop

        cmp r3, r5
        jne LoopCompara

    load r4, pontResultado ; ponteiro do resultado
    loadn r5, #Resultado ; endereço do vetor Resultado
    add r5, r4, r5 ; endereço das Resultado[pontResultado]

    loadn r3, #256 ; cor vermelha
    add r0, r0, r3 ; a letra errada ficou vermelha
    
    storei r5, r0 ; guarda a letra no Resultado[pontResultado]
    
    jmp RtsCompara

    Continua:
        ; r6 tem a "posição da letra digitada"
        cmp r3, r6 ; compara se as posições das letras da palavra são iguais
        jeq Iguais
        
        load r4, pontResultado ; ponteiro das Resultado
        loadn r5, #Resultado ; endereço do vetor Resultado
        add r5, r4, r5 ; endereço das Resultado[pontResultado]

        loadn r3, #1024 ; cor azul escuro
        add r0, r0, r3 ; a letra na posição errada ficou azul escuro
        storei r5, r0 ; guarda a letra no Resultado[pontResultado]
        
        jmp RtsCompara
        
        Iguais:
            load r4, pontResultado ; ponteiro das Resultado
            loadn r5, #Resultado ; endereço do vetor Resultado
            add r5, r4, r5 ; endereço das Resultado[pontResultado]

            loadn r3, #7168 ; cor azul claro
            add r0, r0, r3 ; a letra igual ficou azul claro
            storei r5, r0 ; guarda a letra no Resultado[pontResultado]
            
            ; como já terminou tudo o que tinha com essa letra
            ; posso mexer em tudo menos, r4 (valor do ponteiro atual) , r6 (posição de letra digitada) , r7 (endereço palavra-alvo)
            ; ligo a flag que nessa palavra, a pessoa acertou a posição e letra
            
            loadn r1, #FlagIguais
            add r1, r6, r1 ; endereço do FlagIguais[r6]
            loadn r2, #1 ; ligar a flag para conferir se a pessoa ganha
            storei r1, r2; flag ligada!

            jmp RtsCompara

    RtsCompara:                
        inc r4 ; atualiza o ponteiro
        loadn r5, #pontResultado
        storei r5, r4 ; guarda o novo valor
            
        pop r5
        pop r4
        pop r3
        pop r2
        pop r1

        rts
        
;--------------------------------------------
;                 Ganhou
;-------------------------------------------- 
Ganha:
    push r0
    push r1
    push r2
    push r3
    push r4
        
        loadn r0, #FlagIguais
        loadn r1, #0 ; Verifica se a flag está ligada
        loadn r3, #0 ; contador
        loadn r4, #5 ; critério de parada
        
        LoopGanha:
            loadi r2, r0
            
            cmp r2, r1
            jeq RtsGanha
            
            inc r0
            inc r3
            
            cmp r3, r4
            jne LoopGanha
            
            call Ganhou
    
    RtsGanha:
        pop r4    
        pop r3
        pop r2
        pop r1
        pop r0
        rts
        
;--------------------------------------------
;                 GANHOU
;--------------------------------------------
Ganhou:
    push r0
    push r1
    push r2
    
        call ApagaTela
        
        loadn r1, #tela5Linha0      ;Endereco onde comeca a primeira linha do cenario
        loadn r2, #30720       ;cor cinza
        call ImprimeTela
        
    loadn r2, #0                    ;inicializa o contador com 0 

    loadn r0, #'s'
    loadn r3, #'n'

    LoopGanhou:
        inchar r1                   ;lê o que a pessoa escreveu
    
        inc r2                      ;contador++
    
        cmp r1, r3                  ;se ele digitou 'n'
        jeq Fim

        cmp r1, r0                  ;se ele digitou 's'
        jeq SimG

        jmp LoopGanhou             ;se ele não digitou/digitou outra coisa

    SimG:
        loadn r5, #2               ;tamanho do banco de palavrass
        mod r3, r2, r5              ;deixo o valor entre 0 e 1

        loadn r0, #palavras     ; endereço do banco de palavras
        add r0, r3, r0          ; endereço palavras[r3]
        loadi r1, r0            ; AQUI tem o endereço da palavra-alvo que estava no palavras[r3]
        
        store restart, r1       ; guardei o valor do endereço da palavra-alvo na variável restart

        pop r3
        pop r2
        pop r1
        pop r0
        
        pop r0                      ; mais um r0 para desimpilhar tudo para ir direto na main 

        jmp Restart

    
    pop r2
    pop r1
    pop r0
    rts
    
;--------------------------------------------
;               FRACASSOU
;--------------------------------------------
Fracassou:
    call ApagaTela
        
        loadn r1, #telaFinalPLinha0      ;Endereco onde começa a primeira linha do cenario
        loadn r2, #30720       ;cor cinza
        call ImprimeTela
        
    loadn r2, #0                    ;inicializa o contador com 0 

    loadn r0, #'s'
    loadn r3, #'n'

    LoopFracassou:
        inchar r1                   ;lê o que a pessoa escreveu
    
        inc r2                      ;contador++
    
        cmp r1, r3                  ;se ele digitou 'n'
        jeq Fim

        cmp r1, r0                  ;se ele digitou 's'
        jeq SimF

        jmp LoopFracassou             ;se ele não digitou/digitou outra coisa

    SimF:
        loadn r5, #2               ;tamanho do banco de palavrass
        mod r3, r2, r5              ;deixo o valor entre 0 e 1

        loadn r0, #palavras     ; endereço do banco de palavras
        add r0, r3, r0          ; endereço palavras[r3]
        loadi r1, r0            ; AQUI tem o endereço da palavra-alvo que estava no palavras[r3]
        
        store restart, r1       ; guardei o valor do endereço da palavra-alvo na variável restart

        pop r3
        pop r2
        pop r1
        pop r0
        
        pop r0                      ; mais um r0 para desimpilhar tudo para ir direto na main 

        jmp Restart


;--------------------------------------------
;                 FIM
;--------------------------------------------
Fim:
    ; seria legal uma tela para finalizar o jogo
    halt
    
;--------------------------------------------
;             Imprime Tela
;--------------------------------------------
ImprimeTela:
    ;r1 = endereco onde comeca a primeira linha do Cenario
    ;r2 = cor do Cenario para ser impresso

    push r0 
    push r1 
    push r2 
    push r3 
    push r4
    push r5

    loadn R0, #0    ; posicao inicial tem que ser o comeco da tela!
    loadn R3, #40   ; Incremento da posicao da tela!
    loadn R4, #41   ; incremento do ponteiro das linhas da tela
    loadn R5, #1200 ; Limite da tela!
    
   ImprimeTela_Loop:
        call ImprimeStr
        add r0, r0, r3      ; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
        add r1, r1, r4      ; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
        cmp r0, r5          ; Compara r0 com 1200
        jne ImprimeTela_Loop    ; Enquanto r0 < 1200

    pop r5  
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts
                
;--------------------------------------------
;             Imprime String 
;--------------------------------------------
ImprimeStr:  
    ;r0 = Posicao da tela que o primeiro caractere da mensagem será impresso 
    ;r1 = endereco onde comeca a mensagem
    ;r2 = cor da mensagem

    push r0 
    push r1 
    push r2 
    push r3 
    push r4
    
    loadn r3, #'\0' ; Criterio de parada

   ImprimeStr_Loop: 
        loadi r4, r1
        cmp r4, r3      ; If (Char == \0)  vai Embora
        jeq ImprimeStr_Sai
        add r4, r2, r4  ; Soma a Cor
        outchar r4, r0  ; Imprime o caractere na tela
        inc r0          ; Incrementa a posicao na tela
        inc r1          ; Incrementa o ponteiro da String
        jmp ImprimeStr_Loop
    
   ImprimeStr_Sai:  
    pop r4  
    pop r3
    pop r2
    pop r1
    pop r0
    rts
    

;--------------------------------------------
;                 Apaga Tela
;--------------------------------------------
ApagaTela:
    push r0
    push r1
    
    loadn r0, #1200     ; apaga as 1200 posicoes da Tela
    loadn r1, #' '      ; com "espaco"
    
       ApagaTela_Loop:  ;;label for(r0=1200;r3>0;r3--)
        dec r0
        outchar r1, r0
        jnz ApagaTela_Loop
 
    pop r1
    pop r0
    rts 

;--------------------------------------------
;                   Telas
;--------------------------------------------  
; Menu 
tela4Linha0 : string "                                        "
tela4Linha1 : string "                                        "
tela4Linha2 : string "                                        "
tela4Linha3 : string "                                        "
tela4Linha4 : string "      PRESSIONE ENTER PARA INICIAR      "
tela4Linha5 : string "      E RECUPERAR O BARCO DO SIMOES     "
tela4Linha6 : string "                                        "
tela4Linha7 : string "                                        "
tela4Linha8 : string "                   l                    "
tela4Linha9 : string "                   |l                   "
tela4Linha10 : string "                   | l                  "
tela4Linha11 : string "                  y|  l                 "
tela4Linha12 : string "                 y||   l                "
tela4Linha13 : string "                y ||    l               "
tela4Linha14 : string "               y  ||     l              "
tela4Linha15 : string "              y   ||      l             "
tela4Linha16 : string "             y    ||       l            "
tela4Linha17 : string "            y     ||        l           "
tela4Linha18 : string "           y      ||         l          "
tela4Linha19 : string "          y_______||          l         "
tela4Linha20 : string "                  ||___________l        "
tela4Linha21 : string "                  ||                    "
tela4Linha22 : string "         _________||____________        "
tela4Linha23 : string "         l                     y        "
tela4Linha24 : string "          l       SIMOES      y         "
tela4Linha25 : string "           l_________________y          "
tela4Linha26 : string "                                        "
tela4Linha27 : string "                                        "
tela4Linha28 : string "                                        "
tela4Linha29 : string "                                        "

; Venceu
tela5Linha0 : string "                                        "
tela5Linha1 : string "                                        "
tela5Linha2 : string "               VOCE VENCEU              "
tela5Linha3 : string "                                        "
tela5Linha4 : string "        AGORA ESTA PRONTO PARA O        "
tela5Linha5 : string "              ATAQUE ZUMBI              "
tela5Linha6 : string "                                        "
tela5Linha7 : string "                   l                    "
tela5Linha8 : string "                   |l                   "
tela5Linha9 : string "                   | l                  "
tela5Linha10 : string "                  y|  l                 "
tela5Linha11 : string "                 y||   l                "
tela5Linha12 : string "                y ||    l               "
tela5Linha13 : string "               y  ||     l              "
tela5Linha14 : string "              y   ||      l             "
tela5Linha15 : string "             y    ||       l            "
tela5Linha16 : string "            y  S  ||        l           "
tela5Linha17 : string "           y      ||         l          "
tela5Linha18 : string "          y_______||    O     l         "
tela5Linha19 : string "           y l    ||__ y|l ____l        "
tela5Linha20 : string "          | S |   ||    |               "
tela5Linha21 : string "         __l_y____||___y_l______        "
tela5Linha22 : string "         l                     y        "
tela5Linha23 : string "          l       SIMOES      y         "
tela5Linha24 : string "           l_________________y          "
tela5Linha25 : string "                                        "
tela5Linha26 : string "                                        "
tela5Linha27 : string "   GOSTARIA DE JOGAR NOVAMENTE? <s/n>   "
tela5Linha28 : string "                                        "
tela5Linha29 : string "                                        "

;Tela Perdeu
telaFinalPLinha0  : string "                                        "
telaFinalPLinha1  : string "                                        "
telaFinalPLinha2  : string "                                        "
telaFinalPLinha3  : string "         O TUBARAO TE PEGOU EM          "
telaFinalPLinha4  : string "                                        "
telaFinalPLinha5  : string "                                        "
telaFinalPLinha6  : string "               GAME OVER                "
telaFinalPLinha7  : string "                                        "
telaFinalPLinha8  : string "      QUER TENTAR NOVAMENTE? <s/n>      "
telaFinalPLinha9  : string "                                        "
telaFinalPLinha10 : string "                                        "
telaFinalPLinha11 : string "                                        "
telaFinalPLinha12 : string "                                        "
telaFinalPLinha13 : string "                                        "
telaFinalPLinha14 : string "        ____                            "
telaFinalPLinha15 : string "       yx  xl       _____               "
telaFinalPLinha16 : string "       l __ y      y    y               "
telaFinalPLinha17 : string "        l__y      y     l               "
telaFinalPLinha18 : string "         y|l      |      y              "
telaFinalPLinha19 : string "        y | l     |      l              "
telaFinalPLinha20 : string "       y  |  l    |       |             "
telaFinalPLinha21 : string "          |       |       |             "
telaFinalPLinha22 : string "         y l      |       |             "
telaFinalPLinha23 : string "        y   l     |       |             "
telaFinalPLinha24 : string "       y     l     l______y             "
telaFinalPLinha25 : string "                                        "
telaFinalPLinha26 : string "                                        "
telaFinalPLinha27 : string "                                        "
telaFinalPLinha28 : string "                                        "
telaFinalPLinha29 : string "                                        "
