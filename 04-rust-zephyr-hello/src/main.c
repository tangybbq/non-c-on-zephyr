/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr/zephyr.h>
#include <zephyr/logging/log.h>

#define LOG_LEVEL LOG_LEVEL_INF
LOG_MODULE_REGISTER(rust);

/* External declaration for main in Rust. */
void rust_main(void);

void main(void)
{
	LOG_ERR("Starting rust");
	rust_main();
	LOG_ERR("Done with Rust");
}

void zlog_string(uint32_t level, const char *text)
{
	/* Levels are based on `log::Level`. */
	switch (level) {
	case 1:
		LOG_ERR("%s", text);
		break;
	case 2:
		LOG_WRN("%s", text);
		break;
	case 3:
		LOG_INF("%s", text);
		break;
	case 4:
		/* Others, or trace logs as debug. */
	default:
		LOG_DBG("%s", text);
		break;
		break;
	}
}
