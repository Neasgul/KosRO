@LAZYGLOBAL OFF.

PARAMETER mission.

LOCAL missionFile IS mission +".ks".

CLEARSCREEN.
IF SHIP:STATUS = "PRELAUNCH" {
    COPYPATH("0:/missions/"+ missionFile,"mission.ks").
    RUNPATH("mission.ks").
} ELSE {
    PRINT "Not on launch pad".
}