org 100h

start:
    ; 1. 화면 초기화 (텍스트 모드 03h 설정)
    mov ax, 0003h
    int 10h

    ; 커서 숨기기 (깜빡임 방지)
    mov ah, 01h
    mov cx, 2607h 
    int 10h

    ; 2. 미로 맵 출력
    mov dx, offset maze_map
    mov ah, 09h
    int 21h

    ; 3. 초기 플레이어 좌표 설정 (X=1, Y=1)
    mov dl, 1
    mov dh, 1

game_loop:
    ; 4. 플레이어 그리기 ('P')
    call set_cursor
    mov al, 'P'
    mov ah, 0Eh
    int 10h

wait_key:
    ; 5. 키 입력 대기 (AX 레지스터에 입력된 키 값이 저장됨)
    mov ah, 00h
    int 16h

    ; ------------------------------------------------
    ; [핵심 수정] AX 레지스터의 값을 스택(Stack)에 백업
    push ax
    ; ------------------------------------------------

    ; 6. 이동 전 현재 위치의 플레이어 지우기 (' ')
    call set_cursor
    mov al, ' '
    mov ah, 0Eh
    int 10h

    ; 현재 좌표 백업 (벽에 부딪혔을 때 되돌리기 위함)
    mov bl, dl
    mov bh, dh

    ; ------------------------------------------------
    ; [핵심 수정] 백업해둔 AX 값을 스택에서 다시 복구
    pop ax
    ; ------------------------------------------------

    ; 7. 키 판별 (방향키 스캔코드 AH, 또는 알파벳 AL 확인)
    cmp ah, 48h
    je move_up
    cmp al, 'w'
    je move_up
    cmp al, 'W'
    je move_up

    cmp ah, 50h
    je move_down
    cmp al, 's'
    je move_down
    cmp al, 'S'
    je move_down

    cmp ah, 4Bh
    je move_left
    cmp al, 'a'
    je move_left
    cmp al, 'A'
    je move_left

    cmp ah, 4Dh
    je move_right
    cmp al, 'd'
    je move_right
    cmp al, 'D'
    je move_right

    cmp al, 27
    je exit_game

    jmp game_loop

move_up:
    dec dh
    jmp check_collision
move_down:
    inc dh
    jmp check_collision
move_left:
    dec dl
    jmp check_collision
move_right:
    inc dl

check_collision:
    ; 8. 이동할 위치의 글자 읽어오기
    call set_cursor
    mov ah, 08h
    mov bh, 0
    int 10h 

    ; 벽('*')인지 확인
    cmp al, '*'
    je restore_pos

    ; 도착지('E')인지 확인
    cmp al, 'E'
    je game_clear

    ; 길이면 그대로 루프 반복 (새 좌표에 P가 그려짐)
    jmp game_loop

restore_pos:
    ; 벽이면 백업해둔 이전 좌표로 복구
    mov dl, bl
    mov dh, bh
    jmp game_loop

game_clear:
    ; 도착지 도달 시 'P'를 그리고 성공 메시지 표시
    call set_cursor
    mov al, 'P'
    mov ah, 0Eh
    int 10h
    
    mov dl, 0
    mov dh, 8 ; 메시지를 띄울 화면 아래쪽 좌표
    call set_cursor
    
    mov dx, offset win_msg
    mov ah, 09h
    int 21h

exit_game:
    ; 프로그램 정상 종료
    mov ah, 4Ch
    int 21h

; =========================================
; 서브루틴: 커서 위치 이동 (DL=X좌표, DH=Y좌표)
; =========================================
set_cursor:
    mov ah, 02h
    mov bh, 0
    int 10h
    ret

; =========================================
; 데이터 변수 영역
; =========================================
maze_map db '*********', 13, 9
         db '* *   *E*', 13, 9
         db '* * * * *', 13, 9
         db '* * * * *', 13, 9
         db '* * * * *', 13, 9
         db '*   *   *', 13, 9
         db '*********$'

win_msg  db 'Clear! You escaped the maze!$'