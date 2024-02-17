from std/cmdline import paramCount, commandLineParams
from terminal import isatty
from strformat import fmt
import ZapUtils

proc zapHelp: void =
  const red: string = "\x1b[01;31m"
  const green: string = "\x1b[01;32m"
  const yellow: string = "\x1b[01;33m"
  const cyan: string = "\x1b[01;36m"
  const orange: string = "\x1b[01;38;02;255;160;00m"
  const reset: string = "\x1b[00m"

  stdout.write("{green}Usage{reset}: {orange}zap{reset} {yellow}[-h] [-d:LIST [-i:TEXT] [-g:POS] [-r:START,STOP] [-t:TEXT] [-f, -l]]{reset}\n\n".fmt)
  stdout.write("{cyan}Option               Description{reset}\n".fmt)
  stdout.write("{red}------               -----------{reset}\n".fmt)
  stdout.write(" {cyan}-d{reset}:{green}LIST{reset}             {yellow}remove all characters in LIST from the zapped string{reset}\n\n".fmt) 
  stdout.write(" {cyan}-f{reset}                  {yellow}get the first value in the zapped string{reset}\n\n".fmt)
  stdout.write(" {cyan}-g{reset}:{green}POS{reset}              {yellow}get the value at POS in the zapped string{reset}\n\n".fmt)
  stdout.write(" {cyan}-h{reset}                  {yellow}show zap usage information{reset}\n\n".fmt)
  stdout.write(" {cyan}-i{reset}:{green}TEXT{reset}             {yellow}inject TEXT where -d:TEXT was in the zapped string{reset}\n\n".fmt)
  stdout.write(" {cyan}-l{reset}                  {yellow}get the last value in the zapped string{reset}\n\n".fmt)
  stdout.write(" {cyan}-r{reset}:{green}START,STOP{reset}       {yellow}get the value(s) from START to STOP{reset} ({green}inclusive{reset})\n\n".fmt)
  stdout.write(" {cyan}-t{reset}:{green}TEXT{reset}             {yellow}remove all ocurrences of TEXT from zapped string{reset}\n\n".fmt)
  quit(0)

proc zap(input: var string, list: var string, text: var string, linject: var string, tinject: var string): string =
  translate(list)
  translate(text)
  var bytes: seq[uint8] = bytearray(input)
  var pos: int = 0

  if linject != "":
    translate(linject)

  if tinject != "":
    translate(tinject)

  while pos < len(bytes):
    case bytes[pos]:
    of uint8(0):
      bytes[pos] = uint8(32)

    of uint8(7):
      bytes[pos] = uint8(32)

    of uint8(8):
      bytes[pos] = uint8(32)

    of uint8(9):
      bytes[pos] = uint8(32)

    of uint8(10):
      bytes[pos] = uint8(32)

    of uint8(11):
      bytes[pos] = uint8(32)

    of uint8(12):
      bytes[pos] = uint8(32)

    of uint8(13):
      bytes[pos] = uint8(32)

    else:
      pos.inc()
      continue

  if list != "":
    zapList(bytes, list, linject)
  if text != "":
    zapText(bytes, text, tinject)

  stripEnds(bytes)
  return stringify(squeezeSpaces(bytes))

