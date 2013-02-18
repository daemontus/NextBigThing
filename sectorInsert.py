import sys
import os
import mmap
import math

def loadFiles():

	print 

	tmp = "temp.bin"
	
	#In case of wrong input, show help
	if(len(sys.argv) != 4 or sys.argv[1] == "help" or sys.argv[1] == "-h"):
		print "This program accepts two filenames and one number as parameters and requires installed NASM compiler"
		print "First - assembly source file"
		print "Second - output .vid(fix sized) disc where compiled assembly should be inserted"
		print "Third - number of first desired sector"
		print "(set desired sector to 0 and make bytes 511 and 512 0xAA55 to make disc bootalbe)"
		print
		return

	if(not os.path.exists(sys.argv[1])):
		print "Assembly file does not exist"
		print
		return
	if(not os.path.exists(sys.argv[2])):
		print "Virtual disc image does not exist"
		print
		return	

	if(not sys.argv[3].isdigit()):
		print "Not valid sector number"
		print
		return

	#compile the assembly file
	os.system("nasm -f bin -o "+tmp+" "+sys.argv[1])

	if(os.path.exists(tmp)):
		print "Compilation successful"
		print "File size: "+str(os.path.getsize(tmp))
	else:
		print "Compilation unsuccessful - check above for errors"
		print
		return

	with open(sys.argv[2], "r+b") as f:
		map = mmap.mmap(f.fileno(),0)

		#go to fixed position where header size is located
		map.seek(0x158)

		#read header size (is writen in little-endian, so 00 20 00 00 means 20 00)
		adress = 0
		for i in range(4):
			adress += ord(map.read(1))*math.pow(16,2*i)

		adress = int(adress)
		adress += int(sys.argv[3])*512
		with open(tmp, "r+b") as g:
			mapG = mmap.mmap(g.fileno(), 0)

			#replace values
			map[adress:adress+mapG.size()] = mapG.read(mapG.size())
			print "Values from ",hex(adress)," to ",hex(adress+mapG.size())," replaced with compiled program"
			mapG.close()
			
		map.close()
		
	#clear traces
	os.system("rm "+tmp)

	print

loadFiles();