include <config/config.scad>





module cuttingBed() {
	// centred on origin

	// dummy surface
	color([1,1,1,0.5]) cube([bedW,bedD,1],center=true);
}

module cuttingBedFrame() {

	bFW = bedW + 2*bedM + 2*bedO;

	ribSpacing = (bedWM - 20) / (bedRibs - 1);
	ribL = bedDM - 40;

	translate([-bFW/2,bedDM/2-10,0]) 
		rotate([0,90,0]) 
		rotate([0,0,90])
		aluProExtrusion(BR_20x40, l=bFW);
		
	translate([-bFW/2,-bedDM/2+10,0]) 
		rotate([0,90,0]) 
		rotate([0,0,90])
		aluProExtrusion(BR_20x40, l=bFW);
	
	for (j=[0,1]) 
		mirror([j,0,0])
		for (i=[0:bedRibs/2-1]) {
		BR20x20WGBP([-bedWM/2+10 + i*ribSpacing, -ribL/2, -10], 
		            [-bedWM/2+10 + i*ribSpacing, ribL/2, -10],
		            roll=0,
		            startGussets=[0,0,0,1], 
		            endGussets=[0,0,0,1]);
	}
	
	*translate([0,0,20]) { 
		// keeps bed centred at origin
		cuttingBed();
		
		// with cutting margins
		color([1,0,0,0.5]) cube([bedWM,bedDM,0.5],center=true);
	}
}



module xCarriage() {
	// plate
	translate([0,0,0]) rotate([90,0,0]) openrail_plate20(wheels=true);

	// laser optics
	translate([0,-30,-50]) color("red") cylinder(r=25/2,h=100);
	
	// bracket
	translate([-25,-50,-15]) roundedRect([50,50,6],6,center=false);
}

module xAxis() {

	t  =ORPlateThickness(ORPLATE20);
	l = frameCY[4] - frameCY[1] + ORPlateWidth(ORPLATE20);

	railLen = bedWM + ORPlateWidth(ORPLATE20)/2;
	
	// drive belt centres
	beltCX = [-railLen/2 - 15 , railLen/2 + 30];
	beltCY = [-12 - openrail_plate_offset];
	beltCZ = [16];
	
	beltIR = pulley_ir(T5x10_metal_pulley);

	// x rail
	translate([-l/2,0,0]) 
		rotate([0,90,0]) 
		aluProExtrusion(BR_20x20, l=l);

	translate([-railLen/2,-10,10]) { 
		rotate([0,90,0]) rotate([0,0,90]) openrail_doubled(railLen,true,true);
	}

	// motor assembly
	translate([beltCX[1],beltCY[0],beltCZ[0]]) {
		rotate([0,180,0]) {
			NEMA(NEMA17);
			metal_pulley(T5x10_metal_pulley);
		}
		
		translate([-25,-23,-6]) roundedRect([50,60,6],6);
	}

	// idler assembly
	translate([beltCX[0],beltCY[0],beltCZ[0]]) {
		rotate([0,180,0]) metal_pulley(T5x10_metal_pulley);
		
		translate([-10,-10,-6]) roundedRect([20,50,6],6);
		
		translate([-10,-10,-32]) roundedRect([20,50,6],6);
	}
	
	// belt
	translate([0,0,beltCZ[0] - 15])
		belt(T5x10, beltCX[0], beltCY[0], beltIR , beltCX[1], beltCY[0], beltIR, gap = 0); 


	translate([0,-openrail_plate_offset-10,0]) 	
		xCarriage();	
	
	
	
	// y carriages
	for (i=[0,1])
		mirror([i,0,0])
		translate([frameCY[4],0, -10]) 
		rotate([0,0,180]) 
		openrail_plate20(wheels=true);
		
	// y belt clips
	for (i=[0,1])
		mirror([i,0,0]) {
		
			translate([l/2-10,-6, -43]) 
				cube([10,12,30]);
			translate([l/2,-10, -43]) 
				cube([5,20,53]);
		}
		
