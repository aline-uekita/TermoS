jmp main

; Variáveis 

; Endereço das palavras e palavras 
palavra0: string "teste"
palavra1: string "pizza"

; Banco de palavras 
palavras: var #2
    static palavras + #0, #palavra0
    static palavras + #1, #palavra1
  
; Letras certas e erradas
Certas: var #10
    static Certas + #0, #0
    static Certas + #1, #0
    static Certas + #2, #0
    static Certas + #3, #0
    static Certas + #4, #0
    static Certas + #5, #0
    static Certas + #6, #0
    static Certas + #7, #0
    static Certas + #8, #0
    static Certas + #9, #0

pontCertas: var #1

Iguais: var #10
    static Iguais + #0, #0
    static Iguais + #1, #0
    static Iguais + #2, #0
    static Iguais + #3, #0
    static Iguais + #4, #0
    static Iguais + #5, #0
    static Iguais + #6, #0
    static Iguais + #7, #0
    static Iguais + #8, #0
    static Iguais + #9, #0

pontIguais: var #1

Erradas: var #10
    static Erradas + #0, #0
    static Erradas + #1, #0
    static Erradas + #2, #0
    static Erradas + #3, #0
    static Erradas + #4, #0
    static Erradas + #5, #0
    static Erradas + #6, #0
    static Erradas + #7, #0
    static Erradas + #8, #0
    static Erradas + #9, #0

pontErradas: var #1

main:
    ; Inicialização 
    loadn r0, #0 
    store pontCertas, r0
    store pontErradas, r0
    store pontIguais, r0

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
        
    call ApagaTela
    
    loadn r0, #644      ; posição na tela
    loadn r2, #1024         ; cor

    call ImprimeStr    

    mov r7, r1 ; guarda em r7 o endereço da palavra (NÃO USAR O R7)
    
    call Jogo
    
    ; Imprimir certos, iguais e errados
    loadn r1, #Certas
    loadn r0, #644      ; posição na tela
    loadn r2, #1024         ; cor

    call ImprimeStr

    loadn r1, #Iguais
    loadn r0, #684      ; posição na tela
    loadn r2, #1024         ; cor

    call ImprimeStr

    loadn r1, #Erradas
    loadn r0, #724      ; posição na tela
    loadn r2, #1024         ; cor

    call ImprimeStr
    
    halt
    
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
            loadn r1, #604 ;posição da letra
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

    load r4, pontErradas ; ponteiro das erradas
    loadn r5, #Erradas ; endereço do vetor Erradas
    add r5, r4, r5 ; endereço das Erradas[pontErradas]
    storei r5, r0 ; guarda a letra no Erradas[pontErradas]
    
    inc r4 ; atualiza o ponteiro
    loadn r5, #pontErradas
    storei r5, r4 ; guarda o novo valor
    jmp RtsCompara

    Continua:
        loadn r5, #'b'
        loadn r4, #444
        outchar r5, r4

    RtsCompara:
        pop r5
        pop r4
        pop r3
        pop r2
        pop r1

        rts
        
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
