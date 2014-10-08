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

#define GMMessageIdGetScreenUIImage       1
#define GMMessageIdSetPid       2
#define GMMessageIdSearch       3
#define GMMessageIdGetMemoryAccessObject    4
#define GMMessageIdModify       5
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
