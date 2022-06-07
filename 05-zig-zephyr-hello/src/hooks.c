// SPDX-License-Identifier: Apache-2.0
/*
 * The Zephyr build system demands a source file in this directory.
 * This can be used for C interface stubs as they are needed.
 */

#include <zephyr/zephyr.h>
#include <string.h>

#define LOG_LEVEL LOG_LEVEL_INF
#include <zephyr/logging/log.h>
#include <zephyr/logging/log_ctrl.h>
LOG_MODULE_REGISTER(zig);

void zig_log_message(int level, const char *msg)
{
	switch (level) {
	case 0:
		LOG_ERR("%s", msg);
		break;
	case 1:
		LOG_WRN("%s", msg);
		break;
	case 2:
		LOG_INF("%s", msg);
		break;
	default:
		LOG_DBG("(%d) %s", level, msg);
	}
}

/* Because of conflicts between libgcc, and the llvm equivalent, we
 * will just define the functions that llvm wants as needed.
 * This could probably be made a lot more efficient, either in
 * code-size by using aliasing, or in performance, but having more
 * optimized versions of the '4' and '8' variants. */

/* Note that the arguments are in a different order than memset. */
void *__aeabi_memset(void *data, size_t n, int c)
{
	return memset(data, c, n);
}

void *__aeabi_memset4(void *data, size_t n, int c)
{
	return memset(data, c, n);
}