	// y sealing plates
	for (i=[0,1])
		mirror([i,0,0]) {
		
			translate([frameCY[3]-8,-80,-25])
				color(grey20)
				render()
				difference () {
					cube([5,105,80]);
				
					// belt
					translate([-1,42,20]) 
						cube([10,20,12]);
					
					// rail
					translate([-1,70,13]) 
						cube([10,22,22]);
					
					// laser	
					translate([-1,20,50]) 
						roundedRectX([10,10,10],4);
					
				}
			
		}
}



module frame() {
	
	assembly("frame");
	
	// base
	// front/back
	for (i=[0,3]) {
		aluProExtrusionBetweenPoints([frameCY[0]-10,frameCX[i],frameCZ[0]], 
		                             [frameCY[5]+10,frameCX[i],frameCZ[0]],
		                             BR_20x40,
		                             90);
	}
	
	// ribs
	for (i=[0,2,3,5]) {
		BR20x40WGBP([frameCY[i],frameCX[0]+10,frameCZ[0]], 
		            [frameCY[i],frameCX[3]-10,frameCZ[0]],
		            roll=0,
		            startGussets=[0,i%2,i%2,0,(i+1)%2,(i+1)%2], 
		            endGussets=[0,i%2,i%2,0,(i+1)%2,(i+1)%2]);
	}
	
	// infill ribs
	ix = frameCY[3] *1/3;
	for (i=[0,1]) mirror([i,0,0])
	BR20x40WGBP([ix,frameCX[0]+10,frameCZ[0]], 
		            [ix,frameCX[3]-10,frameCZ[0]],
		            roll=0,
		            startGussets=[0,1,1,0,0,0], 
		            endGussets=[0,1,1,0,0,0,0]);
	
	// corner posts
	for (x=[0,5],y=[0,3])
		BR20x20WGBP([frameCY[x],frameCX[y],frameCZ[0]+20], 
		            [frameCY[x],frameCX[y],frameCZ[3]+10],
		            roll=0,
		            startGussets=[y==0?1:0,x==5?1:0,y==0?0:1,x==0?1:0], 
		            endGussets=[0,0,0,0]);
		            
	// inner posts
	for (x=[2,3],y=[0,3])
		BR20x20WGBP([frameCY[x],frameCX[y],frameCZ[0]+20], 
		            [frameCY[x],frameCX[y],frameCZ[4]+10],
		            roll=90,
		            startGussets=[x==2?1:0,
		            			  y==3?1:0,
		            			  x==3?1:0,
		            			  y==0?1:0], 
		            endGussets=[0,0,0,0]);
	
	
	// left/right top ribs
	for (i=[0,5]) {
		BR20x20WGBP([frameCY[i],frameCX[0]+10,frameCZ[3]], 
		            [frameCY[i],frameCX[3]-10,frameCZ[3]],
		            roll=0,
		            startGussets=[1,0,0,0], 
		            endGussets=[1,0,0,0]);
	}
	
	// inner top ribs
	for (i=[2,3]) {
		BR20x20WGBP([frameCY[i],frameCX[0]+10,frameCZ[4]], 
		            [frameCY[i],frameCX[3]-10,frameCZ[4]],
		            roll=0,
		            startGussets=[1,0,0,0], 
		            endGussets=[1,0,0,0]);
	}
	
	// top back
	BR20x40WGBP([frameCY[2]+10,frameCX[3],frameCZ[4]-10], 
		            [frameCY[3]-10,frameCX[3],frameCZ[4]-10],
		            roll=90,
		            startGussets=[0,1,0,1,0,0], 
		            endGussets=[0,1,0,1,0,0]);
		            
	// mid back
	BR20x20WGBP([frameCY[2]+10,frameCX[3],frameCZ[1]], 
		            [frameCY[3]-10,frameCX[3],frameCZ[1]],
		            roll=90,
		            startGussets=[1,0,1,0], 
		            endGussets=[1,0,1,0]);
		            
