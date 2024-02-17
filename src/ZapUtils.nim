import re
from strutils import parseInt, join

proc bytearray*[T: string](target: T): seq[uint8] =
  var chars: seq[uint8]

  for ch in target:
    chars.add(uint8(ch))
  
  result = chars

proc stringify*(bytes: seq[uint8]): string =
  var zapped: string = ""

  for ch in bytes:
    zapped &= char(ch)

  result = zapped

proc translate*(value: var string): void =
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

proc squeezeSpaces*(bytes: var seq[uint8]): seq[uint8] =
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

proc stripEnds*(unzapped: var seq[uint8]): void =
  if len(unzapped) > 0:
    const front: int = 0
    var back: int = len(unzapped) - 2

    if len(unzapped) > 0 and unzapped[front] == uint8(32):
      unzapped.delete(front)
      back = len(unzapped) - 1

    if len(unzapped) > 0 and unzapped[back] == uint8(32):
      unzapped.delete(back)

proc zapList*(original_bytes: var seq[uint8], list: string, linject: string): void =
  let linject = linject
  let list_bytes: seq[uint8] = bytearray(list)
  var linject_bytes: seq[uint8] = bytearray(linject)
  var pos: int = 0

  if len(linject_bytes) > 0:
    linject_bytes.add(uint8(32))

  if len(original_bytes) >= len(list_bytes):
    var index: int = 0

    while pos < len(list_bytes):
      while index < len(original_bytes):
        if original_bytes[index] == list_bytes[pos]:
          if linject == "":
              original_bytes[index] = uint8(32)

          else:
            original_bytes[index..index] = linject_bytes
        index.inc()
      pos.inc()
      index = 0

proc zapText*(original_bytes: var seq[uint8], text: string, tinject: string): void =
  let tinject = tinject
  let text_bytes: seq[uint8] = bytearray(text)
  var tinject_bytes: seq[uint8] = bytearray(tinject)

  if len(tinject_bytes) > 0:
    tinject_bytes.add(uint8(32))

  if len(original_bytes) >= len(text_bytes):
    var start: int = 0
    var stop: int = len(text_bytes) - 1

    while stop < len(original_bytes):
      if original_bytes[start..stop] == text_bytes:
        if tinject == "":
            original_bytes[start..stop] = @[uint8(32)]

        else:
          original_bytes[start..stop] = tinject_bytes

      start.inc()
      stop.inc()

proc checkParams*(param: string): string =
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

  elif param.contains(re"^((-t)(:{1,2})([\w\W]{1,}))$"):
    return "-t"

  else:
    stderr.write("Invalid or malformed argument -> '" & param & "'")
    quit(1)

proc splitParam*(param: string): string =
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

  elif param.startsWith(re"(-t)"):
    let value: seq[string] = param.split(re"(:)", 1)
    return value[1]

  else:
    return ""

proc zapFirst*(zapped: string): string =
  let values: seq[string] = zapped.split(re" ")
  return (try: values[0] except IndexDefect: "")

proc zapGet*(param: string, zapped: string): string =
  let values: seq[string] = zapped.split(re" ")

  try:
    return values[parseInt(param)]
  except IndexDefect:
    stderr.write("Position out of range")
    quit(1)

proc zapLast*(zapped: string): string =
  let values: seq[string] = zapped.split(re" ")
  return (try: values[^1] except IndexDefect: "")

proc zapRange*(param: string, zapped: string): string =
  let values: seq[string] = zapped.split(re" ")
  let start_stop: seq[string] = param.split(re"(,)")
  let start: int = parseInt(start_stop[0])
  let stop: int = parseInt(start_stop[1])

  try:
    return values[start..stop].join(" ")
  except IndexDefect:
    stderr.write("Indices out of range -> '" & param & "'")
    quit(1)
