from common import MapDataMultiplier


"""
    0_0 1_0 2_0 3_0
    0_1 1_1 2_1 3_1

"""
mdm = MapDataMultiplier("island", x_len=3, y_len=1, x_rep=10, y_rep=10, buffer_x=2, buffer_y=2)
mdm.run(0,0)