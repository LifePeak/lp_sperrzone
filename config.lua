Config = {}
Config.Locale  = 'de'

Config.UseOldESX = false -- If you use the old ESX (1.1) set this to true otherwise false
Config.PoliceJobs      = {"police", "swat", "fib", "sheriff"}
Config.Command         = "sperrzone"
Config.CommandWayPoint = "sperrzonewp"
Config.CommandRemove   = "rsperrzone"
Config.CommandRemoveAll= "rallsperrzone"
Config.NotificationPicture = 'CHAR_CALL911' --https://wiki.gtanet.work/index.php?title=Notification_Pictures


Config.MaxRadius   = 2000     -- Maximal radios in meter
Config.MaxTime     = 60 * 10  -- Maximal allowed time a Sperrzone will remain (if not deleted beforehand)
Config.RenewalTime = 60 * 3   -- Time in seconds the Sperrzone will be renewed if cops are in the area.



Config.Notification = {}
Config.Notification.System = 'lp_notify' -- none / lp_notify
Config.Notification.displaytime = 1300 --ms
Config.Notification.Postion = "top right" -- Only works lp_notify! | lp_"top right", [top Left, top Right, bottom Left, bottom Right]
