import std/[cmdline, terminal]

proc bytearray[T: string](target: T): seq[uint8] =
  var chars: seq[uint8]

  for ch in target:
    chars.add(uint8(ch))
  
  result = chars

proc zapHelp: void =
  stdout.write("Usage: zap [OPTION] [ARG] [TEXT] or TEXT | zap OPTION [ARG]\n")
  stdout.write("Description: remove a specific character or ASCII escape sequences from text\n\n")
  stdout.write("Option                    Description\n")
  stdout.write("------                    -----------\n")
  stdout.write(" -h, --help               show zap usage information\n")
  stdout.write(" -al, --all               remove all escape characters (default)\n")
  stdout.write(" -nl, --null              remove all \\0 characters\n")
  stdout.write(" -bl, --bell              remove all \\a characters\n")
  stdout.write(" -bs, --bspace            remove all \\b characters\n")
  stdout.write(" -ht, --htab              remove all \\t characters\n")
  stdout.write(" -lf, --lfeed             remove all \\n characters\n")
  stdout.write(" -vt, --vtab              remove all \\v characters\n")
  stdout.write(" -ff, --ffeed             remove all \\f characters\n")
  stdout.write(" -cr, --creturn           remove all \\r characters\n")
  stdout.write(" -ch, --character         remove all occurences of the given character\n")
  quit(0)

proc addSpace(bytes: seq[uint8], character: uint8 = uint8(0)): seq[uint8] =
  var pos: int = 0
  var curr, next: uint8 = 0
  var modified: seq[uint8] = @[]

  while pos < len(bytes):
    curr = bytes[pos]
    next = (try: bytes[pos+1] except IndexDefect: break)
    
    if (curr >= uint8(33) and curr < 127) and next in [uint8(0), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13)]:
      modified.add(curr)
      modified.add(uint8(32))

    elif (character >= 32 and character < 127) and (curr == character and next != character):
      modified.add(curr)
      modified.add(uint8(32))

    else:
      modified.add(curr)
    
    pos.inc()

  return modified

proc squeezeSpaces(bytes: seq[uint8]): seq[uint8] =
  var pos: int = 0
  var prev, curr, next: uint8 = 0
  var modified: seq[uint8] = @[]

  while pos < len(bytes):
    prev = (try: bytes[pos - 1] except IndexDefect: uint8(0))
    curr = bytes[pos]
    next = (try: bytes[pos + 1] except IndexDefect: break)

    if prev == uint8(32):
      if (curr == uint8(32) and next == uint8(32)):
        pos.inc()
        continue

      elif (curr == uint8(32) and next != uint8(32)):
        pos.inc()
        continue

      elif (curr != uint8(32) and next == uint8(32)):
        modified.add(curr)

      else:
        modified.add(curr)

    elif prev != uint8(32):
      if (curr == uint8(32) and next == uint8(32)):
        pos.inc()
        continue

      elif (curr != uint8(32) and next == uint8(32)):
        modified.add(curr)

      else:
        modified.add(curr)
    
    pos.inc()

  return modified

proc zap(data: string = "", option: string = "--all", character: uint8 = 0): string =
  var bytes: seq[uint8] = squeezeSpaces(addSpace(bytearray(data), character))
  var unzapped: string = ""

  for ch in bytes:
    case option:
      of "--null":
        if ch != uint8(0):
          unzapped &= char(ch)

      of "--bell":
        if ch != uint8(7):
          unzapped &= char(ch)

      of "--bspace":
        if ch != uint8(8):
          unzapped &= char(ch)

      of "--htab":
        if ch != uint8(9):
          unzapped &= char(ch)

      of "--lfeed":
        if ch != uint8(10):
          unzapped &= char(ch)

      of "--vtab":
        if ch != uint8(11):
          unzapped &= char(ch)

      of "--ffeed":
        if ch != uint8(12):
          unzapped &= char(ch)

      of "--creturn":
        if ch != uint8(13):
          unzapped &= char(ch)

      of "--all":
        if character != uint8(0):
          if ch notin [uint8(0), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), character]:
            unzapped &= char(ch)

        else:
          if ch notin [uint8(0), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13)]:
            unzapped &= char(ch)

      else:
        unzapped &= char(ch)

  return unzapped

