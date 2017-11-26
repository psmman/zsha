# vim:ft=zsh ts=2 sw=2 sts=2
#
function svn_prompt_info() {
  if in_svn; then
    if [ "x$SVN_SHOW_BRANCH" = "xtrue" ]; then
      unset SVN_SHOW_BRANCH
      _DISPLAY=$(svn_get_branch_name)
    else
      _DISPLAY=$(svn_get_repo_name)
    fi
    echo "$ZSH_PROMPT_BASE_COLOR$ZSH_THEME_SVN_PROMPT_PREFIX\
$ZSH_THEME_REPO_NAME_COLOR$_DISPLAY$ZSH_PROMPT_BASE_COLOR$ZSH_THEME_SVN_PROMPT_SUFFIX$ZSH_PROMPT_BASE_COLOR$(svn_dirty)$(svn_dirty_pwd)$ZSH_PROMPT_BASE_COLOR"
    unset _DISPLAY
  fi
}


function in_svn() {
  if $(svn info >/dev/null 2>&1); then
    return 0
  fi
  return 1
}

function svn_get_repo_name() {
  if in_svn; then
    svn info | sed -n 's/Repository\ Root:\ .*\///p' | read SVN_ROOT
    svn info | sed -n "s/URL:\ .*$SVN_ROOT\///p"
  fi
}

function svn_get_branch_name() {
  _DISPLAY=$(
    svn info 2> /dev/null | \
      awk -F/ \
      '/^URL:/ { \
        for (i=0; i<=NF; i++) { \
          if ($i == "branches" || $i == "tags" ) { \
            print $(i+1); \
            break;\
          }; \
          if ($i == "trunk") { print $i; break; } \
        } \
      }'
  )
  
  if [ "x$_DISPLAY" = "x" ]; then
    svn_get_repo_name
  elif [ "x$_DISPLAY" = "xtrunk" ]; then
    echo "trunk"
  else
    echo "NOT trunk"
  fi
  unset _DISPLAY
}

function svn_get_rev_nr() {
  if in_svn; then
    svn info 2> /dev/null | sed -n 's/Revision:\ //p'
  fi
}

function svn_dirty_choose() {
  if in_svn; then
    local root=$(LANG=C svn info 2> /dev/null | sed -n 's/^Working Copy Root Path: //p')
    if svn status $root 2> /dev/null | command grep -Eq '^\s*[ACDIM!?L]'; then
      # Grep exits with 0 when "One or more lines were selected", return "dirty".
      echo $1
    elif $(echo $status_str | grep -Eq '^\s*[?]'); then
      echo $2
    else
      # Otherwise, no lines were found, or an error occurred. Return clean.
      echo $3
    fi
  fi
}

svn_dirty_pwd () {
      svn_dirty_choose_pwd $ZSH_THEME_SVN_PROMPT_DIRTY_PWD $ZSH_THEME_SVN_PROMPT_CLEAN_PWD
}

function svn_dirty_choose_pwd () {
  if in_svn; then
    root=`pwd`
    if $(svn status $root 2> /dev/null | grep -Eq '^\s*[ACDIM!?L]'); then
      # Grep exits with 0 when "One or more lines were selected", return "dirty".
      echo $1
    else
      # Otherwise, no lines were found, or an error occurred. Return clean.
      echo $2
    fi
  fi
}

function svn_dirty_pwd () {
  svn_dirty_choose_pwd $ZSH_THEME_SVN_PROMPT_DIRTY_PWD $ZSH_THEME_SVN_PROMPT_CLEAN_PWD
}


