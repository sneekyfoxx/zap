from std/cmdline import paramCount, commandLineParams
from terminal import isatty
import re
from strutils import parseInt, join
from strformat import fmt

proc zapHelp: void =
  const red: string = "\x1b[01;31m"
  const green: string = "\x1b[01;32m"
  const yellow: string = "\x1b[01;33m"
  const cyan: string = "\x1b[01;36m"
  const orange: string = "\x1b[01;38;02;255;160;00m"
  const reset: string = "\x1b[00m"

  stdout.write("{green}Usage{reset}: {orange}zap{reset} {yellow}[-h] [-d:TEXT [-i:TEXT] [-g:POS] [-r:START,STOP] [-f, -l]]{reset}\n\n".fmt)
  stdout.write("{cyan}Option               Description{reset}\n".fmt)
  stdout.write("{red}------               -----------{reset}\n".fmt)
  stdout.write(" {cyan}-d{reset}:{green}TEXT{reset}             {yellow}remove all ocurrences of TEXT from zapped string{reset}\n\n".fmt)
  stdout.write(" {cyan}-f{reset}                  {yellow}get the first value in the zapped string{reset}\n\n".fmt)
  stdout.write(" {cyan}-g{reset}:{green}POS{reset}              {yellow}get the value at POS in the zapped string{reset}\n\n".fmt)
  stdout.write(" {cyan}-h{reset}                  {yellow}show zap usage information{reset}\n\n".fmt)
  stdout.write(" {cyan}-i{reset}:{green}TEXT{reset}             {yellow}inject TEXT where -d:TEXT was in the zapped string{reset}\n\n".fmt)
  stdout.write(" {cyan}-l{reset}                  {yellow}get the last value in the zapped string{reset}\n\n".fmt)
  stdout.write(" {cyan}-r{reset}:{green}START,STOP{reset}       {yellow}get the value(s) from START to STOP{reset} ({green}inclusive{reset})\n".fmt)
  quit(0)

proc bytearray[T: string](target: T): seq[uint8] =
  var chars: seq[uint8]

  for ch in target:
    chars.add(uint8(ch))
  
  result = chars

proc stringify(bytes: seq[uint8]): string =
  var zapped: string = ""

  for ch in bytes:
    zapped &= char(ch)

  result = zapped

proc translate(value: var string): void =
  var pos: int = 0

  while pos < len(value):
    let curr: string = $(value[pos])
    let next: string = (try: $(value[pos + 1]) except IndexDefect: "")

    if uint8(curr[0]) == uint8('\\'):
      if next != "":
        if uint8(next[0]) == uint8('0'): value[pos..pos + 1] = "\0"
        elif uint8(next[0]) == uint8('b'): value[pos..pos + 1] = "\b"
        elif uint8(next[0]) == uint8('t'): value[pos..pos + 1] = "\t"
        elif uint8(next[0]) == uint8('n'): value[pos..pos + 1] = "\n"
        elif uint8(next[0]) == uint8('v'): value[pos..pos + 1] = "\v"
        elif uint8(next[0]) == uint8('f'): value[pos..pos + 1] = "\f"
        elif uint8(next[0]) == uint8('r'): value[pos..pos + 1] = "\r"
        elif uint8(next[0]) == uint8('\\'): value[pos..pos + 1] = "\\"
    pos.inc()

proc squeezeSpaces(bytes: var seq[uint8]): seq[uint8] =
  var pos: int = 0

  while pos < len(bytes):
    try:
      if bytes[pos] == uint8(32) and bytes[pos + 1] == uint8(32):
        bytes.delete(pos)
        pos.dec()
        continue
    except IndexDefect:
      break
    finally:
      pos.inc()

  return bytes

proc stripEnds(unzapped: var seq[uint8]): void =
  const front: int = 0
  var back: int = len(unzapped) - 2

  if len(unzapped) > 0:
    if unzapped[front] == uint8(32):
      unzapped.delete(front)
      back = len(unzapped) - 1

    if unzapped[back] == uint8(32):
      unzapped.delete(back)

