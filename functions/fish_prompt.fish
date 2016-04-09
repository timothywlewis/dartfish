function fish_prompt
    set -l status_copy $status
    set -l status_color 0fc
    set -l root_glyph
    set -l pwd_info (pwd_info "/")

    if test "$status_copy" -ne 0
        set status_color f30
    end

    if pwd_is_home
        echo -sn (set_color -o $status_color) "⋊> " (set_color normal)
        set root_glyph "~/"
    else
        echo -sn (set_color -o $status_color) "⧕ " (set_color normal)
        set root_glyph "/"
    end

    if test 0 -eq (id -u $USER) -o ! -z "$SSH_CLIENT"
        echo -sn (set_color 0fc) (host_info "user@host ") (set_color normal)
    end

    echo -sn (set_color cff) $root_glyph (set_color normal)

    if test ! -z "$pwd_info[2]"
        echo -sn (set_color cff) "$pwd_info[2]/" (set_color normal)
    end

    if test ! -z "$pwd_info[1]"
        echo -sn (set_color 0fc) "$pwd_info[1]" (set_color normal)
    end

    if test ! -z "$pwd_info[3]"
        echo -sn (set_color cff) "/$pwd_info[3]" (set_color normal)
    end

    if set -l branch_name (git_branch_name)
        set -l git_glyph " on "
        set -l branch_glyph
        set -l branch_color 0fc -o

        if git_is_detached_head
            set git_glyph " detached "
        end

        if git_is_touched
            set branch_color cc3

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

        echo -sn (set_color fff) "$git_glyph" (set_color normal)
        echo -sn (set_color "$branch_color") "$branch_name" (set_color normal)

        if test ! -z "$git_ahead"
            echo -sn (set_color fff) " $git_ahead" (set_color normal)
        end

        echo -sn (set_color fff) "$branch_glyph" (set_color normal)
    end

    echo " "
end