proc activeTTY(count: int, params: seq[string]): void =
  var (input, list, text, linject, tinject, zapped, param1, param2, param3) = ("", "", "", "", "", "", "", "", "")

  if count == 0:
    quit(0)

  elif count == 1:
    param1 = params[0].checkParams()

    if param1 == "-h":
      zapHelp()

    elif param1 in ["-d", "-f", "-g", "-l", "-r", "-t"]:
      stderr.write("Not enough arguments")
      quit(1)

    else:
      input = params[0]
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)
      quit(0) 

  elif count == 2:
    input = params[1]
    param1 = params[0].checkParams()

    if param1 == "-d":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-f":
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-g":
      input = params[1]
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapGet(splitParam(params[0]), zapped))

    elif param1 == "-h":
      stderr.write("'" & param1 & "' doesn't accept any arguments")
      quit(1)

    elif param1 == "-i":
      stderr.write("Not enough arguments")
      quit(1)

    elif param1 == "-l":
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-r":
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapRange(splitParam(params[0]), zapped))

    elif param1 == "-t":
      input = params[1]
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

  elif count == 3:
    param1 = params[0].checkParams()
    param2 = params[1].checkParams()

    if param1 == "-d" and param2 == "-f":
      input = params[2]
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-d" and param2 == "-g":
      input = params[2]
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapGet(splitParam(params[1]), zapped))

    elif param1 == "-d" and param2 == "-i":
      input = params[2]
      list = splitParam(params[0])
      linject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-d" and param2 == "-l":
      input = params[2]
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-d" and param2 == "-r":
      input = params[2]
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapRange(splitParam(params[1]), zapped))

    elif param1 == "-d" and param2 == "-t":
      input = params[2]
      list = splitParam(params[0])
      text = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-t" and param2 == "-f":
      input = params[2]
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-t" and param2 == "-g":
      input = params[2]
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapGet(splitParam(params[1]), zapped))

    elif param1 == "-t" and param2 == "-i":
      input = params[2]
      text = splitParam(params[0])
      tinject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-t" and param2 == "-l":
      input = params[2]
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-t" and param2 == "-r":
      input = params[2]
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapRange(splitParam(params[1]), zapped))

    elif param1 == "-h" xor param2 == "-h":
      stderr.write("'-h' cannot be used with other arguments")
      quit(1)

    else:
      stderr.write("Invalid argument positioning")
      quit(1)

  elif count == 4:
    input = params[3]
    param1 = params[0].checkParams()
    param2 = params[1].checkParams()
    param3 = params[2].checkParams()

    if param1 == "-d" and param2 == "-r" and param3 == "-f":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapFirst(zap_range))

    elif param1 == "-d" and param2 == "-r" and param3 == "-l":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapLast(zap_range))

    elif param1 == "-d" and param2 == "-i" and param3 == "-f":
      list = splitParam(params[0])
      linject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-d" and param2 == "-i" and param3 == "-l":
      list = splitParam(params[0])
      linject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-d" and param2 == "-i" and param3 == "-r":
      list = splitParam(params[0])
      linject = splitParam(params[1])
      var zrange: string = splitParam(params[2])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(zrange, zapped)
      stdout.write(zap_range)

    elif param1 == "-t" and param2 == "-r" and param3 == "-f":
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapFirst(zap_range))

    elif param1 == "-t" and param2 == "-r" and param3 == "-l":
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapLast(zap_range))

    elif param1 == "-t" and param2 == "-i" and param3 == "-f":
      text = splitParam(params[0])
      tinject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-t" and param2 == "-i" and param3 == "-l":
      text = splitParam(params[0])
      tinject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-t" and param2 == "-i" and param3 == "-r":
      text = splitParam(params[0])
      tinject = splitParam(params[1])
      var zrange: string = splitParam(params[2])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(zrange, zapped)
      stdout.write(zap_range)

    elif param1 == "-d" and param2 == "-t" and param3 == "-f":
      list = splitParam(params[0])
      text = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-d" and param2 == "-t" and param3 == "-g":
      list = splitParam(params[0])
      text = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapGet(splitParam(params[2]), zapped))

    elif param1 == "-d" and param2 == "-t" and param3 == "-i":
      list = splitParam(params[0])
      text = splitParam(params[1])
      linject = splitParam(params[2])
      tinject = splitParam(params[2])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-d" and param2 == "-t" and param3 == "-l":
      list = splitParam(params[0])
      text = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-d" and param2 == "-t" and param3 == "-r":
      list = splitParam(params[0])
      text = splitParam(params[1])
      var zrange: string = splitParam(params[2])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(zrange, zapped)
      stdout.write(zap_range)

    elif param1 == "-h" xor param2 == "-h" xor param3 == "-h":
      stderr.write("'-h' cannot be used with other arguments")
      quit(1)

    else:
      stderr.write("Invalid argument positioning")
      quit(1)

  else:
    stderr.write("Too many arguments\n")
    quit(1)

  quit(0)

