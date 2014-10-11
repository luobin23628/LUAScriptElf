//
//  Global.h
//  imem
//
//  Created by luobin on 14-7-16.
//
//

#ifndef imem_Global_h
#define imem_Global_h

#import "LightMessaging.h"

static LMConnection connection = {
	MACH_PORT_NULL,
	"LUAScriptElf.datasource"
};


static LMConnection tweakConnection = {
	MACH_PORT_NULL,
	"LUAScriptTweak.datasource"
};

#define TweakMessageIdAlertView       1

static LMConnection daemonConnection = {
    MACH_PORT_NULL,
    "LUAScriptDaemon.datasource"
};

#define DaemonConnectionMessageIdRun    10001
#define DaemonConnectionMessageIdStop    10002
#define DaemonConnectionMessageIdRunStatus    10003




#endif
