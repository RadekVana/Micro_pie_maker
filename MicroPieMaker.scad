/*******************************************************
Tool to create micro pies

Created by Vana Radek 2019-08-10
*******************************************************/

include <nutsnbolts-master/cyl_head_bolt.scad>;

$fn = $preview ?32 : 100;



/*******************************************************
VARIABLES
*******************************************************/
/******************************************************/
//spring
springInnerD = 10;//12.5;
springOuterD = 12.5;//15;

/******************************************************/
//threat
threat_fill_d = springInnerD -3.5; 
threat_cut_d = springInnerD - 0.5;
threat_orad = (springOuterD-1)/2; 
threat_lead = 3;
threat_len = 10;
threat_start_len = 2;

/******************************************************/
//piston
pistonTopD = springInnerD-0.5;
pistonTopH = 55;//46;
pistonTrhedH = threat_len;
pistonNonTrhedH = pistonTopH-pistonTrhedH;
pistonBaseD = 25;
pistonBaseH = 5;
pistonBaseEdgeH = 2;
pistonBaseEdgeD = pistonBaseD - 2*pistonBaseEdgeH;
pistonBaseH_nonEdged = pistonBaseH - pistonBaseEdgeH;


/******************************************************/
//cap
capD = 26;
capTopD = 13;
capH = 18.5;
capTopH = (capD - capTopD)/2;
capSpringH = 5;

/******************************************************/
//body
bodyD = 36.5;
bodyH = 22.5;
bodyTopD = 32.5;
bodyBotH = 11.5;
bodyTopH = 2;
bodyMidH = bodyH - bodyBotH - bodyTopH;
bodyBotHoleD = bodyD - 1.6;
bodyBotHoleH = 7;
bodyPistonHoleD = pistonTopD+0.5;



/*******************************************************
MODULES
*******************************************************/
module myThreat(

	fill_d = threat_fill_d, 
	cut_d = threat_cut_d,
	orad = threat_orad, 
	lead = threat_lead,
	len = threat_len,
	start_len = threat_start_len
	){
		cylinder(d = fill_d, h=len);
        intersection(){
            cylinder(d = cut_d, h=len);
            thread(orad, len, lead);
			
			//start
			virtual_d2 =  ((cut_d-fill_d)/start_len)*len + fill_d;
			cylinder(d1 = virtual_d2, d2 = fill_d, h=len);
        }

}

module piston(){
	cylinder(d = pistonTopD, h = pistonNonTrhedH);
	translate([0,0,-pistonBaseH_nonEdged])cylinder(d = pistonBaseD, h = pistonBaseH_nonEdged);
	translate([0,0,-pistonBaseH])cylinder(d2 = pistonBaseD, d1 = pistonBaseEdgeD, h = pistonBaseEdgeH);
	translate([0,0,pistonNonTrhedH])myThreat();
}





module cap(extraThreatD = 0.6){
	difference(){
		union(){
			cylinder(d = capD, h = capH-capTopH);
			translate([0,0,capH-capTopH])cylinder(d1 = capD, d2 = capTopD, h = capTopH);
		}

		translate([0,0,capSpringH]){
			myThreat(	fill_d 	= threat_fill_d+extraThreatD,	
						cut_d 	= threat_cut_d+extraThreatD,	
						orad 	= threat_orad+extraThreatD/2);
			
			//ramp for screw
			cylinder(d1 = pistonTopD+1+0.5, d2 = pistonTopD+0.5, h = 0.5);
		}
		translate([0,0,-0.1])cylinder(d = springOuterD + 0.5, h = capSpringH+0.1);
	}

}

module body(edgeR = 0.6){
	edgeD = edgeR*2;
	
