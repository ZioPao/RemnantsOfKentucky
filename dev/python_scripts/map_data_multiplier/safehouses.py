from common import MapDataMultiplier

#fix this
mdm = MapDataMultiplier("safehouse", x_len=0, y_len=0, x_rep=1, y_rep=4, buffer_x=0, buffer_y=0)
#mdm.run(0,100)

mdm.run_single(0, 100, 0, 200)



files = [
    { "x":0, "y": 100}
]