	BR20x20WGBP([frameCY[2]+10,frameCX[1],frameCZ[1]], 
		            [frameCY[3]-10,frameCX[1],frameCZ[1]],
		            roll=90,
		            startGussets=[0,0,1,1], 
		            endGussets=[0,0,1,1]);
	
	
	// top beams
	for (x=[0,3],y=[0,3]) {
		BR20x20WGBP([frameCY[x]+10,frameCX[y],frameCZ[3]], 
		            [frameCY[x+2]-10,frameCX[y],frameCZ[3]],
		            roll=0,
		            startGussets=[(x==0&&y==0?1:0),0,(x==0&&y==3?1:0),1], 
		            endGussets=[(x==3&&y==0?1:0),0,(x==3&&y==3?1:0),1]);
	}
		            
	// top laser casing beam
	BR20x20WGBP([frameCY[2]+10,frameCX[2],frameCZ[4]], 
		            [frameCY[3]-10,frameCX[2],frameCZ[4]],
		            roll=0,
		            startGussets=[1,0,0,0], 
		            endGussets=[1,0,0,0]);
	
	
	
	// top of z ribs
	for (i=[2,3]) {
		BR20x20WGBP([frameCY[i],frameCX[0]+10,frameCZ[1]], 
		            [frameCY[i],frameCX[3]-10,frameCZ[1]],
		            roll=0,
		            startGussets=[1,0,0,0], 
		            endGussets=[1,0,1,0]);
	}
	
	// z rib posts
	for (x=[2,3])
		BR20x20WGBP([frameCY[x],frameCX[1],frameCZ[0]+20], 
		            [frameCY[x],frameCX[1],frameCZ[1]-10],
		            roll=0,
		            startGussets=[1,0,0,0], 
		            endGussets=[1,0,0,0]);
	
	
	end("frame");
	
}

module zAssembly() {
	h = NEMA_length(NEMA17);
	
	rodLen = frameCZ[1] - frameCZ[0] - 30;

	// motor assemblies
	for (x=[0,1], y=[-1,1]) 
		mirror([x,0,0])
		translate([(frameCY[3] + NEMA_width(NEMA17)/2 + 10), y*(bedDM/2-20-NEMA_width(NEMA17)/2),0]) {
	
		// motor	
		translate([0,0,h]) NEMA(NEMA17);
	
		// threaded rod
		translate([0,0,h+20]) cylinder(h=frameCZ[1]-80, r= 5/2);

		// coupling
		translate([0,0,h+4]) cylinder(h=25, r= 15/2);
	}
	
	// linear rod assemblies
	for (x=[0,1]) 
		mirror([x,0,0])
		translate([(frameCY[3]), -(bedDM/2-40),0]) {
		
			// linear rod
			translate([0,0,40]) cylinder(h=rodLen, r= 10/2);
	
			// bearing
	
	}
}

module laserTube() {
	color([1,1,1,0.4]) 
		cylinder(r=60/2, h=700);
}

module laserTubeAssembly() {

	translate([-350, frameCX[3]-50,frameCZ[1]+60]) 
		rotate([0,90,0]) 
		laserTube();

}

module yAssembly() {

	railLen = bedD + ORPlateDepth(ORPLATE40);
	
	w = NEMA_width(NEMA17);
	d = w + 10;
	
	beltIR = pulley_ir(T5x10_metal_pulley);

	beltCX = [frameCY[4] +  w/2 + 2];
	beltCY = [frameCX[0] + 40, 
			  frameCX[3] - 40];
	beltCZ = [frameCZ[2] - 16];
	
	
	// xAxis
	translate([0,xCarriagePos+60,frameCZ[2] + 20 + openrail_plate_offset])
		xAxis();
	
	
	// y rails
	for (i=[1,4]) {
		BR20x20WGBP([frameCY[i],frameCX[0]+10,frameCZ[2]], 
		            [frameCY[i],frameCX[3]-10,frameCZ[2]],
		            roll=0,
		            startGussets=[0,1,0,1], 
		            endGussets=[0,1,0,1]);
	}
	
