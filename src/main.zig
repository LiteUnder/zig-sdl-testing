const std = @import("std");
const c = @import("c.zig");
const warn = std.debug.warn;
const panic = std.debug.panic;

pub const rmask = 0xff000000;
pub const gmask = 0x00ff0000;
pub const bmask = 0x0000ff00;
pub const amask = 0x000000ff;


pub fn sdlAssertZero(ret: c_int) void {
    if (ret == 0) return;
    c.SDL_Log("assertion failed. %s", c.SDL_GetError());
    panic("see above sdl error", .{});
}

pub fn main() anyerror!void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        panic("unable to init sdl: {}\n", .{c.SDL_GetError()});
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Test", 0, 0, 1920, 1080, c.SDL_WINDOW_SHOWN) orelse {
        panic("unable to create window: {}\n", .{c.SDL_GetError()});
    };
    defer c.SDL_DestroyWindow(window);

    const renderer: *c.SDL_Renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
        panic("unable to create renderer: {}", .{c.SDL_GetError()});
    };
    defer c.SDL_DestroyRenderer(renderer);

    // get image through stb_image
    var width: c_int = undefined;
    var height: c_int = undefined;
    var channels: c_int = undefined;

    var image = c.stbi_load("./spritesheet.png", &width, &height, &channels, c.STBI_rgb_alpha);

    warn("{}\n", .{image});
    warn("{}\n", .{channels});
    const sdl_img = c.SDL_CreateRGBSurfaceWithFormatFrom(@ptrCast(*c_void, &image),
                                                width,
                                                height,
                                                32, 4*width, c.SDL_PIXELFORMAT_RGBA32); 
    if (sdl_img == null) {
        c.SDL_Log("CreateRGBSurface failed: %s\n", c.SDL_GetError());
        panic("bye", .{});
    }
    var tex = c.SDL_CreateTextureFromSurface(renderer, sdl_img);
    if (tex == null) {
         c.SDL_Log("CreateTextureFromSurface failed: %s", c.SDL_GetError());
         panic("fuck", .{});
    }
    // main loop
    var x: u8 = 0;
    var inv: bool = false;
    while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    warn("exiting and cleanup\n", .{});
                    return;
                },
                else => {},
            }
        }

        sdlAssertZero(c.SDL_SetRenderDrawColor(renderer, x, x, x, 255));
        sdlAssertZero(c.SDL_RenderClear(renderer));
        sdlAssertZero(c.SDL_RenderCopy(renderer, tex, null, null));
        c.SDL_RenderPresent(renderer);
    }
    c.SDL_FreeSurface(sdl_img);
    c.free_image(image);
}