proc zapDelete(original_bytes: var seq[uint8], target: string, inject: string): void =
  let inject = inject
  let target_bytes: seq[uint8] = bytearray(target)

  if len(original_bytes) >= len(target_bytes):
    var start: int = 0
    var stop: int = len(target_bytes) - 1

    while stop < len(original_bytes):
      if original_bytes[start..stop] == target_bytes:
        if inject == "":
            original_bytes[start..stop] = @[uint8(32)]

        else:
          var inject_bytes: seq[uint8] = bytearray(inject)
          inject_bytes.add(uint8(32))
          original_bytes[start..stop] = inject_bytes

      start.inc()
      stop.inc()
  return

proc zap(text: var string, target: var string, inject: var string): string =
  translate(text)
  var bytes: seq[uint8] = bytearray(text)
  var pos: int = 0

  if target != "":
    translate(target)

  if inject != "":
    translate(inject)

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

  if target != "":
    zapDelete(bytes, target, inject)

  stripEnds(bytes)
  return stringify(squeezeSpaces(bytes))

proc checkParams(param: string): string =
  if param.contains(re"^((-d)(:{1,2})([\w\W]{1,}))$"):
    return "-d"

  elif param.contains(re"^(-f)$"):
    return "-f"

  elif param.contains(re"^((-g)(:{1})(\d+))$"):
    return "-g"

  elif param.contains(re"^(-h)$"):
    return "-h"

  elif param.contains(re"^((-i)(:{1,2})([\w\W]{1,}))$"):
    return "-i"

  elif param.contains(re"^(-l)$"):
    return "-l"

  elif param.contains(re"^((-r)(:{1})(\d+)(,{1})(\d+))$"):
    return "-r"

  else:
    stderr.write("Invalid or malformed argument -> '" & param & "'")
    quit(1)

proc splitParam(param: string): string =
  if param.startsWith(re"(-d)"):
    let value: seq[string] = param.split(re"(:)", 1)
    return value[1]

  elif param.startsWith(re"(-g)"):
    let value: seq[string] = param.split(re"(:)")
    
    try:
      let number: int = parseInt(value[1])

      if number < 0:
        stderr.write("Argument to '-g' must be positive")
        quit(1)

      else:
        return $(number)
    except ValueError:
      stderr.write("Argument to '-g' must be a number")
      quit(1)

  elif param.startsWith(re"(-i)"):
    let values: seq[string] = param.split(re"(:)")
    return values[1]

  elif param.startsWith(re"(-r)"):
    let values: seq[string] = param.split(re"(:)")

    try:
      let start_stop: seq[string] = values[1].split(re"(,)")
      let start: int = parseInt(start_stop[0])
      let stop: int = parseInt(start_stop[1])

      if start < 0:
        stderr.write("'" & $(start) & "' must be positive")
        quit(1)

      elif stop < 0:
        stderr.write("'" & $(stop) & "' must be positive")
        quit(1)

      else:
        return $(start) & "," & $(stop)

    except ValueError:
      stderr.write("Arguments to '-r' must be numbers separated by a comma")
      quit(1)

  else:
    return ""

proc zapFirst(zapped: string): string =
  let values: seq[string] = zapped.split(re" ")
  return (try: values[0] except IndexDefect: "")

proc zapGet(param: string, zapped: string): string =
  let values: seq[string] = zapped.split(re" ")

  try:
    return values[parseInt(param)]
  except IndexDefect:
    stderr.write("Position out of range")
    quit(1)

proc zapLast(zapped: string): string =
  let values: seq[string] = zapped.split(re" ")
  return (try: values[^1] except IndexDefect: "")

proc zapRange(param: string, zapped: string): string =
  let values: seq[string] = zapped.split(re" ")
  let start_stop: seq[string] = param.split(re"(,)")
  let start: int = parseInt(start_stop[0])
  let stop: int = parseInt(start_stop[1])

  try:
    return values[start..stop].join(" ")
  except IndexDefect:
    stderr.write("Indices out of range -> '" & param & "'")
    quit(1)

