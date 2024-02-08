## BagMan - a basic OpenMower map editor

For convenience, I like to put this repo inside a directory called *_bagman_dir* inside my home dir, then use another
shell script in my home directory (called bagman.sh) to change into that directory and execute the 'real' bagman.sh
script:

```                                                                                 
cd _bagman_dir
bash bagman.sh "$@"
```

Note that it needs to pass any args to the real bagman script.
