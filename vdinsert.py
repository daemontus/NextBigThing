import sys
import os
import mmap
import math

def loadFiles():

	print 
	
	#In case of wrong input, show help
	if(len(sys.argv) != 3 or sys.argv[1] == "help" or sys.argv[1] == "-h"):
		print "This program accepts two filenames as parameters and requires NASM compiler"
		print "First - assembly source file"
		print "Second - output .vid disc where compiled assembly should be inserted"
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

	#compile the assembly file
	os.system("nasm -f bin -o boot.bin "+sys.argv[1])
	if(os.path.exists("boot.bin")):
		print "Compilation successful"
		print "File size: "+str(os.path.getsize("boot.bin"))
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
		with open("boot.bin", "r+b") as g:
			mapG = mmap.mmap(g.fileno(), 0)

			#replace values
			map[adress:adress+mapG.size()] = mapG.read(mapG.size())
			print "Values from ",hex(adress)," to ",hex(adress+mapG.size())," replaced with compiled bootloader"
			mapG.close()
			
		map.close()
		
	#clear traces
	os.system("rm boot.bin")

	print

loadFiles();