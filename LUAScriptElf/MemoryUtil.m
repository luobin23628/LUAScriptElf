//
//  MemoryUtil.m
//  LUAScriptElf
//
//  Created by luobin on 14-10-3.
//
//

#import "MemoryUtil.h"
#import <mach/mach.h>

@implementation MemoryUtil

+ (BOOL)memoryReadFromPid:(pid_t)pid address:(vm_address_t)address buffer:(void *)buffer bufferSize:(size_t)size {
    kern_return_t kret;
    task_t task;
    kret = task_for_pid(mach_task_self(), pid, &task);
    if (kret != KERN_SUCCESS) {
        fprintf(stderr,"Unable to read process %d - kernel return code 0x%x", pid, kret);
        return NO;
    }
    mach_msg_type_number_t bufferSize = size;
    if ((kret = vm_read_overwrite(task, (mach_vm_address_t)address, size, buffer, &bufferSize)) == KERN_SUCCESS) {
        
    }
    if (buffer != nil) {
        free(buffer);
        buffer = nil;
    }
    
    if (kret != KERN_SUCCESS) {
        fprintf(stderr,"Unable to read memory at @%u - kernel return code 0x%x", address, kret);
        return NO;
    } else {
        return YES;
    }
}


+ (BOOL)memoryWriteFromPid:(pid_t)pid address:(vm_address_t)address data:(void *)data dataSize:(size_t)dataSize {
    kern_return_t kret;
    task_t task;
    kret = task_for_pid(mach_task_self(), pid, &task);
    if (kret != KERN_SUCCESS) {
        fprintf(stderr,"Unable to read process %d - kernel return code 0x%x", pid, kret);
        return NO;
    }
    
    vm_prot_t oriProtection;
    vm_address_t regionAddress = 0;
    vm_size_t regionSize;
    mach_port_t object_name;
    vm_region_basic_info_data_64_t info;
    mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT_64;
    while (vm_region(task, &regionAddress, &regionSize, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &count, &object_name) == KERN_SUCCESS) {
        if (regionAddress + regionSize > address) {
            oriProtection = info.protection;
            break;
        }
        regionAddress += regionSize;
    }
    if (!oriProtection) {
        return NO;
    }
    
    BOOL changeProtection = !(oriProtection & VM_PROT_READ)
    || !(oriProtection & VM_PROT_WRITE);
    
    /* Change memory protections to rw- */
    if (changeProtection) {
        if((kret = vm_protect(task, address, dataSize, false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY)) != KERN_SUCCESS) {
            NSLog(@"vm_protect failed, error %d: %s\n", kret, mach_error_string(kret));
            return NO;
        }
    }
    
    /* Actually perform the write */
    if ((kret = vm_write(task, address, data, dataSize)) != KERN_SUCCESS) {
        NSLog(@"mach_vm_write failed, error %d: %s\n", kret, mach_error_string(kret));
        return NO;
    }
    
    /* Change memory protections back to*/
    if (changeProtection) {
        if((kret = vm_protect(task, address, dataSize, false, oriProtection)) != KERN_SUCCESS) {
            NSLog(@"vm_protect failed, error %d: %s\n", kret, mach_error_string(kret));
            return NO;
        }
    }
    return YES;
    
}

@end
