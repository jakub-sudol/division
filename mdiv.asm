global mdiv

; rejestry trzymają od pierwszego ustawienia do końca programu
; r10 - wskaźnik na dzielną
; rsi - n
; r11 - dzielnik
; r8 - znak dzielnej
; r9 - znak dzielnika

mdiv:
    lea r10, [rdi + 8 * rsi - 8]; zapisuje w r10 wskaźnik na dzielna
    mov r11, rdx ; zapisuje w r11 dzielnik
    mov r8, [r10]
    shr r8, 63
    and r8, 1 ; ustawienie r8 na znak dzielnej
    jz .ustaw_znak_dzielnika 

.zmien_dzielna: ; zmienia znak dzielnej
    mov rdi, r10 ; rdi trzyma wskaznik na aktualnie zmieniany element
    mov rdx, rsi ; rdx trzyma n - index elementu

.petla_zmien_dzielna: ; zmienia wszystkie bity dzielnej
    
    not qword [rdi] ; neguje wszystkie bity elementu
    sub rdi, 8  ; przesuwa wskaźnik na następny element
    dec rdx
    jnz .petla_zmien_dzielna ; wywołuje zmiane bitow nastepnego elementu
    add rdi, 8 ; ustawia wskaznik na ostatni element dzielnej

.dodaj_jeden: ; rdi wskazuje na ostatni element dzielnej, zaczynamy od końca
    add qword [rdi], 1
    jnc .sprawdz_overflow ; kończymy dodawanie
    add rdi, 8 ; przesuwa wskaźnik na następny element
    jmp .dodaj_jeden ; kontynuujemy dodawanie

; overflow jest gdy dzielna była najmniejsza możliwa a dzielnik -1
.sprawdz_overflow:
    and qword [r10], -1 ; jeśli dzielna była najmniejsza to teraz wynosi -1
    jns .ustaw_znak_dzielnika
    inc r11 ; sprawdzanie czy dzielnik to -1
    jz .overflow 
    dec r11 ; przywrocenie poprawnej wartosci dzielnika

.ustaw_znak_dzielnika: ; ustawienie r9 na znak dzielnika
    mov r9, r11 
    shr r9, 63
    and r9, 1 ; ustawienie r9 na znak dzielnika
    jz .przygotowanie_dzielenia ; nie trzeba zmieniać znaku

.zmien_dzielnik: ; zmienia znak r11 - dzielnik
    neg r11 ; ustawia dzielnik na liczbe przeciwna

.przygotowanie_dzielenia:
    mov rcx, r10 ; rcx wskazuje na dzielony element, teraz na początek
    mov rdi, rsi ; rdi to n - index elementu
    xor rdx, rdx

.petla_dzielenie: ; rdx:rax, rdx-reszta, rax-element, r11-dzielnik
    mov rax, [rcx] ; zapisujemy w rax następny element
    div r11 
    mov [rcx], rax ; zapisujemy w pamięci wynik dzielenia

    sub rcx, 8 ; przesunięcie wskaźnika na następny element
    dec rdi
    jnz .petla_dzielenie ; jesli jest jeszcze element powtarzamy

.ustawianie_znakow:
    mov rax, rdx ; trzymamy reszte w rax
    and r8, r8 ; sprawdza czy dzielna byla ujemny
    jnz .zmien_reszte ; jesli tak zmienia znak reszty
    and r9, r9 ; jesli nie to sprawdza czy dzielnik byl ujemny
    jz .exit
.zmien_dzielna_2: ; zmienia znak dzielnej
    mov rdi, r10 ; rdi trzyma wskaznik na aktualnie zmieniany element
    mov rdx, rsi ; rdx trzyma n - index elementu

.petla_zmien_dzielna_2:
    not qword [rdi] ; neguje bity
    sub rdi, 8 ; przesuwa wskaźnik na następny element
    dec rdx
    jnz .petla_zmien_dzielna_2 ; jesli jest jeszcze element powtarza
    add rdi, 8 ; ustawia wskaźnik na ostatni element

.dodaj_jeden_2: ; rdi wskazuje na ostatni element dzielnej
    add qword [rdi], 1 ; zapisuje w pamieci element
    jnc .exit ; konczy dodawanie
    add rdi, 8 ; przesuwa wskaźnik na następny element
    jmp .dodaj_jeden_2 ; kontynuuje dodawanie

.zmien_reszte: ; zmienia znak reszty
    neg rax ; zmienia reszte na liczbe przeciwna
    and r9, r9 ; sprawdza czy dzielnik był ujemny
    jz .zmien_dzielna_2 ; jesli nie to zmienia znak dzielnej

.exit: ; w rax znajduje sie reszta
    ret
    
.overflow: ; r11 = 0
    div r11
    ret