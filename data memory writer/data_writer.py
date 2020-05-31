file = open("data.in", "r")
lines = file.readlines()
file.close()
adrs = list()
datas = list()
for i in range(len(lines)):
    adr = lines[i].split()[0]
    data = lines[i].split()[1]
    data = hex(int(data))[2:]
    while(len(data) < 8) : data = '0' + data
    adrs.append(int(adr))
    datas.append(data)

file = open('..\modelsim\data.data' , 'w')
i = 0
while i < 16000:
    if (i in adrs):
        indx = adrs.index(i)
        file.write(datas[indx] + '\n')
    else:
        file.write('00000000\n')
    i = i + 1
file.close()