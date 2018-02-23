// Ship variables /!\ THOSE PARAMETERS NEED TWEAKING
GLOBAL waitPitch is 40.
GLOBAL targetApoeta is 80.
GLOBAL maxCorrection is 30.

// engines list
GLOBAL enginesList IS LIST().
LIST ENGINES IN enginesList.

// Mission parameters
LOCAL targetInclination IS 0.
LOCAL targetApoapsis IS 280000.
LOCAL targetPeriapsis IS 170000.
LOCAL targetLAN IS 0.


IF targetLAN <> 0 {
    COPYPATH("0:/WaitForLAN.ks","WaitForLAN.ks").
    RUNPATH("WaitForLAN.ks",targetLAN).
    DELETEPATH("WaitForLAN.ks").
}

COPYPATH("0:/LaunchATM.ks","LaunchATM.ks").
RUNPATH("LaunchATM.ks", targetInclination).
DELETEPATH("LaunchATM.ks").