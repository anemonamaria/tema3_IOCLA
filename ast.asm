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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    enter   0, 0
    mov     edi, [ebp + 8]
    xor     ecx, ecx
    xor     eax, eax
    
cat_timp:
    movzx   esi, byte [edi]   ;zero extension
    cmp     esi, dword 0      ; daca string-ul s-a terminat iesim din functie
    je      gata
    
    cmp     esi, 45 ;ascii for '-'
    je      minus
    cmp     esi, 48 ;ascii for '0'
    jl      urmatorul_nr
    cmp     esi, 57; ascii for '9'
    jg      urmatorul_nr
    
    sub     esi, 48
    mov     edx, 10
    imul    edx
    add     eax, esi
    
    inc     edi
    jmp     cat_timp
    
minus:
    mov     ecx, 1
    inc     edi
    jmp     cat_timp  
 
urmatorul_nr:
    xor     eax, eax
    
gata:
    cmp     ecx, 0
    je      return
    mov     edx, -1
    imul    edx
    
return:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    leave
    ret

create_tree:
    ; TODO
    enter   0, 0 
    pusha
    xor     eax, eax
    mov     [root], dword 0

    ; Nod 1
    mov     eax, dword [ebp + 8]
   ; PRINTF32 `eax %s\n\x0`, eax
    push    eax
    call    strdup
    add     esp, 4
    ;PRINTF32 `eax %s\n\x0`, eax

    mov     ecx, eax ; impartim in primul token string-ul
    push    delim
    push    ecx
    call    strtok
    add     esp, 8

    push    eax
    call    strdup
    add     esp, 4
    mov     ebx, eax


    push    12
    call    malloc
    add     esp, 4
  
    mov     [eax], ebx      ; creeam nodul
    mov     [eax + 4], dword 0
    mov     [eax + 8], dword 0
    mov     [root], eax

    push    eax

    push    delim
    push    dword 0
    call    strtok
    add     esp, 8
    ;PRINTF32 `root %s\n\x0`, ebx
while:
    push    eax
    call    strdup
    add     esp, 4
    mov     ebx, eax
    
    push    12
    call    malloc
    add     esp, 4
    mov     [eax], ebx      ; creeam nodul
    mov     [eax + 4], dword 0
    mov     [eax + 8], dword 0

    ;PRINTF32 `caracter din while  %s\n\x0`, ebx
    cmp     byte  [ebx], '+'
    je      urca_pe_stiva
    cmp     byte [ebx], '-'
    je      caz_special
    cmp     byte [ebx], '*'
    je      urca_pe_stiva
    cmp     byte [ebx], '/'
    je      urca_pe_stiva
    jne     next       ; daca ajunge aici inseamna ca avem un 

caz_special:
    push    eax
    push    ebx
    call    strlen
    add     esp, 4
    cmp     eax, 1
    pop     eax
    je      urca_pe_stiva
    jne     next
continue: 
    ;PRINTF32 `la ce ne aflam %s\n\x0`, ebx
    push    delim
    push    dword 0
    call    strtok
    add     esp, 8
    
    ;PRINTF32 `\n\n\x0`
    cmp     eax, 0
    jne     while
    jmp     exit

urca_pe_stiva:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop     ecx
    ;PRINTF32 `urca pe stiva   %s\n\x0`, [ecx]
    cmp     [ecx + 4], dword 0
    je      adauga_operator_stanga
    mov     [ecx + 8], eax      ;daca stanga nu e libera inseamna ca cel din dreapta e liber
    
    jmp     salt
adauga_operator_stanga:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;PRINTF32 `adauga op stanga\n\x0`
    mov     [ecx + 4], eax


    push    ecx
salt:

    ;PRINTF32 `salt\n\x0`
    push    eax
    jmp     continue

next:

    pop     ecx
    ;PRINTF32 `next   %s\n\x0`, [ecx]
    cmp     [ecx + 4], dword 0
    je      adauga_frunza_stanga
    ;PRINTF32 `frunza dreapta\n\x0`

    mov     [ecx + 8], eax      ;daca stanga nu e libera inseamna ca cel din dreapta e liber
    
    jmp     salt2
adauga_frunza_stanga:
    ;PRINTF32 `frunza stanga\n\x0`
    mov     [ecx + 4], eax
    push    ecx
salt2:
    ;PRINTF32 `salt2\n\x0`
    jmp     continue

exit:
    ;PRINTF32 `exit\n\x0`
   ; mov     eax, [root]
    ;push    0
   ; push    eax
   ; call    printTree
    ;add     esp, 8
    ;push    eax
    ;call    print_tree_preorder

    ;add     esp, 4
    
   ; pop     eax
    popa
    leave
    mov     eax, [root]
    ret