proc inactiveTTY(count: int, params: seq[string]): void =
  var (input, list, text, linject, tinject, zapped, param1, param2, param3) = ("", "", "", "", "", "", "", "", "")

  if count == 0:
    quit(0)

  elif count == 1:
    input = readAll(stdin)
    param1 = params[0].checkParams()

    if param1 == "-d":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-f":
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-g":
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapGet(splitParam(params[0]), zapped))

    elif param1 == "-h":
      stderr.write("'" & param1 & "' doesn't accept any arguments")
      quit(1)

    elif param1 == "-i":
      stderr.write("Not enough arguments")
      quit(1)

    elif param1 == "-l":
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-r":
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapRange(splitParam(params[0]), zapped))

    elif param1 == "-t":
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    else:
      discard readAll(stdin)
      stderr.write("Not enough arguments")
      quit(1)

  elif count == 2:
    input = readAll(stdin)
    param1 = params[0].checkParams()
    param2 = params[1].checkParams()

    if param1 == "-d" and param2 == "-f":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-d" and param2 == "-g":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapGet(splitParam(params[1]), zapped))

    elif param1 == "-d" and param2 == "-i":
      list = splitParam(params[0])
      linject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-d" and param2 == "-l":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-d" and param2 == "-r":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapRange(splitParam(params[1]), zapped))

    elif param1 == "-d" and param2 == "-t":
      list = splitParam(params[0])
      text = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-t" and param2 == "-f":
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-t" and param2 == "-g":
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapGet(splitParam(params[1]), zapped))

    elif param1 == "-t" and param2 == "-i":
      text = splitParam(params[0])
      tinject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-t" and param2 == "-l":
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-t" and param2 == "-r":
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapRange(splitParam(params[1]), zapped))

    elif param1 == "-h" xor param2 == "-h":
      stderr.write("'-h' cannot be used with other arguments")
      quit(1)

  elif count == 3:
    input = readAll(stdin)
    param1 = params[0].checkParams()
    param2 = params[1].checkParams()
    param3 = params[2].checkParams()

    if param1 == "-d" and param2 == "-r" and param3 == "-f":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapFirst(zap_range))

    elif param1 == "-d" and param2 == "-r" and param3 == "-l":
      list = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapLast(zap_range))

    elif param1 == "-d" and param2 == "-i" and param3 == "-f":
      list = splitParam(params[0])
      linject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-d" and param2 == "-i" and param3 == "-l":
      list = splitParam(params[0])
      linject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-d" and param2 == "-i" and param3 == "-r":
      list = splitParam(params[0])
      linject = splitParam(params[1])
      var zrange: string = splitParam(params[2])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(zrange, zapped)
      stdout.write(zap_range)

    elif param1 == "-t" and param2 == "-r" and param3 == "-f":
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapFirst(zap_range))

    elif param1 == "-t" and param2 == "-r" and param3 == "-l":
      text = splitParam(params[0])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapLast(zap_range))

    elif param1 == "-t" and param2 == "-i" and param3 == "-f":
      text = splitParam(params[0])
      tinject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-t" and param2 == "-i" and param3 == "-l":
      text = splitParam(params[0])
      tinject = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-t" and param2 == "-i" and param3 == "-r":
      text = splitParam(params[0])
      tinject = splitParam(params[1])
      var zrange: string = splitParam(params[2])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(zrange, zapped)
      stdout.write(zap_range)

    elif param1 == "-d" and param2 == "-t" and param3 == "-f":
      list = splitParam(params[0])
      text = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-d" and param2 == "-t" and param3 == "-g":
      list = splitParam(params[0])
      text = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapGet(splitParam(params[2]), zapped))

    elif param1 == "-d" and param2 == "-t" and param3 == "-i":
      list = splitParam(params[0])
      text = splitParam(params[1])
      linject = splitParam(params[2])
      tinject = splitParam(params[2])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapped)

    elif param1 == "-d" and param2 == "-t" and param3 == "-l":
      list = splitParam(params[0])
      text = splitParam(params[1])
      zapped = zap(input, list, text, linject, tinject)
      stdout.write(zapLast(zapped))

    elif param1 == "-d" and param2 == "-t" and param3 == "-r":
      list = splitParam(params[0])
      text = splitParam(params[1])
      var zrange: string = splitParam(params[2])
      zapped = zap(input, list, text, linject, tinject)

      let zap_range: string = zapRange(zrange, zapped)
      stdout.write(zap_range)

    elif param1 == "-h" xor param2 == "-h" xor param3 == "-h":
      stderr.write("'-h' cannot be used with other arguments")
      quit(1)

    else:
      stderr.write("Invalid argument positioning")
      quit(1)

  else:
    stderr.write("Too many arguments\n")
    quit(1)

  quit(0)

if isatty(stdin):
  activeTTY(paramCount(), commandLineParams())

else:
  inactiveTTY(paramCount(), commandLineParams())
