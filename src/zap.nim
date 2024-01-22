import std/[cmdline, terminal]

proc bytearray[T: string](target: T): seq[uint8] =
  var chars: seq[uint8]

  for ch in target:
    chars.add(uint8(ch))
  
  result = chars

proc zap(data: string = "", option: string = "--all"): string =
  var targets: seq[uint8] = bytearray(data)
  var unzapped: string = ""

  for ch in targets:
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
        if ch notin [uint8(0), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13)]:
          unzapped &= char(ch)

      else:
        unzapped &= char(ch)

  return unzapped

proc main(count: int, params: seq[string]): int =
  if count == 0:
    return 0

  elif count == 1:
    if isatty(stdin):
      stdout.write(zap(params[0]))
    else:
      var zapped: string

      if params[0] in ["-al", "--all"]:
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
      if params[0] in ["-al", "--all"]:
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
      stderr.write("Too many arguments")
      return 1

  else:
    return 1

quit(main(paramCount(), commandLineParams()))
