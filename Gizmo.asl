state("GIZMO_GAME-Win64-Shipping")
{
    // cheeky cast since TT_None and TT_Paused are 0x0 and 0x1
    bool        isPaused            : 0x29CCB20, 0x7C0;
    string1024  levelName           : 0x29CCB20, 0x7C8, 0x0;
    ulong       worldContext        : 0x29CCB20, 0xDF0, 0x30, 0x288;
    bool        isFinished          : 0x29CCB20, 0xDF0, 0x38, 0x0, 0x30, 0x380, 0x87E;
    float       x                   : 0x29CCB20, 0xDF0, 0x38, 0x0, 0x30, 0x380, 0x160, 0x15C;
    float       y                   : 0x29CCB20, 0xDF0, 0x38, 0x0, 0x30, 0x380, 0x160, 0x160;
    float       z                   : 0x29CCB20, 0xDF0, 0x38, 0x0, 0x30, 0x380, 0x160, 0x164;
    string1024  timer               : 0x29CCB20, 0xDF0, 0x30, 0x288, 0x138, 0xA0, 0x2E48, 0x3A8, 0x0;
    long        timerTicks          : 0x29CCB20, 0xDF0, 0x30, 0x288, 0x138, 0xA0, 0x2E48, 0x3A0;
}

startup
{
    // Switch to GameTime

    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var messageResult = MessageBox.Show(
            "Syncing splits with the in-game clock requires comparing against Game Time.\nWould you like to switch to it?",
            "LiveSplit | Gizmo",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Question
        );

        if (messageResult == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }

    // Location Splits

    settings.Add("location", false, "Locations");

    // Common Splits

    settings.Add("common", false, "Common", "location");

    settings.Add("common_start", false, "First Bend", "common");
    settings.Add("common_bridge", false, "Broken Bridge", "common");
    settings.Add("common_hallSnow", false, "Snowblowers Hall", "common");
    settings.Add("common_canyon1", false, "Canyon 1", "common");
    settings.Add("common_ice", false, "Ice Room", "common");
    settings.Add("common_climb", false, "Climb", "common");
    settings.Add("common_statue", false, "Statue Room", "common");
    settings.Add("common_hallDrone", false, "Drone Hall", "common");
    settings.Add("common_canyon2", false, "Canyon 2", "common");
    settings.Add("common_gap", false, "Drone Pit", "common");

    // Any% Specific Splits

    settings.Add("any", false, "Any%", "location");

    settings.Add("any_clock", false, "Clock Room (Left Exit)", "any");

    // Secret Ending Specific Splits

    settings.Add("secret", false, "Secret Ending", "location");

    settings.Add("secret_clock", false, "Clock Room (Forward Exit)", "secret");
    settings.Add("secret_claw", false, "Claw Room", "secret");
    settings.Add("secret_canyon", false, "Canyon", "secret");
    settings.Add("secret_pillar", false, "Ice Pillar", "secret");
    settings.Add("secret_pipe", false, "Pipe", "secret");
    settings.Add("secret_tv", false, "Monitor", "secret");

    // @todo Collectible Splits

    // settings.Add("collectible", false, "Collectibles");

    // settings.Add("collectible_beacon", false, "Beacons", "collectible");
    // settings.Add("collectible_crate", false, "Crates", "collectible");
    // settings.Add("collectible_bot", false, "Bots", "collectible");
}

init
{
    vars.locations = new bool[32];
}

isLoading
{
    return current.isPaused || current.levelName != "/Game/levels/level_01/level_01b";
}

