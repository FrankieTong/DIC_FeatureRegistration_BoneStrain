function h = funMItoMinimizeNLdif(x0,vec1,vec2)

adjustedVec2 = stressWhiteningBackgroundRelationShip(x0,vec2);

h = 1 - mutualinfo(vec1,adjustedVec2);