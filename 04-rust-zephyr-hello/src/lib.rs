// #![feature(no_std)]
// #![feature(lang_items)]
#![no_std]

use core::{
    fmt,
    fmt::Write,
};

extern "C" {
    pub fn zlog_string(level: u32, text: *const u8);
    pub fn printk(text: *const u8);
    pub fn logging_output(text: *const u8, len: usize) -> usize;
}


use panic_halt as _;

#[no_mangle]
pub extern "C" fn rust_main() {
    unsafe { printk("Hello from rust\n\0".as_ptr()); }
    log::set_logger(&ZEPHYR_LOGGER).unwrap();
    log::set_max_level(log::LevelFilter::Info);

    log::info!("Info message");
    log::debug!("Debug message");
    log::warn!("Warn message");
    log::error!("Error message");
}

static ZEPHYR_LOGGER: ZephyrLogger = ZephyrLogger;

struct ZephyrLogger;

impl log::Log for ZephyrLogger {
    // Should logging be enabled at this level.  For now, it is safe to return true, and we'll just
    // log everything.
    fn enabled(&self, _metadata: &log::Metadata) -> bool {
        true
    }

    fn log(&self, record: &log::Record) {
        if !self.enabled(record.metadata()) {
            return;
        }

        // Use a logging_output function.
        // let mut buf = ZephyrLogBackend;
        // writeln!(buf, "<{}>: {}", record.level(), record.args()).unwrap();

        // Log to a temp buffer, and null terminate.
        let mut buf = LogBuffer::new(); // Stack, should probably be static.
        // Level is handled by Zephyr, so don't print it here.
        write!(buf, "{}\0", record.args()).unwrap();
        unsafe { zlog_string(record.level() as u32, buf.buffer.as_ptr()); }
    }

    fn flush(&self) {
        // Nothing
    }
}

struct ZephyrLogBackend;

impl Write for ZephyrLogBackend {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        unsafe { logging_output(s.as_ptr(), s.len()); }
        Ok(())
    }
}

// For simple logging, we'll use a small buffer to store results, and append the
// nul termination.
struct LogBuffer {
    buffer: [u8; 256],
    used: usize,
}

impl LogBuffer {
    fn new() -> LogBuffer {
        LogBuffer { buffer: [0; 256], used: 0 }
    }
}

impl Write for LogBuffer {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        for b in s.bytes() {
            if self.used >= self.buffer.len() {
                return Err(fmt::Error);
            }
            self.buffer[self.used] = b;
            self.used += 1;
        }
        Ok(())
    }
}
