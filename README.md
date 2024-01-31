                                        ███████╗_█████╗_██████╗_
                                        ╚══███╔╝██╔══██╗██╔══██╗
                                        __███╔╝_███████║██████╔╝
                                        _███╔╝__██╔══██║██╔═══╝_
                                        ███████╗██║__██║██║_____
                                        ╚══════╝╚═╝__╚═╝╚═╝_____
                                 ⚡ zap characters from text with ease

## About

**Zap** is a command line utility which combines the basic functionalities of two well known command line utilities, **cut** and **tr**. Similar to *cut*, **Zap** can remove a character of the users choice and it removes all occurrences of that character. Like *tr*, **Zap** can remove any ASCII escape sequence of the users choice but what's different about **Zap** is that by default, it removes all occurrences of all ASCII escape characters and truncates them to a single space. **Zap** doesn't provide all of the other functionalities provided by **cut** and **tr** and was not meant to be a replacement for those utilities but was instead created to work along side those utilities.

## Why use *Zap*?

Some of the benefits of using **Zap** is that it can help reduce the number of times *cut* and *tr* may need to be executed. Example: `"some text" | zap -ch ":" | cut -d " " -f# | grep -E 'something'`. The previous example removes all ASCII escape sequences as well as the ':' character and sends the output to cut, etc.
