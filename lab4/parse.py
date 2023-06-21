import os

count = 0
vendor = None
with open('devices.txt') as f:
	lines = f.readlines()
	for line in lines:
		line = line.strip(" \n\r")

		if "" == line.strip() or line[0] == "#":
			continue # comment or empty line
		elif line[0] == "\t" and line[1] != "\t":
			# device
			if vendor is None:
				continue
			try:
				code, description = line.strip().split("  ", 1)
			except:
				print("ERROR", repr(line), line.strip().split("  ", 1))
				quit()
			with open("db/%s/%s" % (vendor, code), "x") as out:
				out.write(description)

		elif line[0] != "\t":
			# vendor
			code, description = line.strip().split("  ", 1)
			vendor = code
			count += 1
			os.mkdir("db/%s" % code)
			with open("db/%s/name" % code, "x") as out:
				out.write(description)
			
		else:
			# subvendor, etc ...
			pass