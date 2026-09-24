; Original test harness for the dispatch ABI; never shipped in the Mod ZIP.
.code
probe_dispatch proc
    push rsi
    sub rsp, 20h
    mov esi, r8d
    movss xmm0, xmm1
    mov rax, 1122334455667788h
    call rcx
    mov [r9], rax
    add rsp, 20h
    pop rsi
    ret
probe_dispatch endp
end
