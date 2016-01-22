/*
 * Description	: 一些采集系统性能指标的函数
 *
 *
 **/

#import <mach/mach.h>
#import <mach/mach_host.h>
#import <sys/sysctl.h>

__inline float getThreadCount()
{
    kern_return_t kr;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;

    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return 1;
    }
	
	return thread_count;
}

//byte,当前剩余内存
static __inline double getMemoryFree()
{
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if(kernReturn != KERN_SUCCESS)
	{
		return NSNotFound;
	}
	
	return (vm_page_size * vmStats.free_count);
}

//byte，当前应用程序占用的内存
__inline double getMemoryUsage()
{
	struct task_basic_info         info;
	kern_return_t           rval = 0;
	mach_port_t             task = mach_task_self();
	mach_msg_type_number_t  tcnt = TASK_BASIC_INFO_COUNT;
	task_info_t             tptr = (task_info_t) &info;
	
	memset(&info, 0, sizeof(info));
	
	rval = task_info(task, TASK_BASIC_INFO, tptr, &tcnt);
	if (!(rval == KERN_SUCCESS))
    {
        return 0;
    }
	
	return info.resident_size;
}


__inline double getSystemTotalMemory()
{
    double systemTotalMemory = 0.0;
    int mem;
    int mib[2];
    size_t length = sizeof(mem);
    mib[0] = CTL_HW;
    mib[1] = HW_USERMEM;
    sysctl(mib, 2, &mem, &length, NULL, 0);
    systemTotalMemory = mem;

    return systemTotalMemory;
}