	// end brackets for rails
	for (x=[0,3],y=[0,3]) {
		BR20x20WGBP([frameCY[x]+10,frameCX[y],frameCZ[2]], 
		            [frameCY[x+2]-10,frameCX[y],frameCZ[2]],
		            roll=0,
		            startGussets=[0,0,0,1], 
		            endGussets=[0,0,0,1]);
	}
	
	// openrails
	for (i=[0,1])
		mirror([i,0,0])
		translate([frameCY[4] + 10,-bedDM/2 + 40,frameCZ[2] + 10]) 
		rotate([-90,90,0])
	 {
			translate([0,20,0]) openrail_doubled(railLen,true,true);
		}
		
	// motors
	for (i=[0,1])
		mirror([i,0,0]) {
			translate([beltCX[0], beltCY[1], beltCZ[0]]) {
				rotate([0,0,90]) NEMA(NEMA17);
				metal_pulley(T5x10_metal_pulley);
			
		
				translate([-d+w/2,-w/2,0]) roundedRect([d,w,6],6);
			}	
		}
	
	
	// belts
	for (i=[0,1])
		mirror([i,0,0]) 
		translate([0,0,beltCZ[0] + 15])
		belt(T5x10, beltCX[0], beltCY[0], beltIR , beltCX[0], beltCY[1], beltIR, gap = 0);
	
	
	// idlers
	for (i=[0,1])
		mirror([i,0,0]) {
			translate([beltCX[0], beltCY[0], beltCZ[0]]) {
				metal_pulley(T5x10_metal_pulley);
			
				translate([-30,-15,0]) roundedRect([40,30,6],6);
			}	
		}
	
	
	// sealing belts
	//frameCY[3]-8
	
	if (showSealingBelts) 
		for (i=[0,1])
		mirror([i,0,0]) 
		{
			// the belt
			translate([frameCY[3]-10, frameCX[0]+20 ,frameCZ[2] + 12])
				color(belt_color)
				render()
				difference() {
					roundedRect([110,railLen + 60, 80], 10, shell=2);
					
					// punch out for sealing plate
					translate([-1,xCarriagePos + bedDM/2 + 2,0]) 
						cube([10,80,100]);
				}
				
			// corner rollers
			translate([frameCY[3] + 2, frameCX[0] + 32 ,frameCZ[2] + 2])
				color(grey80)
				render() {
					
					for (i=[0,1],j=[0,1]) 
						translate([i*86,j* (railLen + 36),0])
						cylinder(r=10, h=100);
					
				}
			
	}
}


module cladding() {
	assembly("cladding");
	
	w1 = frameCY[5] - frameCY[0] + 20;
	w2 = frameCY[3] - frameCY[2] + 20;
	
	d1 = frameCX[3] - frameCX[0] + 20;
	d2 = frameCX[1] - frameCX[0];
	
	// bottom
	color(grey20)
		translate([-w1/2, frameCX[0] - 10, -3])
		cube([w1, d1, 3]);
		
	// inner bottom
	color(grey20)
		translate([0,0,40])
		render()
		linear_extrude(3)
		difference() {
			translate([-w2/2, frameCX[0] - 10, 0])
				square([w2, d2]);
			
			// inner posts
			for (x=[1,2],y=[0,3])
				translate([frameCY[x] - 8,frameCX[y],0])
				roundedSquare([42,62],3,center=true);
			
			// rear inner posts
			for (x=[1,2],y=[1])
				translate([frameCY[x],frameCX[y] + 10,0])
				roundedSquare([22,42],3,center=true);
			
			// stepper brackets
			// ??
			
			// linear rod brackets
			// ??
			
		}
		

