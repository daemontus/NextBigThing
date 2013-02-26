import sys
import os
import mmap
import math

def loadFiles():

	print 

	tmpo = "temp.o"
	tmpb = "temp.bin"
	
	#In case of wrong input, show help
	if(len(sys.argv) != 3 or sys.argv[1] == "help" or sys.argv[1] == "-h"):
		print "This program accepts two filenames and one number as parameters and requires installed i386-gcc and linker"
		print "First - c code"
		print "Second - output .vid(fix sized) disc where compiled assembly should be inserted"
		print "To download required software, instal MacPorts"
		print
		return

	if(not os.path.exists(sys.argv[1])):
		print "C source file does not exist"
		print
		return
	if(not os.path.exists(sys.argv[2])):
		print "Virtual disc image does not exist"
		print
		return	

	#compile the assembly file
	os.system("i386-elf-gcc -c -o "+tmpo+" "+sys.argv[1])

	if(os.path.exists(tmpo)):
		print "Compilation successful"
		print "File size: "+str(os.path.getsize(tmpo))
	else:
		print "Compilation failed - check above for errors"
		print
		return

	#link the object file
	os.system("i386-elf-ld "+tmpo+" "+" -o "+tmpb+" --oformat=binary -Ttext=0x1000 -e k_main");

	if(os.path.exists(tmpb)):
		print "Linking successful"
		print "File size: "+str(os.path.getsize(tmpb))
	else:
		print "Linking failed - check above for errors"
		print
		os.system("rm "+tmpb)
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
		adress += 9*512
		with open(tmpb, "r+b") as g:
			mapG = mmap.mmap(g.fileno(), 0)

			#replace values
			map[adress:adress+mapG.size()] = mapG.read(mapG.size())
			print "Values from ",hex(adress)," to ",hex(adress+mapG.size())," replaced with compiled program"
			mapG.close()
			
		map.close()
		
	#clear traces
	os.system("rm "+tmpb)
	os.system("rm "+tmpo)

	print

loadFiles();