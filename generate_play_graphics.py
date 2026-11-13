import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import arabic_reshaper
from bidi.algorithm import get_display

def ar_text(text):
    return get_display(arabic_reshaper.reshape(text))

def create_play_store_graphics():
    out_dir = r"e:\AntiGravity_Projects\NewRepo\google_play_package\graphics"
    os.makedirs(out_dir, exist_ok=True)
    
    icon_src = r"e:\AntiGravity_Projects\NewRepo\assets\icon\app_icon.png"
    src_icon = Image.open(icon_src).convert("RGBA")
    
    # 1. Google Play High-Res Icon: 512x512
    icon_512 = src_icon.resize((512, 512), Image.Resampling.LANCZOS)
    icon_512_path = os.path.join(out_dir, "app_icon_512.png")
    icon_512.save(icon_512_path, "PNG", optimize=True)
    print(f"Generated 512x512 Icon: {icon_512_path} ({os.path.getsize(icon_512_path)} bytes)")

    # 2. Google Play Feature Graphic: 1024x500 (No Alpha channel required by Google Play)
    width, height = 1024, 500
    fg = Image.new("RGB", (width, height), (15, 23, 42)) # Slate 900
    draw = ImageDraw.Draw(fg)

    # Background gradient
    for y in range(height):
        t = y / height
        r = int(15 * (1 - t) + 30 * t)
        g = int(23 * (1 - t) + 27 * t)
        b = int(42 * (1 - t) + 85 * t)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    # Ambient radial glow behind the logo
    glow_center_x, glow_center_y = 240, 250
    glow_overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_overlay)
    
    for radius in range(250, 20, -15):
        alpha = int(45 * (1 - radius / 250))
        glow_draw.ellipse(
            [glow_center_x - radius, glow_center_y - radius, glow_center_x + radius, glow_center_y + radius],
            fill=(79, 70, 229, alpha)
        )
    for radius in range(160, 10, -10):
        alpha = int(75 * (1 - radius / 160))
        glow_draw.ellipse(
            [glow_center_x - radius, glow_center_y - radius, glow_center_x + radius, glow_center_y + radius],
            fill=(124, 58, 237, alpha)
        )

    # Ambient star particles
    star_positions = [
        (80, 80), (120, 420), (450, 70), (480, 430), (700, 60), 
        (920, 90), (960, 410), (620, 440), (840, 390), (980, 240)
    ]
    for sx, sy in star_positions:
        glow_draw.ellipse([sx - 2, sy - 2, sx + 2, sy + 2], fill=(255, 255, 255, 180))
        glow_draw.ellipse([sx - 6, sy - 6, sx + 6, sy + 6], fill=(99, 102, 241, 60))

    fg_rgba = fg.convert("RGBA")
    fg_rgba = Image.alpha_composite(fg_rgba, glow_overlay)

    # Place resized App Icon on the left
    icon_size = 280
    icon_resized = src_icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    
    shadow_offset = 12
    shadow_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    icon_x = 100
    icon_y = (height - icon_size) // 2
    
    shadow_draw.rounded_rectangle(
        [icon_x + 8, icon_y + shadow_offset, icon_x + icon_size - 8, icon_y + icon_size + shadow_offset],
        radius=50,
        fill=(0, 0, 0, 130)
    )
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(16))
    fg_rgba = Image.alpha_composite(fg_rgba, shadow_layer)
    fg_rgba.paste(icon_resized, (icon_x, icon_y), icon_resized)

    final_fg = fg_rgba.convert("RGB")
    final_draw = ImageDraw.Draw(final_fg)

    # Fonts
    try:
        title_font = ImageFont.truetype("arialbd.ttf", 54)
        en_tag_font = ImageFont.truetype("arialbd.ttf", 22)
        ar_tag_font = ImageFont.truetype("tahoma.ttf", 20)
        sub_font = ImageFont.truetype("arial.ttf", 16)
        badge_font = ImageFont.truetype("segoeuib.ttf", 16)
    except:
        title_font = ImageFont.load_default()
        en_tag_font = ImageFont.load_default()
        ar_tag_font = ImageFont.load_default()
        sub_font = ImageFont.load_default()
        badge_font = ImageFont.load_default()

    text_x = 425
    # App Name
    final_draw.text((text_x, 110), "StarWireHub", font=title_font, fill=(255, 255, 255))
    
    # Accent underline
    final_draw.rounded_rectangle([text_x, 180, text_x + 190, 186], radius=3, fill=(99, 102, 241))

    # English Tagline
    final_draw.text((text_x, 210), "Explore Trending GitHub Repositories & FOSS Alternatives", font=en_tag_font, fill=(241, 245, 249))
    
    # Arabic Tagline (Properly shaped)
    ar_str = ar_text("بوابتك الذكية لاكتشاف مستودعات جيت هب والبدائل الحرة")
    final_draw.text((text_x, 248), ar_str, font=ar_tag_font, fill=(148, 163, 184))
    
    # Feature Bullet summary
    final_draw.text((text_x, 290), "Live GitHub Stats  •  Weekly Growth Velocity  •  Arabic AI Summaries  •  Offline Ready", font=sub_font, fill=(100, 116, 139))

    # Feature Badges
    badges = [
        ("Weekly Velocity", (245, 158, 11)),
        ("FOSS Alternatives", (168, 85, 247)),
        ("Hourly Sync & Alerts", (16, 185, 129)),
    ]
    
    badge_x = text_x
    badge_y = 340
    for text, text_col in badges:
        bbox = final_draw.textbbox((0, 0), text, font=badge_font)
        bw = bbox[2] - bbox[0] + 30
        bh = 38
        
        final_draw.rounded_rectangle(
            [badge_x, badge_y, badge_x + bw, badge_y + bh],
            radius=19,
            fill=(30, 41, 59),
            outline=(71, 85, 105),
            width=1
        )
        final_draw.text((badge_x + 15, badge_y + 9), text, font=badge_font, fill=text_col)
        badge_x += bw + 14

    fg_path = os.path.join(out_dir, "feature_graphic_1024x500.png")
    final_fg.save(fg_path, "PNG", optimize=True)
    print(f"Generated Feature Graphic: {fg_path} ({os.path.getsize(fg_path)} bytes)")

if __name__ == "__main__":
    create_play_store_graphics()
