setopt promptsubst

_git_branch(){
  __ref=$(\git symbolic-ref HEAD 2> /dev/null) || __ref="detached" || return;
  echo -n "${__ref#refs/heads/}";
  unset __ref;
}

_git_rev(){
  __rev=$(\git rev-parse HEAD | cut -c 1-7);
  echo -n "${__rev}";
  unset __rev;
}

_git_remote_defined(){
  if [ ! -z "`\git remote -v | head -1 | awk '{print $1}' | tr -d ' \n'`" ]; then
    echo -ne 1
  else
    echo -ne 0
  fi
}

_git_remote_name(){
  if \git remote -v | grep origin > /dev/null; then
    echo -ne "origin"
  else
    echo -ne "`\git remote -v | head -1 | awk '{print $1}' | tr -d " \n"`"
  fi
}

_git_dirty(){
  GIT_TRACKED_COLOR=cyan
  GIT_UNTRACKED_COLOR=red
  GIT_UNPUSHED_COLOR=yellow

  __mod_t=$(\git status --porcelain 2>/dev/null | grep '^M[A,M,D,R, ]\{1\} \|^R[A,M,D,R, ]\{1\} ' | wc -l | tr -d ' ');
  __add_t=$(\git status --porcelain 2>/dev/null | grep '^A[A,M,D,R, ]\{1\} ' | wc -l | tr -d ' ');
  __del_t=$(\git status --porcelain 2>/dev/null | grep '^D[A,M,D,R, ]\{1\} ' | wc -l | tr -d ' ');
  
  __mod_ut=$(\git status --porcelain 2>/dev/null | grep '^[A,M,D,R, ]\{1\}M \|^[A,M,D,R, ]\{1\}R ' | wc -l | tr -d ' ');
  __add_ut=$(\git status --porcelain 2>/dev/null | grep '^[A,M,D,R, ]\{1\}A ' | wc -l | tr -d ' ');
  __del_ut=$(\git status --porcelain 2>/dev/null | grep '^[A,M,D,R, ]\{1\}D ' | wc -l | tr -d ' ');
  
  __new=$(\git status --porcelain 2>/dev/null | grep '^?? ' | wc -l | tr -d ' ');
  __unpushed=$(git rev-list $(_git_branch)..$(_git_remote_name)/$(_git_branch) --count 2>/dev/null);
  __unpushed_other_way=$(git rev-list $(_git_remote_name)/$(_git_branch)..$(_git_branch) --count 2>/dev/null);


  [[ "$__add_t" != "0" ]]              && echo -n " %B%F{$GIT_TRACKED_COLOR}$(_git_branch)%b%f";
  [[ "$__add_ut" != "0" ]]             && echo -n " %B%F{$GIT_UNTRACKED_COLOR}$(_git_branch)%b%f";
  [[ "$__mod_t" != "0" ]]              && echo -n " %B%F{$GIT_TRACKED_COLOR}$(_git_branch)%b%f";
  [[ "$__mod_ut" != "0" ]]             && echo -n " %B%F{$GIT_UNTRACKED_COLOR}$(_git_branch)%b%f";
  [[ "$__del_t" != "0" ]]              && echo -n " %B%F{$GIT_TRACKED_COLOR}$(_git_branch)%b%f";
  [[ "$__del_ut" != "0" ]]             && echo -n " %B%F{$GIT_UNTRACKED_COLOR}$(_git_branch)%b%f";
  [[ "$__new" != "0" ]]                && echo -n " %B%F{$GIT_UNTRACKED_COLOR}$(_git_branch)%b%f";
  [[ "$__unpushed" != "0" ]]           && echo -n " %B%F{$GIT_UNPUSHED_COLOR}$(_git_branch)%b%f";
  [[ "$__unpushed_other_way" != "0" ]] && echo -n " %B%F{$GIT_UNPUSHED_COLOR}$(_git_branch)%b%f";

  unset __mod_ut __add_ut __mod_t __new __add_t __del_t __del_ut __unpushed
}

_git_clean_or_dirty() {
  if [ -z "$(_git_dirty)" ]; then
    echo -n " %B%F{green}$(_git_branch)%b%f"
  else
    echo $(_git_dirty)
  fi
}

_color() {
  if [ -n "$1" ]; then
    echo "%B%F{$2}$1%b%f"
  fi
}

_separate()               { if [ -n "$1" ]; then echo " $1"; fi }
_grey()                   { echo "$(_color "$1" grey)" }
_yellow()                 { echo "$(_color "$1" yellow)" }
_green()                  { echo "$(_color "$1" green)" }
_red()                    { echo "$(_color "$1" red)" }
_cyan()                   { echo "$(_color "$1" cyan)" }
_blue()                   { echo "$(_color "$1" blue)" }

_working_directory()      { echo "$(_blue "%c")" }

_display_current_vim_mode() {
  if [[ $VIMODE == 'vicmd' ]]; then
    echo "$(_red "✘")"
  else
    echo "$(_green "✔")"
  fi
}

function zle-line-init zle-keymap-select {
  VIMODE=$KEYMAP
  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

PROMPT='$(_working_directory)$(_separate $(_git_clean_or_dirty)) $(_display_current_vim_mode)  '