	// left/right outer panels
	for (i=[0,1])
		mirror([i,0,0])
		color(grey20)
		translate([frameCY[5]+10, frameCX[0] - 10, 0])
		cube([3, d1, frameCZ[3] + 10]);
	
	
	// left/right inner lower panels
	for (i=[0,1])
		mirror([i,0,0])
		color("orange")
		render()
		translate([frameCY[3]-13, frameCX[0] - 10, 43])
		difference() {
			cube([3, d2, frameCZ[1] - 13]);
			
			// vertical slots for bed
			translate([-2,38,-10]) 
				cube([10,24,frameCZ[1]-73+20]);
	
			translate([-2, bedDM + 15,-10]) 
				cube([10,30,frameCZ[1]-73+20]);
		}
		
	// left/right inner upper panels
	for (i=[0,1])
		mirror([i,0,0])
		color("orange")
		render()
		translate([frameCY[3]-13, frameCX[0] - 10, frameCZ[1]+30])
		difference() {
			cube([3, frameCX[2] - frameCX[0], frameCZ[4] - frameCZ[1]-20]);
			
			// slot for x axis travel and laser path
			translate([-2,70,-10]) roundedRectX([10,d1,70],10);
		}
		
	// inner lower back
	color("orange")
		translate([frameCY[2],frameCX[1]-13,43])
		render()
		cube([w2-20,3,frameCZ[1]-33]);
	
	// inner upper back
	color("orange")
		translate([frameCY[2]+10,frameCX[2]-13,frameCZ[1]+13])
		render()
		cube([w2-40,3,frameCZ[4] - frameCZ[1]-3]);
	
	// inner shelf
	color("orange")
		translate([0,frameCX[1]-10,frameCZ[1]+10])
		render()
		linear_extrude(3)
		difference() {
			translate([-w2/2, 0, 0])
				square([w2, frameCX[3] - frameCX[1]  +20]);
			
			// punch out for rear posts
			
		}
	
		
	// front / back sides
	for (i=[0,1],j=[0,1])
		mirror([i,0,0])
		color(grey20)
		render()
		translate([frameCY[3]-10, j==0?frameCX[0] - 10: frameCX[3]+13, 0])
		rotate([90,0,0])
		linear_extrude(3)
		polygon( points=[[0, 0], 
						 [frameCY[5]-frameCY[3]+20, 0],
						 [frameCY[5]-frameCY[3]+20, frameCZ[3]+10],
						 [40, frameCZ[4]+10],
						 [0, frameCZ[4]+10]] );
						 
						 
	// top of sides
	for (i=[0,1])
		mirror([i,0,0])
		color(grey20)
		translate([frameCY[3]-10, frameCX[0] - 10, frameCZ[3] + 10])
		cube([frameCY[5]-frameCY[3] + 20, d1, 3]);
	
	
	// top of back
	color("orange")
		translate([frameCY[2]+10,frameCX[2]-10,frameCZ[3]+10])
		render()
		cube([w2-40,frameCX[3] - frameCX[2] + 20,3]);
	
	
	// lid
	color([1,0.8,0.5,0.5])
		translate([frameCY[2]+10,frameCX[2]-10,frameCZ[3]+10])
		render()
		rotate([-40,0,0])
		{
			// place origin at hinge line
			translate([0,-(frameCX[2] - frameCX[0]),-(frameCZ[3]-frameCZ[2])]) 
				cube([w2-40,3 ,frameCZ[3]-frameCZ[2]]);
				
			translate([0,-(frameCX[2] - frameCX[0]),0]) 
				cube([w2-40,frameCX[2] - frameCX[0] ,3]);	
		}
	
	
	// front door - needs handle
	color("orange")
		translate([frameCY[2]+10,frameCX[0]-10,frameCZ[0]+20])
		render()
		rotate([60,0,0])
		cube([w2-40,3 ,frameCZ[2]-30]);
	
	end("cladding");
}


laserTubeAssembly();

frame();

zAssembly();

translate([0,0,bedVPos]) cuttingBedFrame();

yAssembly();

*cladding();
