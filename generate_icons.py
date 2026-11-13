import os
import math
from PIL import Image, ImageDraw, ImageFilter

def create_app_icon(size=1024):
    # Canvas
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background Rounded Squircle with Vibrant Deep Indigo-to-Violet Gradient
    # Radius
    r = int(size * 0.22)
    padding = int(size * 0.04)
    box = [padding, padding, size - padding, size - padding]

    # Create gradient background
    base_grad = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    for y in range(size):
        # Diagonal gradient from Indigo #3730A3 to Violet #6D28D9 to Cyan #0284C7
        t = y / size
        # Color interpolation
        r_col = int(40 + (100 - 40) * t)
        g_col = int(30 + (40 - 30) * t)
        b_col = int(140 + (230 - 140) * t)
        for x in range(size):
            t_diag = (x + y) / (2 * size)
            cr = int(35 * (1 - t_diag) + 90 * t_diag)
            cg = int(25 * (1 - t_diag) + 50 * t_diag)
            cb = int(120 * (1 - t_diag) + 240 * t_diag)
            base_grad.putpixel((x, y), (cr, cg, cb, 255))

    # Mask for rounded squircle
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(box, radius=r, fill=255)

    # Apply mask
    bg_composite = Image.composite(base_grad, Image.new('RGBA', (size, size), (0, 0, 0, 0)), mask)

    # 2. Glowing Ambient Ring inside
    glow_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)
    center = (size // 2, size // 2)

    # Outer circle orbit
    orbit_radius = int(size * 0.28)
    orbit_box = [center[0] - orbit_radius, center[1] - orbit_radius,
                 center[0] + orbit_radius, center[1] + orbit_radius]
    glow_draw.ellipse(orbit_box, outline=(99, 102, 241, 100), width=int(size * 0.012))

    # Second tilted orbit
    orbit2_r_x = int(size * 0.32)
    orbit2_r_y = int(size * 0.18)
    # Draw orbit points
    for deg in range(0, 360, 2):
        rad = math.radians(deg)
        # tilt angle 35 deg
        tilt = math.radians(35)
        ox = orbit2_r_x * math.cos(rad)
        oy = orbit2_r_y * math.sin(rad)
        rx = center[0] + ox * math.cos(tilt) - oy * math.sin(tilt)
        ry = center[1] + ox * math.sin(tilt) + oy * math.cos(tilt)
        glow_draw.ellipse([rx - 3, ry - 3, rx + 3, ry + 3], fill=(6, 182, 212, 160))

    # Orbit satellite nodes
    node_angles = [45, 135, 225, 315]
    for deg in node_angles:
        rad = math.radians(deg)
        nx = center[0] + orbit_radius * math.cos(rad)
        ny = center[1] + orbit_radius * math.sin(rad)
        glow_draw.ellipse([nx - 14, ny - 14, nx + 14, ny + 14], fill=(245, 158, 11, 230))
        glow_draw.ellipse([nx - 7, ny - 7, nx + 7, ny + 7], fill=(255, 255, 255, 255))

    # 3. Main Central Stellar Hub: 4-Point Star + Code Nexus
    star_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    star_draw = ImageDraw.Draw(star_layer)

    # 4-Point Star geometry
    star_outer = int(size * 0.22)
    star_inner = int(size * 0.065)
    star_points = []
    for i in range(8):
        angle = i * (math.pi / 4)
        dist = star_outer if i % 2 == 0 else star_inner
        px = center[0] + dist * math.sin(angle)
        py = center[1] - dist * math.cos(angle)
        star_points.append((px, py))

    # Glow shadow behind star
    shadow_star = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    sh_draw = ImageDraw.Draw(shadow_star)
    sh_draw.polygon(star_points, fill=(6, 182, 212, 220))
    shadow_star = shadow_star.filter(ImageFilter.GaussianBlur(radius=int(size * 0.035)))

    # Star body with pure white and subtle cyan gradient
    star_draw.polygon(star_points, fill=(255, 255, 255, 250))

    # Inner Core diamond (Golden Amber for Stars / Repos)
    core_points = []
    core_dist = int(size * 0.075)
    for i in range(4):
        angle = i * (math.pi / 2) + (math.pi / 4)
        px = center[0] + core_dist * math.sin(angle)
        py = center[1] - core_dist * math.cos(angle)
        core_points.append((px, py))

    core_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    core_draw = ImageDraw.Draw(core_layer)
    core_draw.polygon(core_points, fill=(245, 158, 11, 255))
    # Small white highlight
    core_draw.ellipse([center[0] - 12, center[1] - 12, center[0] + 12, center[1] + 12], fill=(255, 255, 255, 255))

    # Combine layers
    final_icon = Image.alpha_composite(bg_composite, glow_layer)
    final_icon = Image.alpha_composite(final_icon, shadow_star)
    final_icon = Image.alpha_composite(final_icon, star_layer)
    final_icon = Image.alpha_composite(final_icon, core_layer)

    return final_icon

def generate_all_icons(base_path):
    icon_1024 = create_app_icon(1024)

    # Ensure asset dir exists
    assets_dir = os.path.join(base_path, 'assets', 'icon')
    os.makedirs(assets_dir, exist_ok=True)
    icon_1024.save(os.path.join(assets_dir, 'app_icon.png'), 'PNG')
    print("Saved 1024x1024 icon to assets/icon/app_icon.png")

    # Android mipmap directories and sizes
    res_dir = os.path.join(base_path, 'android', 'app', 'src', 'main', 'res')
    mipmap_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    for folder, dim in mipmap_sizes.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        resized = icon_1024.resize((dim, dim), Image.Resampling.LANCZOS)
        target_path = os.path.join(folder_path, 'ic_launcher.png')
        resized.save(target_path, 'PNG')
        print(f"Saved {dim}x{dim} to {target_path}")

if __name__ == '__main__':
    project_root = r"e:\AntiGravity_Projects\NewRepo"
    generate_all_icons(project_root)

