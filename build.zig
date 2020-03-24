const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("zig-test", "src/main.zig");
    exe.linkSystemLibrary("SDL2");
    exe.addIncludeDir("stb");
    exe.addCSourceFile("stb/stb_image.c", &[_][]const u8{});
    exe.linkLibC();
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
