section .data
    delim db " ", 0

section .bss
    root resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern strdup
extern malloc
extern strtok
extern strlen

global create_tree
global iocla_atoi
 
iocla_atoi: 
    enter   0, 0
    mov     esi, [ebp + 8]          ; realizam o copie a string-ului dat in input
    xor     ecx, ecx
    xor     eax, eax
    xor     edx, edx
    push    edi
    
while1:
    movzx   edi, byte [esi]     
    test    edi, edi                ; daca string-ul ramas este null inseamna ca
    je      gata                    ; am terminat verificarea
    add     esi, 1

    cmp     edi, '-'                ; daca este '-' trebuie sa retinem pentru a
    je      negativ                 ; inmulti la final cu -1
    cmp     edi, '0'                ; caracterele cu codurile ascii < 0 nu ne
    jl      return                  ; intereseaza
    cmp     edi, '9'                ; caracterele cu codurile ascii > 9 nu ne
    jg      return                  ; intereseaza
    
    sub     edi, '0'
    mov     ebx, 10
    imul    ebx                     ; inmultim numarul format cu 10 ca sa putem
    add     eax, edi                ; adauga cifra la care ne aflam
    jmp     while1
    
negativ:
    mov     ecx, 1                  ; nr negativ (ecx = 0 pt nr pozitive)
    jmp     while1  
 
gata:
    cmp     ecx, 0                  ; verificam daca avem un numar negativ 
    je      return                  
    imul    eax, -1
    pop     edi
    
return:
    leave
    ret

create_tree:
    enter   0, 0 
    pusha
    xor     eax, eax
    mov     [root], dword 0

    mov     eax, dword [ebp + 8]   ; realizam o copie a string-ului dat in input
    push    eax
    call    strdup
    add     esp, 4

    mov     ecx, eax 
    push    delim
    push    ecx
    call    strtok                 ; aflam primul token (root)
    add     esp, 8

    push    eax
    call    strdup
    add     esp, 4
    mov     ebx, eax
    push    12
    call    malloc
    add     esp, 4
  
    mov     [eax], ebx              ; facem un nod cu tokenul aflat
    mov     [eax + 4], dword 0
    mov     [eax + 8], dword 0
    mov     [root], eax
    push    eax                     ; urcam pe stiva root-ul

    push    delim
    push    dword 0
    call    strtok
    add     esp, 8

while2:                             ; folosim un while pentru a afla
    push    eax                     ; toate nodurile
    call    strdup
    add     esp, 4
    mov     ebx, eax
    
    push    12
    call    malloc
    add     esp, 4
    mov     [eax], ebx              ; nodul ce va fi introdus in structura
    mov     [eax + 4], dword 0
    mov     [eax + 8], dword 0

    cmp     byte [ebx], '+'         ; verificam daca cumva nodul contine
    je      urca_pe_stiva           ; operatori si ii urcam pe stiva
    cmp     byte [ebx], '-'
    je      caz_special
    cmp     byte [ebx], '*'
    je      urca_pe_stiva
    cmp     byte [ebx], '/'
    je      urca_pe_stiva
    jne     next                    ; avem numar, nu il urcam in stiva

caz_special:
    push    eax
    push    ebx
    call    strlen
    add     esp, 4

    cmp     eax, 1                  ; verificam daca '-' vine de la diferenta
    pop     eax                     ; sau de la un numar negativ
    je      urca_pe_stiva
    jne     next

continue: 
    push    delim
    push    dword 0
    call    strtok
    add     esp, 8
    
    cmp     eax, 0
    jne     while2
    jmp     exit

urca_pe_stiva:
    pop     ecx
    cmp     [ecx + 4], dword 0
    je      adauga_operator_stanga
    mov     [ecx + 8], eax          ; daca stanga este ocupata inseamna ca 
    jmp     salt                    ; pozitia din dreapta este sigur libera

adauga_operator_stanga:
    mov     [ecx + 4], eax
    push    ecx                    

salt:
    push    eax
    jmp     continue

next:
    pop     ecx                     ; scoatem operatorul din stiva daca
    cmp     [ecx + 4], dword 0      ; are ambii fii ocupati
    je      adauga_frunza_stanga
    mov     [ecx + 8], eax          ; daca stanga este ocupata inseamna ca 
    jmp     salt2                   ; pozitia din dreapta este sigur libera

adauga_frunza_stanga:
    mov     [ecx + 4], eax
    push    ecx

salt2:
    jmp     continue

exit:
    popa
    leave
    mov     eax, [root]             ; returnam structura in eax
    ret