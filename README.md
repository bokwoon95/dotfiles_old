quick way
``` bash
bash -c "$(curl -L https://tiny.cc/bwinitsh)"
```

To inspect the script before running it instead (`:cq` to abort the script):
``` bash
curlsh () { file=$(mktemp);curl -L "$1" > $file;vi $file && sh $file;rm $file; }
curlsh https://tiny.cc/bwinit
```
