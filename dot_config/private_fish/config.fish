# ssh-agent
if test -z "$SSH_AUTH_SOCK"
    eval (ssh-agent -c) > /dev/null
    ssh-add "$HOME/.ssh/id_ed25519"
end

if status is-interactive
    # 起動の挨拶
    set -g fish_greeting

    # vi key bindings
    fish_vi_key_bindings
end
