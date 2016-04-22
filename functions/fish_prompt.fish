function fish_prompt
    # If any of the colour variables aren't defined they're set to 'normal' colour 
    for color in $fish_color_cwd $fish_color_cwd_root $fish_color_error $fish_color_host $fish_color_operator $fish_color_user
        if set -q color
            set color normal
        end
    end
    
    # Make a local copy of the status code of last command
    set -l status_copy $status
    # Since there isn't a "official" colour variables for sucess colour, we've chose one. 
    set -l status_color 0fc

    # If last command exited with an error change colour of the "Dartfish" in the prompt
    if test "$status_copy" -ne 0
        set status_color $fish_color_error
    end

    # Change Dartfish symbol based on current location
    if pwd_is_home
        echo -sn (set_color -o $status_color) "⨉⪧ "
    else
        echo -sn (set_color -o $status_color) "⧕ "
    end
    set_color normal
    
    # If running in root mode or connected to some other host, display relavent information
    if test 0 -eq (id -u $USER) -o ! -z "$SSH_CLIENT"
        echo -sn (set_color -o $fish_color_user) (host_info "user")
        echo -sn (set_color $fish_color_normal) "@"
        echo -sn (set_color -o $fish_color_host) (host_info "host ")
    end
    set_color normal 
    
    # Switch colour variables based on current user
    switch $USER
        case root
        set_color $fish_color_cwd_root
        case "*"
        set_color $fish_color_cwd
    end
    echo -sn (prompt_pwd)
    
    # Git information if cwd is a git repo
    if set -l branch_name (git_branch_name)
        set -l git_glyph " on "
        set -l branch_glyph
        # Using custom colours since there aren't defined variables for git stuff
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
        echo -sn (set_color $branch_color) "$branch_name" (set_color normal)

        if test ! -z "$git_ahead"
            echo -sn (set_color fff) " $git_ahead" (set_color normal)
        end

        echo -sn (set_color fff) "$branch_glyph" (set_color normal)
    end

    # Operator at the end to show the end of prompt, can be confusing without it sometimes
    set_color $fish_color_operator
    echo -ns " ⟩"
    set_color normal
end
