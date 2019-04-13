#!/bin/bash

gitconfig() {

  # alias 'g' to 'git' if user has not already used it
  [ "${SHELL##*/}" == "zsh" ] && shellrc=$HOME/.zshrc
  [ "${SHELL##*/}" == "bash" ] && shellrc=$HOME/.bashrc
  if ! grep "^alias g=" $shellrc >/dev/null 2>&1; then
    echo "alias g=\"git \"" >> $shellrc
    source $shellrc
  fi

  #~~~ settings ~~~ #
  printf "\n#~~~ settings ~~~#\n"


  ## user ##
  # name
  if ! git config --global user.name >/dev/null 2>&1; then
    read -p "user.name not found, please enter your name: " name
    git config --global user.name "$name"
  fi
  # email
  if ! git config --global user.email >/dev/null 2>&1; then
    read -p "user.email not found, please enter your email: " email
    git config --global user.email "$email"
  fi
  echo "user.name : $(git config --global user.name)"
  echo "user.email : $(git config --global user.email)"


  ## [credential] ##
  # helper
  if ! git config --global credential.helper >/dev/null 2>&1; then
    if [[ "$(uname -s)" == "Linux" ]]; then
      git config --global credential.helper "cache --timeout=86400"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
      git config --global credential.helper "osxkeychain"
    elif [[ "$(uname -s)" == "MINGW"* || "$(uname -s)" == "CYGWIN"* ]]; then
      git config --global credential.helper "manager"
    fi
  fi; echo "credential.helper : $(git config --global credential.helper)"


  ## [core] ##
  if ! git config --global core.excludesfile >/dev/null 2>&1; then
    git config --global core.excludesfile "~/.gitignore"
  fi; echo "core.excludesfile : $(git config --global core.excludesfile)"
  if ! git config --global core.pager >/dev/null 2>&1; then
    git config --global core.pager "less"
  fi; echo "core.pager : $(git config --global core.pager)"
  if ! git config --global core.editor >/dev/null 2>&1; then
    git config --global core.editor "vim"
  fi; echo "core.editor : $(git config --global core.editor)"


  ## [pull] ##
  if ! git config --global pull.rebase >/dev/null 2>&1; then
    git config --global pull.rebase true
  fi; echo "pull.rebase : $(git config --global pull.rebase)"


  ## [diff] ##
  if ! git config --global diff.tool >/dev/null 2>&1; then
    git config --global diff.tool "vimdiff"
  fi; echo "diff.tool : $(git config --global diff.tool)"
  if ! git config --global diff.algorithm >/dev/null 2>&1; then
    git config --global diff.algorithm "patience"
  fi; echo "diff.algorithm : $(git config --global diff.algorithm)"


  ## [difftool] ##
  if ! git config --global difftool.prompt >/dev/null 2>&1; then
    git config --global difftool.prompt true
  fi; echo "difftool.prompt : $(git config --global difftool.prompt)"


  ## [commit] ##
  if ! git config --global commit.verbose >/dev/null 2>&1; then
    git config --global commit.verbose true
  fi; echo "commit.verbose : $(git config --global commit.verbose)"


  ## [pager] ##
  if [ ! -f "/usr/local/opt/git/share/git-core/contrib/diff-highlight/diff-highlight" ]; then
    sudo curl https://raw.githubusercontent.com/git/git/fd99e2bda0ca6a361ef03c04d6d7fdc7a9c40b78/contrib/diff-highlight/diff-highlight -Lo /usr/local/bin/diff-highlight --create-dirs || dhfail="true"
    sudo chmod a+x /usr/local/bin/diff-highlight || dhfail="true"
    dhpath="/usr/local/bin/diff-highlight"
  else
    dhpath="/usr/local/opt/git/share/git-core/contrib/diff-highlight/diff-highlight"
  fi

  if [ \"$dhfail\" = "" ]; then
    if ! git config --global pager.log >/dev/null 2>&1; then
      git config --global pager.log "$dhpath | less -RiMSFX#4"
    fi; echo "pager.log : $(git config --global pager.log)"
    if ! git config --global pager.show >/dev/null 2>&1; then
      git config --global pager.show "$dhpath | less -RiMSFX#4"
    fi; echo "pager.show : $(git config --global pager.show)"
    if ! git config --global pager.diff >/dev/null 2>&1; then
      git config --global pager.diff "$dhpath | less -RiMSFX#4"
    fi; echo "pager.diff : $(git config --global pager.diff)"


    ## [interactive] ##
    if ! git config --global interactive.diffFilter >/dev/null 2>&1; then
      git config --global interactive.diffFilter "$dhpath"
    fi; echo "interactive.diffFilter : $(git config --global interactive.diffFilter)"


    ## [color] ##
    if ! git config --global color.diff >/dev/null 2>&1; then
      git config --global color.diff "always"
    fi; echo "color.diff : $(git config --global color.diff)"
  fi


  #~~~ babygit ~~~#
  printf "\n#~~~ babygit ~~~#\n"


  if ! git config --global alias.s >/dev/null 2>&1; then
    git config --global alias.s "status"
    echo "alias s ✓"
  else
    echo "alias s already defined"
  fi; # s

  if ! git config --global alias.l >/dev/null 2>&1; then
    git config --global alias.l "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --reflog"
    echo "alias l ✓"
  else
    echo "alias l already defined"
  fi; # l

  if ! git config --global alias.ll >/dev/null 2>&1; then
    git config --global alias.ll "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    echo "alias ll ✓"
  else
    echo "alias ll already defined"
  fi; # ll

  if ! git config --global alias.commits >/dev/null 2>&1; then
    git config --global alias.commits "!commits() {
    if [ \"\$#\" -eq 0 ];
    then git add . && git commit -v;
    else git add . && git commit -vm \"\$@\";
    fi; }; commits"
    echo "alias commits ✓"
  else
    echo "alias commits already defined"
  fi; # commits

  if ! git config --global alias.commitpush >/dev/null 2>&1; then
    git config --global alias.commitpush "!commitpush() {
    if [ \"\$#\" -eq 0 ];
    then git add . && git commit -v && git push origin \$(git branch | grep \\* | cut -d ' ' -f2);
    else git add . && git commit -vm \"\$@\" && git push origin \$(git branch | grep \\* | cut -d ' ' -f2);
    fi; }; commitpush"
    echo "alias commitpush ✓"
  else
    echo "alias commitpush already defined"
  fi; # commitpush

  if ! git config --global alias.somecommitpush >/dev/null 2>&1; then
    git config --global alias.somecommitpush "!somecommitpush() {
    if [ \"\$#\" -eq 0 ];
    then git commit -v && git push origin \$(git branch | grep \\* | cut -d ' ' -f2);
    else git commit -vm \"\$@\" && git push origin \$(git branch | grep \\* | cut -d ' ' -f2);
    fi; }; somecommitpush"
    echo "alias somecommitpush ✓"
  else
    echo "alias somecommitpush already defined"
  fi; # somecommitpush

  if ! git config --global alias.pulll >/dev/null 2>&1; then
    git config --global alias.pulll "!pulll() {
    old=\$(git stash list | wc -l);
    git stash --include-untracked && git pull --rebase origin \$(git branch | grep \\* | cut -d ' ' -f2);
    new=\$(git stash list | wc -l);
    [ \"\$old\" != \"\$new\" ] && git stash pop; }; pulll"
    echo "alias pulll ✓"
  else
    echo "alias pulll already defined"
  fi; # pulll

  if ! git config --global alias.goto >/dev/null 2>&1; then
    git config --global alias.goto "!goto() {
    git checkout --quiet \"\$1\"
    && git branch -f master HEAD
    && git checkout --quiet master; 
    git status; }; goto"
    echo "alias goto ✓"
  else
    echo "alias goto already defined"
  fi; # goto

  if ! git config --global alias.fixpush >/dev/null 2>&1; then
    git config --global alias.fixpush "!git reset --soft HEAD~1
    && git reset .
    && git stash --include-untracked
    && git pull --rebase origin \$(git branch | grep \\* | cut -d ' ' -f2)
    && git stash pop"
    echo "alias fixpush ✓"
  else
    echo "alias fixpush already defined"
  fi; # fixpush

  if ! git config --global alias.forcepull >/dev/null 2>&1; then
    git config --global alias.forcepull "!git fetch --all
    && git reset --hard origin/\$(git branch | grep \\* | cut -d ' ' -f2)"
    echo "alias forcepull ✓"
  else
    echo "alias forcepull already defined"
  fi; # forcepull

  if ! git config --global alias.forcepush >/dev/null 2>&1; then
    git config --global alias.forcepush "push -f origin \$(git branch | grep \\* | cut -d ' ' -f2)"
    echo "alias forcepush ✓"
  else
    echo "alias forcepush already defined"
  fi; # forcepush

  if ! git config --global alias.undocommit >/dev/null 2>&1; then
    git config --global alias.undocommit "!git reset --soft HEAD~1 && git reset ."
    echo "alias undocommit ✓"
  else
    echo "alias undocommit already defined"
  fi; # undocommit

  if ! git config --global alias.cheatsheet >/dev/null 2>&1; then
    git config --global alias.cheatsheet "!
    echo '   s                     git status';
    echo '   l                     Shows the commit log';
    echo;
    echo '   commits [msg]         Make new commit with a message';
    echo '   commitpush [msg]      Make new commit with a message & push to GitHub';
    echo '   pulll                 git pull without overwriting local files';
    echo;
    echo '   goto [commit]         Goto a particular commit';
    echo '   fixpush               Fixes a failed push if you forgot to pull before pushing';
    echo '   forcepull             Forcibly overwrite your repo with GitHubs repo';
    echo '   forcepush             Forcibly overwrite Githubs repo with your repo';
    echo '   undocommit            Undo your last commit from the git log';
    echo '                         The changes will still be there, just uncommitted';
    echo;
    "
    echo "alias cheatsheet ✓"
  else
    echo "alias cheatsheet already defined"
  fi; # cheatsheet


  #~~~ convenience ~~~#
  printf "\n#~~~ convenience ~~~#\n"


  if ! git config --global alias.b >/dev/null 2>&1; then
    git config --global alias.b "branch"
    echo "alias b ✓"
  else
    echo "alias b already defined"
  fi; # b
  if ! git config --global alias.ra >/dev/null 2>&1; then
    git config --global alias.ra "reset ."
    echo "alias ra ✓"
  else
    echo "alias ra already defined"
  fi; # ra
  if ! git config --global alias.a >/dev/null 2>&1; then
    git config --global alias.a "add"
    echo "alias a ✓"
  else
    echo "alias a already defined"
  fi; # a
  if ! git config --global alias.aa >/dev/null 2>&1; then
    git config --global alias.aa "add ."
    echo "alias aa ✓"
  else
    echo "alias aa already defined"
  fi; # aa
  if ! git config --global alias.ap >/dev/null 2>&1; then
    git config --global alias.ap "add -p"
    echo "alias ap ✓"
  else
    echo "alias ap already defined"
  fi; # ap
  if ! git config --global alias.c >/dev/null 2>&1; then
    git config --global alias.c "checkout"
    echo "alias c ✓"
  else
    echo "alias c already defined"
  fi; # c
  if ! git config --global alias.cb >/dev/null 2>&1; then
    git config --global alias.cb "checkout -b"
    echo "alias cb ✓"
  else
    echo "alias cb already defined"
  fi; # cb
  if ! git config --global alias.diffc >/dev/null 2>&1; then
    git config --global alias.diffc "diff --cached"
    echo "alias diffc ✓"
  else
    echo "alias diffc already defined"
  fi; # diffc
  if ! git config --global alias.d >/dev/null 2>&1; then
    git config --global alias.d "difftool"
    echo "alias d ✓"
  else
    echo "alias d already defined"
  fi; # d
  if ! git config --global alias.dc >/dev/null 2>&1; then
    git config --global alias.dc "difftool --cached"
    echo "alias dc ✓"
  else
    echo "alias dc already defined"
  fi; # dc
  if ! git config --global alias.co >/dev/null 2>&1; then
    git config --global alias.co "commit"
    echo "alias co ✓"
  else
    echo "alias co already defined"
  fi; # co
  if ! git config --global alias.checkdangling >/dev/null 2>&1; then
    git config --global alias.checkdangling "fsck --unreachable --no-reflogs"
    echo "alias checkdangling ✓"
  else
    echo "alias checkdangling already defined"
  fi; # checkdangling
  if ! git config --global alias.prunedangling >/dev/null 2>&1; then
    git config --global alias.prunedangling "!git reflog expire --expire-unreachable=now --all;
    git gc --prune=now;"
    echo "alias prunedangling ✓"
  else
    echo "alias prunedangling already defined"
  fi; # prunedangling
  if ! git config --global alias.em >/dev/null 2>&1; then
    git config --global alias.em "!em() {
    [ -z \"\$EDITOR\" ] && EDITOR='vim';
    \$EDITOR \$(git status --porcelain | awk '{print \$2}'); }; em"
    echo "alias em ✓"
  else
    echo "alias em already defined"
  fi; # em
  if ! git config --global alias.ec >/dev/null 2>&1; then
    git config --global alias.ec "!ec() {
    [ -z \"\$EDITOR\" ] && EDITOR='vim';
    git diff --name-only | uniq | xargs \$EDITOR; }; ec"
    echo "alias ec ✓"
  else
    echo "alias ec already defined"
  fi; # ec
  if ! git config --global alias.copyfile >/dev/null 2>&1; then
    git config --global alias.copyfile "!copyfile() {
    fname=\"\${2%.*}\";
    fext=\".\${2##*.}\";
    [ \"\$fname\" = \"\$fext\" ] && fext='';
    branch=\$(echo \"\$1\" | sed 's/[[:space:]]\\{1,\\}/_/g');
    git show \"\$1\":\"\$2\" > \"\$fname-\$branch\$fext\";
    git status; }; copyfile"
    echo "alias copyfile ✓"
  else
    echo "alias copyfile already defined"
  fi; # copyfile
  if ! git config --global alias.overwrite >/dev/null 2>&1; then
    git config --global alias.overwrite "!overwrite() {
    git checkout \"\$1\" -- \"\$2\";
    git status; }; overwrite"
    echo "alias overwrite ✓"
  else
    echo "alias overwrite already defined"
  fi; # overwrite
  if ! git config --global alias.ac >/dev/null 2>&1; then
    git config --global alias.ac "!ac() {
    if [ \"\$#\" -eq 0 ];
    then git add . && git commit -v;
    else git add . && git commit -vm \"\$@\";
    fi; }; ac"
    echo "alias ac ✓"
  else
    echo "alias ac already defined"
  fi; # ac
  if ! git config --global alias.cpush >/dev/null 2>&1; then
    git config --global alias.cpush "!cpush() {
    if [ \"\$#\" -eq 0 ];
    then git commit -v && git push origin \$(git branch | grep \\* | cut -d ' ' -f2);
    else git commit -vm \"\$@\" && git push origin \$(git branch | grep \\* | cut -d ' ' -f2);
    fi; }; cpush"
    echo "alias cpush ✓"
  else
    echo "alias cpush already defined"
  fi; # cpush
  if ! git config --global alias.acpush >/dev/null 2>&1; then
    git config --global alias.acpush "!acpush() {
    if [ \"\$#\" -eq 0 ];
    then git add . && git commit -v && git push origin \$(git branch | grep \\* | cut -d ' ' -f2);
    else git add . && git commit -vm \"\$@\" && git push origin \$(git branch | grep \\* | cut -d ' ' -f2);
    fi; }; acpush"
    echo "alias acpush ✓"
  else
    echo "alias acpush already defined"
  fi; # acpush


  # https://thoughtbot.com/blog/sed-102-replace-in-place
  # https://stackoverflow.com/a/11163357
  sed -i.bak 's/[[:space:]]*\\n[[:space:]]*/\\\'$'\n\t/g' $HOME/.gitconfig && rm $HOME/.gitconfig.bak

}

gitconfig

echo
echo "---------------"
echo "git config done"
echo "---------------"
