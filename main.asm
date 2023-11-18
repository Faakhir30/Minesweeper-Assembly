; CONVENTIONS:
; any pen yak is not allowed to use regs other than 32 bit, DWORD ky ilawa nothing use
include Irvine32.inc
include macros.inc
.data
rowLen DWORD 8
gridBuffer DWORD 64 DUP(0)
tmp DWORD ?
numberOfMines DWORD 5


.code
DisplayGrid PROC

    mov ecx, lengthof gridBuffer -1
    mov esi, OFFSET gridBuffer
    L1:
        mov eax, [esi]
        call WriteDec
        mwrite " "
        add esi, 4
        mov eax, ecx
        xor edx, edx
        mov ebx, rowLen
        div ebx
        mov tmp, ecx
        cmp tmp, 1
        je exitProc
        cmp edx, 0
        je L2
        loop L1
    L2:
        call crlf
        loop L1
    exitProc:
        mov eax, [esi]
        call WriteDec
    ret
DisplayGrid ENDP

placeMines PROC
    mov ecx, numberOfMines
    mov tmp, ecx
    L1:
        mov eax,50
        call Delay
        mov eax, lengthof gridBuffer
        call randomize
        call RandomRange
        mov esi, OFFSET gridBuffer
        mov ebx, 4
        imul ebx
        mov ebx, [esi+eax]
        cmp ebx, 9
        je L1
        mov ebx, 9
        mov [esi+eax], ebx
        cmp tmp,0
        je exitProc
        dec tmp
        loop L1
    exitProc:
    ret
placeMines ENDP

assignWeights PROC
    .data
        isLeftValid BYTE 1
        isRightValid BYTE 1
        isUpValid BYTE 1
        isDownValid BYTE 1
    .code
    mov tmp, 0
    mov eax, rowLen
    mov ebx, 4
    mul ebx
    mov edi, eax
    mov esi, OFFSET gridBuffer
    L1:
        mov isDownValid, 1
        mov isUpValid, 1
        mov isLeftValid, 1
        mov isRightValid, 1
        mov eax, tmp
        call WriteDec
        call crlf
        mov ebx, [esi]
        cmp ebx,9
        je NextPlace
    checkLeft:
        mov ebx, rowLen
        mov eax,tmp
        xor edx, edx
        div ebx
        cmp edx, 0
        je unvalidLeft
        jmp checkRight
    unvalidLeft:
        mov isLeftValid, 0
    checkRight:
        mov eax, tmp
        add eax, 1
        mov ebx, rowLen
        xor edx, edx
        div ebx
        cmp edx, 0
        je unvalidRight        
        jmp checkUp
    unvalidRight:
        mov isRightValid, 0
    checkUp:
        mov eax, tmp
        mov ebx, rowLen
        xor edx, edx
        div ebx
        cmp eax, 0
        je unvalidUp
        jmp checkDown
    unvalidUp:
        mov isUpValid, 0
    checkDown:
        mov eax, tmp
        mov ebx, rowLen
        xor edx, edx
        div ebx
        cmp eax, rowLen-1
        je unvalidDown
        jmp calcRight
    unvalidDown:
        mov isDownValid, 0
    calcRight:
        cmp isRightValid, 0
        je calcLeft
        mov ebx, [esi+4]
        cmp ebx, 9
        jne calcLeft
        mov eax, 1
        add [esi], eax
    calcLeft:
        cmp isLeftValid, 0
        je calcUp
        mov ebx, [esi-4]
        cmp ebx, 9
        jne calcUp
        mov eax, 1
        add [esi], eax
    calcUp:
        cmp isUpValid, 0
        je calcDown
        sub esi, edi
        mov ebx, [esi]
        add esi, edi
        cmp ebx, 9
        jne calcDown
        mov eax, 1
        add [esi], eax
    calcDown:
        cmp isDownValid, 0
        je calcUperRight
        add esi, edi
        mov ebx, [esi]
        sub esi, edi
        cmp ebx, 9
        jne calcUperRight
        mov eax, 1
        add [esi], eax
    calcUperRight:
        cmp isRightValid, 0
        je calcLowerRight
        cmp isUpValid, 0
        je calcLowerRight
        sub esi, edi
        mov ebx, [esi+4]
        add esi, edi
        cmp ebx, 9
        jne calcUperLeft
        mov eax, 1
        add [esi], eax
    calcUperLeft:
        cmp isLeftValid, 0
        je calcLowerLeft
        cmp isUpValid, 0
        je calcLowerLeft
        sub esi, edi
        mov ebx, [esi-4]
        add esi, edi
        cmp ebx, 9
        jne calcLowerLeft
        mov eax, 1
        add [esi], eax
    calcLowerLeft:
        cmp isLeftValid, 0
        je calcLowerRight
        cmp isDownValid, 0
        je calcLowerRight
        mov ebx, [esi+edi-4]
        cmp ebx, 9
        jne calcLowerRight
        mov eax, 1
        add [esi], eax
    calcLowerRight:
        cmp isRightValid, 0
        je NextPlace
        cmp isDownValid, 0
        je NextPlace
        mov ebx, [esi+edi+4]
        cmp ebx, 9
        jne NextPlace
        mov eax, 1
        add [esi], eax
                
    NextPlace:
        add esi, 4
        inc tmp
        mov eax, tmp
        cmp eax, lengthof gridBuffer
        je exitProc
        jmp L1 
    exitProc:
    ret
assignWeights ENDP
initializeBoard Proc
    call placeMines
    call assignWeights
    ret
initializeBoard ENDP

main PROC
    call initializeBoard
    call DisplayGrid
    RET
    main ENDP
END main


















; helpers functions
; -------------------------------------------------------------

; calcMod Proc:
;     pop ebx
;     pop eax
;     xor edx, edx
;     div