gameTime
{
    if (string.IsNullOrEmpty(current.timer))
    {
        return TimeSpan.Zero;
    }

    // only use the display timer for the ending split
    // fun fact: milliseconds are displayed incorrectly (reads 0.XYZ as 0.YZ)
    //     0x3A0 TimeSpan EndPipe_BP.Time
    //           +00000000.00:00:46.581363000
    //     0x3A8 FString  EndPipe_BP.SpeedTimer:
    //           "0:46:81"
    // RIP those 0.3 seconds
    if (current.isFinished)
    {
        var digits = current.timer.Split(':');

        var minutes = int.Parse(digits[0]);
        var seconds = int.Parse(digits[1]);
        var milliseconds = 10 * int.Parse(digits[2]);

        return new TimeSpan(0, 0, minutes, seconds, milliseconds);
    }

    // use the accurate time for all other splits
    return TimeSpan.FromTicks(current.timerTicks);
}

reset
{
    return old.worldContext == 0 && current.worldContext != 0 && old.levelName == "/Game/levels/level_01/level_01b";
}

split
{
    if (current.isFinished)
    {
        return true;
    }

    // @todo Collectible Splits

    // if (settings["collectible_beacon"] && false)
    // {
    //     return true;
    // }

    // if (settings["collectible_crate"] && false)
    // {
    //     return true;
    // }

    // if (settings["collectible_bot"] && false)
    // {
    //     return true;
    // }

    var i = -1;

    if (settings["common_start"] && !vars.locations[++i] && current.x >= 1000)
    {
        return vars.locations[i] = true;
    }

    if (settings["common_bridge"] && !vars.locations[++i] && current.x >= 6600)
    {
        return vars.locations[i] = true;
    }

    if (settings["common_hallSnow"] && !vars.locations[++i] && current.x >= 10200)
    {
        return vars.locations[i] = true;
    }

    if (settings["common_canyon1"] && !vars.locations[++i] && current.x >= 16100)
    {
        return vars.locations[i] = true;
    }

    if (settings["common_ice"] && !vars.locations[++i] && current.x >= 22100)
    {
        return vars.locations[i] = true;
    }

    if (settings["common_climb"] && !vars.locations[++i] && current.x >= 25750)
    {
        return vars.locations[i] = true;
    }

    if (settings["common_statue"] && !vars.locations[++i] && current.x >= 31750)
    {
        return vars.locations[i] = true;
    }

    if (settings["common_hallDrone"] && !vars.locations[++i] && current.x >= 35800)
    {
        return vars.locations[i] = true;
    }

    if (settings["common_canyon2"] && !vars.locations[++i] && current.x >= 51850)
    {
        return vars.locations[i] = true;
    }

    if (settings["common_gap"] && !vars.locations[++i] && current.x >= 57850)
    {
        return vars.locations[i] = true;
    }

    if (settings["any_clock"] && !vars.locations[++i] && current.x >= 59450 && current.x <= 62050 && current.y < -750)
    {
        return vars.locations[i] = true;
    }

    if (settings["secret_clock"] && !vars.locations[++i] && current.x >= 63750)
    {
        return vars.locations[i] = true;
    }

    if (settings["secret_claw"] && !vars.locations[++i] && current.x >= 67850)
    {
        return vars.locations[i] = true;
    }

    if (settings["secret_canyon"] && !vars.locations[++i] && current.x >= 76950)
    {
        return vars.locations[i] = true;
    }

    if (settings["secret_pillar"] && !vars.locations[++i] && current.x >= 81400)
    {
        return vars.locations[i] = true;
    }

    if (settings["secret_pipe"] && !vars.locations[++i] && current.x >= 82500 && current.y <= 4150 && current.z >= 1250)
    {
        return vars.locations[i] = true;
    }

    if (settings["secret_tv"] && !vars.locations[++i] && current.x >= 79800 && current.y <= 2800 && current.z >= 2650)
    {
        return vars.locations[i] = true;
    }
}

start
{
    return current.levelName == "/Game/levels/level_01/level_01b";
}

onStart
{
    vars.locations = new bool[32];
}

exit
{
    timer.IsGameTimePaused = true;
}

shutdown
{
    timer.IsGameTimePaused = true;
}
