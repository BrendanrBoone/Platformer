#!/usr/bin/env python

blockDimensions = input("How many pixels are on an axis of a block? ")

x = input("PositionX? ")
y = input("PositionY? ")

resX, resY = int(blockDimensions) * int(x), int(blockDimensions) * int(y)

print("Pixel Position you gave was (" + str(resX) + ", " + str(resY) + ")")
