BALL_DIAMETER = 40;
SHELL_THICKNESS = 2;
DETAIL = 100;
NUMBER_OF_CUTS = 9;
CUT_OFFSET_FROM_CENTER = 4;

CUT_HEIGHT = BALL_DIAMETER / NUMBER_OF_CUTS;
BALL_RADIUS = BALL_DIAMETER / 2;

translate(v = [0, 0, BALL_RADIUS]) // Lift up to the build platform
{
    rotate(a = [0, 90, 0]) // Rotate so spine is on top and bottom, for better extrusion-printing
    {
        difference()
        {
            sphere(r = BALL_RADIUS, $fn = DETAIL);
            sphere(r = BALL_RADIUS - SHELL_THICKNESS, $fn = DETAIL);
            //cube(size = [40, 40, 40]); // use this to peek at the thickness
            for (i = [2 : 2 : NUMBER_OF_CUTS - 2])
            {
                translate(v = [-1 * BALL_DIAMETER, CUT_OFFSET_FROM_CENTER, -1 * BALL_RADIUS + i * CUT_HEIGHT])
                    cube(size=[BALL_DIAMETER * 2, BALL_DIAMETER, CUT_HEIGHT]);
            }
            for (i = [1 : 2 : NUMBER_OF_CUTS - 1])
            {
                translate(v = [-1 * BALL_DIAMETER, -1 * (CUT_OFFSET_FROM_CENTER + BALL_DIAMETER), -1 * BALL_RADIUS + i * CUT_HEIGHT])
                    cube(size=[BALL_DIAMETER * 2, BALL_DIAMETER, CUT_HEIGHT]);
            }
    
        }
    }
}
