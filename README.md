## Quick way
``` bash
bash -c "$(curl -L https://tiny.cc/bwinit)"
```

## Inspecting the script before running it
``` bash
expandurl() { curl -sIL "$1" 2>&1 | awk '/^Location/ {print $2}' | tail -n1; }
curlsh() { file=$(mktemp);curl -L "$1" > $file;vi $file && sh $file;rm $file; }
temp=$(expandurl https://tiny.cc/bwinit); temp=${temp%$'\r'}; echo $temp
```
The output of the above should match `https://raw.githubusercontent.com/bokwoon95/dotfiles/master/init.sh`. If it matches, you can curl the script over for inspection before running it (abort the script with `:cq` while in vi).
``` bash
curlsh $temp
```
