; vim:ft=nasm
global _start
section .text

extern discord_config_init
extern discord_run
extern discord_set_on_ready
extern discord_set_on_interaction_create
extern discord_create_interaction_response
extern discord_create_guild_application_command
extern discord_cleanup
extern ccord_global_cleanup
extern ccord_global_init

; my own strlen function cause I'm gonna need it
extern z_strcmp
_start:

    call ccord_global_init

    mov edi, config_file
    call discord_config_init
    mov rdi, rax

    mov esi, on_ready
    call discord_set_on_ready;(rdi, esi)

    mov esi, on_interaction
    call discord_set_on_interaction_create;(rdi, esi)

    call discord_run

    call discord_cleanup;(rdi)
    call ccord_global_cleanup

    mov rax, 60
    mov rdi, 0
    syscall

on_ready: ; TODO: This should be a lot better than it currently is.
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov [rbp-8], rdi
    mov [rbp-16], rsi

    mov rax, 1
    mov rdi, 1
    mov rsi, bot_on
    mov rdx, 19
    syscall

    mov rax, [rbp-16]
    mov rax, [rax+40]
    mov rax, [rax]
    mov [application_id], rax

    mov rdi, ping_command_params
    mov qword [rdi], ping_command_params_name
    mov qword [rdi+8], ping_command_params_description

    mov rdi, [rbp-8]
    mov rsi, [application_id]
    mov rdx, [tholly_support_guild_id]
    mov rcx, ping_command_params
    mov r8, 0
    call discord_create_guild_application_command;(client, application_id, guild_id, params, ret)

    leave
    ret

on_interaction: ; This takes in 2 pointers
    push rbp
    mov rbp, rsp
    sub rsp, 16 ; Make room for 2 8 byte pointers

    mov [rbp-8], rdi 
    mov [rbp-16], rsi ; This is the discord_interaction event

    cmp qword [rsi+16], 2
    jne on_interaction__return
    ; Handle the interaction
    ; TODO: I have created the thingy, now for some reason rdi, and rsi are
    ; getting overwritten and my program's crashing.
    ; push rdi
    ; push rsi
    ; mov rdi, ping_command_params_name
    ; mov rsi, ping_command_params_name
    ; call z_strcmp
    ; pop rsi
    ; pop rdi
    ; test eax, eax
    ; je on_interaction__return ; FIXME: uncomment this piece of shit and actually check for the ping command

    ; Handle command
    mov qword [ping_command_response_callback_data_content], ping_command_response_message
    mov qword [ping_command_discord_interaction_reponse_data], ping_command_response_callback_data
    mov rax, [rbp-16]
    mov rdx, [rax+64]
    mov rax, [rbp-16]
    mov rsi, [rax]
    mov rax, [rbp-8]
    mov rcx, ping_command_discord_interaction_response
    mov r8d, 0
    call discord_create_interaction_response
on_interaction__return:
    leave
    ret

section .data
config_file: db "config.json", 0
bot_on: db "The bot is online!", 10
got_interaction: db "Got an interaction!", 10
ping_command_params_name: db "ping", 0
ping_command_params_description: db "basic ping command", 0
ping_command_params: dq 5 dup (0)
application_id: dq 0
tholly_support_guild_id: dq 560568593188651015

; discord_interaction_callback_data
ping_command_discord_interaction_response:
ping_command_discord_interaction_response_type: dq 4 ; XXX: 4 is DISCORD_INTERACTION_CHANNEL_MESSAGE_WITH_SOURCE
ping_command_discord_interaction_reponse_data: dq 0
ping_command_response_callback_data:
ping_command_response_callback_data_components: dq 0
ping_command_response_callback_data_tts: dq 0
ping_command_response_callback_data_content: dq 0
ping_command_void: db 48 dup (0)
; interaction callback
ping_command_response_message: db "Pong!", 0