	difference(){
		union()
		{
			translate([0,0,+edgeR]) minkowski(){
				cylinder(d = bodyTopD-edgeD, h = bodyH - edgeD);
				
			
				union(){
					sphere(r = edgeR);
					translate([0,0,-edgeR])cylinder(d = edgeD, h =edgeR);
				}
			}
			cylinder(d = bodyD, h = bodyBotH);
		}
		
	
	//holder hole
		translate([0,0,bodyBotH + bodyMidH/2+edgeR])
		rotate_extrude(convexity = 10)
			translate([(bodyTopD)/2, 0, 0])
				rotate([0,0,-45])union(){
					circle(r = bodyMidH /2);
					translate([0,-bodyMidH /2,0])square(bodyMidH);
				}
				
			
	
		//bot hole with nice inner edge
		 {
			cylinder(d = bodyBotHoleD, h = bodyBotHoleH - edgeR);	
			cylinder(d = bodyBotHoleD- edgeD, h = bodyBotHoleH);	
			
			translate([0,0,bodyBotHoleH-edgeR])
			rotate_extrude(convexity = 10)
				translate([(bodyBotHoleD - edgeD)/2, 0, 0])
					circle(r = edgeR);
		}
		//piston hole with nice edges
		{
			cylinder(d = bodyPistonHoleD, h = bodyH);
			translate([0,0,bodyBotHoleH-0.1]) cylinder(d1 = pistonTopD+0.5 + edgeD+0.2,d2 = pistonTopD+0.5, h = edgeR+0.1);
			translate([0,0,bodyH - edgeR+0.1]) cylinder(d2 = pistonTopD+0.5 + edgeD+0.2,d1 = pistonTopD+0.5, h = edgeR+0.1);
		}
	}
	

	
	

}


module oldBody(edgeR = 0.6){
	edgeD = edgeR*2;
	
	difference(){
		minkowski()
		{
			union(){
				cylinder(d = bodyTopD-edgeD, h = bodyH - edgeD);
				cylinder(d = bodyD-edgeD, h = bodyBotH-edgeR);
			}
			union(){
				sphere(r = edgeR);
				translate([0,0,-edgeR/2])cube([edgeD,edgeD,edgeR],true);
			}
			

		}
	
	//holder hole
		translate([0,0,bodyBotH + bodyMidH/2])
		rotate_extrude(convexity = 10)
			translate([(bodyTopD)/2, 0, 0])
				rotate([0,0,-45])union(){
					circle(r = bodyMidH /2);
					//square(sqrt(2*(bodyMidH /2)*(bodyMidH /2)));
					//translate([0,-bodyMidH /2,0])square(bodyMidH /2);
					translate([0,-bodyMidH /2,0])square(bodyMidH);
				}
				
			
			
	
		//bot hole with nice inner edge
		translate([0,0,-edgeR]) {
			cylinder(d = bodyBotHoleD, h = bodyBotHoleH - edgeR);	
			cylinder(d = bodyBotHoleD- edgeD, h = bodyBotHoleH);	
			
			translate([0,0,bodyBotHoleH-edgeR])
			rotate_extrude(convexity = 10)
				translate([(bodyBotHoleD - edgeD)/2, 0, 0])
					circle(r = edgeR);
		}
		//piston hole with nice edges
		translate([0,0,-edgeR]){
			cylinder(d = pistonTopD+0.5, h = bodyH);
			translate([0,0,bodyBotHoleH-0.1]) cylinder(d1 = pistonTopD+0.5 + edgeD+0.2,d2 = pistonTopD+0.5, h = edgeR+0.1);
			translate([0,0,bodyH - edgeR+0.1]) cylinder(d2 = pistonTopD+0.5 + edgeD+0.2,d1 = pistonTopD+0.5, h = edgeR+0.1);
		}
	}
	

	
	
}

module debug(){

	difference(){
		union(){
			piston();

			translate([0,0,pistonTopH+10+bodyH+10])cap();

			translate([0,0,pistonTopH+10]) body();
		}
	cube(200);	
	}
}

/*******************************************************
EXPORTS
*******************************************************/

//debug();

piston();

//cap();

//body();

