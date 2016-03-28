function fish_prompt
    set -l status_copy $status
    set -l status_color fc9
    set -l root_glyph
    set -l pwd_info (pwd_info "/")

    if test "$status_copy" -ne 0
        set status_color f30
    end

    if pwd_is_home
        echo_color -o $status_color "⋊> "
        set root_glyph "~/"
    else
        echo_color -o $status_color "⧕ "
        set root_glyph "/"
    end

    if test 0 -eq (id -u $USER) -o ! -z "$SSH_CLIENT"
        echo_color 0fc (host_info "user@host ")
    end

    echo_color ffc $root_glyph

    if test ! -z "$pwd_info[2]"
        echo_color ffc "$pwd_info[2]/"
    end

    if test ! -z "$pwd_info[1]"
        echo_color fc9 "$pwd_info[1]"
    end

    if test ! -z "$pwd_info[3]"
        echo_color ffc "/$pwd_info[3]"
    end

    if set -l branch_name (git_branch_name)
        set -l git_glyph " on "
        set -l branch_glyph
        set -l branch_color 0fc -o

        if git_is_detached_head
            set git_glyph " detached "
        end

        if git_is_touched
            set branch_color fc9

            if git_is_staged
                if git_is_dirty
                    set branch_glyph " ±"
                else
                    set branch_glyph " +"
                end
            else
                set branch_glyph " *"
            end
        end

        set -l git_ahead (command git rev-list --left-right --count 'HEAD..master' ^ /dev/null | awk '
            $1 > 0 { printf("↑") }
            $2 > 0 { printf("↓") }
        ')

        if git_is_stashed
            set branch_name "{$branch_name}"
        end

        echo_color fff "$git_glyph"
        echo_color $branch_color "$branch_name"

        if test ! -z "$git_ahead"
            echo_color fff " $git_ahead"
        end

        echo_color fff "$branch_glyph"
    end

    echo_color " "
end
