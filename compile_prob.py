#! /usr/bin/python
import os


folder = "subset3_prob_55" 
files = [f for f in os.listdir(folder) if f.endswith('.csv')]
num_files = len(files)
num_y_intra = 11
num_uv_intra = 12

sum_prob = []
for y in range(num_y_intra):
  sum_prob.append([0] * num_uv_intra)

for file in files:
  with open(os.path.join(folder, file)) as f:
    y = 0
    for line in f:
      data = line.split(':')
      prob = data[1].split(',')
      assert(len(prob) - 1 == num_uv_intra)
      for uv in range(num_uv_intra):
        sum_prob[y][uv] += int(prob[uv])
      y = y + 1
    assert(y == num_y_intra)

for y in range(num_y_intra):
  print("{ ", end="")
  for uv in range(num_uv_intra):
    sum_prob[y][uv] = int(round(sum_prob[y][uv] / num_files))
    print("%5d " % sum_prob[y][uv], end="")
  print("},")