proc main(count: int, params: seq[string]): int =
  if count == 0:
    return 0

  elif count == 1:
    var zapped: string

    if isatty(stdin):
      if params[0] in ["-h", "--help"]:
        zapHelp()

      else:
        zapped = params[0].zap("--all")
        stdout.write(zapped)
    else:
      if params[0] in ["-h", "--help"]:
        discard readAll(stdin)
        zapHelp()

      elif params[0] in ["-al", "--all"]:
        zapped = readAll(stdin).zap("--all")
        stdout.write(zapped)

      elif params[0] in ["-nl", "--null"]:
        zapped = readAll(stdin).zap("--null")
        stdout.write(zapped)

      elif params[0] in ["-bl", "--bell"]:
        zapped = readAll(stdin).zap("--bell")
        stdout.write(zapped)

      elif params[0] in ["-bs", "--bspace"]:
        zapped = readAll(stdin).zap("--bspace")
        stdout.write(zapped)

      elif params[0] in ["-ht", "--htab"]:
        zapped = readAll(stdin).zap("--htab")
        stdout.write(zapped)

      elif params[0] in ["-lf", "--lfeed"]:
        zapped = readAll(stdin).zap("--lfeed")
        stdout.write(zapped)

      elif params[0] in ["-vt", "--vtab"]:
        zapped = readAll(stdin).zap("--vtab")
        stdout.write(zapped)

      elif params[0] in ["-ff", "--ffeed"]:
        zapped = readAll(stdin).zap("--ffeed")
        stdout.write(zapped)

      elif params[0] in ["-cr", "--creturn"]:
        zapped = readAll(stdin).zap("--creturn")
        stdout.write(zapped)

      else:
        stderr.write("Invlaid argument: '" & params[0] & "'")
        return 1

  elif count == 2:
    var zapped: string

    if isatty(stdin):
      if params[0] in ["-h", "--help"]:
        stdout.write("'-h' and '--help' doesn't accept any arguments")
        return 1

      elif params[0] in ["-al", "--all"]:
        zapped = params[1].zap("--all")
        stdout.write(zapped)

      elif params[0] in ["-nl", "--null"]:
        zapped = params[1].zap("--null")
        stdout.write(zapped)

      elif params[0] in ["-bl", "--bell"]:
        zapped = params[1].zap("--bell")
        stdout.write(zapped)

      elif params[0] in ["-bs", "--bspace"]:
        zapped = params[1].zap("--bspace")
        stdout.write(zapped)

      elif params[0] in ["-ht", "--htab"]:
        zapped = params[1].zap("--htab")
        stdout.write(zapped)

      elif params[0] in ["-lf", "--lfeed"]:
        zapped = params[1].zap("--lfeed")
        stdout.write(zapped)

      elif params[0] in ["-vt", "--vtab"]:
        zapped = params[1].zap("--vtab")
        stdout.write(zapped)

      elif params[0] in ["-ff", "--ffeed"]:
        zapped = params[1].zap("--ffeed")
        stdout.write(zapped)

      elif params[0] in ["-cr", "--creturn"]:
        zapped = params[1].zap("--creturn")
        stdout.write(zapped)

      else:
        stderr.write("Invlaid argument: '" & params[0] & "'")
        return 1
    else:
      if params[0] in ["-ch", "--character"]:
        if len(params[1]) > 1:
          stderr.write("'" & params[1] & "' contains too many characters")
          return 1

        else:
          zapped = readAll(stdin).zap("--all", uint8(params[1][0]))
          stdout.write(zapped)

      else:
        return 1

  elif count == 3:
    var zapped: string

    if isatty(stdin):
      if params[0] in ["-ch", "--character"]:
        if len(params[1]) > 1:
          stderr.write("'" & params[1] & "' contains too many characters")
          return 1

        else:
          zapped = params[2].zap("--all", uint8(params[1][0]))
          stdout.write(zapped)

    else:
      return 1

  else:
    stderr.write("Too many arguments")
    return 1

  return 0

quit(main(paramCount(), commandLineParams()))
