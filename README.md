                                        ███████╗_█████╗_██████╗_
                                        ╚══███╔╝██╔══██╗██╔══██╗
                                        __███╔╝_███████║██████╔╝
                                        _███╔╝__██╔══██║██╔═══╝_
                                        ███████╗██║__██║██║_____
                                        ╚══════╝╚═╝__╚═╝╚═╝_____
                                 ⚡ zap characters from text with ease

## About

**Zap** is a command line utility which combines the basic functionalities of two well known command line utilities, **cut** and **tr**. Zap doesn't have all the functionalities of *cut* or *tr* because it isn't meant to replace them. **Zap** was created to make slicing strings in the terminal a little bit easier.

## Similarities To *cut*

- slice strings based on a given delimiter
- select a one or more fields

## Similarities To *tr*

- able to truncate characters
- able to remove a character (ANSII escape characters included)

## Why use *Zap*?

Some of the benefits of using **Zap** is that it can help reduce the number of times *cut* and *tr* may need to be executed. Example: `"some text" | zap -c:":" -l | grep -E 'something'`. The previous example removes all ASCII escape sequences as well as the ':' character, gets the last field, and sends the output to grep. In many cases you may find yourself using *zap* inplace of *cut*.

## Usage Examples

`zap -c:'CHAR' [-g:POS] [[-r:START,STOP] [-f | -l]] TEXT`

`TEXT | zap -c:'CHAR' [-g:POS] [[-r:START,STOP] [-f | -l]]`