proc activeTTY(count: int, params: seq[string]): void =
  var (text, target, inject, zapped, param1, param2) = ("", "", "", "", "", "")

  if count == 0:
    quit(0)

  elif count == 1:
    param1 = params[0].checkParams()

    if param1 == "-h":
      zapHelp()

    elif param1 in ["-d", "-g", "-l", "-r"]:
      stderr.write("Not enough arguments")
      quit(1)

    else:
      text = params[0]
      zapped = zap(text, target, inject)
      stdout.write(zapped)
      quit(0) 

  elif count == 2:
    param1 = params[0].checkParams()

    if param1 == "-d":
      text = params[1]
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapped)

    elif param1 == "-g":
      text = params[1]
      zapped = zap(text, target, inject)
      stdout.write(zapGet(splitParam(params[0]), zapped))

    elif param1 == "-h":
      stderr.write("'" & param1 & "' doesn't accept any arguments")
      quit(1)

    elif param1 in ["-l", "-r"]:
      stderr.write("Not enough arguments")
      quit(1)

  elif count == 3:
    param1 = params[0].checkParams()
    param2 = params[1].checkParams()

    if param1 == "-d" and param2 == "-f":
      text = params[2]
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-d" and param2 == "-g":
      text = params[2]
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapGet(splitParam(params[1]), zapped))

    elif param1 == "-d" and param2 == "-i":
      text = params[2]
      target = splitParam(params[0])
      inject = splitParam(params[1])
      zapped = zap(text, target, inject)
      stdout.write(zapped)

    elif param1 == "-d" and param2 == "-l":
      text = params[2]
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapLast(zapped))

    elif param1 == "-d" and param2 == "-r":
      text = params[2]
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapRange(splitParam(params[1]), zapped))

    elif param1 == "-h" xor param2 == "-h":
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
  var (text, target, inject, zapped, param1, param2, param3) = ("", "", "", "", "", "", "")

  if count == 0:
    quit(0)

  elif count == 1:
    text = readAll(stdin)
    param1 = params[0].checkParams()

    if param1 == "-d":
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapped)

    elif param1 == "-h":
      stderr.write("'" & param1 & "' doesn't accept any arguments")
      quit(1)

    elif param1 in ["-g", "-l", "-r"]:
      stderr.write("Not enough arguments")
      quit(1)

    else:
      discard readAll(stdin)
      stderr.write("Not enough arguments")
      quit(1)

  elif count == 2:
    text = readAll(stdin)
    param1 = params[0].checkParams()
    param2 = params[1].checkParams()

    if param1 == "-d" and param2 == "-f":
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-d" and param2 == "-g":
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapGet(splitParam(params[1]), zapped))

    elif param1 == "-d" and param2 == "-i":
      target = splitParam(params[0])
      inject = splitParam(params[1])
      zapped = zap(text, target, inject)
      stdout.write(zapped)

    elif param1 == "-d" and param2 == "-l":
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapLast(zapped))

    elif param1 == "-d" and param2 == "-r":
      target = splitParam(params[0])
      zapped = zap(text, target, inject)
      stdout.write(zapRange(splitParam(params[1]), zapped))

    elif param1 == "-h" xor param2 == "-h":
      stderr.write("'-h' cannot be used with other arguments")
      quit(1)

  elif count == 3:
    text = readAll(stdin)
    param1 = params[0].checkParams()
    param2 = params[1].checkParams()
    param3 = params[2].checkParams()

    if param1 == "-d" and param2 == "-r" and param3 == "-f":
      target = splitParam(params[0])
      zapped = zap(text, target, inject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapFirst(zap_range))

    elif param1 == "-d" and param2 == "-r" and param3 == "-l":
      target = splitParam(params[0])
      zapped = zap(text, target, inject)

      let zap_range: string = zapRange(splitParam(params[1]), zapped)
      stdout.write(zapLast(zap_range))

    elif param1 == "-d" and param2 == "-i" and param3 == "-f":
      target = splitParam(params[0])
      inject = splitParam(params[1])
      zapped = zap(text, target, inject)
      stdout.write(zapFirst(zapped))

    elif param1 == "-d" and param2 == "-i" and param3 == "-l":
      target = splitParam(params[0])
      inject = splitParam(params[1])
      zapped = zap(text, target, inject)
      stdout.write(zapLast(zapped))

    elif param1 == "-d" and param2 == "-i" and param3 == "-r":
      target = splitParam(params[0])
      inject = splitParam(params[1])
      var zrange: string = splitParam(params[2])
      zapped = zap(text, target, inject)

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
