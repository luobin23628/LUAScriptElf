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

#define GMMessageIdAlertView       1
#define GMMessageIdSearch       3
#define GMMessageIdRun    4
#define GMMessageIdStop       5
#define GMMessageIdClearSearchData 6
#define GMMessageIdReset        7
#define GMMessageIdCheckValid   8
#define GMMessageIdGetLockedList  9
#define GMMessageIdGetStoredList  10
#define GMMessageIdRemoveLockedOrStoredObjects  11

#define GMMessageIdAddAppIdentifier  20
#define GMMessageIdRemoveAppIdentifier  21
#define GMMessageIdGetAppIdentifiers  22

#endif
