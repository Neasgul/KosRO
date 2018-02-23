COPYPATH("0:/LaunchUtils.ks","LaunchUtils.ks").
RUNONCEPATH("LaunchUtils.ks").

// Azimuth Calcul
SET lauchLoc to SHIP:GEOPOSITION.
SET initAzimuth TO arcsin(max(min(cos(targetInclination) / cos(launchLoc:LAT),1),-1)).
SET targetOrbitSpeed TO SQRT(SHIP:BODY:MU / (200000+SHIP:BODY:RADIUS)).
SET rotvelx to targetOrbitSpeed*sin(initAzimuth) - (6.2832*SHIP:BODY:RADIUS/SHIP:BODY:ROTATIONPERIOD).
SET rotvely to targetOrbitSpeed*cos(initAzimuth).
SET azimuth to arctan(rotvelx / rotvely).
IF targetInclination < 0 {SET azimuth to 180-azimuth.}.

// Engines Start
SET SHIP:CONTROL:MAINTHROTTLE TO 1.0.
LOCK STEERING TO HEADING(90, 90).
WAIT 1.
STAGE.
PRINT "Engines started.".

// Wait for thrust
WAIT UNTIL SHIP:AVAILABLETHRUSTAT(1) >= (SHIP:MAXTHRUSTAT(1)* 0.95).

// Lift off
STAGE.
PRINT "Lift off".

WAIT UNTIL ALT:RADAR > 100.

// Gravity turn start
PRINT "Gravity Turn".
SET fullySteeredAngle to 90 - waitPitch.
SET atmpGround to SHIP:BODY:ATM:SEALEVELPRESSURE * CONSTANT:ATMTOKPA.
SET maxQ to SHIP:Q.

LOCK altitude to ALT:RADAR.
LOCK atmp to SHIP:BODY:ATM:ALTITUDEPRESSURE(altitude) * CONSTANT:ATMTOKPA.
LOCK atmoDensity to atmp / atmpGround.
LOCK apoeta to max(0,ETA:APOAPSIS).

// Atmospheric gravity turn
LOCK firstPhasePitch to fullySteeredAngle - (fullySteeredAngle * atmoDensity).
LOCK STEERING to HEADING(azimuth, 90 - firstPhasePitch).
UNTIL apoeta >= targetApoeta {
	FLAMEOUT(3).
	ACTIVATORS().
    if SHIP:Q > maxQ {
        SET maxQ to SHIP:Q.
    }
    ELSE {
        PRINT "Passing max Q : " +maxQ.
    }
	set endTurnAltitude to altitude.
	set endTurnOrbitSpeed to SHIP:VELOCITY:ORBIT:MAG.
	set secondPhasePitch to firstPhasePitch.
}
UNLOCK firstPhasePitch.
UNLOCK STEERING.
UNLOCK atmoDensity.
UNLOCK atmp.

// Second phase of graviy turn
SET atmoEndAltitude to 110000.
SET tolerance to targetApoeta * 0.5.
LOCK shipAngle to VANG(SHIP:UP:VECTOR, SHIP:SRFPROGRADE:VECTOR).
LOCK correctiondAmp to (altitude - endTurnAltitude) / (atmoEndAltitude - endTurnAltitude).
LOCK mx to shipAngle + (maxCorrection * correctiondAmp).
LOCK mi to shipAngle - (maxCorrection * correctiondAmp).
LOCK orbitSpeedFactor to ((targetOrbitSpeed - SHIP:VELOCITY:ORBIT:MAG) / (targetOrbitSpeed - endTurnOrbitSpeed)).
LOCK tApoEta to targetApoeta * orbitSpeedFactor. 
SET ae to 0.
LOCK correction to max(-maxCorrection*0.3,((tApoEta - ae) / tolerance) * maxCorrection).
LOCK secondPhasePitch to max(mi,min(mx, shipAngle - correction )).
LOCK STEERING to HEADING(azimuth, 90 - secondPhasePitch).

PRINT "Horizontal burn".
UNTIL ALT:PERIAPSIS >= 140000 OR ALT:APOAPSIS >= targetApoapsis{
	FLAMEOUT(3).
	ACTIVATORS().
	if SHIP:VERTICALSPEED > 0 {
		SET ae to apoeta.
	} else {
		SET ae to 0.
	}
}

// In orbit
//Performs engine shutdown.
for eng in enginesList{
    if eng:THRUST > 0{
        eng:SHUTDOWN.
    }
}

DELETEPATH("libLaunchUtils.ks").
// give back controls
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
LOCK THROTTLE TO 0.
UNLOCK STEERING.