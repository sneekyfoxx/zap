import std/[cmdline, terminal, re, strutils]

proc zapHelp: void =
  stdout.write("Usage: zap [OPTIONS] [TEXT] || TEXT | zap [OPTIONS]\n")
  stdout.write("Description: remove a specific character or ASCII escape sequences from text\n\n")
  stdout.write("Option                    Description\n")
  stdout.write("------                    -----------\n")
  stdout.write(" -c:CHAR                  remove all occurences of the given character\n")
  stdout.write(" -f                       get the first value in the zapped string\n")
  stdout.write(" -g:POS                   get the value at POS in the zapped string\n")
  stdout.write(" -h                       show zap usage information\n")
  stdout.write(" -i:CHAR                  inject CHAR where -c:CHAR was in the zapped string\n")
  stdout.write(" -l                       get the last value in the zapped string\n")
  stdout.write(" -r:START,STOP            get the value(s) starting at START and stoping at STOP (inclusive)\n")
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

proc translate(value: string): string =
  case value:
  of r"\0": return "\0"
  of r"\a": return "\a"
  of r"\b": return "\b"
  of r"\t": return "\t"
  of r"\n": return "\n"
  of r"\v": return "\v"
  of r"\f": return "\f"
  of r"\r": return "\r"
  else: return value

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

proc zap(data: string = "", character: uint8 = 0, inject: uint8 = 0): string =
  var bytes: seq[uint8] = bytearray(data)
  var pos: int = 0

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
      if character != uint8(0) and bytes[pos] == character:
        if inject != uint8(0):
          bytes[pos] = inject

        else:
          bytes[pos] = uint8(32)

    pos.inc()

  stripEnds(bytes)
  return stringify(squeezeSpaces(bytes))

proc checkParams(param: string): string =
  if param.contains(re"^((-c)(:{1,2})([\w\W]{1}))$"):
    return "-c"

  elif param.contains(re"^(-f)$"):
    return "-f"

  elif param.contains(re"^((-g)(:{1})(\d+))$"):
    return "-g"

  elif param.contains(re"^(-h)$"):
    return "-h"

  elif param.contains(re"^((-i)(:{1,2})([\w\W]{1,2}))$"):
    return "-i"

  elif param.contains(re"^(-l)$"):
    return "-l"

  elif param.contains(re"^((-r)(:{1})(\d+)(,{1})(\d+))$"):
    return "-r"

  else:
    stderr.write("Invalid or malformed argument -> '" & param & "'")
    quit(1)

proc splitParam(param: string): string =
  if param.startsWith(re"(-c)"):
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

proc zapInjection(param: string): string =
  if len(param) == 2 and param notin [r"\0", r"\a", r"\b", r"\t", r"\n", r"\v", r"\f", r"\r"]:
    stderr.write("Too many characters -> '" & param & "' isn't an escape character")
    quit(1)

  else:
    return translate(param)

proc main(count: int, params: seq[string]): int =
  var zapped, param1, param2, param3: string

  if count == 0:
    return 0

  elif count == 1:
    if isatty(stdin): # if is a terminal
      param1 = params[0].checkParams()

      if param1 == "-h":
        zapHelp()

      elif param1 in ["-c", "-g", "-l", "-r"]:
        stderr.write("Not enough arguments")
        return 1

      else:
        zapped = params[0].zap()
        stdout.write(zapped)
        return 0 

    else: # if not a terminal
      param1 = params[0].checkParams()

      if param1 == "-c":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = readAll(stdin).zap(character)
        stdout.write(zapped)

      elif param1 == "-h":
        stderr.write("'" & param1 & "' doesn't accept any arguments")
        return 1

      elif param1 in ["-g", "-l", "-r"]:
        stderr.write("Not enough arguments")
        return 1

      else:
        discard readAll(stdin)
        stderr.write("Not enough arguments")
        return 1

  elif count == 2:
    if isatty(stdin):
      param1 = params[0].checkParams()

      if param1 == "-c":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = params[1].zap(character)
        stdout.write(zapped)

      elif param1 == "-g":
        zapped = params[1].zap()
        stdout.write(zapGet(splitParam(params[0]), zapped))

      elif param1 == "-h":
        stderr.write("'" & param1 & "' doesn't accept any arguments")
        return 1

      elif param1 in ["-l", "-r"]:
        stderr.write("Not enough arguments")
        return 1

    else:
      param1 = params[0].checkParams()
      param2 = params[1].checkParams()

      if param1 == "-c" and param2 == "-f":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = readAll(stdin).zap(character)
        stdout.write(zapFirst(zapped))

      elif param1 == "-c" and param2 == "-g":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = readAll(stdin).zap(character)
        stdout.write(zapGet(splitParam(params[1]), zapped))

      elif param1 == "-c" and param2 == "-i":
        let character: uint8 = uint8(splitParam(params[0])[0])
        let injection: string = zapInjection(splitParam(params[1]))
        zapped = readAll(stdin).zap(character, uint8(injection[0]))
        stdout.write(zapped)

      elif param1 == "-c" and param2 == "-l":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = readAll(stdin).zap(character)
        stdout.write(zapLast(zapped))

      elif param1 == "-c" and param2 == "-r":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = readAll(stdin).zap(character)
        stdout.write(zapRange(splitParam(params[1]), zapped))

      elif param1 == "-h" xor param2 == "-h":
        stderr.write("'-h' cannot be used with other arguments")
        return 1

  elif count == 3:
    param1 = params[0].checkParams()
    param2 = params[1].checkParams()

    if isatty(stdin):
      if param1 == "-c" and param2 == "-f":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = params[2].zap(character)
        stdout.write(zapFirst(zapped))

      elif param1 == "-c" and param2 == "-g":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = params[2].zap(character)
        stdout.write(zapGet(splitParam(params[1]), zapped))

      elif param1 == "-c" and param2 == "-i":
        let character: uint8 = uint8(splitParam(params[0])[0])
        let injection: string = zapInjection(splitParam(params[1]))
        zapped = params[2].zap(character, uint8(injection[0]))
        stdout.write(zapped)

      elif param1 == "-c" and param2 == "-l":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = params[2].zap(character)
        stdout.write(zapLast(zapped))

      elif param1 == "-c" and param2 == "-r":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = params[2].zap(character)
        stdout.write(zapRange(splitParam(params[1]), zapped))

      elif param1 == "-h" xor param2 == "-h":
        stderr.write("'-h' cannot be used with other arguments")
        return 1

      else:
        stderr.write("Invalid argument positioning")
        return 1

    else:
      param1 = params[0].checkParams()
      param2 = params[1].checkParams()
      param3 = params[2].checkParams()

      if param1 == "-c" and param2 == "-r" and param3 == "-f":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = readAll(stdin).zap(character)
        let zap_range: string = zapRange(splitParam(params[1]), zapped)
        stdout.write(zapFirst(zap_range))

      elif param1 == "-c" and param2 == "-r" and param3 == "-l":
        let character: uint8 = uint8(splitParam(params[0])[0])
        zapped = readAll(stdin).zap(character)
        let zap_range: string = zapRange(splitParam(params[1]), zapped)
        stdout.write(zapLast(zap_range))

      elif param1 == "-h" xor param2 == "-h" xor param3 == "-h":
        stderr.write("'-h' cannot be used with other arguments")
        return 1

      else:
        stderr.write("Invalid argument positioning")
        return 1

  else:
    stderr.write("Too many arguments\n")
    return 1

  return 0

quit(main(paramCount(), commandLineParams()))
