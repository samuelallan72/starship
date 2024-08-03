# this file is both a valid
# - overlay which can be loaded with `overlay use starship.nu`
# - module which can be used with `use starship.nu`
# - script which can be used with `source starship.nu`
export-env {
    $env.STARSHIP_SHELL = "nu"

    $env.config.hooks.pre_execution ++= {||
        let cmd = commandline | parse --regex '\s*(:?sudo\s+)?(?<cmd>\w+).*' | get cmd
        if ($cmd | is-not-empty) {
            export-env {
                $env.LAST_CMD = $cmd | first
            }
        }
    }

    load-env {
        STARSHIP_SESSION_KEY: (random chars -l 16)
        PROMPT_MULTILINE_INDICATOR: (
            ^::STARSHIP:: prompt --continuation
        )

        # Does not play well with default character module.
        # TODO: Also Use starship vi mode indicators?
        PROMPT_INDICATOR: ""

        PROMPT_COMMAND: {||
            # jobs are not supported
            (
                ^::STARSHIP:: prompt
                    --cmd-duration $env.CMD_DURATION_MS
                    --cmd ($env | default '' LAST_CMD | get LAST_CMD)
                    $"--status=($env.LAST_EXIT_CODE)"
                    --terminal-width (term size).columns
            )
        }

        config: ($env.config? | default {} | merge {
            render_right_prompt_on_last_line: true
        })

        PROMPT_COMMAND_RIGHT: {||
            (
                ^::STARSHIP:: prompt
                    --right
                    --cmd-duration $env.CMD_DURATION_MS
                    --cmd ($env | default '' LAST_CMD | get LAST_CMD)
                    $"--status=($env.LAST_EXIT_CODE)"
                    --terminal-width (term size).columns
            )
        }
    }
}

