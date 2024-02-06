                                        ███████╗_█████╗_██████╗_
                                        ╚══███╔╝██╔══██╗██╔══██╗
                                        __███╔╝_███████║██████╔╝
                                        _███╔╝__██╔══██║██╔═══╝_
                                        ███████╗██║__██║██║_____
                                        ╚══════╝╚═╝__╚═╝╚═╝_____
                                 ⚡ zap characters from text with ease

## About

**Zap** is a command line utility which combines the basic functionalities of two well known command line utilities, **cut** and **tr**. Zap doesn't have all the functionalities of *cut* or *tr* because it isn't meant to replace them. **Zap** was created to make slicing strings in the terminal a little bit easier. **Zap** removes all escape characters and truncates all spaces by default reducing the number of zaps, cuts, and tranlations in the process.

## Similarities To *cut*

- slice strings based on a given delimiter
- select a one or more fields (range in zap)

## Similarities To *tr*

- character truncation (default in zap)
- ANSII escape character deletion (not including hex and octal)
- character replacement (injection in zap)


## Why use *Zap*?

Some of the benefits of using **Zap** is that it can help reduce the number of times *cut* and *tr* may need to be executed. Example: `"some text" | zap -d:":" -l | grep -E 'something'`. The previous example removes all ASCII escape sequences as well as the ':' character, gets the last field, and sends the output to grep. In many cases you may find yourself using *zap* inplace of *cut*.

## Usage Examples

``` bash
$ example="This is some\nexample text\tfor testing the zap utility\0"
$ zap -d:'example' -i:'actual'
This is some actual text for testing the zap utility
$
```

`zap -d:TEXT [-i:TEXT] [-g:POS] [-r:START,STOP] [-f, -l] TEXT`

`TEXT | zap -d:TEXT [-i:TEXT] [-g:POS] [-r:START,STOP] [-f, -l]`
